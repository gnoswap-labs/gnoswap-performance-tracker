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
| Execute | 2,527,824 | 76 | 1,353,678 |
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
| CreatePool | 6,702,507 | 23,765 | 5,860,070 |
| Mint (fee:3000, wide range) | 31,563,810 | 22,696 | 29,311,709 |
| Remaining pool allocation create | 6,707,391 | 23,741 | 5,862,254 |
| Remaining pool allocation mint-wide | 31,644,924 | 22,671 | 29,296,683 |
| Remaining pool allocation mint-crossing-range | 27,343,201 | 8,916 | 26,232,760 |
| Remaining pool repeat no-cross exact-in forward stage-1 | 24,746,514 | 9,032 | 21,294,347 |
| Remaining pool repeat no-cross exact-in forward stage-10 | 225,001,373 | 126 | 215,550,157 |
| Remaining pool repeat no-cross exact-in forward stage-100 | 2,273,994,711 | 75 | 2,179,135,174 |
| Remaining pool repeat no-cross exact-in forward stage-1000 | 22,964,328,427 | 70 | 22,013,012,610 |
| Remaining pool repeat no-cross exact-in reverse stage-1 | 24,657,730 | 3,070 | 23,633,786 |
| Remaining pool repeat no-cross exact-in reverse stage-10 | 242,767,854 | 10 | 233,026,216 |
| Remaining pool repeat no-cross exact-in reverse stage-100 | 2,446,438,569 | 0 | 2,349,189,879 |
| Remaining pool repeat no-cross exact-in reverse stage-1000 | 24,325,405,372 | 33 | 23,354,031,014 |
| Remaining pool repeat exact-out forward control | 24,802,334 | 0 | 23,796,911 |
| Remaining pool repeat exact-out reverse control | 24,054,289 | 0 | 23,077,456 |
| Remaining pool repeat crossing exact-in forward | 31,749,336 | 84 | 30,513,182 |
| Remaining pool repeat crossing exact-in reverse | 38,836,550 | -2 | 37,497,305 |
| Remaining pool lifecycle collect-fee | 14,358,834 | 164 | 13,337,636 |
| Remaining pool lifecycle burn-wide | 31,402,599 | -2,549 | 29,692,901 |
| Remaining pool lifecycle burn-crossing-range | 34,307,422 | -7,103 | 32,219,475 |
| Swap (gns -> wugnot, fee:500) | 47,062,741 | 6 | 44,166,037 |
| DecreaseLiquidity | 25,629,052 | 12 | 24,170,610 |
| IncreaseLiquidity | 23,156,821 | -2,084 | 22,246,632 |
| Mint (bar:foo:500) | 29,757,957 | 22,683 | 27,410,092 |
| CollectFee (with unwrap) | 7,920,914 | 44 | 5,945,386 |
| DecreaseLiquidity (w. Remove) | 22,336,958 | 62 | 19,417,404 |
| Mint (reposition) | 30,584,484 | 8,619 | 29,425,901 |
| SetPoolTier (tier 1) | 4,030,471 | 47,025 | 1,842,521 |
| StakeToken | 10,626,856 | 23,393 | 9,722,774 |
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
| ExactInSingleSwapRoute(grc20) - fee:10000 | 26,985,509 | 9,060 | 23,484,602 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,576,229 | 9,060 | 27,979,978 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 27,049,846 | 9,060 | 23,530,119 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 26,912,083 | 9,060 | 23,411,416 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,223,979 | 9,060 | 22,731,187 |
| ExactInSwapRoute(grc20) - fee:100 | 30,832,003 | 9,060 | 27,243,867 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,296,968 | 9,060 | 22,785,356 |
| ExactInSwapRoute(grc20) - fee:500 | 26,167,857 | 9,060 | 22,675,305 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,818,510 | 9,060 | 25,291,784 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,260,006 | 9,060 | 29,640,549 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 28,758,863 | 9,060 | 25,213,085 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,654,648 | 9,060 | 25,127,930 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,080,015 | 9,060 | 24,561,409 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,538,815 | 9,060 | 28,927,478 |
| ExactOutSwapRoute(grc20) - fee:3000 | 28,029,020 | 9,060 | 24,491,362 |
| ExactOutSwapRoute(grc20) - fee:500 | 27,933,457 | 9,060 | 24,414,859 |
| BuildSingleHopRoutePath | 202,459 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 52,664,118 | 9,073 | 48,317,338 |
| MultiHop ExactOut (2 hops) | 73,098,150 | 76 | 70,759,223 |
| MultiHop ExactIn (3 hops) | 72,299,087 | 45 | 69,774,673 |
| MultiHop ExactOut (3 hops) | 110,805,396 | 0 | 107,474,705 |
| MultiRoute ExactIn (50:50 split) | 71,621,121 | 6 | 69,035,339 |
| MultiRoute ExactOut (50:50 split) | 96,975,959 | 4 | 93,869,844 |
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
| Swap (halving, 10 staked tick-crosses) | 106,480,949 | 3,735 | 101,967,158 |
| Swap (halving, 1 staked tick-cross) | 32,215,996 | 2,819 | 30,525,494 |
| Swap (halving, 50 staked tick-crosses) | 445,701,290 | 7,266 | 429,850,626 |
| Swap (no halving, 10 staked tick-crosses) | 94,306,069 | -7,104 | 90,189,028 |
| Swap (no halving, 1 staked tick-cross) | 26,020,329 | -7,678 | 24,606,292 |
| Swap (no halving, 50 staked tick-crosses) | 406,952,088 | -5,102 | 392,032,816 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 1) | 110,389,478 | 34,728 | 105,523,993 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 2) | 131,699,397 | 15,195 | 127,033,567 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 3) | 132,577,335 | 14,651 | 127,915,747 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 4) | 136,793,729 | 14,630 | 132,098,824 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 5) | 133,989,010 | 57,364 | 129,101,989 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 6) | 137,423,843 | 15,207 | 132,636,063 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 7) | 133,529,447 | 14,738 | 128,762,146 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 8) | 138,582,393 | 35,401 | 133,641,424 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 9) | 133,535,040 | 14,981 | 128,763,321 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 10) | 137,640,486 | 14,736 | 132,835,389 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 11) | 134,716,758 | 35,354 | 129,790,746 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 12) | 137,769,436 | 14,970 | 132,960,038 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 13) | 133,854,050 | 14,742 | 129,065,106 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 14) | 140,312,791 | 80,768 | 135,133,687 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 15) | 134,351,324 | 15,463 | 129,473,383 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 16) | 138,426,023 | 14,731 | 133,514,744 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 17) | 135,499,844 | 35,401 | 130,467,661 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 18) | 138,478,952 | 14,970 | 133,563,435 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 19) | 134,500,048 | 14,751 | 129,604,940 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 20) | 141,039,902 | 58,739 | 135,826,813 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 21) | 134,414,878 | 15,232 | 129,521,711 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 22) | 138,597,400 | 14,719 | 133,670,936 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 23) | 135,567,319 | 35,412 | 130,519,913 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 24) | 138,670,692 | 14,969 | 133,739,941 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 25) | 134,730,025 | 14,741 | 129,819,729 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 26) | 141,139,434 | 58,689 | 135,910,153 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 27) | 134,651,642 | 15,221 | 129,743,296 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 28) | 138,741,114 | 14,729 | 133,799,443 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 29) | 135,811,467 | 35,401 | 130,748,891 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 30) | 138,774,174 | 14,969 | 133,828,273 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 31) | 134,866,326 | 14,741 | 129,940,880 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 32) | 142,680,036 | 104,110 | 137,218,797 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 33) | 135,241,432 | 15,701 | 130,229,778 |
| Accumulated-reward Swap (10 staked tick-crosses, first visit) | 110,388,952 | 34,728 | 105,523,993 |
| Accumulated-reward Reverse swap (10 staked tick-crosses, reverse visit) | 131,699,397 | 15,195 | 127,033,567 |
| Accumulated-reward Swap (10 staked tick-crosses, third visit) | 132,577,335 | 14,651 | 127,915,747 |
| Accumulated-reward Swap (1 staked tick-cross, first visit) | 31,650,344 | 5,462 | 30,039,488 |
| Accumulated-reward Reverse swap (1 staked tick-cross, reverse visit) | 33,535,830 | 3,390 | 32,087,616 |
| Accumulated-reward Swap (1 staked tick-cross, third visit) | 35,491,483 | 3,341 | 34,017,053 |
| Accumulated-reward Swap (50 staked tick-crosses, first visit) | 468,565,731 | 165,287 | 451,343,218 |
| Accumulated-reward Reverse swap (50 staked tick-crosses, reverse visit) | 577,115,080 | 68,151 | 559,343,294 |
| Accumulated-reward Swap (50 staked tick-crosses, third visit) | 574,078,350 | 65,368 | 556,440,511 |
| No-cross control (boundary staked=false) | 15,241,321 | 6 | 14,389,084 |
| No-cross control (boundary staked=true) | 15,426,151 | 6 | 14,490,034 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
