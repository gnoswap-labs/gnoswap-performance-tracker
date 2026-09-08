| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| TickMathGetSqrtRatioAtTick (minTick) | 1,689,865 | 0 | 1,565,901 |
| TickMathGetSqrtRatioAtTick (maxTick) | 2,058,854 | 0 | 2,010,200 |
| TickMathGetSqrtRatioAtTick (zero) | 334,802 | 0 | 322,554 |
| TickMathGetSqrtRatioAtTick | 1,527,883 | 0 | 1,501,949 |
| TickMathGetTickAtSqrtRatio | 3,863,554 | 0 | 3,733,669 |
| GetLiquidityForAmounts | 3,211,535 | 0 | 3,153,602 |
| GetAmountsForLiquidity | 2,981,525 | 0 | 2,937,658 |
| LiquidityMathAddDelta (positive) | 449,547 | 0 | 431,320 |
| LiquidityMathAddDelta (negative) | 471,588 | 0 | 463,867 |
| LiquidityMathAddDelta | 437,865 | 0 | 431,320 |
| GetAmount0Delta | 3,631,434 | 0 | 3,328,476 |
| GetAmount1Delta | 2,329,750 | 0 | 2,298,269 |
| SwapMathComputeSwapStep | 4,232,740 | 0 | 4,157,059 |
| Propose Community Pool Spend | 2,436,117 | 20,560 | 1,968,413 |
| Propose Parameter Change | 2,992,330 | 19,532 | 2,550,061 |
| Vote | 1,020,769 | 4,488 | 860,873 |
| Execute | 2,528,088 | 76 | 1,353,678 |
| Propose Text | 1,931,909 | 18,333 | 1,581,409 |
| Propose Text with Inactive: 100 | 2,347,937 | 8,501 | 2,078,803 |
| CollectUndelegatedGns (100 delegations, 1 withdraws) | 25,137,447 | 0 | 22,353,363 |
| CollectUndelegatedGns (10 delegations, 10 withdraws) | 4,375,919 | 0 | 3,847,077 |
| CollectUndelegatedGns (10 delegations, 1 withdraws) | 2,337,329 | 0 | 1,950,057 |
| CollectUndelegatedGns (10 delegations, 50 withdraws) | 13,436,619 | 18 | 12,278,277 |
| CollectUndelegatedGns (10 delegations, 5 withdraws) | 3,243,369 | 0 | 2,793,177 |
| CollectUndelegatedGns (1 delegation, 10 withdraws) | 611,432 | 0 | 541,799 |
| CollectUndelegatedGns (1 delegation, 1 withdraws) | 407,573 | 0 | 352,097 |
| CollectUndelegatedGns (1 delegation, 50 withdraws) | 1,517,472 | 0 | 1,384,919 |
| CollectUndelegatedGns (1 delegation, 5 withdraws) | 498,177 | 0 | 436,409 |
| CollectReward (100 delegations, 1 withdraws) | 3,439,469 | 2,333 | 2,787,123 |
| CollectReward (10 delegations, 10 withdraws) | 3,439,379 | 2,323 | 2,787,123 |
| CollectReward (10 delegations, 1 withdraws) | 3,435,591 | 2,323 | 2,783,337 |
| CollectReward (10 delegations, 50 withdraws) | 3,438,312 | 2,323 | 2,786,056 |
| CollectReward (10 delegations, 5 withdraws) | 3,432,388 | 2,323 | 2,780,134 |
| CollectReward (1 delegation, 10 withdraws) | 3,509,511 | 2,395 | 2,783,337 |
| CollectReward (1 delegation, 1 withdraws) | 3,685,097 | 2,395 | 2,955,457 |
| CollectReward (1 delegation, 50 withdraws) | 3,506,308 | 2,395 | 2,780,134 |
| CollectReward (1 delegation, 5 withdraws) | 3,507,465 | 2,395 | 2,781,291 |
| gov/staker CollectReward (1 protocol-fee tokens) | 3,686,283 | 368 | 2,962,390 |
| gov/staker CollectReward (2 protocol-fee tokens) | 5,840,745 | -1,860 | 5,015,062 |
| gov/staker CollectReward (3 protocol-fee tokens) | 8,115,227 | -3,992 | 7,069,573 |
| gov/staker CollectReward (4 protocol-fee tokens) | 10,400,912 | -6,122 | 9,128,591 |
| gov/staker CollectReward (4 protocol-fee tokens but zero amount) | 1,701,190 | 0 | 1,173,935 |
| Delegate | 4,989,756 | 38,285 | 1,942,824 |
| Undelegate | 2,279,200 | 840 | 1,586,279 |
| Undelegate (5 delegations, cached external calls) | 9,705,646 | 3,510 | 6,778,953 |
| Delegate (cached external calls) | 3,046,853 | 3,210 | 2,323,417 |
| Undelegate (early exit, 3 of 10 delegations) | 6,656,620 | 2,088 | 4,833,951 |
| Redelegate | 4,363,314 | 1,423 | 3,049,928 |
| Redelegate (50 of 100 delegations, optimized) | 123,363,976 | -118,826 | 90,714,642 |
| Undelegate (50 delegatees, large AVL traversal) | 2,459,149 | 708 | 1,789,243 |
| CollectDepositGns (deposit 1/5, remaining 4) | 7,704,244 | 1,850 | 6,534,801 |
| CollectDepositGns (deposit 2/5, remaining 3) | 7,366,642 | -2,257 | 6,311,632 |
| CollectDepositGns (deposit 3/5, remaining 2) | 7,340,262 | -2,257 | 6,287,637 |
| CollectDepositGns (deposit 4/5, remaining 1) | 7,345,708 | -2,257 | 6,295,468 |
| CollectDepositGns (deposit 5/5, remaining 0) | 7,218,065 | -8,456 | 6,190,891 |
| Launchpad CollectDepositGns | 7,571,486 | -4,155 | 6,431,670 |
| CollectProtocolFee (1 token) | 3,561,082 | 4,426 | 2,909,586 |
| CollectProtocolFee (2 tokens) | 5,622,664 | 8,750 | 4,749,453 |
| CollectProtocolFee (5 tokens) | 11,846,105 | 21,724 | 10,283,758 |
| Launchpad CollectRewardByDepositId | 3,300,520 | 2,070 | 2,926,616 |
| Create Launchpad Project | 8,514,225 | 33,729 | 6,117,361 |
| Launchpad DepositGns | 6,420,331 | 24,246 | 4,183,559 |
| Launchpad TransferLeftFromProjectByAdmin | 1,260,660 | 41 | 1,071,291 |
| CreatePool | 6,701,805 | 25,361 | 5,859,879 |
| Mint (fee:3000, wide range) | 31,521,738 | 22,702 | 29,270,728 |
| Swap (gns -> wugnot, fee:500) | 47,027,189 | 0 | 44,129,286 |
| DecreaseLiquidity | 25,614,822 | 18 | 24,155,654 |
| IncreaseLiquidity | 23,100,544 | -2,084 | 22,194,191 |
| Mint (bar:foo:500) | 29,702,508 | 22,689 | 27,357,651 |
| CollectFee (with unwrap) | 7,921,566 | 44 | 5,945,168 |
| DecreaseLiquidity (w. Remove) | 22,322,728 | 62 | 19,402,448 |
| Mint (reposition) | 30,529,035 | 8,619 | 29,373,460 |
| SetPoolTier (tier 1) | 3,952,838 | 24,457 | 1,842,521 |
| StakeToken | 10,579,863 | 23,393 | 9,715,027 |
| UintTree Set (0) | 73,225 | 0 | 50,305 |
| UintTree Get (0) | 56,128 | 0 | 53,965 |
| UintTree Set (1) | 57,310 | 0 | 53,249 |
| UintTree Get (1) | 56,128 | 0 | 53,965 |
| UintTree Set (255) | 57,310 | 0 | 53,249 |
| UintTree Get (255) | 56,128 | 0 | 53,965 |
| UintTree Set (256) | 57,310 | 0 | 53,249 |
| UintTree Get (256) | 56,128 | 0 | 53,965 |
| UintTree Set (65535) | 57,310 | 0 | 53,249 |
| UintTree Get (65535) | 56,128 | 0 | 53,965 |
| UintTree Set (4294967295) | 57,310 | 0 | 53,249 |
| UintTree Get (4294967295) | 56,128 | 0 | 53,965 |
| UintTree Set (9223372036854775807) | 57,310 | 0 | 53,249 |
| UintTree Get (9223372036854775807) | 56,128 | 0 | 53,965 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 26,914,113 | 9,054 | 23,414,359 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,504,833 | 9,054 | 27,909,735 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 26,978,450 | 9,054 | 23,459,876 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 26,840,687 | 9,054 | 23,341,173 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,152,583 | 9,054 | 22,660,944 |
| ExactInSwapRoute(grc20) - fee:100 | 30,760,607 | 9,054 | 27,173,624 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,225,572 | 9,054 | 22,715,113 |
| ExactInSwapRoute(grc20) - fee:500 | 26,096,461 | 9,054 | 22,605,062 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,747,114 | 9,054 | 25,221,541 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,188,610 | 9,054 | 29,570,306 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 28,687,467 | 9,054 | 25,142,842 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,583,252 | 9,054 | 25,057,687 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,008,619 | 9,054 | 24,491,166 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,467,419 | 9,054 | 28,857,235 |
| ExactOutSwapRoute(grc20) - fee:3000 | 27,957,624 | 9,054 | 24,421,119 |
| ExactOutSwapRoute(grc20) - fee:500 | 27,862,061 | 9,054 | 24,344,616 |
| BuildSingleHopRoutePath | 202,459 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 52,553,428 | 9,061 | 48,206,355 |
| MultiHop ExactOut (2 hops) | 72,989,313 | 76 | 70,657,048 |
| MultiHop ExactIn (3 hops) | 72,136,372 | 33 | 69,611,792 |
| MultiHop ExactOut (3 hops) | 110,644,705 | 0 | 107,323,126 |
| MultiRoute ExactIn (50:50 split) | 71,455,923 | 0 | 68,870,877 |
| MultiRoute ExactOut (50:50 split) | 96,813,403 | 4 | 93,714,190 |
| CollectReward (only Internal Reward) | 13,986,040 | 11,137 | 12,586,433 |
| CollectReward 2nd (only Internal Reward) | 13,766,907 | 40 | 12,755,127 |
| storage growth: CollectReward 20 staked positions | 15,518,112 | 62 | 14,614,100 |
| storage growth: CollectReward 40 staked positions | 16,100,857 | 0 | 15,198,355 |
| storage growth: CollectReward 60 staked positions | 16,127,079 | 0 | 15,224,577 |
| storage growth: CollectReward 80 staked positions | 16,260,741 | 0 | 15,348,362 |
| storage growth: CollectReward 100 staked positions | 16,228,705 | 0 | 15,316,326 |
| CollectReward with Warmup Range (30% ~ 30%) | 14,024,036 | 11,119 | 12,618,488 |
| CollectReward with Warmup Range (30% ~ 50%) | 16,042,429 | 58 | 14,970,417 |
| CollectReward with Warmup Range (30% ~ 70%) | 18,347,295 | 18 | 17,215,577 |
| CollectReward with Warmup Range (30% ~ 100%) | 20,676,088 | 18 | 19,484,660 |
| CollectReward with Warmup Range (100% ~) | 13,441,758 | -6 | 12,508,566 |
| CollectReward with Warmup Range 2nd (100% ~) | 13,326,405 | 0 | 12,393,234 |
| EndExternalIncentive (unclaimablePeriods=100) | 2,425,562 | 147 | 2,202,244 |
| EndExternalIncentive (unclaimablePeriods=10) | 2,311,196 | 141 | 2,095,770 |
| EndExternalIncentive (unclaimablePeriods=50) | 2,386,736 | 141 | 2,166,386 |
| Swap (halving, 10 staked tick-crosses) | 106,293,957 | 3,729 | 101,861,239 |
| Swap (halving, 1 staked tick-cross) | 32,088,345 | 2,813 | 30,474,934 |
| Swap (halving, 50 staked tick-crosses) | 445,234,380 | 7,260 | 429,498,667 |
| staker.NewIncentives (constructor + initial period) | 969,027 | 7,125 | 72,705 |
| staker.NewPool (constructor + seeded histories) | 359,666 | 23,416 | 232,000 |
| staker.Pool.stakedLiquidity Set (#2) | 137,238 | 1,317 | 94,187 |
| staker.Pool.stakedLiquidity Set (#3-4) | 255,057 | 2,510 | 174,886 |
| staker.Pool.stakedLiquidity Set (#5) | 234,105 | 5,500 | 171,254 |
| staker.Pool.stakedLiquidity Set (#6-13) | 1,394,207 | 14,238 | 985,120 |
| staker.Pool.stakedLiquidity Set (#14) | 399,440 | 7,815 | 315,103 |
| staker.Pool.stakedLiquidity Set (#15-63) | 12,623,260 | 122,807 | 9,240,293 |
| staker.Pool.stakedLiquidity Set (#64) | 225,882 | 1,255 | 160,001 |
| staker.Pool.stakedLiquidity Set (#65) | 329,397 | 3,309 | 248,966 |
| staker.Pool.stakedLiquidity Set (#66-127) | 18,865,714 | 164,298 | 13,836,570 |
| staker.Pool.stakedLiquidity Set (#128) | 633,658 | 8,002 | 515,273 |
| staker.Pool.stakedLiquidity Set (#129) | 249,406 | 1,336 | 175,637 |
| staker.Pool.stakedLiquidity Reverse newest | 272,373 | 0 | 179,760 |
| staker.Pool.stakedLiquidity Reverse range (last 4) | 296,347 | 0 | 283,567 |
| staker.Pool.rewardCache Set (#2) | 123,208 | 435 | 86,761 |
| staker.Pool.rewardCache Set (#3-4) | 233,420 | 774 | 160,034 |
| staker.Pool.rewardCache Set (#5) | 219,700 | 4,664 | 163,828 |
| staker.Pool.rewardCache Set (#6-13) | 1,304,170 | 7,326 | 925,712 |
| staker.Pool.rewardCache Set (#14) | 386,488 | 6,990 | 307,677 |
| staker.Pool.rewardCache Set (#15-63) | 12,068,287 | 80,696 | 8,876,419 |
| staker.Pool.rewardCache Set (#64) | 215,245 | 388 | 152,575 |
| staker.Pool.rewardCache Set (#65) | 316,693 | 2,454 | 241,540 |
| staker.Pool.rewardCache Set (#66-127) | 18,162,474 | 110,578 | 13,376,158 |
| staker.Pool.rewardCache Set (#128) | 620,714 | 7,126 | 507,847 |
| staker.Pool.rewardCache Set (#129) | 238,610 | 460 | 168,211 |
| staker.Pool.rewardCache Reverse newest | 187,794 | 0 | 179,760 |
| staker.Pool.rewardCache Reverse range (last 4) | 292,777 | 0 | 283,567 |
| staker.Pool.globalRewardRatioAccumulation Set (#2) | 130,031 | 459 | 93,481 |
| staker.Pool.globalRewardRatioAccumulation Set (#3-4) | 247,066 | 822 | 173,474 |
| staker.Pool.globalRewardRatioAccumulation Set (#5) | 226,811 | 4,688 | 170,548 |
| staker.Pool.globalRewardRatioAccumulation Set (#6-13) | 1,361,261 | 7,522 | 981,384 |
| staker.Pool.globalRewardRatioAccumulation Set (#14) | 394,093 | 7,015 | 314,875 |
| staker.Pool.globalRewardRatioAccumulation Set (#15-63) | 12,431,032 | 81,921 | 9,229,121 |
| staker.Pool.globalRewardRatioAccumulation Set (#64) | 222,550 | 413 | 159,773 |
| staker.Pool.globalRewardRatioAccumulation Set (#65) | 324,298 | 2,479 | 248,738 |
| staker.Pool.globalRewardRatioAccumulation Set (#66-127) | 19,172,355 | 112,156 | 14,361,182 |
| staker.Pool.globalRewardRatioAccumulation Set (#128) | 648,005 | 7,152 | 534,286 |
| staker.Pool.globalRewardRatioAccumulation Set (#129) | 265,589 | 486 | 194,650 |
| staker.Pool.globalRewardRatioAccumulation Reverse newest | 187,794 | 0 | 179,760 |
| staker.Pool.globalRewardRatioAccumulation Reverse range (last 4) | 292,777 | 0 | 283,567 |
| staker.Pool.historicalTick Set (#1) | 97,350 | 2,299 | 61,357 |
| staker.Pool.historicalTick Set (#2-4) | 339,490 | 1,188 | 230,533 |
| staker.Pool.historicalTick Set (#5) | 219,891 | 4,660 | 163,980 |
| staker.Pool.historicalTick Set (#6-13) | 1,305,413 | 7,326 | 926,928 |
| staker.Pool.historicalTick Set (#14) | 386,649 | 6,990 | 307,829 |
| staker.Pool.historicalTick Set (#15-63) | 12,075,735 | 80,696 | 8,883,867 |
| staker.Pool.historicalTick Set (#64) | 215,397 | 388 | 152,727 |
| staker.Pool.historicalTick Set (#65) | 316,845 | 2,454 | 241,692 |
| staker.Pool.historicalTick Set (#66-127) | 18,171,898 | 110,578 | 13,385,582 |
| staker.Pool.historicalTick Set (#128) | 620,866 | 7,126 | 507,999 |
| staker.Pool.historicalTick Set (#129) | 238,762 | 460 | 168,363 |
| staker.Pool.historicalTick Reverse newest | 187,794 | 0 | 179,760 |
| staker.Pool.historicalTick Reverse range (last 4) | 292,777 | 0 | 283,567 |
| staker.Pool.incentives.unclaimablePeriods Set (#2) | 126,414 | 447 | 86,410 |
| staker.Pool.incentives.unclaimablePeriods Set (#3-4) | 239,832 | 774 | 159,332 |
| staker.Pool.incentives.unclaimablePeriods Set (#5) | 222,906 | 4,664 | 163,477 |
| staker.Pool.incentives.unclaimablePeriods Set (#6-13) | 1,329,818 | 7,326 | 922,904 |
| staker.Pool.incentives.unclaimablePeriods Set (#14) | 389,694 | 6,990 | 307,326 |
| staker.Pool.incentives.unclaimablePeriods Set (#15-63) | 12,225,381 | 80,696 | 8,859,220 |
| staker.Pool.incentives.unclaimablePeriods Set (#64) | 218,451 | 388 | 152,224 |
| staker.Pool.incentives.unclaimablePeriods Set (#65) | 319,899 | 2,454 | 241,189 |
| staker.Pool.incentives.unclaimablePeriods Reverse newest | 172,583 | 0 | 165,960 |
| staker.Pool.incentives.unclaimablePeriods Reverse range (last 4) | 277,566 | 0 | 269,767 |
| staker.Pool.incentives.unclaimablePeriods Remove (#5) | 218,831 | -350 | 159,183 |
| staker.Pool.incentives.byStartTime Set (#1) | 134,942 | 2,714 | 91,552 |
| staker.Pool.incentives.byStartTime Set (#2-4) | 504,957 | 2,433 | 377,325 |
| staker.Pool.incentives.byStartTime Set (#5) | 279,048 | 5,075 | 215,064 |
| staker.Pool.incentives.byStartTime Set (#6-13) | 1,872,365 | 10,650 | 1,436,568 |
| staker.Pool.incentives.byStartTime Set (#14) | 462,778 | 7,406 | 375,406 |
| staker.Pool.incentives.byStartTime Set (#15-63) | 16,754,271 | 101,080 | 13,166,339 |
| staker.Pool.incentives.byStartTime Set (#64) | 319,429 | 804 | 249,105 |
| staker.Pool.incentives.byStartTime Set (#65) | 422,725 | 2,870 | 338,070 |
| staker.Pool.incentives.byStartTime Reverse newest | 179,720 | 0 | 172,714 |
| staker.Pool.incentives.byStartTime Reverse range (last 4) | 295,038 | 0 | 286,856 |
| staker.Pool.incentives.byStartTime Remove (#5) | 326,705 | -765 | 263,677 |
| Swap (no halving, 10 staked tick-crosses) | 94,166,609 | -1,468 | 90,083,109 |
| Swap (no halving, 1 staked tick-cross) | 25,939,947 | -2,042 | 24,555,732 |
| Swap (no halving, 50 staked tick-crosses) | 406,532,710 | 534 | 391,680,857 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
