package research

import "testing"

func mustSetupResearchHarnessEnv(t *testing.T) *researchHarnessEnv {
	t.Helper()
	baseEnv := mustSetupTestEnv(t)
	adminAddr, err := gnokeyAddress(baseEnv.gnoContainer, "gnoswap_admin")
	if err != nil {
		t.Fatalf("query gnoswap_admin address: %v", err)
	}
	return &researchHarnessEnv{
		TestEnv:      baseEnv,
		poolAddr:     baseEnv.mustQueryAddressByRole(t, "pool"),
		positionAddr: baseEnv.mustQueryAddressByRole(t, "position"),
		adminAddr:    adminAddr,
		wrapperAddr:  querySwapWrapperAddressMaybe(baseEnv.gnoContainer, baseEnv.cfg.GnoGnokeyRemote),
	}
}
