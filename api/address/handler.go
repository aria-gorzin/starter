package address

// import (
// 	"encoding/json"
// 	"errors"
// 	"io"
// 	"net/http"
// 	"strconv"

// 	db "github.com/aria/app/db/sqlc"
// 	"github.com/aria/app/middleware"
// 	"github.com/aria/app/util"
// 	"github.com/go-playground/validator/v10"
// 	"github.com/jackc/pgx/v5/pgtype"
// )

// type AddressRouter struct {
// 	store    db.Store
// 	validate *validator.Validate
// }

// func NewRouter(store db.Store, v *validator.Validate) *AddressRouter {
// 	return &AddressRouter{store: store, validate: v}
// }

// /* -------- register -------- */

// func (r *AddressRouter) Register(mux *http.ServeMux) {
// 	mux.Handle("POST /addresses", middleware.Trace(r.createAddress, "address.create"))
// 	mux.Handle("GET /addresses/{id}", middleware.Trace(r.getAddressByID, "address.get_by_id"))
// 	mux.Handle("GET /addresses", middleware.Trace(r.listAddresses, "address.list"))
// 	mux.Handle("PUT /addresses/{id}", middleware.Trace(r.updateAddressByID, "address.update"))
// 	mux.Handle("DELETE /addresses/{id}", middleware.Trace(r.deleteAddress, "address.delete"))
// }

// /* -------- CRUD -------- */

// // createAddress creates a new address.
// // @Summary Create a new address
// // @Description Create a new address
// // @Tags addresses
// // @Accept json
// // @Produce json
// // @Param request body createAddressRequest true "Address Info"
// // @Success 200 {object} addressResponse
// // @Failure 400 {object} util.CustomError
// // @Failure 422 {object} util.ValidateErrors
// // @Router /addresses [post]
// // @Security BearerAuth
// func (r *AddressRouter) createAddress(w http.ResponseWriter, req *http.Request) error {
// 	var input createAddressRequest
// 	err := readJSON(w, req, &input)
// 	if err != nil {
// 		return util.ErrInvalidBody(err)
// 	}

// 	if err := r.validate.Struct(&input); err != nil {
// 		return util.NewValidationErrors(err.(validator.ValidationErrors))
// 	}

// 	addr, err := r.store.CreateAddress(req.Context(), db.CreateAddressParams{
// 		ClientID: input.ClientID,
// 		Title:    input.Title,
// 		City:     input.City,
// 		Street:   pgtype.Text{String: util.Deref(input.Street), Valid: input.Street != nil},
// 		Phone:    pgtype.Text{String: util.Deref(input.Phone), Valid: input.Phone != nil},
// 		Zip:      pgtype.Text{String: util.Deref(input.Zip), Valid: input.Zip != nil},
// 		Lat:      pgtype.Float4{Float32: util.Deref(input.Lat), Valid: input.Lat != nil},
// 		Long:     pgtype.Float4{Float32: util.Deref(input.Long), Valid: input.Long != nil},
// 	})
// 	if err != nil {
// 		return err
// 	}

// 	return writeJSON(w, http.StatusOK, newAddressResponse(addr))
// }

// // getAddressByID gets an address by ID.
// // @Summary Get an address by ID
// // @Description Get an address by ID
// // @Tags addresses
// // @Accept json
// // @Produce json
// // @Param id path int true "Address ID"
// // @Success 200 {object} addressResponse
// // @Failure 400 {object} util.CustomError
// // @Failure 404 {object} util.CustomError
// // @Router /addresses/{id} [get]
// // @Security BearerAuth
// func (r *AddressRouter) getAddressByID(w http.ResponseWriter, req *http.Request) error {
// 	id, err := strconv.ParseInt(req.PathValue("id"), 10, 64)
// 	if err != nil {
// 		return util.ErrInvalidParam("id")
// 	}

// 	a, err := r.store.GetAddress(req.Context(), id)
// 	if err != nil {
// 		return util.ErrItemNotFound("address")
// 	}
// 	return writeJSON(w, http.StatusOK, newAddressResponse(a))
// }

// // listAddresses lists addresses by client ID.
// // @Summary List addresses by client ID
// // @Description List addresses by client ID
// // @Tags addresses
// // @Accept json
// // @Produce json
// // @Param client_id query int true "Client ID"
// // @Success 200 {array} addressResponse
// // @Failure 400 {object} util.CustomError
// // @Failure 404 {object} util.CustomError
// // @Router /addresses [get]
// // @Security BearerAuth
// func (r *AddressRouter) listAddresses(w http.ResponseWriter, req *http.Request) error {
// 	idStr := req.URL.Query().Get("client_id")
// 	if idStr == "" {
// 		return util.ErrBadRequest("client_id is required")
// 	}
// 	clientID, err := strconv.ParseInt(idStr, 10, 64)
// 	if err != nil {
// 		return util.ErrBadRequest("invalid client_id")
// 	}

// 	list, err := r.store.ListAddresses(req.Context(), clientID)
// 	if err != nil {
// 		return err
// 	}

// 	resp := make([]addressResponse, 0, len(list))
// 	for _, a := range list {
// 		resp = append(resp, newAddressResponse(a))
// 	}
// 	return writeJSON(w, http.StatusOK, resp)
// }

// // updateAddressByID updates an address by ID.
// // @Summary Update an address by ID
// // @Description Update an address by ID
// // @Tags addresses
// // @Accept json
// // @Produce json
// // @Param id path int true "Address ID"
// // @Param request body updateAddressRequest true "Address Info"
// // @Success 200 {object} addressResponse
// // @Failure 400 {object} util.CustomError
// // @Failure 404 {object} util.CustomError
// // @Failure 422 {object} util.ValidateErrors
// // @Router /addresses/{id} [put]
// // @Security BearerAuth
// func (r *AddressRouter) updateAddressByID(w http.ResponseWriter, req *http.Request) error {
// 	id, err := strconv.ParseInt(req.PathValue("id"), 10, 64)
// 	if err != nil {
// 		return util.ErrInvalidParam("id")
// 	}

// 	var input updateAddressRequest
// 	err = readJSON(w, req, &input)
// 	if err != nil {
// 		return util.ErrInvalidBody(err)
// 	}

// 	if err := r.validate.Struct(&input); err != nil {
// 		return util.NewValidationErrors(err.(validator.ValidationErrors))
// 	}

// 	a, err := r.store.UpdateAddress(req.Context(), db.UpdateAddressParams{
// 		ID:     id,
// 		Title:  input.Title,
// 		City:   input.City,
// 		Street: pgtype.Text{String: util.Deref(input.Street), Valid: input.Street != nil},
// 		Phone:  pgtype.Text{String: util.Deref(input.Phone), Valid: input.Phone != nil},
// 		Zip:    pgtype.Text{String: util.Deref(input.Zip), Valid: input.Zip != nil},
// 		Lat:    pgtype.Float4{Float32: util.Deref(input.Lat), Valid: input.Lat != nil},
// 		Long:   pgtype.Float4{Float32: util.Deref(input.Long), Valid: input.Long != nil},
// 	})
// 	if err != nil {
// 		return err
// 	}
// 	return writeJSON(w, http.StatusOK, newAddressResponse(a))
// }

// // deleteAddress deletes an address by ID.
// // @Summary Delete an address by ID
// // @Description Delete an address by ID
// // @Tags addresses
// // @Accept json
// // @Produce json
// // @Param id path int true "Address ID"
// // @Success 204
// // @Failure 400 {object} util.CustomError
// // @Failure 404 {object} util.CustomError
// // @Router /addresses/{id} [delete]
// // @Security BearerAuth
// func (r *AddressRouter) deleteAddress(w http.ResponseWriter, req *http.Request) error {
// 	id, err := strconv.ParseInt(req.PathValue("id"), 10, 64)
// 	if err != nil {
// 		return util.ErrInvalidParam("id")
// 	}

// 	if err := r.store.DeleteAddress(req.Context(), id); err != nil {
// 		return err
// 	}
// 	w.WriteHeader(http.StatusNoContent)
// 	return nil
// }

// // --- helpers ---

// func writeJSON(w http.ResponseWriter, status int, data interface{}) error {
// 	w.Header().Set("Content-Type", "application/json")
// 	w.WriteHeader(status)
// 	return json.NewEncoder(w).Encode(data)
// }

// func readJSON(w http.ResponseWriter, r *http.Request, dst interface{}) error {
// 	dec := json.NewDecoder(r.Body)
// 	dec.DisallowUnknownFields()

// 	err := dec.Decode(dst)
// 	if err != nil {
// 		return err
// 	}

// 	err = dec.Decode(&struct{}{})
// 	if err != io.EOF {
// 		return errors.New("body must only have a single JSON value")
// 	}

// 	return nil
// }
