package research

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
	"time"
)

func httpGet(url string) ([]byte, error) {
	const maxRetries = 3

	var lastErr error
	for i := range maxRetries {
		if i > 0 {
			time.Sleep(time.Duration(i) * time.Second)
		}

		resp, err := http.Get(url)
		if err != nil {
			lastErr = err
			continue
		}

		body, err := io.ReadAll(resp.Body)
		resp.Body.Close()
		if err != nil {
			lastErr = err
			continue
		}

		if resp.StatusCode == http.StatusServiceUnavailable {
			lastErr = fmt.Errorf("HTTP 503 from %s", url)
			continue
		}

		if resp.StatusCode != http.StatusOK {
			return nil, fmt.Errorf("HTTP %d from %s: %s", resp.StatusCode, url, string(body))
		}

		return body, nil
	}

	return nil, lastErr
}

func gnoQEval(containerID, rpcEndpoint, expression string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	stdout, err := gnoQEvalRawWithContext(ctx, containerID, rpcEndpoint, expression)
	if err != nil {
		return "", err
	}

	const prefix = "data: "
	idx := strings.Index(stdout, prefix)
	if idx < 0 {
		return "", fmt.Errorf("unexpected gnokey output (no 'data: ' prefix): %s", stdout)
	}

	return strings.TrimSpace(stdout[idx+len(prefix):]), nil
}

func gnoQEvalRaw(containerID, rpcEndpoint, expression string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	return gnoQEvalRawWithContext(ctx, containerID, rpcEndpoint, expression)
}

func gnoQEvalRawWithContext(ctx context.Context, containerID, rpcEndpoint, expression string) (string, error) {

	stdout, stderr, err := dockerExec(ctx, containerID,
		"gnokey", "query", "vm/qeval",
		"-data", expression,
		"-remote", rpcEndpoint,
	)
	if err != nil {
		return "", fmt.Errorf("gnokey qeval %s: %w: %s", expression, err, stderr)
	}

	return stdout, nil
}

func gnokeyAddress(containerID, keyName string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	stdout, stderr, err := dockerExec(ctx, containerID, "gnokey", "list")
	if err != nil {
		return "", fmt.Errorf("gnokey list: %w: %s", err, stderr)
	}

	for _, line := range strings.Split(stdout, "\n") {
		trimmed := strings.TrimSpace(line)
		if !strings.Contains(trimmed, " "+keyName+" ") && !strings.HasPrefix(trimmed, keyName+" ") {
			continue
		}
		addr := regexp.MustCompile(`g1[0-9a-z]+`).FindString(trimmed)
		if addr != "" {
			return addr, nil
		}
	}

	return "", fmt.Errorf("address for key %s not found in gnokey list output", keyName)
}
