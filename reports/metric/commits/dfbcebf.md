| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| TickMathGetSqrtRatioAtTick (minTick) | 1,796,156 | 0 | 1,564,855 |
| TickMathGetSqrtRatioAtTick (maxTick) | 2,153,780 | 0 | 2,014,557 |
| TickMathGetSqrtRatioAtTick (zero) | 327,274 | 0 | 301,208 |
| TickMathGetSqrtRatioAtTick | 1,599,994 | 0 | 1,497,962 |
| TickMathGetTickAtSqrtRatio | 4,048,216 | 0 | 3,713,107 |
| GetLiquidityForAmounts | 3,365,129 | 0 | 3,126,606 |
| GetAmountsForLiquidity | 3,132,189 | 0 | 2,919,489 |
| LiquidityMathAddDelta (positive) | 475,326 | 0 | 426,230 |
| LiquidityMathAddDelta (negative) | 496,669 | 0 | 460,071 |
| LiquidityMathAddDelta | 460,563 | 0 | 426,230 |
| GetAmount0Delta | 3,799,290 | 0 | 3,326,245 |
| GetAmount1Delta | 2,439,253 | 0 | 2,275,741 |
| SwapMathComputeSwapStep | 4,458,177 | 0 | 4,152,456 |
| Propose Community Pool Spend | 3,991,609 | 20,552 | 3,283,927 |
| Propose Parameter Change | 4,606,979 | 19,533 | 3,866,928 |
| Vote | 1,091,732 | 4,486 | 879,296 |
| Execute | 2,673,536 | 76 | 1,387,571 |
| Propose Text | 3,449,358 | 18,334 | 2,884,765 |
| Propose Text with Inactive: 100 | 3,929,650 | 8,501 | 3,387,797 |
| CollectUndelegatedGns (100 delegations, 1 withdraws) | 90,514,807 | 0 | 75,445,377 |
| CollectUndelegatedGns (10 delegations, 10 withdraws) | 10,608,086 | 0 | 8,737,981 |
| CollectUndelegatedGns (10 delegations, 1 withdraws) | 3,113,936 | 0 | 2,463,451 |
| CollectUndelegatedGns (10 delegations, 50 withdraws) | 43,914,086 | 0 | 36,624,781 |
| CollectUndelegatedGns (10 delegations, 5 withdraws) | 6,444,536 | 0 | 5,252,131 |
| CollectUndelegatedGns (1 delegation, 10 withdraws) | 678,155 | 0 | 555,520 |
| CollectUndelegatedGns (1 delegation, 1 withdraws) | 446,603 | 0 | 359,878 |
| CollectUndelegatedGns (1 delegation, 50 withdraws) | 1,707,275 | 0 | 1,425,040 |
| CollectUndelegatedGns (1 delegation, 5 withdraws) | 549,515 | 0 | 446,830 |
| CollectReward (100 delegations, 1 withdraws) | 2,783,774 | 2,387 | 2,003,375 |
| CollectReward (10 delegations, 10 withdraws) | 2,783,618 | 2,375 | 2,003,375 |
| CollectReward (10 delegations, 1 withdraws) | 2,783,039 | 2,375 | 2,002,796 |
| CollectReward (10 delegations, 50 withdraws) | 2,783,618 | 2,375 | 2,003,375 |
| CollectReward (10 delegations, 5 withdraws) | 2,783,131 | 2,375 | 2,002,888 |
| CollectReward (1 delegation, 10 withdraws) | 2,847,611 | 2,447 | 2,002,796 |
| CollectReward (1 delegation, 1 withdraws) | 2,834,281 | 2,447 | 1,990,284 |
| CollectReward (1 delegation, 50 withdraws) | 2,847,703 | 2,447 | 2,002,888 |
| CollectReward (1 delegation, 5 withdraws) | 2,847,611 | 2,447 | 2,002,796 |
| Delegate | 5,405,454 | 38,283 | 2,066,319 |
| Undelegate | 3,325,735 | 840 | 2,422,309 |
| Undelegate (5 delegations, cached external calls) | 14,854,587 | 3,512 | 10,906,019 |
| Delegate (cached external calls) | 3,906,164 | 3,210 | 2,965,829 |
| Undelegate (early exit, 3 of 10 delegations) | 9,757,593 | 2,088 | 7,263,627 |
| Redelegate | 6,395,570 | 1,423 | 4,708,551 |
| Redelegate (50 of 100 delegations, optimized) | 177,625,731 | -118,830 | 132,981,968 |
| Undelegate (50 delegatees, large AVL traversal) | 3,462,024 | 708 | 2,566,553 |
| CollectDepositGns (deposit 1/5, remaining 4) | 4,559,889 | 1,852 | 3,256,463 |
| CollectDepositGns (deposit 2/5, remaining 3) | 4,072,626 | -2,257 | 2,947,374 |
| CollectDepositGns (deposit 3/5, remaining 2) | 4,051,969 | -2,257 | 2,930,026 |
| CollectDepositGns (deposit 4/5, remaining 1) | 4,058,600 | -2,257 | 2,938,580 |
| CollectDepositGns (deposit 5/5, remaining 0) | 4,018,762 | -8,456 | 2,921,772 |
| Launchpad CollectDepositGns | 4,491,385 | -4,155 | 3,217,075 |
| CollectProtocolFee (1 token) | 2,944,034 | 4,477 | 2,147,146 |
| CollectProtocolFee (2 tokens) | 4,300,613 | 8,871 | 3,285,405 |
| CollectProtocolFee (5 tokens) | 8,401,303 | 22,044 | 6,715,804 |
| Launchpad CollectProtocolFee (tokens: 10) | 15,172,298 | 44,289 | 12,387,752 |
| Launchpad CollectRewardByDepositId | 1,702,965 | 2,070 | 1,307,790 |
| Create Launchpad Project | 9,157,051 | 30,726 | 6,173,693 |
| Launchpad DepositGns | 5,409,315 | 24,232 | 3,076,478 |
| Launchpad TransferLeftFromProjectByAdmin | 1,315,024 | 5 | 1,080,750 |
| CreatePool | 6,240,156 | 15,264 | 5,194,223 |
| Mint (fee:3000, wide range) | 27,806,645 | 24,702 | 24,167,575 |
| Swap (gns -> wugnot, fee:500) | 50,432,095 | 736 | 44,939,325 |
| DecreaseLiquidity | 27,906,318 | -2,101 | 24,815,335 |
| IncreaseLiquidity | 23,826,803 | -2,084 | 21,699,516 |
| Mint (bar:foo:500) | 25,884,103 | 24,694 | 22,244,752 |
| CollectFee (with unwrap) | 7,608,062 | 46 | 6,548,276 |
| DecreaseLiquidity (w. Remove) | 23,134,421 | 72 | 20,245,291 |
| Mint (reposition) | 26,687,147 | 8,623 | 24,118,896 |
| SetPoolTier (tier 1) | 6,001,610 | 45,381 | 3,536,934 |
| StakeToken | 18,724,794 | 22,344 | 16,107,787 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 28,503,126 | 9,046 | 23,514,464 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 33,504,925 | 9,150 | 28,142,826 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 28,766,891 | 9,046 | 23,662,492 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 28,425,859 | 9,046 | 23,445,977 |
| ExactInSwapRoute(grc20) - fee:10000 | 27,780,342 | 9,046 | 22,850,995 |
| ExactInSwapRoute(grc20) - fee:100 | 32,801,018 | 9,150 | 27,496,941 |
| ExactInSwapRoute(grc20) - fee:3000 | 28,053,546 | 9,046 | 23,007,815 |
| ExactInSwapRoute(grc20) - fee:500 | 27,721,952 | 9,046 | 22,800,092 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 30,457,560 | 9,046 | 25,352,149 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 35,290,831 | 9,150 | 29,827,219 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 30,582,377 | 9,046 | 25,374,084 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 30,279,345 | 9,046 | 25,191,853 |
| ExactOutSwapRoute(grc20) - fee:10000 | 29,758,243 | 9,046 | 24,710,920 |
| ExactOutSwapRoute(grc20) - fee:100 | 34,610,391 | 9,150 | 29,203,574 |
| ExactOutSwapRoute(grc20) - fee:3000 | 29,892,499 | 9,046 | 24,741,647 |
| ExactOutSwapRoute(grc20) - fee:500 | 29,598,905 | 9,046 | 24,568,208 |
| BuildSingleHopRoutePath | 214,235 | 0 | 48,894 |
| MultiHop ExactIn (2 hops) | 55,022,302 | 9,266 | 47,683,640 |
| MultiHop ExactOut (2 hops) | 77,355,339 | 73 | 70,926,892 |
| MultiHop ExactIn (3 hops) | 75,698,988 | 253 | 68,940,287 |
| MultiHop ExactOut (3 hops) | 117,878,620 | 0 | 108,322,104 |
| MultiRoute ExactIn (50:50 split) | 75,123,237 | 110 | 68,292,763 |
| MultiRoute ExactOut (50:50 split) | 102,689,319 | 4 | 94,033,436 |
| CollectReward (only Internal Reward) | 28,572,104 | 11,489 | 24,879,572 |
| CollectReward 2nd (only Internal Reward) | 28,792,286 | 491 | 25,397,621 |
| CollectReward With External Rewards (1 incentives) | 45,619,800 | 12,935 | 39,985,476 |
| CollectReward With External Rewards 2nd (1 incentives) | 45,556,146 | 484 | 40,295,620 |
| CollectReward With External Rewards (5 incentives) | 111,569,961 | 14,817 | 98,404,189 |
| CollectReward With External Rewards 2nd (5 incentives) | 111,868,570 | 463 | 99,212,649 |
| CreateExternalIncentive | 6,910,776 | 71,220 | 4,448,572 |
| EndExternalIncentive | 3,576,741 | -1,994 | 3,127,059 |
| RegisterInitializer (v1) | 79,533 | 0 | 52,142 |
| RegisterInitializer (v2) | 61,518 | 0 | 54,856 |
