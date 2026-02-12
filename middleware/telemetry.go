package middleware

import (
	"net/http"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/codes"
)

// Trace wraps a middleware.Handler with OpenTelemetry tracing.
func Trace(next Handler, spanName string) Handler {
	return func(w http.ResponseWriter, r *http.Request) error {
		tr := otel.Tracer("api")
		ctx, span := tr.Start(r.Context(), spanName)
		defer span.End()

		r = r.WithContext(ctx)

		err := next(w, r)
		if err != nil {
			span.RecordError(err)
			span.SetStatus(codes.Error, err.Error())
		}
		return err
	}
}
