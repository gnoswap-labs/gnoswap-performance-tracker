package research

const (
	researchReportEnv                               = "RESEARCH_REPORT"
	researchReportOutputEnv                         = "RESEARCH_REPORT_OUT"
	probeCheckpointsEnv                             = "WORKLOAD_NS"
	workloadWrappedUgnotPath                        = "gno.land/r/gnoland/wugnot"
	workloadGnsPath                                 = "gno.land/r/gnoswap/gns"
	commonPkgPath                                   = "gno.land/r/gnoswap/common"
	poolPkgPath                                     = "gno.land/r/gnoswap/pool"
	positionPkgPath                                 = "gno.land/r/gnoswap/position"
	gnftPkgPath                                     = "gno.land/r/gnoswap/gnft"
	routerPkgPath                                   = "gno.land/r/gnoswap/router"
	stakerPkgPath                                   = "gno.land/r/gnoswap/staker"
	emissionPkgPath                                 = "gno.land/r/gnoswap/emission"
	workloadFeeTier                          uint32 = 3000
	routerMixedFeeTier                       uint32 = 100
	routerWorkloadFeeTier                    uint32 = 500
	routerContractWideTickLower              int32  = -6960
	routerContractWideTickUpper              int32  = 6960
	initialSqrtPriceX96                             = "79228162514264337593543950337"
	routerExactInSingleHopAmountIn                  = "50000000"
	routerExactInTwoHopAmountIn                     = "10000000"
	routerExactInQuoteRatios                        = "100"
	routerExactInAmountOutMin                       = "1"
	routerExactOutSingleHopAmountOut                = "500000"
	routerExactOutTwoHopAmountOut                   = "500"
	routerExactOutQuoteRatios                       = "100"
	routerExactOutSingleHopAmountInMax              = "50000000"
	routerExactOutTwoHopAmountInMax                 = "10000"
	routerMintAmount0                               = "100000000"
	routerMintAmount1                               = "100000000"
	routerSameBoundsTickLower                int32  = -1920
	routerSameBoundsTickUpper                int32  = 1920
	workloadMaxApprove                              = "9223372036854775806"
	workloadTxGasFee                                = "3000000ugnot"
	workloadTxGasWanted                             = "3000000000"
	workloadWrappedDeposit                          = "1000000"
	workloadWrappedDepositMinimum                   = int64(1000)
	workloadWideTickLower                    int32  = -887220
	workloadWideTickUpper                    int32  = 887220
	workloadNarrowTickLower                  int32  = -60
	workloadNarrowTickUpper                  int32  = 60
	workloadDefaultDeadline                  int64  = 9999999999
	workloadMintAmount0                             = "500000"
	workloadMintAmount1                             = "500000"
	workloadDecreaseMintAmount0                     = "5000000"
	workloadDecreaseMintAmount1                     = "5000000"
	workloadIncreaseAmount0                         = "100000"
	workloadIncreaseAmount1                         = "100000"
	stakerFixedExternalIncentiveRewardAmount        = "10000000000"
	stakerPoolTier                                  = "3"
	stakerEmissionDays                              = int64(365)
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

type routerScenarioState struct {
	tokenInPath  string
	tokenOutPath string
	route        string
	reverseRoute string
	poolPaths    []string
}

type routerPositionSpec struct {
	TickLower      int32
	TickUpper      int32
	Amount0Desired string
	Amount1Desired string
}

type tokenBudget struct {
	GNS          int64
	WrappedUgnot int64
}

type checkpointPoint struct {
	N            int64
	SampleCount  int
	GasStats     metricStats
	StorageStats metricStats
	CostStats    metricStats
}
