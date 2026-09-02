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
| Propose Community Pool Spend | 2,841,466 | 23,967 | 2,248,740 |
| Propose Parameter Change | 3,396,269 | 22,939 | 2,830,388 |
| Vote | 1,023,785 | 4,486 | 860,873 |
| Execute | 2,855,330 | -3,317 | 1,674,343 |
| Propose Text | 2,337,258 | 21,740 | 1,861,736 |
| Propose Text with Inactive: 100 | 2,698,939 | 11,910 | 2,378,857 |
| CollectUndelegatedGns (100 delegations, 1 withdraws) | 25,137,430 | 0 | 22,353,363 |
| CollectUndelegatedGns (10 delegations, 10 withdraws) | 4,375,902 | 0 | 3,847,077 |
| CollectUndelegatedGns (10 delegations, 1 withdraws) | 2,337,312 | 0 | 1,950,057 |
| CollectUndelegatedGns (10 delegations, 50 withdraws) | 13,436,602 | 18 | 12,278,277 |
| CollectUndelegatedGns (10 delegations, 5 withdraws) | 3,243,352 | 0 | 2,793,177 |
| CollectUndelegatedGns (1 delegation, 10 withdraws) | 611,415 | 0 | 541,799 |
| CollectUndelegatedGns (1 delegation, 1 withdraws) | 407,556 | 0 | 352,097 |
| CollectUndelegatedGns (1 delegation, 50 withdraws) | 1,517,455 | 0 | 1,384,919 |
| CollectUndelegatedGns (1 delegation, 5 withdraws) | 498,160 | 0 | 436,409 |
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
| Delegate | 4,987,438 | 38,285 | 1,942,824 |
| Undelegate | 2,279,183 | 840 | 1,586,279 |
| Undelegate (5 delegations, cached external calls) | 9,705,629 | 3,510 | 6,778,953 |
| Delegate (cached external calls) | 3,046,836 | 3,210 | 2,323,417 |
| Undelegate (early exit, 3 of 10 delegations) | 6,656,603 | 2,088 | 4,833,951 |
| Redelegate | 4,363,297 | 1,423 | 3,049,928 |
| Redelegate (50 of 100 delegations, optimized) | 123,363,959 | -118,826 | 90,714,642 |
| Clean delegation snapshots (1000 stale proposals) | 456,195,760 | -648,227 | 379,155,441 |
| Undelegate (50 delegatees, large AVL traversal) | 2,459,132 | 708 | 1,789,243 |
| CollectDepositGns (deposit 1/5, remaining 4) | 7,454,961 | 1,850 | 6,397,847 |
| CollectDepositGns (deposit 2/5, remaining 3) | 7,070,841 | -2,257 | 6,124,356 |
| CollectDepositGns (deposit 3/5, remaining 2) | 7,047,439 | -2,257 | 6,103,339 |
| CollectDepositGns (deposit 4/5, remaining 1) | 7,052,885 | -2,257 | 6,111,170 |
| CollectDepositGns (deposit 5/5, remaining 0) | 6,928,220 | -8,456 | 6,009,571 |
| Launchpad CollectDepositGns | 7,328,159 | -4,155 | 6,300,672 |
| CollectProtocolFee (1 token) | 3,561,082 | 4,426 | 2,909,586 |
| CollectProtocolFee (2 tokens) | 5,622,664 | 8,750 | 4,749,453 |
| CollectProtocolFee (5 tokens) | 11,846,105 | 21,724 | 10,283,758 |
| Launchpad CollectRewardByDepositId | 3,263,200 | 2,070 | 2,918,983 |
| Create Launchpad Project | 8,480,892 | 30,768 | 6,109,705 |
| Launchpad DepositGns | 6,280,064 | 24,246 | 4,101,397 |
| Launchpad TransferLeftFromProjectByAdmin | 1,260,646 | 41 | 1,072,335 |
| CreatePool | 6,518,657 | 15,225 | 5,756,852 |
| Mint (fee:3000, wide range) | 31,157,145 | 22,697 | 28,969,506 |
| Swap (gns -> wugnot, fee:500) | 46,742,928 | 6 | 43,998,407 |
| DecreaseLiquidity | 26,805,514 | -2,101 | 25,262,792 |
| IncreaseLiquidity | 22,740,619 | -2,084 | 21,894,022 |
| Mint (bar:foo:500) | 29,339,001 | 22,684 | 27,057,482 |
| CollectFee (with unwrap) | 8,773,085 | 44 | 6,797,619 |
| DecreaseLiquidity (w. Remove) | 23,565,199 | 72 | 20,621,410 |
| Mint (reposition) | 30,166,974 | 8,609 | 29,073,291 |
| SetPoolTier (tier 1) | 3,922,918 | 47,025 | 1,837,357 |
| StakeToken | 10,632,333 | 29,035 | 9,713,627 |
| UintTree Set (0) | 71,965 | 0 | 50,305 |
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
| ExactInSingleSwapRoute(grc20) - fee:10000 | 27,371,132 | 9,060 | 23,999,979 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,969,454 | 9,060 | 28,503,105 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 27,438,235 | 9,060 | 24,048,262 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 27,301,985 | 9,060 | 23,931,071 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,609,602 | 9,060 | 23,246,564 |
| ExactInSwapRoute(grc20) - fee:100 | 31,225,228 | 9,060 | 27,766,994 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,685,357 | 9,060 | 23,303,499 |
| ExactInSwapRoute(grc20) - fee:500 | 26,557,759 | 9,060 | 23,194,960 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 29,202,936 | 9,060 | 25,805,964 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,646,808 | 9,060 | 30,157,449 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 29,146,055 | 9,060 | 25,730,031 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 29,043,353 | 9,060 | 25,646,388 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,464,441 | 9,060 | 25,075,589 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,925,617 | 9,060 | 29,444,378 |
| ExactOutSwapRoute(grc20) - fee:3000 | 28,416,212 | 9,060 | 25,008,308 |
| ExactOutSwapRoute(grc20) - fee:500 | 28,322,162 | 9,060 | 24,933,317 |
| BuildSingleHopRoutePath | 201,196 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 52,850,738 | 9,073 | 48,681,537 |
| MultiHop ExactOut (2 hops) | 74,085,299 | 76 | 71,840,804 |
| MultiHop ExactIn (3 hops) | 73,055,743 | 45 | 70,660,531 |
| MultiHop ExactOut (3 hops) | 112,987,139 | 0 | 109,784,338 |
| MultiRoute ExactIn (50:50 split) | 72,383,193 | 6 | 69,927,547 |
| MultiRoute ExactOut (50:50 split) | 98,450,990 | 4 | 95,478,363 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
