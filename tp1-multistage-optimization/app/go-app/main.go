package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"
)

type HealthResponse struct {
	Status    string            `json:"status"`
	Timestamp string            `json:"timestamp"`
	Version   string            `json:"version"`
	GoVersion string            `json:"go_version"`
	Memory    map[string]uint64 `json:"memory"`
}

type DataResponse struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    []DataPoint `json:"data"`
}

type DataPoint struct {
	ID        int     `json:"id"`
	Value     float64 `json:"value"`
	Timestamp int64   `json:"timestamp"`
}

var startTime = time.Now()

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/", handleRoot)
	mux.HandleFunc("/health", handleHealth)
	mux.HandleFunc("/api/data", handleData)

	server := &http.Server{
		Addr:         ":" + port,
		Handler:      mux,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Printf("Server starting on port %s", port)
	log.Printf("Go version: %s", runtime.Version())
	log.Printf("GOOS: %s, GOARCH: %s", runtime.GOOS, runtime.GOARCH)

	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"status":    "success",
		"message":   "Hello from optimized Go Docker container!",
		"timestamp": time.Now().Format(time.RFC3339),
		"version":   runtime.Version(),
		"uptime":    time.Since(startTime).String(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)

	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now().Format(time.RFC3339),
		Version:   "1.0.0",
		GoVersion: runtime.Version(),
		Memory: map[string]uint64{
			"alloc_mb":       m.Alloc / 1024 / 1024,
			"total_alloc_mb": m.TotalAlloc / 1024 / 1024,
			"sys_mb":         m.Sys / 1024 / 1024,
		},
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func handleData(w http.ResponseWriter, r *http.Request) {
	data := make([]DataPoint, 100)
	for i := 0; i < 100; i++ {
		data[i] = DataPoint{
			ID:        i,
			Value:     float64(i) * 3.14159,
			Timestamp: time.Now().Unix(),
		}
	}

	response := DataResponse{
		Status:  "success",
		Message: fmt.Sprintf("Generated %d data points", len(data)),
		Data:    data,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
