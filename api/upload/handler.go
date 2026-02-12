package upload

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/aria/app/middleware"
	"github.com/aria/app/util"
)

const MAX_UPLOAD_SIZE = 5 * 1024 * 1024 // 5 MB
const UPLOAD_DIR = "./upload"

type UploadRouter struct {
	// dependencies like a logger or config can be added here
}

func NewRouter() *UploadRouter {
	return &UploadRouter{}
}

func (ur *UploadRouter) Register(mux *http.ServeMux) {
	mux.Handle("POST /upload", middleware.Handler(ur.uploadHandler))
	mux.HandleFunc("GET /upload/{filename}", ur.viewHandler)
}
func writeErrorAndClose(w http.ResponseWriter, err error) {
	http.Error(w, err.Error(), http.StatusBadRequest)

	// Attempt to close the connection after sending the response.
	if closeNotifier, ok := w.(http.CloseNotifier); ok {
		notify := closeNotifier.CloseNotify()
		select {
		case <-notify:
			// already closed
		default:
			if flusher, ok := w.(http.Flusher); ok {
				flusher.Flush()
			}
			// closing happens automatically after handler returns
		}
	}
}

// uploadHandler uploads a new image.
// @Summary Upload an image
// @Description Upload a new image file (jpeg or png), with a size limit of 5MB.
// @Tags upload
// @Accept multipart/form-data
// @Produce json
// @Param image formData file true "Image file to upload"
// @Param name formData string true "A name to associate with the image"
// @Success 201 {object} map[string]string "File uploaded successfully"
// @Failure 400 {object} util.CustomError "Bad Request"
// @Failure 500 {object} util.CustomError "Internal Server Error"
// @Router /upload [post]
// @Security BearerAuth
func (ur *UploadRouter) uploadHandler(w http.ResponseWriter, r *http.Request) error {
	// Wrap the request body with MaxBytesReader to limit the upload size.
	r.Body = http.MaxBytesReader(w, r.Body, MAX_UPLOAD_SIZE) // keeps a hard cap at the transport layer

	if err := r.ParseMultipartForm(MAX_UPLOAD_SIZE); err != nil {
		return util.ErrBadRequest("file is too large1 (max 5MB)")
	}

	userName := r.FormValue("name")
	if userName == "" {
		return util.ErrBadRequest("form field 'name' is required")
	}

	file, handler, err := r.FormFile("image")
	if err != nil {
		return util.ErrBadRequest("form field 'image' is required")
	}
	defer file.Close()

	// Read the first 512 bytes to check the file type.
	buff := make([]byte, 512)
	if _, err := io.ReadFull(file, buff); err != nil && err != io.ErrUnexpectedEOF {
		// NEW: tolerate short files (ErrUnexpectedEOF) but error on other issues
		return fmt.Errorf("could not read file header: %w", err)
	}
	contentType := http.DetectContentType(buff)
	if contentType != "image/jpeg" && contentType != "image/png" {
		return util.ErrBadRequest("invalid file type, only jpeg and png are allowed")
	}

	// Reset the file read pointer to the beginning.
	if _, err := file.Seek(0, 0); err != nil {
		return fmt.Errorf("could not reset file pointer: %w", err)
	}

	// Create the upload directory if it doesn't exist.
	if err := os.MkdirAll(UPLOAD_DIR, os.ModePerm); err != nil {
		return fmt.Errorf("could not create upload directory: %w", err)
	}

	// Create a safe filename with a date prefix.
	datePrefix := time.Now().Format("20060102")
	safeUserName := filepath.Base(userName)
	ext := filepath.Ext(handler.Filename)
	fileName := fmt.Sprintf("%s-%s%s", datePrefix, safeUserName, ext)
	filePath := filepath.Join(UPLOAD_DIR, fileName)

	// Create the destination file.
	dst, err := os.Create(filePath)
	if err != nil {
		return fmt.Errorf("could not create destination file: %w", err)
	}
	defer dst.Close()

	var written int64
	const chunkSize = 64 * 1024 // 64 KiB
	buf := make([]byte, chunkSize)
	fmt.Println("Starting file upload...")
	for {
		n, readErr := file.Read(buf)
		if n > 0 {
			written += int64(n)
			if written > MAX_UPLOAD_SIZE {
				// Clean up partial file and reject.
				dst.Close()
				_ = os.Remove(filePath) // best-effort cleanup
				return util.ErrBadRequest("file is too large (max 5MB)")
			}
			if _, err := dst.Write(buf[:n]); err != nil {
				dst.Close()
				_ = os.Remove(filePath)
				return fmt.Errorf("could not write file: %w", err)
			}
		}
		if readErr == io.EOF {
			break
		}
		if readErr != nil {
			dst.Close()
			_ = os.Remove(filePath)
			return fmt.Errorf("could not read file: %w", readErr)
		}
	}

	// Respond with a success message.
	return writeJSON(w, http.StatusCreated, map[string]string{
		"message":  "file uploaded successfully",
		"filename": fileName,
	})
}

// viewHandler serves an uploaded image.
// @Summary View an uploaded image
// @Description Serves an uploaded image by its filename.
// @Tags upload
// @Produce image/png
// @Produce image/jpeg
// @Param filename path string true "Filename of the image to view"
// @Success 200 {file} file "The image file"
// @Failure 404 {object} util.CustomError "Not Found"
// @Router /upload/{filename} [get]
func (ur *UploadRouter) viewHandler(w http.ResponseWriter, r *http.Request) {
	fileName := r.PathValue("filename")
	if fileName == "" {
		util.ErrorResponse(w, util.ErrNotFound)
		return
	}

	// Prevent directory traversal by cleaning the path.
	safeFileName := filepath.Base(fileName)
	filePath := filepath.Join(UPLOAD_DIR, safeFileName)

	// Check if the file exists before serving.
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		http.NotFound(w, r)
		return
	}

	http.ServeFile(w, r, filePath)
}

// --- helpers ---

func writeJSON(w http.ResponseWriter, status int, data interface{}) error {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	return json.NewEncoder(w).Encode(data)
}
