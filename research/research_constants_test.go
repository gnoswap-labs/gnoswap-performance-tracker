package research

const (
	researchReportEnv                    = "RESEARCH_REPORT"
	researchReportOutputEnv              = "RESEARCH_REPORT_OUT"
	probeCheckpointsEnv                  = "WORKLOAD_NS"
	workloadWrappedUgnotPath             = "gno.land/r/gnoland/wugnot"
	workloadGnsPath                      = "gno.land/r/gnoswap/gns"
	poolPkgPath                          = "gno.land/r/gnoswap/pool"
	positionPkgPath                      = "gno.land/r/gnoswap/position"
	stakerPkgPath                        = "gno.land/r/gnoswap/staker"
	workloadSwapWrapperPkgPath           = "gno.land/r/swap_probe_wrapper"
	workloadFeeTier               uint32 = 3000
	initialSqrtPriceX96                  = "79228162514264337593543950337"
	swapSqrtPriceLimitExactInX96         = "1461446703485210103287273052203988822378723970341"
	swapSqrtPriceLimitExactOutX96        = "1461373636630004318706518188784493106690254656249"
	swapAmountSpecifiedExactIn           = "1000000"
	swapAmountSpecifiedExactOut          = "-5000"
	workloadMaxApprove                   = "9223372036854775806"
	workloadUserAddress                  = "g1z437dpuh5s4p64vtq09dulg6jzxpr2hd4q8r5x"
	workloadWrappedDeposit               = "100000000"
	workloadWideTickLower         int32  = -887220
	workloadWideTickUpper         int32  = 887220
	workloadDefaultDeadline       int64  = 9999999999
	workloadMintAmount0                  = "5000000"
	workloadMintAmount1                  = "5000000"
	workloadIncreaseAmount0              = "1000000"
	workloadIncreaseAmount1              = "1000000"
	stakerPoolTier                       = "3"
	stakerEmissionStart                  = int64(1)
	stakerEmissionEnd                    = int64(7776001)
)

type txMetrics struct {
	GasUsed      int64
	StorageDelta int64
	TotalTxCost  int64
}

type researchHarnessEnv struct {
	*TestEnv
	poolAddr     string
	positionAddr string
	stakerAddr   string
	adminAddr    string
	wrapperAddr  string
}

type checkpointPoint struct {
	N            int64
	SampleCount  int
	GasStats     metricStats
	StorageStats metricStats
	CostStats    metricStats
}
