package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/aria/app/token"
	"github.com/aria/app/util"
)

const (
	authorizationHeaderKey  = "authorization"
	authorizationTypeBearer = "bearer"
)

func Auth(tokenMaker *token.PasetoMaker) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authorizationHeader := r.Header.Get(authorizationHeaderKey)

			if len(authorizationHeader) == 0 {
				util.ErrorResponse(w, util.ErrUnauthorized)
				return
			}

			fields := strings.Fields(authorizationHeader)
			if len(fields) < 2 {
				util.ErrorResponse(w, util.ErrUnauthorized)
				return
			}

			authorizationType := strings.ToLower(fields[0])
			if authorizationType != authorizationTypeBearer {
				util.ErrorResponse(w, util.ErrUnauthorized)
				return
			}

			accessToken := fields[1]
			payload, err := tokenMaker.VerifyToken(accessToken, token.TokenTypeAuth)
			if err != nil {
				util.ErrorResponse(w, util.ErrUnauthorized)
				return
			}

			ctx := context.WithValue(r.Context(), token.AuthorizationPayloadKey, payload)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func IsAdmin(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		payload, ok := r.Context().Value(token.AuthorizationPayloadKey).(*token.Payload)
		if !ok {
			util.ErrorResponse(w, util.ErrForbidden)
			return
		}

		adminRoles := []string{util.SuperuserRole, util.OwnerRole, util.AdminRole, util.OperatorRole, util.DriverRole}
		if util.Includes(adminRoles, payload.Role) {
			next.ServeHTTP(w, r)
			return
		}
		util.ErrorResponse(w, util.ErrForbidden)
	})
}

func IsSuperuser(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		payload, ok := r.Context().Value(token.AuthorizationPayloadKey).(*token.Payload)
		if !ok {
			util.ErrorResponse(w, util.ErrForbidden)
			return
		}

		if util.SuperuserRole == payload.Role {
			next.ServeHTTP(w, r)
			return
		}
		util.ErrorResponse(w, util.ErrForbidden)
	})
}
