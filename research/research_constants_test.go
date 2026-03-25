package research

const (
	researchReportEnv                      = "RESEARCH_REPORT"
	researchReportOutputEnv                = "RESEARCH_REPORT_OUT"
	probeCheckpointsEnv                    = "WORKLOAD_NS"
	workloadWrappedUgnotPath               = "gno.land/r/gnoland/wugnot"
	workloadGnsPath                        = "gno.land/r/gnoswap/gns"
	poolPkgPath                            = "gno.land/r/gnoswap/pool"
	positionPkgPath                        = "gno.land/r/gnoswap/position"
	gnftPkgPath                            = "gno.land/r/gnoswap/gnft"
	routerPkgPath                          = "gno.land/r/gnoswap/router"
	stakerPkgPath                          = "gno.land/r/gnoswap/staker"
	workloadFeeTier                 uint32 = 3000
	routerWorkloadFeeTier           uint32 = 500
	initialSqrtPriceX96                    = "79228162514264337593543950337"
	routerExactInAmountIn                  = "10000000"
	routerExactInQuoteRatios               = "100"
	routerExactInAmountOutMin              = "1"
	routerExactInSqrtPriceLimitX96         = "0"
	routerExactOutAmountOut                = "1000"
	routerExactOutQuoteRatios              = "100"
	routerExactOutAmountInMax              = "10000"
	routerExactOutSqrtPriceLimitX96        = "78228162514264337593543950336"
	routerMintAmount0                      = "100000000"
	routerMintAmount1                      = "100000000"
	workloadMaxApprove                     = "9223372036854775806"
	workloadUserAddress                    = "g1z437dpuh5s4p64vtq09dulg6jzxpr2hd4q8r5x"
	workloadWrappedDeposit                 = "100000000"
	workloadWideTickLower           int32  = -887220
	workloadWideTickUpper           int32  = 887220
	workloadDefaultDeadline         int64  = 9999999999
	workloadMintAmount0                    = "5000000"
	workloadMintAmount1                    = "5000000"
	workloadIncreaseAmount0                = "1000000"
	workloadIncreaseAmount1                = "1000000"
	stakerPoolTier                         = "3"
	stakerEmissionStart                    = int64(1)
	stakerEmissionEnd                      = int64(7776001)
)

type txMetrics struct {
	GasUsed      int64
	StorageDelta int64
	TotalTxCost  int64
	HasTotalCost bool
}

type researchHarnessEnv struct {
	*TestEnv
	poolAddr     string
	positionAddr string
	stakerAddr   string
	routerAddr   string
	adminAddr    string
}

type checkpointPoint struct {
	N            int64
	SampleCount  int
	GasStats     metricStats
	StorageStats metricStats
	CostStats    metricStats
}
