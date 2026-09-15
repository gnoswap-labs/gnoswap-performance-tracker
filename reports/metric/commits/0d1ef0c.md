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
| Propose Community Pool Spend | 2,772,349 | 23,971 | 2,190,878 |
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
| CollectReward (100 delegations, 1 withdraws) | 5,305,321 | 10,205 | 4,471,836 |
| CollectReward (10 delegations, 10 withdraws) | 4,972,546 | 10,120 | 4,148,727 |
| CollectReward (10 delegations, 1 withdraws) | 4,968,754 | 10,120 | 4,144,937 |
| CollectReward (10 delegations, 50 withdraws) | 4,971,475 | 10,120 | 4,147,656 |
| CollectReward (10 delegations, 5 withdraws) | 4,965,547 | 10,120 | 4,141,730 |
| CollectReward (1 delegation, 10 withdraws) | 4,915,498 | 10,192 | 4,016,547 |
| CollectReward (1 delegation, 1 withdraws) | 5,109,205 | 10,192 | 4,206,788 |
| CollectReward (1 delegation, 50 withdraws) | 4,912,291 | 10,192 | 4,013,340 |
| CollectReward (1 delegation, 5 withdraws) | 4,913,444 | 10,192 | 4,014,493 |
| gov/staker CollectReward (1 protocol-fee tokens) | 5,105,826 | 8,169 | 4,208,778 |
| gov/staker CollectReward (2 protocol-fee tokens) | 8,807,931 | -5,029 | 7,622,307 |
| gov/staker CollectReward (3 protocol-fee tokens) | 12,562,747 | -12,073 | 10,940,985 |
| gov/staker CollectReward (4 protocol-fee tokens) | 16,370,301 | -19,117 | 14,299,392 |
| gov/staker CollectReward (4 protocol-fee tokens but zero amount) | 7,445,268 | 0 | 6,256,958 |
| Delegate | 5,323,303 | 48,722 | 2,084,576 |
| Undelegate | 2,535,434 | 2,487 | 1,731,961 |
| Undelegate (5 delegations, cached external calls) | 11,192,514 | 11,505 | 7,681,827 |
| Delegate (cached external calls) | 3,354,498 | 4,809 | 2,511,296 |
| Undelegate (early exit, 3 of 10 delegations) | 7,637,098 | 6,885 | 5,419,491 |
| Redelegate | 4,910,646 | 4,669 | 3,374,743 |
| Redelegate (50 of 100 delegations, optimized) | 145,682,388 | -20,498 | 103,855,966 |
| Undelegate (50 delegatees, large AVL traversal) | 2,819,970 | 2,320 | 1,990,629 |
| CollectDepositGns (deposit 1/5, remaining 4) | 8,245,300 | 3,437 | 6,972,666 |
| CollectDepositGns (deposit 2/5, remaining 3) | 7,904,465 | -670 | 6,752,735 |
| CollectDepositGns (deposit 3/5, remaining 2) | 7,881,260 | -670 | 6,730,931 |
| CollectDepositGns (deposit 4/5, remaining 1) | 7,887,686 | -670 | 6,738,758 |
| CollectDepositGns (deposit 5/5, remaining 0) | 7,732,695 | -6,869 | 6,606,280 |
| Launchpad CollectDepositGns | 8,075,488 | -2,520 | 6,833,669 |
| CollectProtocolFee (1 token) | 4,960,427 | 12,227 | 4,136,635 |
| CollectProtocolFee (2 tokens) | 8,668,569 | 24,276 | 7,394,973 |
| CollectProtocolFee (5 tokens) | 19,933,181 | 60,459 | 17,270,384 |
| Launchpad CollectProtocolFee (tokens: 10) | 40,012,909 | 120,788 | 34,932,250 |
| Launchpad CollectRewardByDepositId | 3,443,827 | 2,070 | 3,053,450 |
| Create Launchpad Project | 9,189,756 | 37,161 | 6,682,257 |
| Launchpad DepositGns | 6,774,762 | 34,283 | 4,322,434 |
| Launchpad TransferLeftFromProjectByAdmin | 1,389,656 | 41 | 1,195,615 |
| CreatePool | 6,822,106 | 24,958 | 5,944,123 |
| Mint (fee:3000, wide range) | 32,196,918 | 22,675 | 29,947,999 |
| Swap (gns -> wugnot, fee:500) | 47,506,419 | 0 | 44,438,256 |
| DecreaseLiquidity | 25,389,869 | 18 | 23,921,380 |
| IncreaseLiquidity | 23,693,578 | -2,084 | 22,780,512 |
| Mint (bar:foo:500) | 30,290,553 | 22,665 | 27,946,173 |
| CollectFee (with unwrap) | 7,939,925 | 44 | 5,787,562 |
| DecreaseLiquidity (w. Remove) | 22,268,906 | 62 | 19,167,570 |
| Mint (reposition) | 31,124,651 | 8,595 | 29,961,936 |
| SetPoolTier (tier 1) | 4,212,621 | 47,025 | 1,834,429 |
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
| ExactInSingleSwapRoute(grc20) - fee:10000 | 28,600,792 | 23,269 | 24,786,355 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 33,191,456 | 23,269 | 29,281,675 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 28,665,159 | 23,269 | 24,831,848 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 28,527,314 | 23,269 | 24,713,117 |
| ExactInSwapRoute(grc20) - fee:10000 | 27,839,262 | 23,269 | 24,032,940 |
| ExactInSwapRoute(grc20) - fee:100 | 32,447,230 | 23,269 | 28,545,564 |
| ExactInSwapRoute(grc20) - fee:3000 | 27,912,281 | 23,269 | 24,087,085 |
| ExactInSwapRoute(grc20) - fee:500 | 27,783,088 | 23,269 | 23,977,006 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 30,433,817 | 23,269 | 26,593,561 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 34,875,257 | 23,269 | 30,942,270 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 30,374,200 | 23,269 | 26,514,838 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 30,269,903 | 23,269 | 26,429,655 |
| ExactOutSwapRoute(grc20) - fee:10000 | 29,695,322 | 23,269 | 25,863,186 |
| ExactOutSwapRoute(grc20) - fee:100 | 34,154,066 | 23,269 | 30,229,199 |
| ExactOutSwapRoute(grc20) - fee:3000 | 29,644,357 | 23,269 | 25,793,115 |
| ExactOutSwapRoute(grc20) - fee:500 | 29,548,712 | 23,269 | 25,716,584 |
| BuildSingleHopRoutePath | 204,343 | 0 | 46,890 |
| MultiHop ExactIn (2 hops) | 53,688,292 | 23,276 | 49,040,984 |
| MultiHop ExactOut (2 hops) | 73,512,375 | 126 | 71,160,870 |
| MultiHop ExactIn (3 hops) | 73,512,895 | 33 | 70,947,244 |
| MultiHop ExactOut (3 hops) | 111,598,116 | 0 | 108,261,423 |
| MultiRoute ExactIn (50:50 split) | 73,139,094 | 0 | 70,511,087 |
| MultiRoute ExactOut (50:50 split) | 98,046,249 | 4 | 94,925,448 |
| CollectReward (only Internal Reward) | 13,994,682 | 25,346 | 12,477,679 |
| CollectReward 2nd (only Internal Reward) | 13,723,878 | 90 | 12,678,195 |
| staker CollectReward (1 external-incentive token) | 13,351,282 | 24,234 | 12,023,116 |
| staker CollectReward (2 external-incentive tokens) | 21,166,878 | 9,384 | 19,746,373 |
| staker CollectReward (3 external-incentive tokens) | 29,263,261 | 9,778 | 27,313,652 |
| staker CollectReward (4 external-incentive tokens) | 37,513,159 | 10,376 | 34,994,965 |
| storage growth: CollectReward 20 staked positions | 15,257,509 | 112 | 14,345,500 |
| storage growth: CollectReward 40 staked positions | 15,719,846 | 0 | 14,818,382 |
| storage growth: CollectReward 60 staked positions | 15,722,340 | 0 | 14,820,876 |
| storage growth: CollectReward 80 staked positions | 15,853,617 | 0 | 14,944,796 |
| storage growth: CollectReward 100 staked positions | 15,839,312 | 0 | 14,930,491 |
| CollectReward With External Rewards (1 incentives) | 22,623,097 | 34,238 | 20,474,054 |
| CollectReward With External Rewards 2nd (1 incentives) | 21,854,745 | 96 | 20,301,343 |
| CollectReward With External Rewards (5 incentives) | 56,193,191 | 69,257 | 51,533,507 |
| CollectReward With External Rewards 2nd (5 incentives) | 53,693,220 | 276 | 50,134,085 |
| CollectReward with Warmup Range (30% ~ 30%) | 14,032,682 | 25,328 | 12,509,738 |
| CollectReward with Warmup Range (30% ~ 50%) | 15,772,979 | 108 | 14,679,191 |
| CollectReward with Warmup Range (30% ~ 70%) | 17,851,076 | 18 | 16,709,709 |
| CollectReward with Warmup Range (30% ~ 100%) | 19,953,124 | 18 | 18,764,174 |
| CollectReward with Warmup Range (100% ~) | 13,396,944 | -6 | 12,431,883 |
| CollectReward with Warmup Range 2nd (100% ~) | 13,281,331 | 0 | 12,316,291 |
| CreateExternalIncentive | 4,134,244 | 66,631 | 3,444,751 |
| EndExternalIncentive | 2,713,910 | -1,979 | 2,493,213 |
| Swap (halving, 10 staked tick-crosses) | 99,907,231 | 3,729 | 95,653,648 |
| Swap (halving, 1 staked tick-cross) | 31,646,904 | 2,813 | 29,980,636 |
| Swap (halving, 50 staked tick-crosses) | 411,433,612 | 7,259 | 396,935,072 |
| StakedLiquidity Control SameTimestamp Stake | 10,296,240 | 22,606 | 9,272,507 |
| StakedLiquidity Control SameTimestamp Unstake | 9,310,836 | 5,726 | 8,544,208 |
| StakedLiquidity Lifecycle InitialStake | 13,767,075 | 32,197 | 12,380,700 |
| StakedLiquidity Lifecycle Unstake 1 | 11,293,413 | -86 | 10,436,397 |
| Swap (no halving, 10 staked tick-crosses) | 87,729,126 | -7,110 | 83,873,102 |
| Swap (no halving, 1 staked tick-cross) | 25,449,416 | -7,684 | 24,060,422 |
| Swap (no halving, 50 staked tick-crosses) | 372,674,945 | -5,109 | 359,108,606 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
