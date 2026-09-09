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
| Propose Community Pool Spend | 2,446,348 | 20,560 | 1,973,983 |
| Propose Parameter Change | 2,992,330 | 19,532 | 2,550,061 |
| Vote | 1,020,769 | 4,488 | 860,873 |
| Execute | 2,532,744 | 76 | 1,353,678 |
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
| CollectReward (100 delegations, 1 withdraws) | 3,457,355 | 2,333 | 2,803,833 |
| CollectReward (10 delegations, 10 withdraws) | 3,457,265 | 2,323 | 2,803,833 |
| CollectReward (10 delegations, 1 withdraws) | 3,453,477 | 2,323 | 2,800,047 |
| CollectReward (10 delegations, 50 withdraws) | 3,456,198 | 2,323 | 2,802,766 |
| CollectReward (10 delegations, 5 withdraws) | 3,450,274 | 2,323 | 2,796,844 |
| CollectReward (1 delegation, 10 withdraws) | 3,527,397 | 2,395 | 2,800,047 |
| CollectReward (1 delegation, 1 withdraws) | 3,702,983 | 2,395 | 2,972,167 |
| CollectReward (1 delegation, 50 withdraws) | 3,524,194 | 2,395 | 2,796,844 |
| CollectReward (1 delegation, 5 withdraws) | 3,525,351 | 2,395 | 2,798,001 |
| gov/staker CollectReward (1 protocol-fee tokens) | 3,710,276 | 368 | 2,984,857 |
| gov/staker CollectReward (2 protocol-fee tokens) | 5,888,205 | -1,860 | 5,059,996 |
| gov/staker CollectReward (3 protocol-fee tokens) | 8,186,417 | -3,992 | 7,136,974 |
| gov/staker CollectReward (4 protocol-fee tokens) | 10,495,832 | -6,122 | 9,218,459 |
| gov/staker CollectReward (4 protocol-fee tokens but zero amount) | 1,701,190 | 0 | 1,173,935 |
| Delegate | 4,989,756 | 38,285 | 1,942,824 |
| Undelegate | 2,279,200 | 840 | 1,586,279 |
| Undelegate (5 delegations, cached external calls) | 9,705,646 | 3,510 | 6,778,953 |
| Delegate (cached external calls) | 3,046,853 | 3,210 | 2,323,417 |
| Undelegate (early exit, 3 of 10 delegations) | 6,656,620 | 2,088 | 4,833,951 |
| Redelegate | 4,363,314 | 1,423 | 3,049,928 |
| Redelegate (50 of 100 delegations, optimized) | 123,363,976 | -118,826 | 90,714,642 |
| Undelegate (50 delegatees, large AVL traversal) | 2,459,149 | 708 | 1,789,243 |
| CollectDepositGns (deposit 1/5, remaining 4) | 7,721,509 | 1,850 | 6,547,860 |
| CollectDepositGns (deposit 2/5, remaining 3) | 7,380,514 | -2,257 | 6,324,691 |
| CollectDepositGns (deposit 3/5, remaining 2) | 7,354,134 | -2,257 | 6,300,696 |
| CollectDepositGns (deposit 4/5, remaining 1) | 7,359,580 | -2,257 | 6,308,527 |
| CollectDepositGns (deposit 5/5, remaining 0) | 7,231,937 | -8,456 | 6,203,950 |
| Launchpad CollectDepositGns | 7,588,751 | -4,155 | 6,444,729 |
| CollectProtocolFee (1 token) | 3,584,812 | 4,426 | 2,932,053 |
| CollectProtocolFee (2 tokens) | 5,670,124 | 8,750 | 4,794,387 |
| CollectProtocolFee (5 tokens) | 11,964,755 | 21,724 | 10,396,093 |
| Launchpad CollectProtocolFee (tokens: 10) | 22,358,495 | 43,713 | 19,585,903 |
| Launchpad CollectRewardByDepositId | 3,308,430 | 2,070 | 2,934,105 |
| Create Launchpad Project | 8,550,023 | 33,729 | 6,147,317 |
| Launchpad DepositGns | 6,420,331 | 24,246 | 4,183,559 |
| Launchpad TransferLeftFromProjectByAdmin | 1,268,570 | 41 | 1,078,780 |
| CreatePool | 6,718,031 | 25,361 | 5,871,037 |
| Mint (fee:3000, wide range) | 31,581,342 | 22,702 | 29,327,561 |
| Remaining pool allocation create | 6,722,915 | 25,337 | 5,873,221 |
| Remaining pool allocation mint-wide | 31,662,456 | 22,677 | 29,312,535 |
| Remaining pool allocation mint-crossing-range | 27,360,415 | 8,916 | 26,248,612 |
| Remaining pool repeat no-cross exact-in forward stage-1 | 24,660,316 | 9,026 | 21,246,411 |
| Remaining pool repeat no-cross exact-in forward stage-10 | 224,151,625 | 126 | 215,070,797 |
| Remaining pool repeat no-cross exact-in forward stage-100 | 2,265,498,211 | 74 | 2,174,341,574 |
| Remaining pool repeat no-cross exact-in forward stage-1000 | 22,879,349,691 | 78 | 21,965,076,610 |
| Remaining pool repeat no-cross exact-in reverse stage-1 | 24,572,279 | 3,075 | 23,585,451 |
| Remaining pool repeat no-cross exact-in reverse stage-10 | 241,914,586 | 10 | 232,542,866 |
| Remaining pool repeat no-cross exact-in reverse stage-100 | 2,437,903,645 | 0 | 2,344,356,379 |
| Remaining pool repeat no-cross exact-in reverse stage-1000 | 24,239,993,269 | 23 | 23,305,684,346 |
| Remaining pool repeat exact-out forward control | 24,716,970 | 5 | 23,748,975 |
| Remaining pool repeat exact-out reverse control | 23,968,538 | 0 | 23,029,121 |
| Remaining pool repeat crossing exact-in forward | 31,638,271 | 78 | 30,441,491 |
| Remaining pool repeat crossing exact-in reverse | 38,712,364 | -2 | 37,413,547 |
| Remaining pool lifecycle collect-fee | 14,353,079 | 157 | 13,331,547 |
| Remaining pool lifecycle burn-wide | 31,416,532 | -2,546 | 29,704,369 |
| Remaining pool lifecycle burn-crossing-range | 34,322,126 | -7,098 | 32,230,943 |
| Swap (gns -> wugnot, fee:500) | 46,900,558 | 0 | 44,048,093 |
| DecreaseLiquidity | 25,642,310 | 18 | 24,182,078 |
| IncreaseLiquidity | 23,173,207 | -2,084 | 22,262,484 |
| Mint (bar:foo:500) | 29,775,489 | 22,689 | 27,425,944 |
| CollectFee (with unwrap) | 7,914,685 | 44 | 5,939,297 |
| DecreaseLiquidity (w. Remove) | 22,350,216 | 62 | 19,428,872 |
| Mint (reposition) | 30,601,698 | 8,619 | 29,441,753 |
| SetPoolTier (tier 1) | 4,030,471 | 47,025 | 1,842,521 |
| StakeToken | 10,624,583 | 23,393 | 9,721,069 |
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
| ExactInSingleSwapRoute(grc20) - fee:10000 | 26,899,658 | 9,054 | 23,436,666 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,477,656 | 9,054 | 27,920,374 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 26,963,995 | 9,054 | 23,482,183 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 26,826,232 | 9,054 | 23,363,480 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,138,128 | 9,054 | 22,683,251 |
| ExactInSwapRoute(grc20) - fee:100 | 30,733,430 | 9,054 | 27,184,263 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,211,117 | 9,054 | 22,737,420 |
| ExactInSwapRoute(grc20) - fee:500 | 26,082,006 | 9,054 | 22,627,369 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,732,659 | 9,054 | 25,243,848 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,161,433 | 9,054 | 29,580,945 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 28,673,012 | 9,054 | 25,165,149 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,568,797 | 9,054 | 25,079,994 |
| ExactOutSwapRoute(grc20) - fee:10000 | 27,994,164 | 9,054 | 24,513,473 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,440,242 | 9,054 | 28,867,874 |
| ExactOutSwapRoute(grc20) - fee:3000 | 27,943,169 | 9,054 | 24,443,426 |
| ExactOutSwapRoute(grc20) - fee:500 | 27,847,606 | 9,054 | 24,366,923 |
| BuildSingleHopRoutePath | 202,459 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 52,477,300 | 9,061 | 48,209,399 |
| MultiHop ExactOut (2 hops) | 72,931,334 | 76 | 70,676,223 |
| MultiHop ExactIn (3 hops) | 72,039,878 | 33 | 69,630,466 |
| MultiHop ExactOut (3 hops) | 110,555,583 | 0 | 107,350,604 |
| MultiRoute ExactIn (50:50 split) | 71,361,888 | 0 | 68,891,132 |
| MultiRoute ExactOut (50:50 split) | 96,722,857 | 4 | 93,738,908 |
| CollectReward (only Internal Reward) | 13,997,438 | 11,137 | 12,597,573 |
| CollectReward 2nd (only Internal Reward) | 13,778,831 | 40 | 12,766,267 |
| staker CollectReward (1 external-incentive token) | 13,624,670 | 10,026 | 12,395,425 |
| staker CollectReward (2 external-incentive tokens) | 20,970,488 | 4,069 | 19,636,466 |
| staker CollectReward (3 external-incentive tokens) | 28,630,586 | 4,502 | 26,809,945 |
| staker CollectReward (4 external-incentive tokens) | 36,478,899 | 5,046 | 34,135,737 |
| storage growth: CollectReward 20 staked positions | 15,322,698 | 62 | 14,433,456 |
| storage growth: CollectReward 40 staked positions | 15,785,077 | 0 | 14,906,382 |
| storage growth: CollectReward 60 staked positions | 15,787,567 | 0 | 14,908,872 |
| storage growth: CollectReward 80 staked positions | 15,918,844 | 0 | 15,032,792 |
| storage growth: CollectReward 100 staked positions | 15,904,575 | 0 | 15,018,523 |
| CollectReward With External Rewards (1 incentives) | 22,021,186 | 14,734 | 20,068,303 |
| CollectReward With External Rewards 2nd (1 incentives) | 21,425,192 | 31 | 19,943,620 |
| CollectReward With External Rewards (5 incentives) | 53,057,905 | 28,757 | 48,930,218 |
| CollectReward With External Rewards 2nd (5 incentives) | 51,305,551 | 52 | 47,982,318 |
| CollectReward with Warmup Range (30% ~ 30%) | 14,035,434 | 11,119 | 12,629,628 |
| CollectReward with Warmup Range (30% ~ 50%) | 16,054,353 | 58 | 14,981,557 |
| CollectReward with Warmup Range (30% ~ 70%) | 18,359,219 | 18 | 17,226,717 |
| CollectReward with Warmup Range (30% ~ 100%) | 20,688,012 | 18 | 19,495,800 |
| CollectReward with Warmup Range (100% ~) | 13,453,682 | -6 | 12,519,706 |
| CollectReward with Warmup Range 2nd (100% ~) | 13,338,329 | 0 | 12,404,374 |
| CreateExternalIncentive | 3,858,805 | 66,634 | 3,184,531 |
| EndExternalIncentive | 2,312,242 | -1,979 | 2,105,747 |
| EndExternalIncentive (unclaimablePeriods=100) | 2,352,154 | 147 | 2,135,539 |
| EndExternalIncentive (unclaimablePeriods=10) | 2,301,857 | 141 | 2,087,490 |
| EndExternalIncentive (unclaimablePeriods=50) | 2,314,287 | 141 | 2,099,920 |
| Swap (halving, 10 staked tick-crosses) | 106,134,816 | 3,729 | 101,681,672 |
| Swap (halving, 1 staked tick-cross) | 32,103,782 | 2,813 | 30,453,803 |
| Swap (halving, 50 staked tick-crosses) | 444,296,473 | 7,260 | 428,614,940 |
| Swap (no halving, 10 staked tick-crosses) | 93,959,936 | -7,110 | 89,903,542 |
| Swap (no halving, 1 staked tick-cross) | 25,908,115 | -7,684 | 24,534,601 |
| Swap (no halving, 50 staked tick-crosses) | 405,547,271 | -5,108 | 390,797,130 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 1) | 110,043,345 | 34,722 | 105,238,507 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 2) | 131,354,014 | 15,195 | 126,747,682 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 3) | 132,232,351 | 14,651 | 127,630,261 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 4) | 136,448,346 | 14,630 | 131,812,939 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 5) | 133,644,026 | 57,364 | 128,816,503 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 6) | 137,078,460 | 15,207 | 132,350,178 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 7) | 133,184,463 | 14,738 | 128,476,660 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 8) | 138,237,010 | 35,401 | 133,355,539 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 9) | 133,190,056 | 14,981 | 128,477,835 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 10) | 137,295,103 | 14,736 | 132,549,504 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 11) | 134,371,774 | 35,354 | 129,505,260 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 12) | 137,424,053 | 14,970 | 132,674,153 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 13) | 133,509,066 | 14,742 | 128,779,620 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 14) | 139,967,408 | 80,768 | 134,847,802 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 15) | 134,006,340 | 15,463 | 129,187,897 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 16) | 138,080,640 | 14,731 | 133,228,859 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 17) | 135,154,860 | 35,401 | 130,182,175 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 18) | 138,133,569 | 14,970 | 133,277,550 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 19) | 134,155,064 | 14,751 | 129,319,454 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 20) | 140,694,519 | 58,739 | 135,540,928 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 21) | 134,069,894 | 15,232 | 129,236,225 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 22) | 138,252,017 | 14,719 | 133,385,051 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 23) | 135,222,335 | 35,412 | 130,234,427 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 24) | 138,325,309 | 14,969 | 133,454,056 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 25) | 134,385,041 | 14,741 | 129,534,243 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 26) | 140,794,051 | 58,689 | 135,624,268 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 27) | 134,306,658 | 15,221 | 129,457,810 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 28) | 138,395,731 | 14,729 | 133,513,558 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 29) | 135,466,483 | 35,401 | 130,463,405 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 30) | 138,428,791 | 14,969 | 133,542,388 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 31) | 134,521,342 | 14,741 | 129,655,394 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 32) | 142,334,653 | 104,110 | 136,932,912 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 33) | 134,896,448 | 15,701 | 129,944,292 |
| Accumulated-reward Swap (10 staked tick-crosses, first visit) | 110,042,819 | 34,722 | 105,238,507 |
| Accumulated-reward Reverse swap (10 staked tick-crosses, reverse visit) | 131,354,014 | 15,195 | 126,747,682 |
| Accumulated-reward Swap (10 staked tick-crosses, third visit) | 132,232,351 | 14,651 | 127,630,261 |
| Accumulated-reward Swap (1 staked tick-cross, first visit) | 31,538,130 | 5,456 | 29,967,797 |
| Accumulated-reward Reverse swap (1 staked tick-cross, reverse visit) | 33,424,366 | 3,390 | 32,015,526 |
| Accumulated-reward Swap (1 staked tick-cross, third visit) | 35,380,418 | 3,341 | 33,945,362 |
| Accumulated-reward Swap (50 staked tick-crosses, first visit) | 467,160,914 | 165,281 | 450,107,532 |
| Accumulated-reward Reverse swap (50 staked tick-crosses, reverse visit) | 575,711,013 | 68,151 | 558,107,209 |
| Accumulated-reward Swap (50 staked tick-crosses, third visit) | 572,674,682 | 65,368 | 555,204,825 |
| No-cross control (boundary staked=false) | 15,155,098 | 0 | 14,341,148 |
| No-cross control (boundary staked=true) | 15,339,928 | 0 | 14,442,098 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
