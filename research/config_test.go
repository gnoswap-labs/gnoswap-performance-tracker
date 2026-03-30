package research

import "testing"

func TestResolveEndpointsUsesContainerRPCAndDerivedRESTForReportMode(t *testing.T) {
	t.Setenv(gnoRESTPortEnv, "49888")

	remote, rest, err := resolveEndpoints(true, "", "")
	if err != nil {
		t.Fatalf("resolveEndpoints: %v", err)
	}
	if remote != "localhost:26657" {
		t.Fatalf("remote = %q, want %q", remote, "localhost:26657")
	}
	if rest != "http://localhost:49888" {
		t.Fatalf("rest = %q, want %q", rest, "http://localhost:49888")
	}
}

func TestResolveEndpointsRequiresRESTForReportMode(t *testing.T) {
	t.Setenv(gnoRESTPortEnv, "")

	if _, _, err := resolveEndpoints(true, "", ""); err == nil {
		t.Fatal("expected error when report mode rest endpoint is missing")
	}
}

func TestResolveEndpointsKeepsDefaultsOutsideReportMode(t *testing.T) {
	remote, rest, err := resolveEndpoints(false, "", "")
	if err != nil {
		t.Fatalf("resolveEndpoints: %v", err)
	}
	if remote != "localhost:26657" {
		t.Fatalf("remote = %q, want localhost:26657", remote)
	}
	if rest != "http://localhost:48888" {
		t.Fatalf("rest = %q, want http://localhost:48888", rest)
	}
}
