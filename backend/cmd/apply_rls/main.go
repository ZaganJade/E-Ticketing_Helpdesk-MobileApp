package main

import (
	"context"
	"flag"
	"log"
	"net/url"
	"os"
	"path/filepath"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

func normalizeDatabaseURL(raw string) string {
	// Supabase often stores passwords with special chars as postgresql://user:[pass]@host/db
	const marker = "://"
	i := strings.Index(raw, marker)
	if i < 0 {
		return raw
	}
	scheme := raw[:i]
	rest := raw[i+len(marker):]
	at := strings.LastIndex(rest, "@")
	if at < 0 {
		return raw
	}
	userInfo := rest[:at]
	hostPart := rest[at+1:]

	if strings.HasPrefix(userInfo, "postgres:[") && strings.Contains(userInfo, "]") {
		end := strings.Index(userInfo, "]")
		password := userInfo[len("postgres:[") : end]
		return scheme + "://" + url.UserPassword("postgres", password).String() + "@" + hostPart
	}
	return raw
}

func main() {
	verifyOnly := flag.Bool("verify", false, "verify database state without applying SQL")
	flag.Parse()

	_ = godotenv.Load()

	dbURL := normalizeDatabaseURL(os.Getenv("DATABASE_URL"))
	if dbURL == "" {
		log.Fatal("DATABASE_URL must be set in backend/.env")
	}

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, dbURL)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer conn.Close(ctx)

	if *verifyOnly {
		verifyDatabase(ctx, conn)
		return
	}

	sqlPath := filepath.Join("..", "supabase", "rls_assignment_flow.sql")
	sqlBytes, err := os.ReadFile(sqlPath)
	if err != nil {
		log.Fatalf("failed to read %s: %v", sqlPath, err)
	}

	if _, err := conn.Exec(ctx, string(sqlBytes)); err != nil {
		log.Fatalf("failed to apply RLS migration: %v", err)
	}

	log.Printf("RLS migration applied from %s", sqlPath)
	verifyDatabase(ctx, conn)
}

func verifyDatabase(ctx context.Context, conn *pgx.Conn) {
	var tableCount int
	err := conn.QueryRow(ctx, `
		SELECT count(*) FROM information_schema.tables
		WHERE table_schema = 'public' AND table_name IN ('pengguna','tiket','komentar','notifikasi','lampiran')
	`).Scan(&tableCount)
	if err != nil {
		log.Fatalf("verify tables: %v", err)
	}
	log.Printf("core tables present: %d/5", tableCount)

	var adminCount int
	err = conn.QueryRow(ctx, `SELECT count(*) FROM pengguna WHERE peran = 'admin'`).Scan(&adminCount)
	if err != nil {
		log.Fatalf("verify admin: %v", err)
	}
	log.Printf("admin users in pengguna: %d", adminCount)

	var policyName string
	err = conn.QueryRow(ctx, `
		SELECT policyname FROM pg_policies
		WHERE tablename = 'tiket' AND policyname = 'tiket_select_policy'
		LIMIT 1
	`).Scan(&policyName)
	if err != nil {
		log.Fatalf("verify tiket_select_policy: %v (run apply_rls first)", err)
	}
	log.Printf("RLS policy %q is active on tiket", policyName)
}
