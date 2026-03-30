package research

import (
	"context"
	"fmt"
	"regexp"
	"testing"
	"time"
)

type TestEnv struct {
	cfg          *Config
	gnoContainer string
}

func mustSetupTestEnv(t *testing.T) *TestEnv {
	t.Helper()

	cfg, err := LoadConfig()
	if err != nil {
		t.Fatalf("load config: %v", err)
	}

	ctx, cancel := context.WithTimeout(t.Context(), 5*time.Minute)
	defer cancel()

	mustWaitForHTTPReady(ctx, t, cfg.GnoREST+"/")
	containerID := mustWaitForContainer(ctx, t, "gno")
	mustWaitForReadyFile(ctx, t, containerID)
	mustWaitForAccessRealm(ctx, t, containerID, cfg.GnoGnokeyRemote)

	return &TestEnv{cfg: cfg, gnoContainer: containerID}
}

func mustWaitForHTTPReady(ctx context.Context, t *testing.T, url string) {
	t.Helper()
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()
	for {
		_, err := httpGet(url)
		if err == nil {
			return
		}
		select {
		case <-ctx.Done():
			t.Fatalf("gno web endpoint not reachable at %s: %v", url, ctx.Err())
		case <-ticker.C:
		}
	}
}

func mustWaitForContainer(ctx context.Context, t *testing.T, service string) string {
	t.Helper()
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()
	for {
		id, err := getContainerID(service)
		if err == nil && id != "" {
			return id
		}
		select {
		case <-ctx.Done():
			t.Fatalf("get %s container ID: %v", service, ctx.Err())
		case <-ticker.C:
		}
	}
}

func mustWaitForReadyFile(ctx context.Context, t *testing.T, containerID string) {
	t.Helper()
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()
	for {
		innerCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
		_, _, err := dockerExec(innerCtx, containerID, "sh", "-lc", "test -f /tmp/gnoswap-ready")
		cancel()
		if err == nil {
			return
		}
		select {
		case <-ctx.Done():
			t.Fatalf("gnoswap deployment readiness file not found: %v", ctx.Err())
		case <-ticker.C:
		}
	}
}

func mustWaitForAccessRealm(ctx context.Context, t *testing.T, containerID, rpc string) {
	t.Helper()
	ticker := time.NewTicker(3 * time.Second)
	defer ticker.Stop()
	for {
		_, err := gnoQEval(containerID, rpc, `gno.land/r/gnoswap/access.MustGetAddress("pool")`)
		if err == nil {
			return
		}
		select {
		case <-ctx.Done():
			t.Fatalf("gnoswap access realm not reachable: %v", ctx.Err())
		case <-ticker.C:
		}
	}
}

func (e *TestEnv) mustEvalAddress(t *testing.T, expr string) string {
	t.Helper()
	content, err := gnoQEval(e.gnoContainer, e.cfg.GnoGnokeyRemote, expr)
	if err != nil {
		t.Fatalf("eval address expr: %v", err)
	}
	addrRe := regexp.MustCompile(`g1[0-9a-z]+`)
	addr := addrRe.FindString(content)
	if addr == "" {
		t.Fatalf("unexpected address output: %s", content)
	}
	return addr
}

func (e *TestEnv) mustQueryAddressByRole(t *testing.T, role string) string {
	t.Helper()
	out, err := gnoQEval(e.gnoContainer, e.cfg.GnoGnokeyRemote, fmt.Sprintf(`gno.land/r/gnoswap/access.MustGetAddress("%s")`, role))
	if err != nil {
		t.Fatalf("query access role %s: %v", role, err)
	}
	addrRe := regexp.MustCompile(`g1[0-9a-z]+`)
	addr := addrRe.FindString(out)
	if addr == "" {
		t.Fatalf("address for role %s not found in qeval output: %s", role, out)
	}
	return addr
}
