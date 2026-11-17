// Command whoami answers every HTTP request with the hostname of the container it runs in.
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

func handler(hostname string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(os.Stdout, "I'm %s\n", hostname)
		fmt.Fprintf(w, "I'm %s\n", hostname)
	}
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal(err)
	}

	server := &http.Server{
		Addr:              ":" + port,
		Handler:           handler(hostname),
		ReadHeaderTimeout: 5 * time.Second,
	}

	fmt.Fprintf(os.Stdout, "Listening on :%s\n", port)
	log.Fatal(server.ListenAndServe())
}
