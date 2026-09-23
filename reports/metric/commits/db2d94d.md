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
| SetPoolTier (tier 1) | 4,031,260 | 47,025 | 1,842,521 |
| StakeToken | 10,635,823 | 29,035 | 9,715,027 |
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
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,504,833 | 9,054 | 27,909,735 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 26,914,113 | 9,054 | 23,414,359 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 26,978,450 | 9,054 | 23,459,876 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 26,840,687 | 9,054 | 23,341,173 |
| ExactInSwapRoute(grc20) - fee:100 | 30,760,607 | 9,054 | 27,173,624 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,152,583 | 9,054 | 22,660,944 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,225,572 | 9,054 | 22,715,113 |
| ExactInSwapRoute(grc20) - fee:500 | 26,096,461 | 9,054 | 22,605,062 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,188,610 | 9,054 | 29,570,306 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,747,114 | 9,054 | 25,221,541 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 28,687,467 | 9,054 | 25,142,842 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,583,252 | 9,054 | 25,057,687 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,467,419 | 9,054 | 28,857,235 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,008,619 | 9,054 | 24,491,166 |
| ExactOutSwapRoute(grc20) - fee:3000 | 27,957,624 | 9,054 | 24,421,119 |
| ExactOutSwapRoute(grc20) - fee:500 | 27,862,061 | 9,054 | 24,344,616 |
| BuildSingleHopRoutePath | 202,459 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 52,553,428 | 9,061 | 48,206,355 |
| MultiHop ExactOut (2 hops) | 72,989,313 | 76 | 70,657,048 |
| MultiHop ExactIn (3 hops) | 72,136,372 | 33 | 69,611,792 |
| MultiHop ExactOut (3 hops) | 110,644,705 | 0 | 107,323,126 |
| MultiRoute ExactIn (50:50 split) | 71,455,923 | 0 | 68,870,877 |
| MultiRoute ExactOut (50:50 split) | 96,813,403 | 4 | 93,714,190 |
| Swap (halving, 1 staked tick-cross) | 32,166,135 | 2,813 | 30,474,934 |
| Swap (halving, 10 staked tick-crosses) | 106,371,747 | 3,729 | 101,861,239 |
| Swap (halving, 50 staked tick-crosses) | 445,312,170 | 7,260 | 429,498,667 |
| Swap (staked pool, no staked tick-cross) | 16,475,714 | 0 | 15,526,980 |
| Swap (no halving, 1 staked tick-cross) | 25,970,205 | -7,684 | 24,555,732 |
| Swap (no halving, 10 staked tick-crosses) | 94,196,867 | -7,110 | 90,083,109 |
| Swap (no halving, 50 staked tick-crosses) | 406,562,968 | -5,108 | 391,680,857 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
