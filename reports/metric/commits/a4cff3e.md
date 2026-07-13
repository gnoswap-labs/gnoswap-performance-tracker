| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| TickMathGetSqrtRatioAtTick (minTick) | 1,781,246 | 0 | 1,583,571 |
| TickMathGetSqrtRatioAtTick (maxTick) | 2,190,074 | 0 | 2,035,580 |
| TickMathGetSqrtRatioAtTick (zero) | 357,458 | 0 | 325,234 |
| TickMathGetSqrtRatioAtTick | 1,626,881 | 0 | 1,521,109 |
| TickMathGetTickAtSqrtRatio | 4,092,238 | 0 | 3,765,639 |
| GetLiquidityForAmounts | 3,374,692 | 0 | 3,137,602 |
| GetAmountsForLiquidity | 3,136,384 | 0 | 2,923,208 |
| LiquidityMathAddDelta (positive) | 477,607 | 0 | 430,660 |
| LiquidityMathAddDelta (negative) | 502,027 | 0 | 464,497 |
| LiquidityMathAddDelta | 465,925 | 0 | 430,660 |
| GetAmount0Delta | 3,813,949 | 0 | 3,331,396 |
| GetAmount1Delta | 2,446,448 | 0 | 2,283,199 |
| SwapMathComputeSwapStep | 4,474,660 | 0 | 4,166,469 |
| Propose Community Pool Spend | 3,990,259 | 20,552 | 3,283,893 |
| Propose Parameter Change | 4,605,725 | 19,533 | 3,866,808 |
| Vote | 1,091,316 | 4,486 | 878,948 |
| Execute | 2,712,087 | 76 | 1,387,118 |
| Propose Text | 3,448,155 | 18,334 | 2,884,645 |
| Propose Text with Inactive: 100 | 3,929,136 | 8,501 | 3,387,503 |
| CollectUndelegatedGns (100 delegations, 1 withdraws) | 90,503,996 | 0 | 75,436,590 |
| CollectUndelegatedGns (10 delegations, 10 withdraws) | 10,606,905 | 0 | 8,737,024 |
| CollectUndelegatedGns (10 delegations, 1 withdraws) | 3,112,755 | 0 | 2,462,494 |
| CollectUndelegatedGns (10 delegations, 50 withdraws) | 43,912,905 | 0 | 36,623,824 |
| CollectUndelegatedGns (10 delegations, 5 withdraws) | 6,443,355 | 0 | 5,251,174 |
| CollectUndelegatedGns (1 delegation, 10 withdraws) | 677,937 | 0 | 555,346 |
| CollectUndelegatedGns (1 delegation, 1 withdraws) | 446,385 | 0 | 359,704 |
| CollectUndelegatedGns (1 delegation, 50 withdraws) | 1,707,057 | 0 | 1,424,866 |
| CollectUndelegatedGns (1 delegation, 5 withdraws) | 549,297 | 0 | 446,656 |
| CollectReward (100 delegations, 1 withdraws) | 2,788,740 | 2,387 | 2,007,786 |
| CollectReward (10 delegations, 10 withdraws) | 2,788,557 | 2,375 | 2,007,786 |
| CollectReward (10 delegations, 1 withdraws) | 2,787,978 | 2,375 | 2,007,207 |
| CollectReward (10 delegations, 50 withdraws) | 2,788,557 | 2,375 | 2,007,786 |
| CollectReward (10 delegations, 5 withdraws) | 2,788,070 | 2,375 | 2,007,299 |
| CollectReward (1 delegation, 10 withdraws) | 2,862,783 | 2,447 | 2,007,207 |
| CollectReward (1 delegation, 1 withdraws) | 2,849,453 | 2,447 | 1,994,695 |
| CollectReward (1 delegation, 50 withdraws) | 2,862,875 | 2,447 | 2,007,299 |
| CollectReward (1 delegation, 5 withdraws) | 2,862,783 | 2,447 | 2,007,207 |
| Delegate | 5,428,300 | 38,287 | 2,067,643 |
| Undelegate | 3,337,373 | 840 | 2,423,636 |
| Undelegate (5 delegations, cached external calls) | 14,862,488 | 3,510 | 10,913,350 |
| Delegate (cached external calls) | 3,907,450 | 3,210 | 2,967,066 |
| Undelegate (early exit, 3 of 10 delegations) | 9,761,535 | 2,088 | 7,267,347 |
| Redelegate | 6,405,484 | 1,423 | 4,708,546 |
| Redelegate (50 of 100 delegations, optimized) | 177,683,799 | -118,830 | 133,036,421 |
| Undelegate (50 delegatees, large AVL traversal) | 3,463,456 | 708 | 2,567,880 |
| CollectDepositGns (deposit 1/5, remaining 4) | 4,560,490 | 1,850 | 3,257,408 |
| CollectDepositGns (deposit 2/5, remaining 3) | 4,073,341 | -2,257 | 2,948,319 |
| CollectDepositGns (deposit 3/5, remaining 2) | 4,052,684 | -2,257 | 2,930,971 |
| CollectDepositGns (deposit 4/5, remaining 1) | 4,059,315 | -2,257 | 2,939,525 |
| CollectDepositGns (deposit 5/5, remaining 0) | 4,019,477 | -8,456 | 2,922,717 |
| Launchpad CollectDepositGns | 4,488,953 | -4,155 | 3,218,020 |
| CollectProtocolFee (1 token) | 2,945,663 | 4,477 | 2,151,287 |
| CollectProtocolFee (2 tokens) | 4,305,398 | 8,871 | 3,292,369 |
| CollectProtocolFee (5 tokens) | 8,415,574 | 22,044 | 6,731,237 |
| Launchpad CollectProtocolFee (tokens: 10) | 15,202,424 | 44,289 | 12,417,300 |
| Launchpad CollectRewardByDepositId | 1,702,481 | 2,070 | 1,307,613 |
| Create Launchpad Project | 9,174,626 | 30,724 | 6,162,581 |
| Launchpad DepositGns | 5,440,612 | 24,236 | 3,077,349 |
| Launchpad TransferLeftFromProjectByAdmin | 1,314,187 | 5 | 1,080,738 |
| CreatePool | 6,315,823 | 15,264 | 5,275,567 |
| Mint (fee:3000, wide range) | 27,938,141 | 24,706 | 24,297,341 |
| Swap (gns -> wugnot, fee:500) | 50,822,879 | 734 | 45,242,095 |
| DecreaseLiquidity | 28,018,187 | -2,101 | 24,910,268 |
| IncreaseLiquidity | 24,006,362 | -2,084 | 21,849,278 |
| Mint (bar:foo:500) | 26,034,383 | 24,694 | 22,383,014 |
| CollectFee (with unwrap) | 7,621,872 | 44 | 6,562,916 |
| DecreaseLiquidity (w. Remove) | 23,242,550 | 72 | 20,338,448 |
| Mint (reposition) | 26,840,856 | 8,601 | 24,248,279 |
| SetPoolTier (tier 1) | 6,022,056 | 45,381 | 3,534,431 |
| StakeToken | 18,805,751 | 22,330 | 16,178,104 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 28,654,738 | 9,044 | 23,614,982 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 33,703,839 | 9,148 | 28,278,706 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 28,915,810 | 9,044 | 23,762,463 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 28,580,698 | 9,044 | 23,545,964 |
| ExactInSwapRoute(grc20) - fee:10000 | 27,931,234 | 9,044 | 22,950,809 |
| ExactInSwapRoute(grc20) - fee:100 | 32,999,212 | 9,148 | 27,632,117 |
| ExactInSwapRoute(grc20) - fee:3000 | 28,201,745 | 9,044 | 23,107,082 |
| ExactInSwapRoute(grc20) - fee:500 | 27,876,071 | 9,044 | 22,899,375 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 30,602,451 | 9,044 | 25,447,339 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 35,485,665 | 9,148 | 29,958,302 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 30,731,144 | 9,044 | 25,469,274 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 30,432,060 | 9,044 | 25,287,043 |
| ExactOutSwapRoute(grc20) - fee:10000 | 29,902,414 | 9,044 | 24,805,406 |
| ExactOutSwapRoute(grc20) - fee:100 | 34,804,505 | 9,148 | 29,333,953 |
| ExactOutSwapRoute(grc20) - fee:3000 | 30,040,546 | 9,044 | 24,836,133 |
| ExactOutSwapRoute(grc20) - fee:500 | 29,750,900 | 9,044 | 24,662,694 |
| BuildSingleHopRoutePath | 214,229 | 0 | 48,894 |
| MultiHop ExactIn (2 hops) | 55,319,755 | 9,265 | 47,906,696 |
| MultiHop ExactOut (2 hops) | 77,824,916 | 76 | 71,311,910 |
| MultiHop ExactIn (3 hops) | 76,056,253 | 253 | 69,232,198 |
| MultiHop ExactOut (3 hops) | 118,588,465 | 2 | 108,901,812 |
| MultiRoute ExactIn (50:50 split) | 75,478,482 | 110 | 68,583,023 |
| MultiRoute ExactOut (50:50 split) | 103,276,551 | 4 | 94,512,858 |
| CollectReward (only Internal Reward) | 28,574,137 | 11,491 | 24,879,210 |
| CollectReward 2nd (only Internal Reward) | 28,790,635 | 491 | 25,397,259 |
| CollectReward With External Rewards (1 incentives) | 45,620,875 | 12,948 | 39,984,450 |
| CollectReward With External Rewards 2nd (1 incentives) | 45,553,676 | 484 | 40,294,681 |
| CollectReward With External Rewards (5 incentives) | 111,567,864 | 14,830 | 98,400,855 |
| CollectReward With External Rewards 2nd (5 incentives) | 111,862,988 | 463 | 99,209,402 |
| CreateExternalIncentive | 6,953,005 | 71,224 | 4,451,300 |
| EndExternalIncentive | 3,576,586 | -1,994 | 3,127,034 |
| RegisterInitializer (v1) | 79,533 | 0 | 52,142 |
| RegisterInitializer (v2) | 61,518 | 0 | 54,856 |
