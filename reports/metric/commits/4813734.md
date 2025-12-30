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
| Propose Community Pool Spend | 2,384,201 | 13,365 | 872,133 |
| Propose Parameter Change | 2,525,375 | 13,200 | 1,515,423 |
| Vote | 810,837 | 2,170 | 581,007 |
| Execute | 3,708,068 | 76 | 582,412 |
| Propose Text | 1,078,315 | 12,739 | 718,171 |
| Propose Text with Inactive: 100 | 1,866,390 | 13,252 | 1,091,993 |
| Delegate | 8,517,582 | 17,248 | 881,219 |
| Undelegate | 2,503,213 | 1,173 | 1,273,669 |
| Collect Undelegated GNS | 105,880 | 0 | 105,880 |
| Redelegate | 3,274,674 | 9,836 | 1,895,808 |
| Create Launchpad Project | 10,345,071 | 28,808 | 1,832,491 |
| CreatePool | 8,587,401 | 18,536 | 2,304,913 |
| Mint (fee:3000, wide range) | 17,668,836 | 40,612 | 11,530,550 |
| Swap (gns -> wugnot, fee:500) | 30,760,045 | 19,749 | 20,634,703 |
| DecreaseLiquidity | 12,625,276 | 58 | 9,830,737 |
| IncreaseLiquidity | 10,545,797 | -2,064 | 9,461,613 |
| Mint (bar:foo:500) | 20,378,409 | 40,589 | 10,602,495 |
| Mint (w. GNOT) | 23,396,940 | 39,630 | 12,065,112 |
| IncreaseLiquidity (w. GNOT) | 12,143,813 | 56 | 10,807,253 |
| DecreaseLiquidity (unwrap=false) | 15,351,618 | 6,396 | 10,432,579 |
| CollectFee (with unwrap) | 3,654,531 | 40 | 2,404,812 |
| DecreaseLiquidity (w. Remove) | 13,303,276 | 4,370 | 9,182,269 |
| Mint (reposition) | 12,287,088 | 33,714 | 10,682,656 |
| SetPoolTier (tier 1) | 4,784,052 | 21,413 | 1,443,662 |
| StakeToken | 8,560,174 | 23,438 | 4,827,079 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 28,114,672 | 5,002 | 11,344,352 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 30,163,585 | 7,819 | 13,391,681 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 28,549,260 | 5,004 | 11,355,491 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 27,995,527 | 5,002 | 11,266,791 |
| ExactInSingleSwapRoute(ugnot) - fee:10000 | 29,383,164 | 7,834 | 12,376,982 |
| ExactInSingleSwapRoute(ugnot) - fee:100 | 31,009,087 | 10,655 | 13,970,009 |
| ExactInSingleSwapRoute(ugnot) - fee:3000 | 29,915,623 | 7,836 | 12,475,512 |
| ExactInSingleSwapRoute(ugnot) - fee:500 | 29,253,375 | 7,835 | 12,267,865 |
| ExactInSwapRoute(grc20) - fee:10000 | 27,854,381 | 5,002 | 11,084,061 |
| ExactInSwapRoute(grc20) - fee:100 | 29,909,838 | 7,819 | 13,137,934 |
| ExactInSwapRoute(grc20) - fee:3000 | 28,292,241 | 5,004 | 11,098,472 |
| ExactInSwapRoute(grc20) - fee:500 | 27,741,780 | 5,002 | 11,013,044 |
| ExactInSwapRoute(ugnot) - fee:10000 | 29,122,873 | 7,834 | 12,116,691 |
| ExactInSwapRoute(ugnot) - fee:100 | 30,755,340 | 10,655 | 13,716,262 |
| ExactInSwapRoute(ugnot) - fee:3000 | 29,658,604 | 7,836 | 12,218,493 |
| ExactInSwapRoute(ugnot) - fee:500 | 28,999,628 | 7,835 | 12,014,118 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,905,720 | 5,002 | 12,145,752 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 30,884,588 | 7,819 | 14,123,036 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 29,274,847 | 5,004 | 12,101,782 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,735,847 | 5,002 | 12,027,815 |
| ExactOutSingleSwapRoute(ugnot) - fee:10000 | 29,781,798 | 7,844 | 12,477,230 |
| ExactOutSingleSwapRoute(ugnot) - fee:100 | 31,281,817 | 10,665 | 13,954,705 |
| ExactOutSingleSwapRoute(ugnot) - fee:3000 | 30,219,022 | 7,846 | 12,490,877 |
| ExactOutSingleSwapRoute(ugnot) - fee:500 | 29,580,625 | 7,845 | 12,307,081 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,656,717 | 5,002 | 11,896,749 |
| ExactOutSwapRoute(grc20) - fee:100 | 30,642,129 | 7,819 | 13,880,577 |
| ExactOutSwapRoute(grc20) - fee:3000 | 29,029,116 | 5,004 | 11,856,051 |
| ExactOutSwapRoute(grc20) - fee:500 | 28,493,388 | 5,002 | 11,785,356 |
| ExactOutSwapRoute(ugnot) - fee:10000 | 29,532,795 | 7,844 | 12,228,227 |
| ExactOutSwapRoute(ugnot) - fee:100 | 31,039,358 | 10,665 | 13,712,246 |
| ExactOutSwapRoute(ugnot) - fee:3000 | 29,973,291 | 7,846 | 12,245,146 |
| ExactOutSwapRoute(ugnot) - fee:500 | 29,338,166 | 7,845 | 12,064,622 |
| BuildSingleHopRoutePath | 1,710,230 | 0 | 23,398 |
| MultiHop ExactIn (2 hops) | 31,272,283 | 10,674 | 22,618,677 |
| MultiHop ExactOut (2 hops) | 35,573,856 | 26 | 34,000,790 |
| MultiHop ExactIn (3 hops) | 35,315,376 | 5,709 | 32,995,346 |
| MultiHop ExactOut (3 hops) | 54,345,650 | 14 | 52,202,328 |
| MultiRoute ExactIn (50:50 split) | 35,550,580 | 2,849 | 32,774,943 |
| MultiRoute ExactOut (50:50 split) | 47,980,859 | 2 | 45,324,900 |
| CollectReward (immediately after stake) | 2,847,217 | -6 | 1,699,909 |
| CreateExternalIncentive | 3,323,378 | 30,612 | 1,614,860 |
| EndExternalIncentive | 1,341,967 | -5,255 | 755,344 |
