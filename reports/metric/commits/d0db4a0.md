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
| Execute | 2,532,177 | 76 | 1,353,678 |
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
| Delegate | 4,992,618 | 38,285 | 1,942,824 |
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
| Create Launchpad Project | 8,552,378 | 33,729 | 6,147,317 |
| Launchpad DepositGns | 6,420,331 | 24,246 | 4,183,559 |
| Launchpad TransferLeftFromProjectByAdmin | 1,268,570 | 41 | 1,078,780 |
| CreatePool | 6,810,310 | 22,101 | 5,968,339 |
| Mint (fee:3000, wide range) | 31,967,144 | 22,696 | 29,727,109 |
| Remaining pool allocation create | 6,815,194 | 22,077 | 5,970,523 |
| Remaining pool allocation mint-wide | 32,045,270 | 22,671 | 29,712,083 |
| Remaining pool allocation mint-crossing-range | 27,743,226 | 8,916 | 26,648,160 |
| Remaining pool repeat no-cross exact-in forward stage-1 | 25,053,135 | 9,032 | 21,654,864 |
| Remaining pool repeat no-cross exact-in forward stage-10 | 228,074,331 | 126 | 219,155,327 |
| Remaining pool repeat no-cross exact-in forward stage-100 | 2,304,714,360 | 62 | 2,215,186,874 |
| Remaining pool repeat no-cross exact-in forward stage-1000 | 23,271,432,329 | 74 | 22,373,529,610 |
| Remaining pool repeat no-cross exact-in reverse stage-1 | 24,964,999 | 3,070 | 23,993,904 |
| Remaining pool repeat no-cross exact-in reverse stage-10 | 245,833,467 | 10 | 236,627,396 |
| Remaining pool repeat no-cross exact-in reverse stage-100 | 2,477,108,853 | 0 | 2,385,201,679 |
| Remaining pool repeat no-cross exact-in reverse stage-1000 | 24,631,940,196 | 8 | 23,714,137,346 |
| Remaining pool repeat exact-out forward control | 25,109,549 | 0 | 24,157,428 |
| Remaining pool repeat exact-out reverse control | 24,361,105 | 0 | 23,437,574 |
| Remaining pool repeat crossing exact-in forward | 32,026,947 | 76 | 30,849,944 |
| Remaining pool repeat crossing exact-in reverse | 39,101,040 | -2 | 37,822,000 |
| Remaining pool lifecycle collect-fee | 14,454,386 | 155 | 13,438,891 |
| Remaining pool lifecycle burn-wide | 31,842,623 | -2,552 | 30,155,993 |
| Remaining pool lifecycle burn-crossing-range | 34,745,952 | -7,098 | 32,682,567 |
| Swap (gns -> wugnot, fee:500) | 47,290,662 | 6 | 44,456,546 |
| DecreaseLiquidity | 26,073,315 | 12 | 24,633,702 |
| IncreaseLiquidity | 23,558,232 | -2,084 | 22,662,032 |
| Mint (bar:foo:500) | 30,161,291 | 22,683 | 27,825,492 |
| CollectFee (with unwrap) | 8,018,353 | 44 | 6,046,641 |
| DecreaseLiquidity (w. Remove) | 22,781,224 | 62 | 19,880,496 |
| Mint (reposition) | 30,984,509 | 8,619 | 29,841,301 |
| SetPoolTier (tier 1) | 4,029,058 | 47,025 | 1,842,521 |
| StakeToken | 10,680,057 | 23,393 | 9,776,337 |
| UintTree Set (0) | 76,075 | 0 | 50,305 |
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
| ExactInSingleSwapRoute(grc20) - fee:10000 | 27,289,765 | 9,060 | 23,845,119 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,867,763 | 9,060 | 28,328,827 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 27,354,102 | 9,060 | 23,890,636 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 27,216,339 | 9,060 | 23,771,933 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,528,235 | 9,060 | 23,091,704 |
| ExactInSwapRoute(grc20) - fee:100 | 31,123,537 | 9,060 | 27,592,716 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,601,224 | 9,060 | 23,145,873 |
| ExactInSwapRoute(grc20) - fee:500 | 26,472,113 | 9,060 | 23,035,822 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 29,122,766 | 9,060 | 25,652,301 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,551,540 | 9,060 | 29,989,398 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 29,063,119 | 9,060 | 25,573,602 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,958,904 | 9,060 | 25,488,447 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,384,271 | 9,060 | 24,921,926 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,830,349 | 9,060 | 29,276,327 |
| ExactOutSwapRoute(grc20) - fee:3000 | 28,333,276 | 9,060 | 24,851,879 |
| ExactOutSwapRoute(grc20) - fee:500 | 28,237,713 | 9,060 | 24,775,376 |
| BuildSingleHopRoutePath | 204,811 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 53,257,508 | 9,073 | 49,026,305 |
| MultiHop ExactOut (2 hops) | 74,179,926 | 76 | 71,969,429 |
| MultiHop ExactIn (3 hops) | 73,210,181 | 45 | 70,855,825 |
| MultiHop ExactOut (3 hops) | 112,428,471 | 0 | 109,290,413 |
| MultiRoute ExactIn (50:50 split) | 72,532,191 | 6 | 70,116,491 |
| MultiRoute ExactOut (50:50 split) | 98,361,550 | 4 | 95,440,567 |
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
| EndExternalIncentive | 2,310,829 | -1,979 | 2,105,747 |
| EndExternalIncentive (unclaimablePeriods=100) | 2,352,154 | 147 | 2,135,539 |
| EndExternalIncentive (unclaimablePeriods=10) | 2,301,857 | 141 | 2,087,490 |
| EndExternalIncentive (unclaimablePeriods=50) | 2,314,287 | 141 | 2,099,920 |
| Swap (halving, 10 staked tick-crosses) | 106,513,847 | 3,735 | 102,090,125 |
| Swap (halving, 1 staked tick-cross) | 32,492,776 | 2,819 | 30,862,256 |
| Swap (halving, 50 staked tick-crosses) | 444,682,146 | 7,266 | 429,023,393 |
| Swap (no halving, 10 staked tick-crosses) | 94,338,967 | -7,104 | 90,311,995 |
| Swap (no halving, 1 staked tick-cross) | 26,297,109 | -7,678 | 24,943,054 |
| Swap (no halving, 50 staked tick-crosses) | 405,932,944 | -5,102 | 391,205,583 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 1) | 110,422,376 | 34,728 | 105,646,960 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 2) | 131,733,045 | 15,195 | 127,156,135 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 3) | 132,611,382 | 14,651 | 128,038,714 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 4) | 136,827,377 | 14,630 | 132,221,392 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 5) | 134,023,057 | 57,364 | 129,224,956 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 6) | 137,457,491 | 15,207 | 132,758,631 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 7) | 133,563,494 | 14,738 | 128,885,113 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 8) | 138,616,041 | 35,401 | 133,763,992 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 9) | 133,569,087 | 14,981 | 128,886,288 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 10) | 137,674,134 | 14,736 | 132,957,957 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 11) | 134,750,805 | 35,354 | 129,913,713 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 12) | 137,803,084 | 14,970 | 133,082,606 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 13) | 133,888,097 | 14,742 | 129,188,073 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 14) | 140,346,439 | 80,768 | 135,256,255 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 15) | 134,385,371 | 15,463 | 129,596,350 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 16) | 138,459,671 | 14,731 | 133,637,312 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 17) | 135,533,891 | 35,401 | 130,590,628 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 18) | 138,512,600 | 14,970 | 133,686,003 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 19) | 134,534,095 | 14,751 | 129,727,907 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 20) | 141,073,550 | 58,739 | 135,949,381 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 21) | 134,448,925 | 15,232 | 129,644,678 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 22) | 138,631,048 | 14,719 | 133,793,504 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 23) | 135,601,366 | 35,412 | 130,642,880 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 24) | 138,704,340 | 14,969 | 133,862,509 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 25) | 134,764,072 | 14,741 | 129,942,696 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 26) | 141,173,082 | 58,689 | 136,032,721 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 27) | 134,685,689 | 15,221 | 129,866,263 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 28) | 138,774,762 | 14,729 | 133,922,011 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 29) | 135,845,514 | 35,401 | 130,871,858 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 30) | 138,807,822 | 14,969 | 133,950,841 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 31) | 134,900,373 | 14,741 | 130,063,847 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 32) | 142,713,684 | 104,110 | 137,341,365 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 33) | 135,275,479 | 15,701 | 130,352,745 |
| Accumulated-reward Swap (10 staked tick-crosses, first visit) | 110,421,850 | 34,728 | 105,646,960 |
| Accumulated-reward Reverse swap (10 staked tick-crosses, reverse visit) | 131,733,045 | 15,195 | 127,156,135 |
| Accumulated-reward Swap (10 staked tick-crosses, third visit) | 132,611,382 | 14,651 | 128,038,714 |
| Accumulated-reward Swap (1 staked tick-cross, first visit) | 31,927,124 | 5,462 | 30,376,250 |
| Accumulated-reward Reverse swap (1 staked tick-cross, reverse visit) | 33,813,360 | 3,390 | 32,423,979 |
| Accumulated-reward Swap (1 staked tick-cross, third visit) | 35,769,412 | 3,341 | 34,353,815 |
| Accumulated-reward Swap (50 staked tick-crosses, first visit) | 467,546,587 | 165,287 | 450,515,985 |
| Accumulated-reward Reverse swap (50 staked tick-crosses, reverse visit) | 576,096,686 | 68,151 | 558,515,662 |
| Accumulated-reward Swap (50 staked tick-crosses, third visit) | 573,060,355 | 65,368 | 555,613,278 |
| No-cross control (boundary staked=false) | 15,545,202 | 6 | 14,749,601 |
| No-cross control (boundary staked=true) | 15,730,029 | 6 | 14,850,551 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
