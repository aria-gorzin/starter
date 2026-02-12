package user

import (
	"context"
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"github.com/aria/app/middleware"
	"go.opentelemetry.io/otel"
)

type UserRouter struct {
	// dependencies like a logger or config can be added here
}

func NewRouter() *UserRouter {
	return &UserRouter{}
}

func (ur *UserRouter) Register(mux *http.ServeMux) {
	fmt.Println("Registering user routes")
	mux.Handle("GET /users", middleware.Handler(ur.listHandler))
}

func (ur *UserRouter) listHandler(w http.ResponseWriter, r *http.Request) error {
	tr := otel.Tracer("list users")
	_, span := tr.Start(r.Context(), "list users")
	defer span.End()

	span.AddEvent("starting to list users")
	// sleep for 1 second to simulate a slow operation
	time.Sleep(time.Second)

	span.AddEvent("finished sleeping")

	// simulate another process and add it to the trace
	_, childSpan := tr.Start(r.Context(), "another process")
	childSpan.AddEvent("child process started")
	time.Sleep(500 * time.Millisecond)
	childSpan.AddEvent("child process finished")
	childSpan.End()

	span.AddEvent("finished another process")

	// run a sub process that will be part of the same trace
	// ctx := opentracing.ContextWithSpan(r.Context(), span)
	supProcess(r.Context())

	// simulate a random error
	if rand.Intn(10) == 0 {
		return fmt.Errorf("random error")
	}

	return nil
}

func supProcess(ctx context.Context) {
	// create span from context and add events to it
	tr := otel.Tracer("sub process")
	_, span := tr.Start(ctx, "sub process")
	defer span.End()

	span.AddEvent("starting sub process")
	time.Sleep(200 * time.Millisecond)
	span.AddEvent("finished sub process")
}
