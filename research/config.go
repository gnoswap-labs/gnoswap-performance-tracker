package research

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
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
	if cfg.GnoGnokeyRemote == "" {
		cfg.GnoGnokeyRemote = "localhost:26657"
	}
	if cfg.GnoREST == "" {
		cfg.GnoREST = "http://localhost:48888"
	}
	if cfg.GnoswapRepo == "" {
		cfg.GnoswapRepo = "https://github.com/gnoswap-labs/gnoswap.git"
	}
	if cfg.GnoswapRef == "" {
		cfg.GnoswapRef = "main"
	}

	return cfg, nil
}
