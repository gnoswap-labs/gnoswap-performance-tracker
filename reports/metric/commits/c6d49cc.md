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
| SwapMathComputeSwapStep | 4,237,966 | 0 | 4,162,089 |
| Propose Community Pool Spend | 2,737,528 | 27,379 | 2,167,049 |
| Propose Parameter Change | 3,293,741 | 26,351 | 2,748,697 |
| Vote | 1,027,015 | 4,486 | 860,873 |
| Execute | 2,916,599 | -6,718 | 1,667,272 |
| Propose Text | 2,233,320 | 25,152 | 1,780,045 |
| Propose Text with Inactive: 100 | 2,645,850 | 15,323 | 2,277,439 |
| CollectUndelegatedGns (1 delegation, 1 withdraws) | 407,573 | 0 | 352,097 |
| CollectUndelegatedGns (1 delegation, 10 withdraws) | 611,432 | 0 | 541,799 |
| CollectUndelegatedGns (1 delegation, 5 withdraws) | 498,177 | 0 | 436,409 |
| CollectUndelegatedGns (1 delegation, 50 withdraws) | 1,517,472 | 0 | 1,384,919 |
| CollectUndelegatedGns (10 delegations, 1 withdraws) | 2,337,329 | 0 | 1,950,057 |
| CollectUndelegatedGns (10 delegations, 10 withdraws) | 4,375,919 | 0 | 3,847,077 |
| CollectUndelegatedGns (10 delegations, 5 withdraws) | 3,243,369 | 0 | 2,793,177 |
| CollectUndelegatedGns (10 delegations, 50 withdraws) | 13,436,619 | 18 | 12,278,277 |
| CollectUndelegatedGns (100 delegations, 1 withdraws) | 25,137,447 | 0 | 22,353,363 |
| CollectReward (1 delegation, 1 withdraws) | 3,685,097 | 2,395 | 2,955,457 |
| CollectReward (1 delegation, 10 withdraws) | 3,509,511 | 2,395 | 2,783,337 |
| CollectReward (1 delegation, 5 withdraws) | 3,507,465 | 2,395 | 2,781,291 |
| CollectReward (1 delegation, 50 withdraws) | 3,506,308 | 2,395 | 2,780,134 |
| CollectReward (10 delegations, 1 withdraws) | 3,435,591 | 2,323 | 2,783,337 |
| CollectReward (10 delegations, 10 withdraws) | 3,439,379 | 2,323 | 2,787,123 |
| CollectReward (10 delegations, 5 withdraws) | 3,432,388 | 2,323 | 2,780,134 |
| CollectReward (10 delegations, 50 withdraws) | 3,438,312 | 2,323 | 2,786,056 |
| CollectReward (100 delegations, 1 withdraws) | 3,439,469 | 2,333 | 2,787,123 |
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
| Clean delegation snapshots (1000 cancelled proposals) | 499,953 | 0 | 435,375 |
| Clean delegation snapshots (1000 stale proposals) | 307,584,278 | -257,760 | 269,709,190 |
| Undelegate (50 delegatees, large AVL traversal) | 2,459,149 | 708 | 1,789,243 |
| CollectDepositGns (deposit 1/5, remaining 4) | 7,454,978 | 1,850 | 6,397,847 |
| CollectDepositGns (deposit 2/5, remaining 3) | 7,070,858 | -2,257 | 6,124,356 |
| CollectDepositGns (deposit 3/5, remaining 2) | 7,047,456 | -2,257 | 6,103,339 |
| CollectDepositGns (deposit 4/5, remaining 1) | 7,052,902 | -2,257 | 6,111,170 |
| CollectDepositGns (deposit 5/5, remaining 0) | 6,928,237 | -8,456 | 6,009,571 |
| Launchpad CollectDepositGns | 7,328,176 | -4,155 | 6,300,672 |
| CollectProtocolFee (1 token) | 3,561,082 | 4,426 | 2,909,586 |
| CollectProtocolFee (2 tokens) | 5,622,664 | 8,750 | 4,749,453 |
| CollectProtocolFee (5 tokens) | 11,846,105 | 21,724 | 10,283,758 |
| Launchpad CollectRewardByDepositId | 3,263,200 | 2,070 | 2,918,983 |
| Create Launchpad Project | 8,482,152 | 30,768 | 6,109,705 |
| Launchpad DepositGns | 6,281,122 | 24,246 | 4,101,397 |
| Launchpad TransferLeftFromProjectByAdmin | 1,261,704 | 41 | 1,072,335 |
| CreatePool | 6,701,805 | 25,361 | 5,859,879 |
| Mint (fee:3000, wide range) | 31,521,738 | 22,702 | 29,270,728 |
| Swap (gns -> wugnot, fee:500) | 47,063,768 | 0 | 44,164,496 |
| DecreaseLiquidity | 25,614,822 | 18 | 24,155,654 |
| IncreaseLiquidity | 23,100,544 | -2,084 | 22,194,191 |
| Mint (bar:foo:500) | 29,702,508 | 22,689 | 27,357,651 |
| CollectFee (with unwrap) | 7,921,563 | 44 | 5,945,168 |
| DecreaseLiquidity (w. Remove) | 22,322,725 | 62 | 19,402,448 |
| Mint (reposition) | 30,529,035 | 8,619 | 29,373,460 |
| SetPoolTier (tier 1) | 4,031,257 | 47,025 | 1,842,521 |
| StakeToken | 10,635,820 | 29,035 | 9,715,027 |
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
| ExactInSingleSwapRoute(grc20) - fee:100 | 32,281,362 | 9,054 | 28,661,986 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 27,685,903 | 9,054 | 24,162,067 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 27,749,753 | 9,054 | 24,207,097 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 27,612,477 | 9,054 | 24,088,881 |
| ExactInSwapRoute(grc20) - fee:100 | 31,537,136 | 9,054 | 27,925,875 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,924,373 | 9,054 | 23,408,652 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,996,875 | 9,054 | 23,462,334 |
| ExactInSwapRoute(grc20) - fee:500 | 26,868,251 | 9,054 | 23,352,770 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,958,716 | 9,054 | 30,316,330 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 29,517,707 | 9,054 | 25,968,052 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 29,457,573 | 9,054 | 25,888,866 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 29,353,845 | 9,054 | 25,804,198 |
| ExactOutSwapRoute(grc20) - fee:100 | 33,237,525 | 9,054 | 29,603,259 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,779,212 | 9,054 | 25,237,677 |
| ExactOutSwapRoute(grc20) - fee:3000 | 28,727,730 | 9,054 | 25,167,143 |
| ExactOutSwapRoute(grc20) - fee:500 | 28,632,654 | 9,054 | 25,091,127 |
| BuildSingleHopRoutePath | 202,459 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 53,388,533 | 9,061 | 49,011,710 |
| MultiHop ExactOut (2 hops) | 74,625,447 | 76 | 72,262,014 |
| MultiHop ExactIn (3 hops) | 73,714,202 | 33 | 71,159,925 |
| MultiHop ExactOut (3 hops) | 113,802,475 | 0 | 110,421,894 |
| MultiRoute ExactIn (50:50 split) | 73,038,160 | 0 | 70,423,417 |
| MultiRoute ExactOut (50:50 split) | 99,210,541 | 4 | 96,066,341 |
| Swap (halving, 1 staked tick-cross) | 32,316,437 | 11,610 | 30,569,347 |
| Swap (halving, 10 staked tick-crosses) | 107,863,373 | 91,699 | 102,760,099 |
| Swap (halving, 50 staked tick-crosses) | 451,851,592 | 448,135 | 433,972,847 |
| Swap (no halving, 1 staked tick-cross) | 26,120,507 | 1,113 | 24,650,145 |
| Swap (no halving, 10 staked tick-crosses) | 95,688,493 | 80,860 | 90,981,969 |
| Swap (no halving, 50 staked tick-crosses) | 413,102,390 | 435,767 | 396,155,037 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
