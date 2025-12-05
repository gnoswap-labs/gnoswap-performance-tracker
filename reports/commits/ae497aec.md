| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| TickMathGetSqrtRatioAtTick (minTick) | 1,555,468 | 0 | 677,324 |
| TickMathGetSqrtRatioAtTick (maxTick) | 873,832 | 0 | 863,400 |
| TickMathGetSqrtRatioAtTick (zero) | 134,165 | 0 | 134,165 |
| TickMathGetSqrtRatioAtTick | 652,368 | 0 | 641,936 |
| TickMathGetTickAtSqrtRatio | 1,817,603 | 0 | 1,660,899 |
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
| Propose Community Pool Spend | 1,600,112 | 14,171 | 1,214,272 |
| Propose Parameter Change | 2,571,829 | 14,006 | 1,812,693 |
| Vote | 394,634 | 80 | 273,546 |
| Execute | 3,799,122 | 76 | 688,298 |
| Propose Text | 1,427,855 | 13,545 | 1,051,711 |
| Delegate | 9,320,383 | 14,944 | 1,497,553 |
| Undelegate | 2,422,211 | 1,334 | 1,259,716 |
| Collect Undelegated GNS | 185,313 | 0 | 185,313 |
| Delegate (to alice) | 9,320,386 | 14,943 | 1,497,556 |
| Redelegate | 2,854,724 | 7,524 | 1,598,593 |
| Create Launchpad Project | 10,541,431 | 28,808 | 1,989,555 |
| CreatePool (wugnot:gns:3000) | 9,423,206 | 17,830 | 3,104,734 |
| Mint (fee:3000, wide range) | 29,335,704 | 42,845 | 23,147,613 |
| DecreaseLiquidity | 19,909,314 | 4,399 | 16,069,237 |
| IncreaseLiquidity | 13,739,581 | 15 | 12,576,900 |
| CreatePool (wugnot:gns:500) | 10,401,664 | 17,829 | 3,101,336 |
| Mint (fee:500, wide range) | 33,574,988 | 42,849 | 23,782,563 |
| Swap (gns -> wugnot, fee:500) | 34,450,461 | 19,749 | 24,345,237 |
| Mint | 32,077,387 | 42,822 | 22,212,424 |
| Mint (w. GNOT) | 34,433,233 | 41,863 | 23,682,820 |
| IncreaseLiquidity (w. GNOT) | 14,490,461 | 56 | 13,162,656 |
| DecreaseLiquidity (unwrap=false) | 20,514,751 | 6,390 | 15,581,856 |
| CollectFee (with unwrap) | 5,351,929 | 40 | 4,101,794 |
| CreatePool (reposition) | 8,092,106 | 17,819 | 3,104,098 |
| Mint (init) | 28,701,780 | 42,822 | 22,209,689 |
| DecreaseLiquidity (w. Remove) | 18,448,961 | 4,364 | 14,322,034 |
| Mint (reposition) | 23,927,206 | 35,980 | 22,295,353 |
| CreatePool (bar:foo:3000) | 8,094,244 | 17,820 | 3,106,204 |
| Mint (bar:foo:3000) | 26,417,362 | 42,809 | 21,652,819 |
| SetPoolTier (tier 1) | 5,363,776 | 22,221 | 2,280,122 |
| StakeToken | 10,168,755 | 21,742 | 6,521,388 |
| Mint (fee:500, range:-6960~6960) | 28,323,132 | 42,831 | 22,146,379 |
| ExactInSingleSwapRoute (wugnot -> gns) | 21,593,910 | 7,834 | 13,760,888 |
| Exact In Swap Route - CreatePool (wugnot:gns:3000) | 9,423,206 | 17,830 | 3,104,734 |
| Exact In Swap Route - Mint Position | 29,411,640 | 42,847 | 23,162,049 |
| ExactInSwapRoute (gns -> wugnot) | 20,912,975 | 5,004 | 12,726,552 |
| ExactInSwapRoute (wugnot -> gns) | 16,141,741 | 4,983 | 14,644,294 |
| ExactInSwapRoute (gns -> wugnot, accumulate fees) | 14,177,319 | 5 | 12,793,104 |
| ExactOutSingleSwapRoute | 31,442,416 | 7,843 | 13,959,598 |
| ExactOutSwapRoute (gns -> wugnot) | 21,902,735 | 5,004 | 13,737,096 |
| ExactOutSwapRoute (wugnot -> gns) | 13,287,733 | 2,157 | 11,898,778 |
| BuildSingleHopRoutePath | 1,710,230 | 0 | 23,398 |
| SetPoolTier (tier 1, for reward) | 5,363,776 | 22,221 | 2,280,122 |
| CollectReward (immediately after stake) | 4,485,482 | -6 | 3,300,606 |
| CreatePool (bar:foo:100) | 9,901,679 | 17,819 | 3,738,055 |
| CreateExternalIncentive | 3,107,324 | 28,114 | 1,851,302 |
| EndExternalIncentive | 1,497,591 | -1,988 | 797,271 |
