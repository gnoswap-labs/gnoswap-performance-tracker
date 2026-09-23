| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| BitMathMSB_one | 93,471 | 0 | 31,705 |
| BitMathLSB_one | 31,678 | 0 | 25,988 |
| BitMathMSB_limb1 | 33,147 | 0 | 31,863 |
| BitMathLSB_limb1 | 28,388 | 0 | 27,300 |
| BitMathMSB_limb2 | 31,773 | 0 | 30,489 |
| BitMathLSB_limb2 | 29,455 | 0 | 28,367 |
| BitMathMSB_limb3 | 30,399 | 0 | 29,115 |
| BitMathLSB_limb3 | 29,467 | 0 | 28,379 |
| BitMathMSB_max | 32,214 | 0 | 30,930 |
| BitMathLSB_max | 27,076 | 0 | 25,988 |
| TickMathGetTickAtSqrtRatio_Q96 | 3,182,671 | 0 | 3,019,139 |
| TickMathGetSqrtRatioAtTick (minTick) | 1,689,859 | 0 | 1,565,901 |
| TickMathGetSqrtRatioAtTick (maxTick) | 2,058,854 | 0 | 2,010,200 |
| TickMathGetSqrtRatioAtTick (zero) | 334,802 | 0 | 322,554 |
| TickMathGetSqrtRatioAtTick | 1,527,883 | 0 | 1,501,949 |
| TickMathGetTickAtSqrtRatio | 3,620,172 | 0 | 3,510,280 |
| GetLiquidityForAmounts | 3,211,514 | 0 | 3,153,602 |
| GetAmountsForLiquidity | 2,981,516 | 0 | 2,937,658 |
| LiquidityMathAddDelta (positive) | 449,544 | 0 | 431,320 |
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
| Delegate | 4,981,344 | 38,285 | 1,942,824 |
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
| Create Launchpad Project | 8,505,813 | 33,729 | 6,117,361 |
| Launchpad DepositGns | 6,420,331 | 24,246 | 4,183,559 |
| Launchpad TransferLeftFromProjectByAdmin | 1,260,660 | 41 | 1,071,291 |
| CreatePool | 6,450,005 | 25,361 | 5,636,490 |
| Mint (fee:3000, wide range) | 31,521,714 | 22,702 | 29,270,728 |
| Swap (gns -> wugnot, fee:500) | 46,797,131 | 0 | 43,905,580 |
| DecreaseLiquidity | 25,614,822 | 18 | 24,155,654 |
| IncreaseLiquidity | 23,100,544 | -2,084 | 22,194,191 |
| Mint (bar:foo:500) | 29,702,484 | 22,689 | 27,357,651 |
| CollectFee (with unwrap) | 7,921,566 | 44 | 5,945,168 |
| DecreaseLiquidity (w. Remove) | 22,322,728 | 62 | 19,402,448 |
| Mint (reposition) | 30,529,035 | 8,619 | 29,373,460 |
| SetPoolTier (tier 1) | 4,031,260 | 47,025 | 1,842,521 |
| StakeToken | 10,617,920 | 23,393 | 9,715,027 |
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
| ExactInSingleSwapRoute(grc20) - fee:10000 | 26,684,372 | 9,054 | 23,190,970 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,275,092 | 9,054 | 27,686,346 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 26,748,709 | 9,054 | 23,236,487 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 26,610,946 | 9,054 | 23,117,784 |
| ExactInSwapRoute(grc20) - fee:10000 | 25,922,842 | 9,054 | 22,437,555 |
| ExactInSwapRoute(grc20) - fee:100 | 30,530,866 | 9,054 | 26,950,235 |
| ExactInSwapRoute(grc20) - fee:3000 | 25,995,831 | 9,054 | 22,491,724 |
| ExactInSwapRoute(grc20) - fee:500 | 25,866,720 | 9,054 | 22,381,673 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,517,373 | 9,054 | 24,998,152 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 32,958,869 | 9,054 | 29,346,917 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 28,457,726 | 9,054 | 24,919,453 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,353,511 | 9,054 | 24,834,298 |
| ExactOutSwapRoute(grc20) - fee:10000 | 27,778,878 | 9,054 | 24,267,777 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,237,678 | 9,054 | 28,633,846 |
| ExactOutSwapRoute(grc20) - fee:3000 | 27,727,883 | 9,054 | 24,197,730 |
| ExactOutSwapRoute(grc20) - fee:500 | 27,632,320 | 9,054 | 24,121,227 |
| BuildSingleHopRoutePath | 202,459 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 51,996,328 | 9,061 | 47,664,494 |
| MultiHop ExactOut (2 hops) | 71,875,113 | 76 | 69,573,326 |
| MultiHop ExactIn (3 hops) | 71,349,531 | 33 | 68,846,542 |
| MultiHop ExactOut (3 hops) | 109,071,023 | 0 | 105,792,626 |
| MultiRoute ExactIn (50:50 split) | 70,669,082 | 0 | 68,105,627 |
| MultiRoute ExactOut (50:50 split) | 95,469,462 | 4 | 92,407,079 |
| Swap (halving, 10 staked tick-crosses) | 103,989,327 | 3,729 | 99,595,418 |
| Swap (halving, 1 staked tick-cross) | 31,549,150 | 2,813 | 29,882,853 |
| Swap (halving, 50 staked tick-crosses) | 434,167,593 | 7,260 | 418,902,502 |
| Swap (no halving, 10 staked tick-crosses) | 91,814,447 | -7,110 | 87,817,288 |
| Swap (no halving, 1 staked tick-cross) | 25,353,220 | -7,684 | 23,963,651 |
| Swap (no halving, 50 staked tick-crosses) | 395,418,391 | -5,108 | 381,084,692 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
