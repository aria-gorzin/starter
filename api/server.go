package api

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"runtime/debug"
	"sync/atomic"
	"time"

	"github.com/aria/app/api/user"
	db "github.com/aria/app/db/sqlc"
	_ "github.com/aria/app/docs"
	"github.com/aria/app/middleware"
	"github.com/aria/app/token"
	"github.com/aria/app/util"
	"github.com/aria/app/worker"
	"github.com/go-playground/validator/v10"
	"github.com/rs/zerolog/log"
	httpSwagger "github.com/swaggo/http-swagger/v2"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

// Server serves HTTP requests for our banking service.
type Server struct {
	config          util.Config
	store           db.Store
	tokenMaker      *token.PasetoMaker
	router          http.Handler
	httpServer      *http.Server
	validator       *validator.Validate
	taskDistributor worker.TaskDistributor
}

var validCurrency validator.Func = func(fieldLevel validator.FieldLevel) bool {
	if currency, ok := fieldLevel.Field().Interface().(string); ok {
		return util.IsSupportedCurrency(currency)
	}
	return false
}

// NewServer creates a new HTTP server and sets up routing.
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
func NewServer(config util.Config, store db.Store) (*Server, error) {
	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	if err != nil {
		return nil, fmt.Errorf("cannot create token maker: %w", err)
	}

	validate := validator.New(validator.WithRequiredStructEnabled())
	validate.RegisterValidation("currency", validCurrency)

	s := &Server{
		config:     config,
		store:      store,
		tokenMaker: tokenMaker,
		validator:  validate,
	}

	s.setupRouter()
	return s, nil
}

var shuttingDown atomic.Bool

func (s *Server) setupRouter() {
	mux := http.NewServeMux()
	// Serve your spec files (yaml/json) from /docs
	mux.Handle("/docs/",
		http.StripPrefix("/docs/", http.FileServer(http.Dir("./docs"))))

	// Choose which spec to load in the UI (env overrides; defaults: yaml then json)
	spec := os.Getenv("SWAGGER_SPEC_PATH")
	if spec == "" {
		if _, err := os.Stat(filepath.Join("docs", "swagger.yaml")); err == nil {
			spec = "/docs/swagger.yaml"
		} else {
			spec = "/docs/swagger.json"
		}
	}

	// Serve Swagger UI at /swagger/
	// http-swagger hosts the UI and loads your spec from `spec`
	mux.Handle("/swagger/",
		httpSwagger.Handler(
			httpSwagger.URL(spec), // URL to your OpenAPI spec
			httpSwagger.DeepLinking(true),
			httpSwagger.DocExpansion("none"), // "list" | "full" | "none"
			httpSwagger.DomID("swagger-ui"),
		),
	)

	// addressRouter := address.NewRouter(s.store, s.validator)
	// addressRouter.Register(mux)

	// uploadRouter := upload.NewRouter()
	// uploadRouter.Register(mux)
	log.Info().Msg("Registering routes")
	userRouter := user.NewRouter()
	userRouter.Register(mux)

	// The order of middleware wrapping matters.
	// The outermost middleware is executed first.
	var handler http.Handler = otelhttp.NewHandler(mux, "http.server")
	handler = s.recoverMiddleware(handler)
	handler = middleware.HttpLogger(handler)
	handler = s.shutdownMiddleware(handler)

	s.router = handler
}

// Start runs the HTTP server on a specific address.
func (s *Server) Start(address string) {
	log.Info().Str("address", address).Msg("Starting server")

	s.httpServer = &http.Server{
		Addr:    address,
		Handler: s.router,
	}

	go func() {
		if err := s.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Panic().Err(err).Msg("Failed to start server")
		}
	}()
}

func (s *Server) Shutdown() error {
	log.Info().Msg("Shutting down server")
	shuttingDown.Store(true)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	return s.httpServer.Shutdown(ctx)
}

func (s *Server) recoverMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				log.Error().Msgf("panic on %s %s: %v", r.Method, r.URL.Path, err)
				log.Error().Msgf("stack trace: %s", string(debug.Stack()))
				util.ErrorResponse(w, util.ErrInternal)
			}
		}()
		next.ServeHTTP(w, r)
	})
}

func (s *Server) shutdownMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if shuttingDown.Load() {
			w.WriteHeader(http.StatusServiceUnavailable)
			w.Write([]byte("Server is shutting down"))
			return
		}
		next.ServeHTTP(w, r)
	})
}
