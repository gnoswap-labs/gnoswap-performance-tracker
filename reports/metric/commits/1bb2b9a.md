| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| TickMathGetSqrtRatioAtTick (minTick) | 1,554,700 | 0 | 677,324 |
| TickMathGetSqrtRatioAtTick (maxTick) | 873,832 | 0 | 863,400 |
| TickMathGetSqrtRatioAtTick (zero) | 134,165 | 0 | 134,165 |
| TickMathGetSqrtRatioAtTick | 652,352 | 0 | 641,936 |
| TickMathGetTickAtSqrtRatio | 1,792,151 | 0 | 1,635,447 |
| GetLiquidityForAmounts | 1,442,983 | 0 | 1,422,279 |
| GetAmountsForLiquidity | 1,333,931 | 0 | 1,333,931 |
| LiquidityMathAddDelta (positive) | 220,687 | 0 | 187,647 |
| LiquidityMathAddDelta (negative) | 200,681 | 0 | 200,681 |
| LiquidityMathAddDelta | 187,647 | 0 | 187,647 |
| IsGNOTPath | 11,223 | 0 | 11,223 |
| IsGNOTNativePath | 11,175 | 0 | 11,175 |
| IsGNOTWrappedPath | 11,175 | 0 | 11,175 |
| ExistsUserSendCoins | 266,478 | 0 | 18,206 |
| GetAmount0Delta | 3,912,271 | 0 | 1,486,687 |
| GetAmount1Delta | 1,050,599 | 0 | 1,040,247 |
| SwapMathComputeSwapStep | 1,879,867 | 0 | 1,859,003 |
| Propose Community Pool Spend | 2,378,259 | 13,365 | 866,191 |
| Propose Parameter Change | 2,499,900 | 13,200 | 1,489,948 |
| Vote | 809,144 | 2,170 | 579,314 |
| Execute | 3,692,105 | 76 | 566,449 |
| Propose Text | 1,052,840 | 12,739 | 692,696 |
| Delegate | 8,497,033 | 17,248 | 897,771 |
| Undelegate | 2,530,104 | 1,173 | 1,290,221 |
| Collect Undelegated GNS | 105,880 | 0 | 105,880 |
| Redelegate | 3,301,565 | 9,836 | 1,912,360 |
| Create Launchpad Project | 10,345,071 | 28,808 | 1,832,491 |
| CreatePool | 8,566,185 | 18,536 | 2,304,913 |
| Mint (fee:3000, wide range) | 17,668,836 | 40,612 | 11,530,550 |
| Swap (gns -> wugnot, fee:500) | 30,760,045 | 19,749 | 20,634,703 |
| DecreaseLiquidity | 12,852,621 | 58 | 9,867,058 |
| IncreaseLiquidity | 10,545,797 | -2,064 | 9,461,613 |
| Mint (bar:foo:500) | 20,378,409 | 40,589 | 10,602,495 |
| Mint (w. GNOT) | 23,396,940 | 39,630 | 12,065,112 |
| IncreaseLiquidity (w. GNOT) | 12,143,813 | 56 | 10,807,253 |
| DecreaseLiquidity (unwrap=false) | 15,485,605 | 9,131 | 10,451,774 |
| CollectFee (with unwrap) | 3,881,828 | 40 | 2,441,133 |
| DecreaseLiquidity (w. Remove) | 13,471,695 | 7,104 | 9,201,464 |
| Mint (reposition) | 12,287,088 | 33,714 | 10,682,656 |
| SetPoolTier (tier 1) | 4,846,088 | 21,413 | 1,455,986 |
| StakeToken | 8,560,174 | 23,438 | 4,827,079 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 28,157,156 | 5,882 | 11,352,648 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 30,206,069 | 8,699 | 13,399,977 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 28,591,744 | 5,884 | 11,363,787 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 28,038,011 | 5,882 | 11,275,087 |
| ExactInSingleSwapRoute(ugnot) - fee:10000 | 29,425,664 | 8,715 | 12,385,278 |
| ExactInSingleSwapRoute(ugnot) - fee:100 | 31,051,587 | 11,536 | 13,978,305 |
| ExactInSingleSwapRoute(ugnot) - fee:3000 | 29,958,123 | 8,717 | 12,483,808 |
| ExactInSingleSwapRoute(ugnot) - fee:500 | 29,295,875 | 8,716 | 12,276,161 |
| ExactInSwapRoute(grc20) - fee:10000 | 27,896,865 | 5,882 | 11,092,357 |
| ExactInSwapRoute(grc20) - fee:100 | 29,952,322 | 8,699 | 13,146,230 |
| ExactInSwapRoute(grc20) - fee:3000 | 28,334,725 | 5,884 | 11,106,768 |
| ExactInSwapRoute(grc20) - fee:500 | 27,784,264 | 5,882 | 11,021,340 |
| ExactInSwapRoute(ugnot) - fee:10000 | 29,165,373 | 8,715 | 12,124,987 |
| ExactInSwapRoute(ugnot) - fee:100 | 30,797,840 | 11,536 | 13,724,558 |
| ExactInSwapRoute(ugnot) - fee:3000 | 29,701,104 | 8,717 | 12,226,789 |
| ExactInSwapRoute(ugnot) - fee:500 | 29,042,128 | 8,716 | 12,022,414 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,948,204 | 5,882 | 12,154,048 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 30,927,072 | 8,699 | 14,131,332 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 29,317,331 | 5,884 | 12,110,078 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,778,331 | 5,882 | 12,036,111 |
| ExactOutSingleSwapRoute(ugnot) - fee:10000 | 29,824,298 | 8,725 | 12,485,526 |
| ExactOutSingleSwapRoute(ugnot) - fee:100 | 31,324,317 | 11,546 | 13,963,001 |
| ExactOutSingleSwapRoute(ugnot) - fee:3000 | 30,261,522 | 8,727 | 12,499,173 |
| ExactOutSingleSwapRoute(ugnot) - fee:500 | 29,623,125 | 8,726 | 12,315,377 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,699,201 | 5,882 | 11,905,045 |
| ExactOutSwapRoute(grc20) - fee:100 | 30,684,613 | 8,699 | 13,888,873 |
| ExactOutSwapRoute(grc20) - fee:3000 | 29,071,600 | 5,884 | 11,864,347 |
| ExactOutSwapRoute(grc20) - fee:500 | 28,535,872 | 5,882 | 11,793,652 |
| ExactOutSwapRoute(ugnot) - fee:10000 | 29,575,295 | 8,725 | 12,236,523 |
| ExactOutSwapRoute(ugnot) - fee:100 | 31,081,858 | 11,546 | 13,720,542 |
| ExactOutSwapRoute(ugnot) - fee:3000 | 30,015,791 | 8,727 | 12,253,442 |
| ExactOutSwapRoute(ugnot) - fee:500 | 29,380,666 | 8,726 | 12,072,918 |
| BuildSingleHopRoutePath | 1,710,230 | 0 | 23,398 |
| MultiHop ExactIn (2 hops) | 31,349,135 | 11,554 | 22,626,973 |
| MultiHop ExactOut (2 hops) | 35,652,273 | 26 | 34,011,365 |
| MultiHop ExactIn (3 hops) | 35,393,793 | 5,709 | 33,005,921 |
| MultiHop ExactOut (3 hops) | 54,424,067 | 14 | 52,212,903 |
| MultiRoute ExactIn (50:50 split) | 35,628,997 | 2,849 | 32,785,518 |
| MultiRoute ExactOut (50:50 split) | 48,059,276 | 2 | 45,335,475 |
| CollectReward (immediately after stake) | 2,847,217 | -6 | 1,699,909 |
| CreateExternalIncentive | 3,323,378 | 30,612 | 1,614,860 |
| EndExternalIncentive | 1,341,967 | -5,255 | 755,344 |
