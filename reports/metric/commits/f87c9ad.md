| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| TickMathGetSqrtRatioAtTick (minTick) | 1,695,130 | 0 | 1,571,470 |
| TickMathGetSqrtRatioAtTick (maxTick) | 2,029,277 | 0 | 2,022,644 |
| TickMathGetSqrtRatioAtTick (zero) | 309,295 | 0 | 309,295 |
| TickMathGetSqrtRatioAtTick | 1,507,990 | 0 | 1,506,049 |
| TickMathGetTickAtSqrtRatio | 3,782,961 | 0 | 3,721,194 |
| GetLiquidityForAmounts | 3,154,763 | 0 | 3,134,693 |
| GetAmountsForLiquidity | 2,936,903 | 0 | 2,927,576 |
| LiquidityMathAddDelta (positive) | 449,062 | 0 | 434,317 |
| LiquidityMathAddDelta (negative) | 468,158 | 0 | 468,158 |
| LiquidityMathAddDelta | 434,317 | 0 | 434,317 |
| GetAmount0Delta | 3,591,016 | 0 | 3,332,860 |
| GetAmount1Delta | 2,290,240 | 0 | 2,282,356 |
| SwapMathComputeSwapStep | 4,175,388 | 0 | 4,159,071 |
| Propose Community Pool Spend | 3,107,172 | 20,539 | 2,744,037 |
| Propose Parameter Change | 3,537,055 | 19,520 | 3,328,117 |
| Vote | 936,575 | 4,490 | 868,718 |
| Execute | 1,571,352 | 76 | 1,330,410 |
| Propose Text | 2,463,380 | 18,321 | 2,346,587 |
| Propose Text with Inactive: 100 | 2,964,452 | 8,501 | 2,842,961 |
| CollectUndelegatedGns (100 delegations, 1 withdraws) | 74,808,734 | 0 | 74,531,438 |
| CollectUndelegatedGns (10 delegations, 10 withdraws) | 8,689,682 | 0 | 8,633,126 |
| CollectUndelegatedGns (10 delegations, 1 withdraws) | 2,430,464 | 0 | 2,373,986 |
| CollectUndelegatedGns (10 delegations, 50 withdraws) | 36,508,082 | 0 | 36,451,526 |
| CollectUndelegatedGns (10 delegations, 5 withdraws) | 5,212,304 | 0 | 5,155,826 |
| CollectUndelegatedGns (1 delegation, 10 withdraws) | 579,640 | 0 | 546,760 |
| CollectUndelegatedGns (1 delegation, 1 withdraws) | 385,537 | 0 | 352,657 |
| CollectUndelegatedGns (1 delegation, 50 withdraws) | 1,442,320 | 0 | 1,409,440 |
| CollectUndelegatedGns (1 delegation, 5 withdraws) | 471,805 | 0 | 438,925 |
| Delegate | 2,918,030 | 38,061 | 1,995,644 |
| Undelegate | 2,539,434 | 1,025 | 2,364,102 |
| Undelegate (5 delegations, cached external calls) | 10,830,339 | 3,510 | 10,665,906 |
| Delegate (cached external calls) | 3,061,545 | 3,210 | 2,895,708 |
| Undelegate (early exit, 3 of 10 delegations) | 7,240,549 | 2,088 | 7,109,749 |
| Redelegate | 4,812,813 | 1,608 | 4,602,273 |
| Redelegate (50 of 100 delegations, optimized) | 130,731,085 | -118,837 | 130,152,622 |
| Undelegate (50 delegatees, large AVL traversal) | 2,642,779 | 708 | 2,511,892 |
| CollectDepositGns (deposit 1/5, remaining 4) | 3,395,525 | 1,851 | 3,181,349 |
| CollectDepositGns (deposit 2/5, remaining 3) | 3,052,614 | -2,072 | 2,882,742 |
| CollectDepositGns (deposit 3/5, remaining 2) | 3,033,184 | -2,257 | 2,865,400 |
| CollectDepositGns (deposit 4/5, remaining 1) | 3,040,142 | -2,257 | 2,873,951 |
| CollectDepositGns (deposit 5/5, remaining 0) | 3,003,608 | -8,456 | 2,857,226 |
| Launchpad CollectDepositGns | 3,337,021 | -4,154 | 3,140,581 |
| Launchpad CollectRewardByDepositId | 1,377,918 | 2,071 | 1,285,554 |
| Create Launchpad Project | 5,072,640 | 30,678 | 4,208,799 |
| Launchpad DepositGns | 3,738,427 | 24,048 | 3,017,827 |
| Launchpad TransferLeftFromProjectByAdmin | 1,147,508 | 5 | 1,054,178 |
| CreatePool | 5,598,546 | 15,264 | 5,144,886 |
| Mint (fee:3000, wide range) | 28,878,752 | 24,657 | 27,933,125 |
| Swap (gns -> wugnot, fee:500) | 46,320,647 | 735 | 44,779,220 |
| DecreaseLiquidity | 22,884,908 | -2,081 | 22,589,741 |
| IncreaseLiquidity | 20,802,538 | -2,064 | 20,685,418 |
| Mint (bar:foo:500) | 27,447,068 | 24,660 | 26,011,748 |
| CollectFee (with unwrap) | 5,586,974 | 45 | 5,418,185 |
| DecreaseLiquidity (w. Remove) | 18,383,405 | 90 | 18,023,549 |
| Mint (reposition) | 28,047,478 | 8,617 | 27,881,239 |
| SetPoolTier (tier 1) | 4,063,603 | 45,375 | 3,482,239 |
| StakeToken | 16,568,497 | 22,326 | 15,985,372 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 25,309,941 | 9,045 | 22,781,832 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 29,942,736 | 9,149 | 27,418,197 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 25,527,160 | 9,047 | 22,921,156 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 25,244,708 | 9,045 | 22,722,146 |
| ExactInSwapRoute(grc20) - fee:10000 | 24,641,606 | 9,045 | 22,118,363 |
| ExactInSwapRoute(grc20) - fee:100 | 29,291,985 | 9,149 | 26,772,312 |
| ExactInSwapRoute(grc20) - fee:3000 | 24,867,617 | 9,047 | 22,266,479 |
| ExactInSwapRoute(grc20) - fee:500 | 24,593,957 | 9,045 | 22,076,261 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 27,158,590 | 9,045 | 24,628,168 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 31,637,820 | 9,149 | 29,111,241 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 27,245,561 | 9,047 | 24,641,399 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 26,999,334 | 9,045 | 24,476,673 |
| ExactOutSwapRoute(grc20) - fee:10000 | 26,512,489 | 9,045 | 23,986,939 |
| ExactOutSwapRoute(grc20) - fee:100 | 31,009,303 | 9,149 | 28,487,596 |
| ExactOutSwapRoute(grc20) - fee:3000 | 26,608,252 | 9,047 | 24,008,962 |
| ExactOutSwapRoute(grc20) - fee:500 | 26,370,817 | 9,045 | 23,853,028 |
| ExactInSwapRoute tick cross 0 ticks with 0 positions (tier: 100) | 3,881,832,245 | 102,783 | 3,880,359,356 |
| ExactInSwapRoute tick cross 0 ticks with 0 positions (tier: 500) | 408,770,000 | 9,594 | 408,480,965 |
| ExactInSwapRoute tick cross 0 ticks with 0 positions (tier: 3000) | 85,610,295 | 1,748 | 85,344,639 |
| ExactInSwapRoute tick cross 0 ticks with 0 positions (tier: 10000) | 43,379,653 | 705 | 43,117,111 |
| ExactInSwapRoute tick cross 1000 ticks with 1000 positions (tier: 100) | 16,211,465,364 | 9,064,810 | 15,239,559,348 |
| ExactInSwapRoute tick cross 1000 ticks with 1000 positions (tier: 500) | 12,963,854,979 | 8,965,602 | 11,993,059,233 |
| ExactInSwapRoute tick cross 1000 ticks with 1000 positions (tier: 3000) | 12,793,705,895 | 8,959,651 | 11,822,773,943 |
| ExactInSwapRoute tick cross 1000 ticks with 1000 positions (tier: 10000) | 12,884,496,848 | 8,960,788 | 11,913,557,732 |
| ExactInSwapRoute tick cross 100 ticks with 100 positions (tier: 100) | 5,012,956,163 | 1,005,877 | 4,993,507,490 |
| ExactInSwapRoute tick cross 100 ticks with 100 positions (tier: 500) | 1,567,997,972 | 905,431 | 1,549,761,560 |
| ExactInSwapRoute tick cross 100 ticks with 100 positions (tier: 3000) | 1,257,503,328 | 897,692 | 1,239,280,410 |
| ExactInSwapRoute tick cross 100 ticks with 100 positions (tier: 10000) | 1,220,938,299 | 896,494 | 1,202,717,808 |
| ExactInSwapRoute tick cross 1 ticks with 1 positions (tier: 100) | 3,902,946,909 | 121,481 | 3,901,158,297 |
| ExactInSwapRoute tick cross 1 ticks with 1 positions (tier: 500) | 431,296,783 | 20,758 | 430,741,048 |
| ExactInSwapRoute tick cross 1 ticks with 1 positions (tier: 3000) | 108,491,457 | 12,919 | 107,959,098 |
| ExactInSwapRoute tick cross 1 ticks with 1 positions (tier: 10000) | 65,626,763 | 11,881 | 65,097,494 |
| ExactInSwapRoute tick cross 250 ticks with 250 positions (tier: 100) | 6,760,286,330 | 2,346,035 | 6,678,348,731 |
| ExactInSwapRoute tick cross 250 ticks with 250 positions (tier: 500) | 3,343,445,330 | 2,245,489 | 3,262,679,696 |
| ExactInSwapRoute tick cross 250 ticks with 250 positions (tier: 3000) | 3,059,932,087 | 2,237,820 | 2,979,188,575 |
| ExactInSwapRoute tick cross 250 ticks with 250 positions (tier: 10000) | 3,031,563,816 | 2,236,948 | 2,950,817,463 |
| ExactInSwapRoute tick cross 500 ticks with 500 positions (tier: 100) | 9,787,417,044 | 4,589,312 | 9,513,623,496 |
| ExactInSwapRoute tick cross 500 ticks with 500 positions (tier: 500) | 6,422,881,562 | 4,489,037 | 6,150,249,008 |
| ExactInSwapRoute tick cross 500 ticks with 500 positions (tier: 3000) | 6,188,377,488 | 4,481,547 | 5,915,757,495 |
| ExactInSwapRoute tick cross 500 ticks with 500 positions (tier: 10000) | 6,197,279,546 | 4,481,152 | 5,924,615,258 |
| ExactInSwapRoute tick cross 50 ticks with 50 positions (tier: 100) | 4,448,352,276 | 558,937 | 4,438,407,063 |
| ExactInSwapRoute tick cross 50 ticks with 50 positions (tier: 500) | 989,346,377 | 458,268 | 980,616,785 |
| ExactInSwapRoute tick cross 50 ticks with 50 positions (tier: 3000) | 673,253,783 | 450,513 | 664,546,541 |
| ExactInSwapRoute tick cross 50 ticks with 50 positions (tier: 10000) | 632,865,029 | 449,556 | 624,156,503 |
| BuildSingleHopRoutePath | 206,648 | 0 | 54,830 |
| MultiHop ExactIn (2 hops) | 47,668,924 | 9,265 | 46,542,658 |
| MultiHop ExactOut (2 hops) | 70,072,967 | 73 | 69,811,652 |
| MultiHop ExactIn (3 hops) | 67,693,339 | 238 | 67,388,557 |
| MultiHop ExactOut (3 hops) | 107,104,724 | 13 | 106,803,149 |
| MultiRoute ExactIn (50:50 split) | 66,706,970 | 112 | 66,308,327 |
| MultiRoute ExactOut (50:50 split) | 92,454,145 | 2 | 92,073,223 |
| CollectReward (only Internal Reward) | 25,306,503 | 11,489 | 24,749,484 |
| CollectReward 2nd (only Internal Reward) | 25,658,184 | 491 | 25,269,141 |
| CollectReward With External Rewards (1 incentives) | 40,189,467 | 12,935 | 39,412,044 |
| CollectReward With External Rewards 2nd (1 incentives) | 40,309,668 | 479 | 39,736,212 |
| CollectReward With External Rewards (5 incentives) | 97,691,535 | 14,820 | 96,104,418 |
| CollectReward With External Rewards 2nd (5 incentives) | 98,258,406 | 463 | 96,930,462 |
| CreateExternalIncentive | 4,536,368 | 70,326 | 4,122,110 |
| EndExternalIncentive | 3,160,035 | -14,581 | 3,046,788 |
| RegisterInitializer (v1) | 127,397 | 0 | 85,997 |
| RegisterInitializer (v2) | 85,997 | 0 | 85,997 |
