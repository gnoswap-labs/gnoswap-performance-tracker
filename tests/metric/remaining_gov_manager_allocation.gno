package metric

import gs "gno.land/r/gnoswap/gov/staker"

// Benchmark-only roots retain instances built by the real domain factories.
// They are separate from protocol state and are not a production transaction API.
var (
	remainingFeeManager      *gs.ProtocolFeeRewardManager
	remainingEmissionManager *gs.EmissionRewardManager
)

func AllocateRemainingFeeManager(cur realm) {
	remainingFeeManager = gs.NewProtocolFeeRewardManager()
}

func AllocateRemainingEmissionManager(cur realm) {
	remainingEmissionManager = gs.NewEmissionRewardManager()
}
