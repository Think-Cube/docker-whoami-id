package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHandler(t *testing.T) {
	for _, path := range []string{"/", "/anything"} {
		rec := httptest.NewRecorder()
		handler("box")(rec, httptest.NewRequest(http.MethodGet, path, nil))

		if rec.Code != http.StatusOK {
			t.Errorf("%s: status = %d, want %d", path, rec.Code, http.StatusOK)
		}
		if got, want := rec.Body.String(), "I'm box\n"; got != want {
			t.Errorf("%s: body = %q, want %q", path, got, want)
		}
	}
}
