package middleware

import (
	"net/http"

	"github.com/aria/app/util"
	"github.com/rs/zerolog/log"
)

// Handler is a custom http.Handler that returns an error.
type Handler func(w http.ResponseWriter, r *http.Request) error

// ServeHTTP makes the Handler implement the http.Handler interface.
func (h Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// Execute the handler and process the error.
	if err := h(w, r); err != nil {
		// Handle CustomError type
		if e, ok := err.(util.CustomError); ok {
			util.ErrorResponse(w, e)
			return
		}

		// Handle validation errors from validator
		if validationErrors, ok := err.(util.ValidateErrors); ok {
			util.ValidationErrorResponse(w, validationErrors)
			return
		}

		// Log the unexpected error.
		log.Error().Err(err).Msg("An unexpected error occurred")

		// Handle unknown errors by sending a generic internal server error.
		util.ErrorResponse(w, util.ErrInternal)
	}
}
