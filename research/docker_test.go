package research

import (
	"strings"
	"testing"
)

func TestGetContainerIDRequiresComposeProjectName(t *testing.T) {
	t.Setenv("COMPOSE_PROJECT_NAME", "")
	_, err := getContainerID("gno")
	if err == nil {
		t.Fatal("expected error when COMPOSE_PROJECT_NAME is missing")
	}
	if !strings.Contains(err.Error(), "COMPOSE_PROJECT_NAME") {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestSplitContainerIDs(t *testing.T) {
	got := splitContainerIDs("\nabc\n\nxyz\n")
	if len(got) != 2 || got[0] != "abc" || got[1] != "xyz" {
		t.Fatalf("splitContainerIDs() = %v", got)
	}
}
