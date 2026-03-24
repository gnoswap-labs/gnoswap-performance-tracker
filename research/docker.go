package research

import (
	"bytes"
	"context"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func getContainerID(service string) (string, error) {
	cmd := exec.Command("docker", "compose", "ps", "-q", service)
	out, composeErr := cmd.Output()
	if composeErr == nil {
		id := strings.TrimSpace(string(out))
		if id != "" {
			return id, nil
		}
	}

	projectName := strings.TrimSpace(os.Getenv("COMPOSE_PROJECT_NAME"))
	if projectName == "" {
		projectName = "gnoswap_performance_research"
	}

	args := []string{"ps", "--filter", "label=com.docker.compose.service=" + service, "--filter", "label=com.docker.compose.project=" + projectName, "--format", "{{.ID}}"}
	cmd = exec.Command("docker", args...)
	out, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("lookup container for service %s: compose err=%v docker ps err=%w", service, composeErr, err)
	}
	id := strings.TrimSpace(string(out))
	if id == "" {
		return "", fmt.Errorf("no container found for service %s (project=%s)", service, projectName)
	}
	return strings.Split(id, "\n")[0], nil
}

func dockerExec(ctx context.Context, containerID string, args ...string) (string, string, error) {
	cmdArgs := append([]string{"exec", containerID}, args...)
	cmd := exec.CommandContext(ctx, "docker", cmdArgs...)
	var stdout bytes.Buffer
	var stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	return stdout.String(), stderr.String(), err
}
