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
| Execute | 2,528,088 | 76 | 1,353,678 |
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
| Delegate | 4,991,820 | 38,285 | 1,942,824 |
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
| Create Launchpad Project | 8,551,580 | 33,729 | 6,147,317 |
| Launchpad DepositGns | 6,420,331 | 24,246 | 4,183,559 |
| Launchpad TransferLeftFromProjectByAdmin | 1,268,570 | 41 | 1,078,780 |
| CreatePool | 6,718,538 | 25,361 | 5,871,037 |
| Mint (fee:3000, wide range) | 31,557,567 | 22,702 | 29,304,202 |
| Swap (gns -> wugnot, fee:500) | 47,051,058 | 0 | 44,151,584 |
| DecreaseLiquidity | 25,630,642 | 18 | 24,170,632 |
| IncreaseLiquidity | 23,148,004 | -2,084 | 22,239,125 |
| Mint (bar:foo:500) | 29,749,971 | 22,689 | 27,402,585 |
| CollectFee (with unwrap) | 7,921,569 | 44 | 5,945,168 |
| DecreaseLiquidity (w. Remove) | 22,338,551 | 62 | 19,417,426 |
| Mint (reposition) | 30,576,495 | 8,619 | 29,418,394 |
| SetPoolTier (tier 1) | 4,030,966 | 47,025 | 1,842,521 |
| StakeToken | 10,808,454 | 22,578 | 9,832,520 |
| UintTree Set (0) | 75,277 | 0 | 50,305 |
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
| ExactInSingleSwapRoute(grc20) - fee:10000 | 26,973,829 | 9,054 | 23,470,149 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,564,549 | 9,054 | 27,965,525 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 27,038,661 | 9,054 | 23,515,666 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 26,900,403 | 9,054 | 23,396,963 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,212,299 | 9,054 | 22,716,734 |
| ExactInSwapRoute(grc20) - fee:100 | 30,820,323 | 9,054 | 27,229,414 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,285,783 | 9,054 | 22,770,903 |
| ExactInSwapRoute(grc20) - fee:500 | 26,156,177 | 9,054 | 22,660,852 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,806,830 | 9,054 | 25,277,331 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,248,326 | 9,054 | 29,626,096 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 28,747,678 | 9,054 | 25,198,632 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,642,968 | 9,054 | 25,113,477 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,068,335 | 9,054 | 24,546,956 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,527,135 | 9,054 | 28,913,025 |
| ExactOutSwapRoute(grc20) - fee:3000 | 28,017,835 | 9,054 | 24,476,909 |
| ExactOutSwapRoute(grc20) - fee:500 | 27,921,777 | 9,054 | 24,400,406 |
| BuildSingleHopRoutePath | 204,013 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 52,640,752 | 9,061 | 48,288,432 |
| MultiHop ExactOut (2 hops) | 73,105,182 | 76 | 70,765,261 |
| MultiHop ExactIn (3 hops) | 72,264,029 | 33 | 69,731,314 |
| MultiHop ExactOut (3 hops) | 110,815,944 | 0 | 107,483,762 |
| MultiRoute ExactIn (50:50 split) | 71,586,558 | 0 | 68,991,980 |
| MultiRoute ExactOut (50:50 split) | 96,971,305 | 4 | 93,861,429 |
| CollectReward (only Internal Reward) | 14,219,507 | 11,137 | 12,814,197 |
| CollectReward 2nd (only Internal Reward) | 14,000,900 | 40 | 12,982,891 |
| staker CollectReward (1 external-incentive token) | 13,994,785 | 10,026 | 12,756,465 |
| staker CollectReward (2 external-incentive tokens) | 21,488,649 | 4,069 | 20,141,922 |
| staker CollectReward (3 external-incentive tokens) | 29,296,793 | 4,502 | 27,459,817 |
| staker CollectReward (4 external-incentive tokens) | 37,293,152 | 5,046 | 34,930,025 |
| storage growth: CollectReward 20 staked positions | 15,544,767 | 62 | 14,650,080 |
| storage growth: CollectReward 40 staked positions | 16,007,146 | 0 | 15,123,006 |
| storage growth: CollectReward 60 staked positions | 16,009,636 | 0 | 15,125,496 |
| storage growth: CollectReward 80 staked positions | 16,140,913 | 0 | 15,249,416 |
| storage growth: CollectReward 100 staked positions | 16,126,644 | 0 | 15,235,147 |
| CollectReward With External Rewards (1 incentives) | 22,391,301 | 14,734 | 20,429,343 |
| CollectReward With External Rewards 2nd (1 incentives) | 21,795,307 | 31 | 20,304,660 |
| CollectReward With External Rewards (5 incentives) | 54,020,204 | 28,757 | 49,868,922 |
| CollectReward With External Rewards 2nd (5 incentives) | 52,267,850 | 52 | 48,921,022 |
| CollectReward with Warmup Range (30% ~ 30%) | 14,257,503 | 11,119 | 12,846,252 |
| CollectReward with Warmup Range (30% ~ 50%) | 16,350,445 | 58 | 15,270,389 |
| CollectReward with Warmup Range (30% ~ 70%) | 18,729,334 | 18 | 17,587,757 |
| CollectReward with Warmup Range (30% ~ 100%) | 21,132,150 | 18 | 19,929,048 |
| CollectReward with Warmup Range (100% ~) | 13,675,751 | -6 | 12,736,330 |
| CollectReward with Warmup Range 2nd (100% ~) | 13,560,398 | 0 | 12,620,998 |
| CreateExternalIncentive | 3,859,300 | 66,634 | 3,184,531 |
| EndExternalIncentive | 2,312,242 | -1,979 | 2,105,747 |
| EndExternalIncentive (unclaimablePeriods=100) | 2,352,154 | 147 | 2,135,539 |
| EndExternalIncentive (unclaimablePeriods=10) | 2,301,857 | 141 | 2,087,490 |
| EndExternalIncentive (unclaimablePeriods=50) | 2,314,287 | 141 | 2,099,920 |
| Swap (halving, 10 staked tick-crosses) | 106,410,733 | 3,729 | 101,898,015 |
| Swap (halving, 1 staked tick-cross) | 32,198,457 | 2,813 | 30,505,572 |
| Swap (halving, 50 staked tick-crosses) | 445,377,910 | 7,260 | 429,562,723 |
| Swap (no halving, 10 staked tick-crosses) | 94,235,853 | -7,110 | 90,119,885 |
| Swap (no halving, 1 staked tick-cross) | 26,002,790 | -7,684 | 24,586,370 |
| Swap (no halving, 50 staked tick-crosses) | 406,628,708 | -5,108 | 391,744,913 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 1) | 111,489,412 | 26,572 | 106,622,960 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 2) | 133,532,741 | 7,045 | 128,847,794 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 3) | 134,410,679 | 6,501 | 129,729,974 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 4) | 138,627,073 | 6,480 | 133,913,051 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 5) | 135,806,760 | 48,936 | 130,916,216 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 6) | 139,256,143 | 6,990 | 134,450,290 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 7) | 135,362,065 | 6,521 | 130,576,373 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 8) | 140,400,128 | 27,212 | 135,455,651 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 9) | 135,367,910 | 6,771 | 130,577,548 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 10) | 139,473,356 | 6,526 | 134,649,616 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 11) | 136,534,664 | 27,137 | 131,604,973 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 12) | 139,602,306 | 6,760 | 134,774,265 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 13) | 135,686,920 | 6,532 | 130,879,333 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 14) | 142,130,760 | 72,600 | 136,947,914 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 15) | 136,184,467 | 7,253 | 131,287,610 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 16) | 140,259,166 | 6,521 | 135,328,971 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 17) | 137,318,107 | 27,191 | 132,281,888 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 18) | 140,312,095 | 6,760 | 135,377,662 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 19) | 136,333,191 | 6,541 | 131,419,167 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 20) | 142,858,123 | 50,529 | 137,641,040 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 21) | 136,248,021 | 7,022 | 131,335,938 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 22) | 140,430,543 | 6,509 | 135,485,163 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 23) | 137,385,582 | 27,202 | 132,334,140 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 24) | 140,503,835 | 6,759 | 135,554,168 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 25) | 136,563,168 | 6,531 | 131,633,956 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 26) | 142,957,697 | 50,479 | 137,724,380 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 27) | 136,484,785 | 7,011 | 131,557,523 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 28) | 140,574,257 | 6,519 | 135,613,670 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 29) | 137,629,730 | 27,191 | 132,563,118 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 30) | 140,607,317 | 6,759 | 135,642,500 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 31) | 136,699,469 | 6,531 | 131,755,107 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 32) | 144,498,257 | 95,900 | 139,033,024 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 33) | 137,074,659 | 7,505 | 132,044,005 |
| Accumulated-reward Swap (10 staked tick-crosses, first visit) | 111,488,886 | 26,572 | 106,622,960 |
| Accumulated-reward Reverse swap (10 staked tick-crosses, reverse visit) | 133,532,741 | 7,045 | 128,847,794 |
| Accumulated-reward Swap (10 staked tick-crosses, third visit) | 134,410,679 | 6,501 | 129,729,974 |
| Accumulated-reward Swap (1 staked tick-cross, first visit) | 31,749,820 | 4,641 | 30,136,377 |
| Accumulated-reward Reverse swap (1 staked tick-cross, reverse visit) | 33,708,647 | 2,575 | 32,256,031 |
| Accumulated-reward Swap (1 staked tick-cross, third visit) | 35,664,300 | 2,526 | 34,185,468 |
| Accumulated-reward Swap (50 staked tick-crosses, first visit) | 474,092,168 | 124,232 | 456,895,865 |
| Accumulated-reward Reverse swap (50 staked tick-crosses, reverse visit) | 586,308,582 | 27,101 | 568,472,241 |
| Accumulated-reward Swap (50 staked tick-crosses, third visit) | 583,271,852 | 24,318 | 565,569,458 |
| No-cross control (boundary staked=false) | 15,229,638 | 0 | 14,374,631 |
| No-cross control (boundary staked=true) | 15,414,465 | 0 | 14,475,581 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
