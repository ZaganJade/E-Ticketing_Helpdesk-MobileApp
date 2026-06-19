package http

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"eticketinghelpdesk/entities"
)

// respondDomainError maps a domain error to the appropriate HTTP status code and
// JSON body. It keeps error handling consistent across handlers:
//   - validation errors  -> 400
//   - unauthorized errors -> 403
//   - not-found errors    -> 404
//   - anything else       -> 500
func respondDomainError(c *gin.Context, err error) {
	switch {
	case entities.IsValidation(err):
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
	case entities.IsUnauthorized(err):
		c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
	case entities.IsNotFound(err):
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
	default:
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}
}

// parseUUIDParam reads a path parameter and parses it as a UUID. On failure it
// writes a 400 response and returns ok=false, so handlers never panic on a
// malformed ID (previously uuid.MustParse would panic -> 500 via recovery).
func parseUUIDParam(c *gin.Context, name string) (uuid.UUID, bool) {
	id, err := uuid.Parse(c.Param(name))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format ID tidak valid"})
		return uuid.Nil, false
	}
	return id, true
}

// currentUserID parses the authenticated user's ID from the gin context (set by
// the auth middleware). On failure (should not happen behind RequireAuth) it
// writes a 401 and returns ok=false.
func currentUserID(c *gin.Context) (uuid.UUID, bool) {
	id, err := uuid.Parse(c.GetString("userID"))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "tidak terautentikasi"})
		return uuid.Nil, false
	}
	return id, true
}
