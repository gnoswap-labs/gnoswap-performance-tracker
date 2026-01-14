| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| TickMathGetSqrtRatioAtTick (minTick) | 1,555,468 | 0 | 677,324 |
| TickMathGetSqrtRatioAtTick (maxTick) | 873,832 | 0 | 863,400 |
| TickMathGetSqrtRatioAtTick (zero) | 134,165 | 0 | 134,165 |
| TickMathGetSqrtRatioAtTick | 652,368 | 0 | 641,936 |
| TickMathGetTickAtSqrtRatio | 1,785,434 | 0 | 1,628,730 |
| GetLiquidityForAmounts | 1,442,983 | 0 | 1,422,279 |
| GetAmountsForLiquidity | 1,372,581 | 0 | 1,372,581 |
| LiquidityMathAddDelta (positive) | 220,687 | 0 | 187,647 |
| LiquidityMathAddDelta (negative) | 199,989 | 0 | 199,989 |
| LiquidityMathAddDelta | 187,647 | 0 | 187,647 |
| IsGNOTPath | 11,223 | 0 | 11,223 |
| IsGNOTNativePath | 11,175 | 0 | 11,175 |
| IsGNOTWrappedPath | 11,175 | 0 | 11,175 |
| ExistsUserSendCoins | 266,478 | 0 | 18,206 |
| GetAmount0Delta | 3,912,271 | 0 | 1,486,687 |
| GetAmount1Delta | 1,050,599 | 0 | 1,040,247 |
| SwapMathComputeSwapStep | 1,879,861 | 0 | 1,858,997 |
| Propose Community Pool Spend | 971,856 | 14,171 | 586,016 |
| Propose Parameter Change | 2,188,677 | 14,006 | 1,184,437 |
| Vote | 316,102 | 80 | 195,014 |
| Execute | 3,685,070 | 76 | 567,350 |
| Propose Text | 799,599 | 13,545 | 423,455 |
| CollectUndelegatedGns (100 delegations, 1 withdraws) | 129,357,103 | -5,985,786 | 88,948,261 |
| CollectUndelegatedGns (10 delegations, 10 withdraws) | 17,507,233 | -646,638 | 12,930,733 |
| CollectUndelegatedGns (10 delegations, 1 withdraws) | 3,908,884 | -98,446 | 3,010,234 |
| CollectUndelegatedGns (10 delegations, 50 withdraws) | 77,929,485 | -3,097,764 | 57,006,333 |
| CollectUndelegatedGns (10 delegations, 5 withdraws) | 9,951,044 | -342,165 | 7,417,794 |
| CollectUndelegatedGns (1 delegation, 10 withdraws) | 1,207,406 | -16,653 | 922,639 |
| CollectUndelegatedGns (1 delegation, 1 withdraws) | 641,831 | -6,744 | 423,934 |
| CollectUndelegatedGns (1 delegation, 50 withdraws) | 3,714,742 | -60,754 | 3,132,759 |
| CollectUndelegatedGns (1 delegation, 5 withdraws) | 892,563 | -11,148 | 644,946 |
| CollectReward (100 delegations, 1 withdraws) | 1,365,603 | 2,387 | 813,437 |
| CollectReward (10 delegations, 10 withdraws) | 1,364,375 | 2,375 | 813,437 |
| CollectReward (10 delegations, 1 withdraws) | 1,364,027 | 2,375 | 813,089 |
| CollectReward (10 delegations, 50 withdraws) | 1,364,375 | 2,375 | 813,437 |
| CollectReward (10 delegations, 5 withdraws) | 1,364,086 | 2,375 | 813,148 |
| CollectReward (1 delegation, 10 withdraws) | 2,047,797 | 2,406 | 812,443 |
| CollectReward (1 delegation, 1 withdraws) | 2,042,689 | 2,406 | 807,335 |
| CollectReward (1 delegation, 50 withdraws) | 2,047,856 | 2,406 | 812,502 |
| CollectReward (1 delegation, 5 withdraws) | 2,047,797 | 2,406 | 812,443 |
| Delegate | 8,276,823 | 14,944 | 712,233 |
| Undelegate | 1,715,423 | 1,334 | 552,928 |
| Undelegate (5 delegations, cached external calls) | 3,658,834 | 10,634 | 2,393,243 |
| Delegate (cached external calls) | 1,840,327 | 6,406 | 805,831 |
| Undelegate (early exit, 3 of 10 delegations) | 2,885,645 | 7,017 | 1,764,358 |
| Redelegate | 1,912,340 | 7,524 | 656,209 |
| Redelegate (50 of 100 delegations, optimized) | 10,933,381 | 62,759 | 6,191,945 |
| Undelegate (50 delegatees, large AVL traversal) | 1,987,015 | 1,321 | 599,988 |
| Launchpad CollectDepositGns | 1,956,243 | 45 | 1,008,583 |
| CollectProtocolFee (1 token) | 1,614,401 | 4,418 | 1,039,589 |
| CollectProtocolFee (2 tokens) | 2,312,966 | 8,794 | 1,541,342 |
| CollectProtocolFee (5 tokens) | 4,445,981 | 21,914 | 3,053,663 |
| Launchpad CollectProtocolFee (tokens: 10) | 7,990,649 | 44,069 | 5,553,593 |
| Launchpad CollectRewardByDepositId | 828,102 | 2,028 | 516,086 |
| Create Launchpad Project | 10,371,231 | 28,808 | 1,832,491 |
| Launchpad DepositGns | 6,511,105 | 12,281 | 1,481,888 |
| Launchpad TransferLeftFromProjectByAdmin | 1,268,800 | 5 | 481,124 |
| CreatePool | 8,584,011 | 18,536 | 2,303,731 |
| Mint (fee:3000, wide range) | 14,677,964 | 40,644 | 8,506,398 |
| Swap (gns -> wugnot, fee:500) | 30,815,468 | 19,749 | 20,626,046 |
| DecreaseLiquidity | 12,990,962 | 58 | 10,196,423 |
| IncreaseLiquidity | 10,792,302 | -2,064 | 9,708,038 |
| Mint (bar:foo:500) | 18,083,041 | 40,621 | 7,564,075 |
| Mint (w. GNOT) | 20,443,643 | 39,662 | 9,039,227 |
| IncreaseLiquidity (w. GNOT) | 12,404,769 | 56 | 11,068,129 |
| DecreaseLiquidity (unwrap=false) | 15,767,057 | 6,396 | 10,829,570 |
| CollectFee (with unwrap) | 3,785,521 | 40 | 2,535,802 |
| DecreaseLiquidity (w. Remove) | 13,691,755 | 4,370 | 9,560,236 |
| Mint (reposition) | 9,254,189 | 33,728 | 7,648,989 |
| SetPoolTier (tier 1) | 4,580,771 | 22,221 | 1,497,117 |
| StakeToken | 8,421,645 | 22,593 | 4,760,822 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 28,209,547 | 5,002 | 11,338,523 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 30,258,326 | 7,819 | 13,385,846 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 28,632,526 | 5,004 | 11,355,365 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 28,090,274 | 5,002 | 11,260,962 |
| ExactInSingleSwapRoute(ugnot) - fee:10000 | 29,475,291 | 7,834 | 12,368,437 |
| ExactInSingleSwapRoute(ugnot) - fee:100 | 31,101,128 | 10,655 | 13,961,458 |
| ExactInSingleSwapRoute(ugnot) - fee:3000 | 29,996,093 | 7,836 | 12,472,670 |
| ExactInSingleSwapRoute(ugnot) - fee:500 | 29,345,342 | 7,835 | 12,259,320 |
| ExactInSwapRoute(grc20) - fee:10000 | 27,949,256 | 5,002 | 11,078,232 |
| ExactInSwapRoute(grc20) - fee:100 | 30,004,579 | 7,819 | 13,132,099 |
| ExactInSwapRoute(grc20) - fee:3000 | 28,375,507 | 5,004 | 11,098,346 |
| ExactInSwapRoute(grc20) - fee:500 | 27,836,527 | 5,002 | 11,007,215 |
| ExactInSwapRoute(ugnot) - fee:10000 | 29,215,000 | 7,834 | 12,108,146 |
| ExactInSwapRoute(ugnot) - fee:100 | 30,847,381 | 10,655 | 13,707,711 |
| ExactInSwapRoute(ugnot) - fee:3000 | 29,739,074 | 7,836 | 12,215,651 |
| ExactInSwapRoute(ugnot) - fee:500 | 29,091,595 | 7,835 | 12,005,573 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,999,903 | 5,002 | 12,139,231 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 30,977,945 | 7,819 | 14,115,817 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 29,357,341 | 5,004 | 12,100,964 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,829,822 | 5,002 | 12,021,294 |
| ExactOutSingleSwapRoute(ugnot) - fee:10000 | 29,872,541 | 7,844 | 12,467,301 |
| ExactOutSingleSwapRoute(ugnot) - fee:100 | 31,371,702 | 10,665 | 13,944,078 |
| ExactOutSingleSwapRoute(ugnot) - fee:3000 | 30,298,028 | 7,846 | 12,486,651 |
| ExactOutSingleSwapRoute(ugnot) - fee:500 | 29,671,128 | 7,845 | 12,297,152 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,750,900 | 5,002 | 11,890,228 |
| ExactOutSwapRoute(grc20) - fee:100 | 30,735,486 | 7,819 | 13,873,358 |
| ExactOutSwapRoute(grc20) - fee:3000 | 29,111,610 | 5,004 | 11,855,233 |
| ExactOutSwapRoute(grc20) - fee:500 | 28,587,363 | 5,002 | 11,778,835 |
| ExactOutSwapRoute(ugnot) - fee:10000 | 29,623,538 | 7,844 | 12,218,298 |
| ExactOutSwapRoute(ugnot) - fee:100 | 31,129,243 | 10,665 | 13,701,619 |
| ExactOutSwapRoute(ugnot) - fee:3000 | 30,052,297 | 7,846 | 12,240,920 |
| ExactOutSwapRoute(ugnot) - fee:500 | 29,428,669 | 7,845 | 12,054,693 |
| BuildSingleHopRoutePath | 1,710,230 | 0 | 23,398 |
| MultiHop ExactIn (2 hops) | 31,145,111 | 10,674 | 22,573,569 |
| MultiHop ExactOut (2 hops) | 35,500,586 | 26 | 33,927,440 |
| MultiHop ExactIn (3 hops) | 35,242,788 | 5,709 | 32,922,758 |
| MultiHop ExactOut (3 hops) | 54,229,779 | 14 | 52,086,457 |
| MultiRoute ExactIn (50:50 split) | 35,473,977 | 2,849 | 32,715,572 |
| MultiRoute ExactOut (50:50 split) | 47,871,960 | 2 | 45,233,233 |
| CollectReward (immediately after stake) | 3,150,982 | -6 | 1,965,562 |
| CreateExternalIncentive | 2,795,511 | 28,114 | 1,539,489 |
| EndExternalIncentive | 1,342,842 | -1,988 | 642,522 |
| RegisterInitializer (v1) | 598,333 | 0 | 60,237 |
| RegisterInitializer (v2) | 60,237 | 0 | 60,237 |
