package middleware

// import (
// 	"context"
// 	"net/http"

// 	"github.com/ardanlabs/service/app/sdk/metrics"
// 	"github.com/ardanlabs/service/foundation/web"
// )

// func HttpLogger(next http.Handler) http.Handler {
// 	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
// 		startTime := time.Now()
// 		rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}

// 		next.ServeHTTP(rw, r)

// 		duration := time.Since(startTime)
// 		statusCode := rw.statusCode

// 		logger := log.Info()
// 		if statusCode >= http.StatusBadRequest {
// 			logger = log.Error().Bytes("body", rw.body)
// 		}

// 		logger.
// 			Str("method", r.Method).
// 			Str("path", r.URL.String()).
// 			Int("status_code", statusCode).
// 			Str("status_text", http.StatusText(statusCode)).
// 			Dur("duration", duration).
// 			Msg("HTTP")
// 	})
// }
// // Metrics updates program counters.
// func Metrics(next http.Handler) http.Handler {
// 	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
// 		rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}
// 		next.ServeHTTP(rw, r)
// 		ctx := metrics.Set(r.Context())
// 		resp := next(ctx, r)
// 		n := metrics.AddRequests(ctx)
// 		if n%1000 == 0 {
// 			metrics.AddGoroutines(ctx)
// 		}
// 		if isError(resp) != nil {
// 			metrics.AddErrors(ctx)
// 		}
// 	})
// }
