package entities

import (
	"errors"
	"fmt"
)

// Domain errors
var (
	ErrNotFound           = errors.New("data tidak ditemukan")
	ErrInvalidInput       = errors.New("input tidak valid")
	ErrUnauthorized       = errors.New("tidak memiliki akses")
	ErrDuplicate          = errors.New("data sudah ada")
	ErrInternal           = errors.New("terjadi kesalahan internal")
	ErrValidation         = errors.New("validasi gagal")
)

// DomainError represents a domain-specific error
type DomainError struct {
	Code    string
	Message string
	Err     error
}

func (e *DomainError) Error() string {
	if e.Err != nil {
		return fmt.Sprintf("[%s] %s: %v", e.Code, e.Message, e.Err)
	}
	return fmt.Sprintf("[%s] %s", e.Code, e.Message)
}

func (e *DomainError) Unwrap() error {
	return e.Err
}

// NewDomainError creates a new domain error
func NewDomainError(code, message string, err error) *DomainError {
	return &DomainError{
		Code:    code,
		Message: message,
		Err:     err,
	}
}

// ValidationError represents a validation error for a specific field
type ValidationError struct {
	Field   string
	Message string
}

func (e *ValidationError) Error() string {
	return fmt.Sprintf("validasi gagal untuk field '%s': %s", e.Field, e.Message)
}

// ValidationErrors contains multiple validation errors
type ValidationErrors struct {
	Errors []ValidationError
}

func (e *ValidationErrors) Error() string {
	msg := "validasi gagal:"
	for _, err := range e.Errors {
		msg += "\n  - " + err.Error()
	}
	return msg
}

func (e *ValidationErrors) Add(field, message string) {
	e.Errors = append(e.Errors, ValidationError{
		Field:   field,
		Message: message,
	})
}

func (e *ValidationErrors) HasErrors() bool {
	return len(e.Errors) > 0
}

// IsNotFound checks if error is not found
func IsNotFound(err error) bool {
	return errors.Is(err, ErrNotFound)
}

// IsUnauthorized checks if error is unauthorized
func IsUnauthorized(err error) bool {
	return errors.Is(err, ErrUnauthorized)
}

// IsValidation checks if error is validation error
func IsValidation(err error) bool {
	return errors.Is(err, ErrValidation)
}

// Common error constructors
func NewNotFoundError(resource string) error {
	return fmt.Errorf("%w: %s tidak ditemukan", ErrNotFound, resource)
}

func NewUnauthorizedError(action string) error {
	return fmt.Errorf("%w: tidak memiliki izin untuk %s", ErrUnauthorized, action)
}

func NewValidationError(field, message string) error {
	return fmt.Errorf("%w: %s - %s", ErrValidation, field, message)
}

func NewDuplicateError(resource string) error {
	return fmt.Errorf("%w: %s sudah ada", ErrDuplicate, resource)
}
