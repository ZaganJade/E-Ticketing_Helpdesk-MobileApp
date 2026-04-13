package middleware

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"eticketinghelpdesk/entities"
)

// ErrorResponse represents error response
type ErrorResponse struct {
	Error   string `json:"error"`
	Code    string `json:"code,omitempty"`
	Details string `json:"details,omitempty"`
}

// ErrorHandler middleware handles errors globally
func ErrorHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		if len(c.Errors) > 0 {
			err := c.Errors.Last()

			// Log error
			log.Printf("Error: %v", err.Err)

			// Determine status code and response
			status, response := processError(err.Err)
			c.JSON(status, response)
		}
	}
}

func processError(err error) (int, ErrorResponse) {
	// Domain errors
	if entities.IsNotFound(err) {
		return http.StatusNotFound, ErrorResponse{
			Error: err.Error(),
			Code:  "NOT_FOUND",
		}
	}

	if entities.IsUnauthorized(err) {
		return http.StatusForbidden, ErrorResponse{
			Error: err.Error(),
			Code:  "FORBIDDEN",
		}
	}

	if entities.IsValidation(err) {
		return http.StatusBadRequest, ErrorResponse{
			Error: err.Error(),
			Code:  "VALIDATION_ERROR",
		}
	}

	// Default internal error
	return http.StatusInternalServerError, ErrorResponse{
		Error: "Terjadi kesalahan internal",
		Code:  "INTERNAL_ERROR",
	}
}
