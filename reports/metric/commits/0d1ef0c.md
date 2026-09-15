| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
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
| GetAmount0Delta | 3,274,179 | 0 | 2,977,700 |
| GetAmount1Delta | 2,329,750 | 0 | 2,298,269 |
| SwapMathComputeSwapStep | 4,232,740 | 0 | 4,157,059 |
| Propose Community Pool Spend | 2,762,118 | 23,971 | 2,185,308 |
| Propose Parameter Change | 3,138,788 | 22,943 | 2,644,115 |
| Vote | 1,006,257 | 4,074 | 844,222 |
| Execute | 2,726,276 | -3,321 | 1,511,599 |
| Propose Text | 2,076,575 | 21,744 | 1,676,203 |
| Propose Text with Inactive: 100 | 2,490,239 | 11,912 | 2,173,645 |
| CollectUndelegatedGns (100 delegations, 1 withdraws) | 25,063,819 | 0 | 22,279,393 |
| CollectUndelegatedGns (10 delegations, 10 withdraws) | 4,368,525 | 0 | 3,839,683 |
| CollectUndelegatedGns (10 delegations, 1 withdraws) | 2,329,935 | 0 | 1,942,663 |
| CollectUndelegatedGns (10 delegations, 50 withdraws) | 13,429,225 | 16 | 12,270,883 |
| CollectUndelegatedGns (10 delegations, 5 withdraws) | 3,235,975 | 0 | 2,785,783 |
| CollectUndelegatedGns (1 delegation, 10 withdraws) | 610,698 | 0 | 541,065 |
| CollectUndelegatedGns (1 delegation, 1 withdraws) | 406,839 | 0 | 351,363 |
| CollectUndelegatedGns (1 delegation, 50 withdraws) | 1,516,738 | 0 | 1,384,185 |
| CollectUndelegatedGns (1 delegation, 5 withdraws) | 497,443 | 0 | 435,675 |
| CollectReward (100 delegations, 1 withdraws) | 5,287,435 | 10,205 | 4,455,126 |
| CollectReward (10 delegations, 10 withdraws) | 4,954,660 | 10,120 | 4,132,017 |
| CollectReward (10 delegations, 1 withdraws) | 4,950,868 | 10,120 | 4,128,227 |
| CollectReward (10 delegations, 50 withdraws) | 4,953,589 | 10,120 | 4,130,946 |
| CollectReward (10 delegations, 5 withdraws) | 4,947,661 | 10,120 | 4,125,020 |
| CollectReward (1 delegation, 10 withdraws) | 4,897,612 | 10,192 | 3,999,837 |
| CollectReward (1 delegation, 1 withdraws) | 5,091,319 | 10,192 | 4,190,078 |
| CollectReward (1 delegation, 50 withdraws) | 4,894,405 | 10,192 | 3,996,630 |
| CollectReward (1 delegation, 5 withdraws) | 4,895,558 | 10,192 | 3,997,783 |
| gov/staker CollectReward (1 protocol-fee tokens) | 5,081,570 | 8,169 | 4,186,311 |
| gov/staker CollectReward (2 protocol-fee tokens) | 8,760,471 | -5,029 | 7,577,373 |
| gov/staker CollectReward (3 protocol-fee tokens) | 12,491,294 | -12,073 | 10,873,584 |
| gov/staker CollectReward (4 protocol-fee tokens) | 16,275,118 | -19,117 | 14,209,524 |
| gov/staker CollectReward (4 protocol-fee tokens but zero amount) | 7,445,268 | 0 | 6,256,958 |
| Delegate | 5,323,303 | 48,722 | 2,084,576 |
| Undelegate | 2,535,434 | 2,487 | 1,731,961 |
| Undelegate (5 delegations, cached external calls) | 11,192,514 | 11,505 | 7,681,827 |
| Delegate (cached external calls) | 3,354,498 | 4,809 | 2,511,296 |
| Undelegate (early exit, 3 of 10 delegations) | 7,637,098 | 6,885 | 5,419,491 |
| Redelegate | 4,910,646 | 4,669 | 3,374,743 |
| Redelegate (50 of 100 delegations, optimized) | 145,682,388 | -20,498 | 103,855,966 |
| Undelegate (50 delegatees, large AVL traversal) | 2,819,970 | 2,320 | 1,990,629 |
| CollectDepositGns (deposit 1/5, remaining 4) | 8,228,035 | 3,437 | 6,959,607 |
| CollectDepositGns (deposit 2/5, remaining 3) | 7,890,593 | -670 | 6,739,676 |
| CollectDepositGns (deposit 3/5, remaining 2) | 7,867,388 | -670 | 6,717,872 |
| CollectDepositGns (deposit 4/5, remaining 1) | 7,873,814 | -670 | 6,725,699 |
| CollectDepositGns (deposit 5/5, remaining 0) | 7,718,823 | -6,869 | 6,593,221 |
| Launchpad CollectDepositGns | 8,058,223 | -2,520 | 6,820,610 |
| CollectProtocolFee (1 token) | 4,936,697 | 12,227 | 4,114,168 |
| CollectProtocolFee (2 tokens) | 8,621,109 | 24,276 | 7,350,039 |
| CollectProtocolFee (5 tokens) | 19,814,531 | 60,459 | 17,158,049 |
| Launchpad CollectRewardByDepositId | 3,435,917 | 2,070 | 3,045,961 |
| Create Launchpad Project | 9,153,958 | 37,161 | 6,652,301 |
| Launchpad DepositGns | 6,774,762 | 34,283 | 4,322,434 |
| Launchpad TransferLeftFromProjectByAdmin | 1,381,746 | 41 | 1,188,126 |
| CreatePool | 6,805,880 | 24,958 | 5,932,965 |
| Mint (fee:3000, wide range) | 32,150,893 | 22,675 | 29,903,367 |
| Swap (gns -> wugnot, fee:500) | 47,482,553 | 0 | 44,415,958 |
| DecreaseLiquidity | 25,374,049 | 18 | 23,906,402 |
| IncreaseLiquidity | 23,630,298 | -2,084 | 22,720,600 |
| Mint (bar:foo:500) | 30,227,273 | 22,665 | 27,886,261 |
| CollectFee (with unwrap) | 7,939,925 | 44 | 5,787,562 |
| DecreaseLiquidity (w. Remove) | 22,253,086 | 62 | 19,152,592 |
| Mint (reposition) | 31,061,371 | 8,595 | 29,902,024 |
| SetPoolTier (tier 1) | 4,213,410 | 47,025 | 1,834,429 |
| StakeToken | 10,224,793 | 22,565 | 9,254,522 |
| UintTree Set (0) | 76,563 | 0 | 50,337 |
| UintTree Get (0) | 56,160 | 0 | 53,997 |
| UintTree Set (1) | 57,342 | 0 | 53,281 |
| UintTree Get (1) | 56,160 | 0 | 53,997 |
| UintTree Set (255) | 57,342 | 0 | 53,281 |
| UintTree Get (255) | 56,160 | 0 | 53,997 |
| UintTree Set (256) | 57,342 | 0 | 53,281 |
| UintTree Get (256) | 56,160 | 0 | 53,997 |
| UintTree Set (65535) | 57,342 | 0 | 53,281 |
| UintTree Get (65535) | 56,160 | 0 | 53,997 |
| UintTree Set (4294967295) | 57,342 | 0 | 53,281 |
| UintTree Get (4294967295) | 56,160 | 0 | 53,997 |
| UintTree Set (9223372036854775807) | 57,342 | 0 | 53,281 |
| UintTree Get (9223372036854775807) | 56,160 | 0 | 53,997 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 28,541,082 | 23,269 | 24,730,565 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 33,131,746 | 23,269 | 29,225,885 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 28,605,449 | 23,269 | 24,776,058 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 28,467,604 | 23,269 | 24,657,327 |
| ExactInSwapRoute(grc20) - fee:10000 | 27,779,552 | 23,269 | 23,977,150 |
| ExactInSwapRoute(grc20) - fee:100 | 32,387,520 | 23,269 | 28,489,774 |
| ExactInSwapRoute(grc20) - fee:3000 | 27,852,571 | 23,269 | 24,031,295 |
| ExactInSwapRoute(grc20) - fee:500 | 27,723,378 | 23,269 | 23,921,216 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 30,374,107 | 23,269 | 26,537,771 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 34,815,547 | 23,269 | 30,886,480 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 30,314,490 | 23,269 | 26,459,048 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 30,210,193 | 23,269 | 26,373,865 |
| ExactOutSwapRoute(grc20) - fee:10000 | 29,635,612 | 23,269 | 25,807,396 |
| ExactOutSwapRoute(grc20) - fee:100 | 34,094,356 | 23,269 | 30,173,409 |
| ExactOutSwapRoute(grc20) - fee:3000 | 29,584,647 | 23,269 | 25,737,325 |
| ExactOutSwapRoute(grc20) - fee:500 | 29,489,002 | 23,269 | 25,660,794 |
| BuildSingleHopRoutePath | 204,343 | 0 | 46,890 |
| MultiHop ExactIn (2 hops) | 53,600,974 | 23,276 | 48,958,907 |
| MultiHop ExactOut (2 hops) | 73,396,506 | 126 | 71,052,657 |
| MultiHop ExactIn (3 hops) | 73,385,238 | 33 | 70,827,722 |
| MultiHop ExactOut (3 hops) | 111,426,877 | 0 | 108,100,787 |
| MultiRoute ExactIn (50:50 split) | 73,008,691 | 0 | 70,389,984 |
| MultiRoute ExactOut (50:50 split) | 97,888,084 | 4 | 94,778,209 |
| Swap (halving, 10 staked tick-crosses) | 99,875,065 | 3,729 | 95,623,692 |
| Swap (halving, 1 staked tick-cross) | 31,615,264 | 2,813 | 29,950,680 |
| Swap (halving, 50 staked tick-crosses) | 411,401,972 | 7,259 | 396,905,116 |
| Incentive Index Add (0 existing siblings) | 84,351 | 0 | 76,404 |
| Incentive Index Add (1 existing siblings) | 107,503 | 0 | 103,532 |
| Incentive Index Remove (1 same-start incentives) | 160,052 | 0 | 155,812 |
| Incentive Index Iterate (1 same-start incentives) | 194,027 | 0 | 112,548 |
| Incentive Index Early Stop (1 same-start incentives) | 109,231 | 0 | 105,738 |
| Incentive Index Add (10 existing siblings) | 107,943 | 0 | 103,892 |
| Incentive Index Remove (10 same-start incentives) | 165,813 | 0 | 160,280 |
| Incentive Index Iterate (10 same-start incentives) | 130,652 | 0 | 127,047 |
| Incentive Index Early Stop (10 same-start incentives) | 109,366 | 0 | 105,873 |
| Incentive Index Add (50 existing siblings) | 109,868 | 0 | 105,492 |
| Incentive Index Remove (50 same-start incentives) | 356,888 | 0 | 344,588 |
| Incentive Index Iterate (50 same-start incentives) | 195,092 | 0 | 191,487 |
| Incentive Index Early Stop (50 same-start incentives) | 109,966 | 0 | 106,473 |
| Incentive Index Add (100 existing siblings) | 112,249 | 0 | 107,492 |
| Incentive Index Remove (100 same-start incentives) | 595,119 | 0 | 574,388 |
| Incentive Index Iterate (100 same-start incentives) | 275,642 | 0 | 272,037 |
| Incentive Index Early Stop (100 same-start incentives) | 110,716 | 0 | 107,223 |
| Swap (no halving, 10 staked tick-crosses) | 87,696,960 | -7,110 | 83,843,146 |
| Swap (no halving, 1 staked tick-cross) | 25,417,776 | -7,684 | 24,030,466 |
| Swap (no halving, 50 staked tick-crosses) | 372,643,305 | -5,109 | 359,078,650 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
