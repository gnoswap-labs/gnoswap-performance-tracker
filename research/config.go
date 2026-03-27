package research

import (
	"fmt"
	"os"
	"strings"

	"github.com/joho/godotenv"
)

const (
	researchReportModeEnv = "RESEARCH_REPORT"
	gnoRESTPortEnv        = "GNO_REST_PORT"
)

type Config struct {
	TestMnemonic    string
	GnoChainID      string
	GnoGnokeyRemote string
	GnoREST         string
	GnoswapRepo     string
	GnoswapRef      string
}

func LoadConfig() (*Config, error) {
	_ = godotenv.Load()

	cfg := &Config{
		TestMnemonic:    os.Getenv("TEST_MNEMONIC"),
		GnoChainID:      os.Getenv("GNO_CHAIN_ID"),
		GnoGnokeyRemote: os.Getenv("GNO_GNOKEY_REMOTE"),
		GnoREST:         os.Getenv("GNO_REST"),
		GnoswapRepo:     os.Getenv("GNOSWAP_REPO"),
		GnoswapRef:      os.Getenv("GNOSWAP_REF"),
	}

	if cfg.TestMnemonic == "" {
		return nil, fmt.Errorf("TEST_MNEMONIC is required")
	}
	if cfg.GnoChainID == "" {
		cfg.GnoChainID = "dev"
	}
	reportMode := strings.TrimSpace(os.Getenv(researchReportModeEnv)) == "1"
	remote, rest, err := resolveEndpoints(reportMode, cfg.GnoGnokeyRemote, cfg.GnoREST)
	if err != nil {
		return nil, err
	}
	cfg.GnoGnokeyRemote = remote
	cfg.GnoREST = rest
	if cfg.GnoswapRepo == "" {
		cfg.GnoswapRepo = "https://github.com/gnoswap-labs/gnoswap.git"
	}
	if cfg.GnoswapRef == "" {
		cfg.GnoswapRef = "main"
	}

	return cfg, nil
}

func resolveEndpoints(reportMode bool, remote, rest string) (string, string, error) {
	remote = strings.TrimSpace(remote)
	rest = strings.TrimSpace(rest)

	if remote == "" {
		remote = "localhost:26657"
	}
	if rest == "" {
		if port := strings.TrimSpace(os.Getenv(gnoRESTPortEnv)); port != "" {
			rest = "http://localhost:" + port
		}
	}

	if reportMode {
		if rest == "" {
			return "", "", fmt.Errorf("%s or %s is required when %s=1", "GNO_REST", gnoRESTPortEnv, researchReportModeEnv)
		}
		return remote, rest, nil
	}

	if remote == "" {
		remote = "localhost:26657"
	}
	if rest == "" {
		rest = "http://localhost:48888"
	}
	return remote, rest, nil
}
