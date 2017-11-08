package main

import (
	"io"
	"log"
	"net/http"
)

func hello(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "Hello, World!")
}
func main() {
	http.HandleFunc("/", hello)
	err := http.ListenAndServe("127.0.0.1:9000", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

// HandleFunc registers the handler function for the given pattern
// in the DefaultServeMux.
