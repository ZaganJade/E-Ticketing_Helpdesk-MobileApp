package main

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"

	"eticketinghelpdesk/config"
	"eticketinghelpdesk/repository"
)

func main() {
	_ = godotenv.Load()
	cfg := config.LoadConfig()
	if cfg.SupabaseURL == "" || cfg.SupabaseServiceKey == "" {
		log.Fatal("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
	}

	nama := envOr("ADMIN_NAMA", "Administrator")
	email := envOr("ADMIN_EMAIL", "admin@helpdesk.local")
	password := os.Getenv("ADMIN_PASSWORD")
	if password == "" {
		log.Fatal("ADMIN_PASSWORD must be set (the admin login password)")
	}

	userID, err := createOrGetAuthUser(cfg.SupabaseURL, cfg.SupabaseServiceKey, nama, email, password)
	if err != nil {
		log.Fatalf("failed to create/find auth user: %v", err)
	}
	log.Printf("auth user id: %s", userID)

	if err := upsertPenggunaAdmin(cfg, userID, nama, email); err != nil {
		log.Fatalf("failed to upsert pengguna admin: %v", err)
	}

	log.Printf("admin ready: %s (id=%s, peran=admin)", email, userID)
}

func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func httpClient() *http.Client {
	return &http.Client{
		Timeout: 30 * time.Second,
		Transport: &http.Transport{
			ForceAttemptHTTP2: false,
			TLSNextProto:      map[string]func(authority string, c *tls.Conn) http.RoundTripper{},
		},
	}
}

func createOrGetAuthUser(baseURL, serviceKey, nama, email, password string) (string, error) {
	body := map[string]interface{}{
		"email":         email,
		"password":      password,
		"email_confirm": true,
		"user_metadata": map[string]interface{}{
			"nama":  nama,
			"peran": "admin",
		},
	}
	raw, _ := json.Marshal(body)

	req, _ := http.NewRequest(http.MethodPost, baseURL+"/auth/v1/admin/users", bytes.NewReader(raw))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("apikey", serviceKey)
	req.Header.Set("Authorization", "Bearer "+serviceKey)

	resp, err := httpClient().Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusOK || resp.StatusCode == http.StatusCreated {
		var out struct {
			ID string `json:"id"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
			return "", fmt.Errorf("decode create response: %w", err)
		}
		if out.ID == "" {
			return "", fmt.Errorf("auth create returned empty id")
		}
		return out.ID, nil
	}

	if resp.StatusCode == http.StatusUnprocessableEntity || resp.StatusCode == http.StatusConflict {
		id, err := findAuthUserByEmail(baseURL, serviceKey, email)
		if err != nil {
			return "", fmt.Errorf("user exists but lookup failed: %w", err)
		}
		return id, nil
	}

	var errBody bytes.Buffer
	_, _ = errBody.ReadFrom(resp.Body)
	return "", fmt.Errorf("auth admin create failed: status %d: %s", resp.StatusCode, errBody.String())
}

func findAuthUserByEmail(baseURL, serviceKey, email string) (string, error) {
	for page := 1; page <= 20; page++ {
		url := fmt.Sprintf("%s/auth/v1/admin/users?page=%d&per_page=200", baseURL, page)
		req, _ := http.NewRequest(http.MethodGet, url, nil)
		req.Header.Set("apikey", serviceKey)
		req.Header.Set("Authorization", "Bearer "+serviceKey)

		resp, err := httpClient().Do(req)
		if err != nil {
			return "", err
		}
		var out struct {
			Users []struct {
				ID    string `json:"id"`
				Email string `json:"email"`
			} `json:"users"`
		}
		dErr := json.NewDecoder(resp.Body).Decode(&out)
		resp.Body.Close()
		if dErr != nil {
			return "", dErr
		}
		if len(out.Users) == 0 {
			break
		}
		for _, u := range out.Users {
			if u.Email == email {
				return u.ID, nil
			}
		}
	}
	return "", fmt.Errorf("auth user with email %s not found", email)
}

func upsertPenggunaAdmin(cfg *config.AppConfig, userID, nama, email string) error {
	client, err := repository.NewSupabaseClient(cfg)
	if err != nil {
		return err
	}
	data := map[string]interface{}{
		"id":            userID,
		"nama":          nama,
		"email":         email,
		"peran":         "admin",
		"password_hash": "managed_by_supabase_auth",
		"dibuat_pada":   time.Now(),
	}
	_, _, err = client.GetTable("pengguna").Insert(data, true, "id", "", "").Execute()
	if err != nil {
		return fmt.Errorf("pengguna upsert: %w", err)
	}
	return nil
}
