package main

import (
	"io"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		io.WriteString(w, "Hello, world!")
	})
	http.ListenAndServe("127.0.0.1:8001", nil)
}
