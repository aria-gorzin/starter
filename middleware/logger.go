package middleware

import (
	"net/http"
	"time"

	"github.com/rs/zerolog/log"
)

type responseWriter struct {
	http.ResponseWriter
	statusCode int
	body       []byte
}

func (rw *responseWriter) WriteHeader(statusCode int) {
	rw.statusCode = statusCode
	rw.ResponseWriter.WriteHeader(statusCode)
}

func (rw *responseWriter) Write(b []byte) (int, error) {
	rw.body = b
	return rw.ResponseWriter.Write(b)
}

func HttpLogger(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		startTime := time.Now()
		rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}

		next.ServeHTTP(rw, r)

		duration := time.Since(startTime)
		statusCode := rw.statusCode

		logger := log.Info()
		if statusCode >= http.StatusBadRequest {
			logger = log.Error().Bytes("body", rw.body)
		}

		logger.
			Str("method", r.Method).
			Str("path", r.URL.String()).
			Int("status_code", statusCode).
			Str("status_text", http.StatusText(statusCode)).
			Dur("duration", duration).
			Msg("HTTP")
	})
}
