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
	projectName := strings.TrimSpace(os.Getenv("COMPOSE_PROJECT_NAME"))
	if projectName == "" {
		return "", fmt.Errorf("COMPOSE_PROJECT_NAME is required")
	}

	cmd := exec.Command("docker", "compose", "-p", projectName, "ps", "-q", service)
	out, composeErr := cmd.Output()
	if composeErr == nil {
		ids := splitContainerIDs(string(out))
		if len(ids) == 1 {
			return ids[0], nil
		}
		if len(ids) > 1 {
			return "", fmt.Errorf("multiple containers found for service %s (project=%s)", service, projectName)
		}
	}

	args := []string{"ps", "--filter", "label=com.docker.compose.service=" + service, "--filter", "label=com.docker.compose.project=" + projectName, "--format", "{{.ID}}"}
	cmd = exec.Command("docker", args...)
	out, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("lookup container for service %s: compose err=%v docker ps err=%w", service, composeErr, err)
	}
	ids := splitContainerIDs(string(out))
	if len(ids) == 0 {
		return "", fmt.Errorf("no container found for service %s (project=%s)", service, projectName)
	}
	if len(ids) > 1 {
		return "", fmt.Errorf("multiple containers found for service %s (project=%s)", service, projectName)
	}
	return ids[0], nil
}

func splitContainerIDs(output string) []string {
	lines := strings.Split(strings.TrimSpace(output), "\n")
	ids := make([]string, 0, len(lines))
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		ids = append(ids, line)
	}
	return ids
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
