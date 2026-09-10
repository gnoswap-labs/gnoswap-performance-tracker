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
| StakerNumbers deposit stake wide (first allocation) | 16,454,569 | 33,852 | 15,056,680 |
| StakerNumbers deposit stake boundary (first allocation) | 14,511,842 | 11,243 | 13,594,131 |
| StakerNumbers deposit stake boundary allocation 2/32 | 14,651,556 | 7,384 | 13,643,370 |
| StakerNumbers deposit stake boundary allocation 3/32 | 14,688,819 | 7,389 | 13,678,415 |
| StakerNumbers deposit stake boundary allocation 4/32 | 14,645,231 | 7,371 | 13,639,102 |
| StakerNumbers deposit stake boundary allocation 5/32 | 14,613,707 | 7,359 | 13,613,668 |
| StakerNumbers deposit stake boundary allocation 6/32 | 14,624,106 | 7,365 | 13,620,785 |
| StakerNumbers deposit stake boundary allocation 7/32 | 14,710,234 | 7,353 | 13,690,040 |
| StakerNumbers deposit stake boundary allocation 8/32 | 14,665,205 | 7,353 | 13,651,084 |
| StakerNumbers deposit stake boundary allocation 9/32 | 14,569,861 | 7,352 | 13,568,849 |
| StakerNumbers deposit stake boundary allocation 10/32 | 14,547,261 | 7,346 | 13,544,071 |
| StakerNumbers deposit stake boundary allocation 11/32 | 14,667,598 | 7,352 | 13,644,750 |
| StakerNumbers deposit stake boundary allocation 12/32 | 14,555,971 | 7,352 | 13,547,796 |
| StakerNumbers deposit stake boundary allocation 13/32 | 14,516,159 | 7,352 | 13,513,000 |
| StakerNumbers deposit stake boundary allocation 14/32 | 14,724,571 | 13,983 | 13,671,816 |
| StakerNumbers deposit stake boundary allocation 15/32 | 14,428,726 | 7,398 | 13,572,497 |
| StakerNumbers deposit stake boundary allocation 16/32 | 14,575,095 | 13,856 | 13,675,624 |
| StakerNumbers deposit stake boundary allocation 17/32 | 15,054,431 | 7,403 | 14,181,413 |
| StakerNumbers deposit stake boundary allocation 18/32 | 14,474,729 | 7,349 | 13,613,811 |
| StakerNumbers deposit stake boundary allocation 19/32 | 14,797,342 | 7,325 | 13,902,323 |
| StakerNumbers deposit stake boundary allocation 20/32 | 14,507,477 | 7,398 | 13,637,300 |
| StakerNumbers deposit stake boundary allocation 21/32 | 14,766,197 | 7,353 | 13,891,948 |
| StakerNumbers deposit stake boundary allocation 22/32 | 14,783,049 | 10,685 | 13,863,329 |
| StakerNumbers deposit stake boundary allocation 23/32 | 14,616,701 | 7,379 | 13,752,403 |
| StakerNumbers deposit stake boundary allocation 24/32 | 14,485,582 | 7,349 | 13,620,807 |
| StakerNumbers deposit stake boundary allocation 25/32 | 14,974,761 | 7,337 | 14,089,272 |
| StakerNumbers deposit stake boundary allocation 26/32 | 14,445,960 | 7,355 | 13,586,859 |
| StakerNumbers deposit stake boundary allocation 27/32 | 14,593,888 | 7,355 | 13,725,843 |
| StakerNumbers deposit stake boundary allocation 28/32 | 14,579,708 | 7,344 | 13,695,717 |
| StakerNumbers deposit stake boundary allocation 29/32 | 14,742,303 | 7,414 | 13,870,380 |
| StakerNumbers deposit stake boundary allocation 30/32 | 14,617,720 | 10,770 | 13,723,993 |
| StakerNumbers deposit stake boundary allocation 31/32 | 14,719,623 | 10,693 | 13,824,708 |
| StakerNumbers deposit stake boundary allocation 32/32 | 14,384,576 | 6,375 | 13,522,618 |
| StakerNumbers deposit collect | 14,603,604 | 11,128 | 13,313,698 |
| StakerNumbers deposit collect repeat | 13,921,278 | 40 | 13,046,670 |
| StakerNumbers deposit collect boundary allocation 1/32 | 9,184,833 | 12 | 8,599,689 |
| StakerNumbers deposit collect boundary allocation 2/32 | 9,235,674 | 12 | 8,649,144 |
| StakerNumbers deposit collect boundary allocation 3/32 | 9,236,412 | 12 | 8,649,882 |
| StakerNumbers deposit collect boundary allocation 4/32 | 9,236,409 | 12 | 8,649,879 |
| StakerNumbers deposit collect boundary allocation 5/32 | 9,236,899 | 12 | 8,650,369 |
| StakerNumbers deposit collect boundary allocation 6/32 | 9,236,173 | 12 | 8,649,643 |
| StakerNumbers deposit collect boundary allocation 7/32 | 9,238,859 | 12 | 8,652,329 |
| StakerNumbers deposit collect boundary allocation 8/32 | 9,244,635 | 12 | 8,658,105 |
| StakerNumbers deposit collect boundary allocation 9/32 | 9,246,108 | 12 | 8,659,578 |
| StakerNumbers deposit collect boundary allocation 10/32 | 9,236,660 | 12 | 8,650,130 |
| StakerNumbers deposit collect boundary allocation 11/32 | 9,238,859 | 12 | 8,652,329 |
| StakerNumbers deposit collect boundary allocation 12/32 | 9,238,369 | 12 | 8,651,839 |
| StakerNumbers deposit collect boundary allocation 13/32 | 9,237,885 | 12 | 8,651,355 |
| StakerNumbers deposit collect boundary allocation 14/32 | 9,239,594 | 12 | 8,653,064 |
| StakerNumbers deposit collect boundary allocation 15/32 | 9,237,144 | 12 | 8,650,614 |
| StakerNumbers deposit collect boundary allocation 16/32 | 9,244,886 | 12 | 8,658,356 |
| StakerNumbers deposit collect boundary allocation 17/32 | 9,249,646 | 12 | 8,663,122 |
| StakerNumbers deposit collect boundary allocation 18/32 | 9,241,910 | 12 | 8,655,386 |
| StakerNumbers deposit collect boundary allocation 19/32 | 9,240,685 | 12 | 8,654,161 |
| StakerNumbers deposit collect boundary allocation 20/32 | 9,242,645 | 12 | 8,656,121 |
| StakerNumbers deposit collect boundary allocation 21/32 | 9,241,910 | 12 | 8,655,386 |
| StakerNumbers deposit collect boundary allocation 22/32 | 9,243,383 | 12 | 8,656,859 |
| StakerNumbers deposit collect boundary allocation 23/32 | 9,241,420 | 12 | 8,654,896 |
| StakerNumbers deposit collect boundary allocation 24/32 | 9,250,871 | 12 | 8,664,347 |
| StakerNumbers deposit collect boundary allocation 25/32 | 9,251,119 | 12 | 8,664,595 |
| StakerNumbers deposit collect boundary allocation 26/32 | 9,243,870 | 12 | 8,657,346 |
| StakerNumbers deposit collect boundary allocation 27/32 | 9,251,606 | 12 | 8,665,082 |
| StakerNumbers deposit collect boundary allocation 28/32 | 9,252,105 | 12 | 8,665,581 |
| StakerNumbers deposit collect boundary allocation 29/32 | 9,244,653 | 12 | 8,658,081 |
| StakerNumbers deposit collect boundary allocation 30/32 | 9,204,434 | 12 | 8,617,862 |
| StakerNumbers deposit collect boundary allocation 31/32 | 9,278,297 | 18 | 8,619,335 |
| StakerNumbers deposit collect boundary allocation 32/32 | 9,268,849 | 18 | 8,609,887 |
| StakerNumbers tick cross positive (32 lower ticks) | 305,847,709 | 106,345 | 295,005,445 |
| StakerNumbers tick cross positive upper rewrite | 34,561,039 | 5,335 | 33,139,728 |
| StakerNumbers tick cross negative (32 lower ticks) | 387,092,634 | 44,449 | 375,422,166 |
| StakerNumbers incentive create | 6,039,470 | 19,763 | 5,352,414 |
| StakerNumbers incentive collect | 11,793,901 | 3,620 | 11,188,175 |
| StakerNumbers incentive paid claim 1/1 | 11,641,734 | 10 | 11,109,907 |
| StakerNumbers incentive paid claim 1/10 | 11,578,458 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 2/10 | 11,576,997 | 0 | 11,045,959 |
| StakerNumbers incentive paid claim 3/10 | 11,640,458 | 0 | 11,109,420 |
| StakerNumbers incentive paid claim 4/10 | 11,577,971 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 5/10 | 11,577,971 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 6/10 | 11,640,945 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 7/10 | 11,575,163 | 0 | 11,044,125 |
| StakerNumbers incentive paid claim 8/10 | 11,574,676 | 0 | 11,043,638 |
| StakerNumbers incentive paid claim 9/10 | 11,641,432 | 0 | 11,110,394 |
| StakerNumbers incentive paid claim 10/10 | 11,578,458 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 1/100 | 11,578,458 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 2/100 | 11,577,484 | 0 | 11,046,446 |
| StakerNumbers incentive paid claim 3/100 | 11,640,960 | 5 | 11,109,907 |
| StakerNumbers incentive paid claim 4/100 | 11,578,749 | 41 | 11,047,420 |
| StakerNumbers incentive paid claim 5/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 6/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 7/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 8/100 | 11,577,778 | 0 | 11,046,446 |
| StakerNumbers incentive paid claim 9/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 10/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 11/100 | 11,577,291 | 0 | 11,045,959 |
| StakerNumbers incentive paid claim 12/100 | 11,640,752 | 0 | 11,109,420 |
| StakerNumbers incentive paid claim 13/100 | 11,574,970 | 0 | 11,043,638 |
| StakerNumbers incentive paid claim 14/100 | 11,573,996 | 0 | 11,042,664 |
| StakerNumbers incentive paid claim 15/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 16/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 17/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 18/100 | 11,641,726 | 0 | 11,110,394 |
| StakerNumbers incentive paid claim 19/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 20/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 21/100 | 11,641,726 | 0 | 11,110,394 |
| StakerNumbers incentive paid claim 22/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 23/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 24/100 | 11,577,291 | 0 | 11,045,959 |
| StakerNumbers incentive paid claim 25/100 | 11,640,752 | 0 | 11,109,420 |
| StakerNumbers incentive paid claim 26/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 27/100 | 11,577,291 | 0 | 11,045,959 |
| StakerNumbers incentive paid claim 28/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 29/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 30/100 | 11,573,996 | 0 | 11,042,664 |
| StakerNumbers incentive paid claim 31/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 32/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 33/100 | 11,577,778 | 0 | 11,046,446 |
| StakerNumbers incentive paid claim 34/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 35/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 36/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 37/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 38/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 39/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 40/100 | 11,641,726 | 0 | 11,110,394 |
| StakerNumbers incentive paid claim 41/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 42/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 43/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 44/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 45/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 46/100 | 11,574,970 | 0 | 11,043,638 |
| StakerNumbers incentive paid claim 47/100 | 11,632,515 | 0 | 11,101,183 |
| StakerNumbers incentive paid claim 48/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 49/100 | 11,577,778 | 0 | 11,046,446 |
| StakerNumbers incentive paid claim 50/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 51/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 52/100 | 11,577,778 | 0 | 11,046,446 |
| StakerNumbers incentive paid claim 53/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 54/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 55/100 | 11,577,291 | 0 | 11,045,959 |
| StakerNumbers incentive paid claim 56/100 | 11,640,752 | 0 | 11,109,420 |
| StakerNumbers incentive paid claim 57/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 58/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 59/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 60/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 61/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 62/100 | 11,637,944 | 0 | 11,106,612 |
| StakerNumbers incentive paid claim 63/100 | 11,574,970 | 0 | 11,043,638 |
| StakerNumbers incentive paid claim 64/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 65/100 | 11,641,726 | 0 | 11,110,394 |
| StakerNumbers incentive paid claim 66/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 67/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 68/100 | 11,577,291 | 0 | 11,045,959 |
| StakerNumbers incentive paid claim 69/100 | 11,640,752 | 0 | 11,109,420 |
| StakerNumbers incentive paid claim 70/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 71/100 | 11,577,778 | 0 | 11,046,446 |
| StakerNumbers incentive paid claim 72/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 73/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 74/100 | 11,577,291 | 0 | 11,045,959 |
| StakerNumbers incentive paid claim 75/100 | 11,640,752 | 0 | 11,109,420 |
| StakerNumbers incentive paid claim 76/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 77/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 78/100 | 11,637,944 | 0 | 11,106,612 |
| StakerNumbers incentive paid claim 79/100 | 11,574,970 | 0 | 11,043,638 |
| StakerNumbers incentive paid claim 80/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 81/100 | 11,641,726 | 0 | 11,110,394 |
| StakerNumbers incentive paid claim 82/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 83/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 84/100 | 11,641,726 | 0 | 11,110,394 |
| StakerNumbers incentive paid claim 85/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 86/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 87/100 | 11,577,291 | 0 | 11,045,959 |
| StakerNumbers incentive paid claim 88/100 | 11,640,752 | 0 | 11,109,420 |
| StakerNumbers incentive paid claim 89/100 | 11,578,265 | 0 | 11,046,933 |
| StakerNumbers incentive paid claim 90/100 | 11,577,291 | 0 | 11,045,959 |
| StakerNumbers incentive paid claim 91/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 92/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 93/100 | 11,577,291 | 0 | 11,045,959 |
| StakerNumbers incentive paid claim 94/100 | 11,640,752 | 0 | 11,109,420 |
| StakerNumbers incentive paid claim 95/100 | 11,574,970 | 0 | 11,043,638 |
| StakerNumbers incentive paid claim 96/100 | 11,577,778 | 0 | 11,046,446 |
| StakerNumbers incentive paid claim 97/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive paid claim 98/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 99/100 | 11,578,752 | 0 | 11,047,420 |
| StakerNumbers incentive paid claim 100/100 | 11,641,239 | 0 | 11,109,907 |
| StakerNumbers incentive end | 1,925,202 | 36 | 1,754,520 |
| StakerNumbers deposit unstake delete | 55,843,851 | -16,120 | 53,533,181 |
| StakerNumbers deposit unstake boundary allocation 1/32 | 42,459,076 | -13,859 | 40,646,057 |
| StakerNumbers deposit unstake boundary allocation 2/32 | 42,748,874 | -13,859 | 40,932,697 |
| StakerNumbers deposit unstake boundary allocation 3/32 | 42,750,983 | -13,859 | 40,937,815 |
| StakerNumbers deposit unstake boundary allocation 4/32 | 42,708,981 | -13,859 | 40,905,486 |
| StakerNumbers deposit unstake boundary allocation 5/32 | 42,717,937 | -13,859 | 40,917,538 |
| StakerNumbers deposit unstake boundary allocation 6/32 | 42,715,376 | -13,859 | 40,918,160 |
| StakerNumbers deposit unstake boundary allocation 7/32 | 42,854,913 | -13,847 | 41,017,173 |
| StakerNumbers deposit unstake boundary allocation 8/32 | 42,962,795 | -17,327 | 41,111,355 |
| StakerNumbers deposit unstake boundary allocation 9/32 | 42,789,608 | -13,859 | 40,952,767 |
| StakerNumbers deposit unstake boundary allocation 10/32 | 42,766,956 | -13,859 | 40,933,298 |
| StakerNumbers deposit unstake boundary allocation 11/32 | 42,767,535 | -13,859 | 40,936,973 |
| StakerNumbers deposit unstake boundary allocation 12/32 | 42,722,206 | -13,859 | 40,901,227 |
| StakerNumbers deposit unstake boundary allocation 13/32 | 42,723,246 | -13,859 | 40,905,363 |
| StakerNumbers deposit unstake boundary allocation 14/32 | 42,722,072 | -17,337 | 40,916,855 |
| StakerNumbers deposit unstake boundary allocation 15/32 | 42,604,194 | -13,859 | 40,806,695 |
| StakerNumbers deposit unstake boundary allocation 16/32 | 42,726,074 | -13,859 | 40,902,998 |
| StakerNumbers deposit unstake boundary allocation 17/32 | 43,297,648 | -13,859 | 41,465,485 |
| StakerNumbers deposit unstake boundary allocation 18/32 | 42,748,997 | -20,469 | 40,945,344 |
| StakerNumbers deposit unstake boundary allocation 19/32 | 42,492,524 | -13,859 | 40,699,490 |
| StakerNumbers deposit unstake boundary allocation 20/32 | 42,317,812 | -13,859 | 40,535,748 |
| StakerNumbers deposit unstake boundary allocation 21/32 | 42,613,355 | -13,859 | 40,825,213 |
| StakerNumbers deposit unstake boundary allocation 22/32 | 42,441,445 | -20,287 | 40,661,241 |
| StakerNumbers deposit unstake boundary allocation 23/32 | 42,323,508 | -13,859 | 40,558,300 |
| StakerNumbers deposit unstake boundary allocation 24/32 | 42,139,004 | -13,859 | 40,378,540 |
| StakerNumbers deposit unstake boundary allocation 25/32 | 42,518,218 | -13,859 | 40,756,428 |
| StakerNumbers deposit unstake boundary allocation 26/32 | 42,070,818 | -13,859 | 40,322,946 |
| StakerNumbers deposit unstake boundary allocation 27/32 | 42,211,488 | -13,859 | 40,452,792 |
| StakerNumbers deposit unstake boundary allocation 28/32 | 42,085,773 | -13,873 | 40,331,638 |
| StakerNumbers deposit unstake boundary allocation 29/32 | 42,347,364 | -13,915 | 40,593,161 |
| StakerNumbers deposit unstake boundary allocation 30/32 | 42,029,262 | -13,916 | 40,281,289 |
| StakerNumbers deposit unstake boundary allocation 31/32 | 42,126,220 | -13,917 | 40,379,875 |
| StakerNumbers deposit unstake boundary allocation 32/32 | 41,956,306 | -31,220 | 40,209,469 |
| CreatePool | 6,718,031 | 25,361 | 5,871,037 |
| Mint (fee:3000, wide range) | 31,555,821 | 22,702 | 29,304,202 |
| Swap (gns -> wugnot, fee:500) | 47,051,400 | 0 | 44,151,584 |
| DecreaseLiquidity | 25,630,642 | 18 | 24,170,632 |
| IncreaseLiquidity | 23,148,004 | -2,084 | 22,239,125 |
| Mint (bar:foo:500) | 29,749,968 | 22,689 | 27,402,585 |
| CollectFee (with unwrap) | 7,921,911 | 44 | 5,945,168 |
| DecreaseLiquidity (w. Remove) | 22,338,893 | 62 | 19,417,426 |
| Mint (reposition) | 30,576,495 | 8,619 | 29,418,394 |
| SetPoolTier (tier 1) | 4,030,816 | 47,025 | 1,842,521 |
| StakeToken | 10,632,865 | 21,592 | 9,731,246 |
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
| ExactInSingleSwapRoute(grc20) - fee:10000 | 26,974,168 | 9,054 | 23,470,149 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,564,888 | 9,054 | 27,965,525 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 27,038,505 | 9,054 | 23,515,666 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 26,900,742 | 9,054 | 23,396,963 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,212,638 | 9,054 | 22,716,734 |
| ExactInSwapRoute(grc20) - fee:100 | 30,820,662 | 9,054 | 27,229,414 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,285,627 | 9,054 | 22,770,903 |
| ExactInSwapRoute(grc20) - fee:500 | 26,156,516 | 9,054 | 22,660,852 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,807,169 | 9,054 | 25,277,331 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,248,665 | 9,054 | 29,626,096 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 28,747,522 | 9,054 | 25,198,632 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,643,307 | 9,054 | 25,113,477 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,068,674 | 9,054 | 24,546,956 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,527,474 | 9,054 | 28,913,025 |
| ExactOutSwapRoute(grc20) - fee:3000 | 28,017,679 | 9,054 | 24,476,909 |
| ExactOutSwapRoute(grc20) - fee:500 | 27,922,116 | 9,054 | 24,400,406 |
| BuildSingleHopRoutePath | 202,459 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 52,641,091 | 9,061 | 48,288,432 |
| MultiHop ExactOut (2 hops) | 73,105,182 | 76 | 70,765,261 |
| MultiHop ExactIn (3 hops) | 72,264,029 | 33 | 69,731,314 |
| MultiHop ExactOut (3 hops) | 110,815,944 | 0 | 107,483,762 |
| MultiRoute ExactIn (50:50 split) | 71,586,063 | 0 | 68,991,980 |
| MultiRoute ExactOut (50:50 split) | 96,971,305 | 4 | 93,861,429 |
| CollectReward (only Internal Reward) | 14,003,329 | 11,137 | 12,602,762 |
| CollectReward 2nd (only Internal Reward) | 13,784,722 | 40 | 12,771,456 |
| staker CollectReward (1 external-incentive token) | 13,642,463 | 10,026 | 12,410,992 |
| staker CollectReward (2 external-incentive tokens) | 21,000,111 | 4,069 | 19,662,411 |
| staker CollectReward (3 external-incentive tokens) | 28,672,039 | 4,502 | 26,846,268 |
| staker CollectReward (4 external-incentive tokens) | 36,532,182 | 5,046 | 34,182,438 |
| storage growth: CollectReward 20 staked positions | 15,328,589 | 62 | 14,438,645 |
| storage growth: CollectReward 40 staked positions | 15,790,968 | 0 | 14,911,571 |
| storage growth: CollectReward 60 staked positions | 15,793,458 | 0 | 14,914,061 |
| storage growth: CollectReward 80 staked positions | 15,924,735 | 0 | 15,037,981 |
| storage growth: CollectReward 100 staked positions | 15,910,466 | 0 | 15,023,712 |
| CollectReward With External Rewards (1 incentives) | 22,038,907 | 14,734 | 20,083,870 |
| CollectReward With External Rewards 2nd (1 incentives) | 21,442,937 | 31 | 19,959,187 |
| CollectReward With External Rewards (5 incentives) | 53,122,946 | 28,757 | 48,987,297 |
| CollectReward With External Rewards 2nd (5 incentives) | 51,370,712 | 52 | 48,039,397 |
| CollectReward with Warmup Range (30% ~ 30%) | 14,041,325 | 11,119 | 12,634,817 |
| CollectReward with Warmup Range (30% ~ 50%) | 16,066,231 | 58 | 14,991,935 |
| CollectReward with Warmup Range (30% ~ 70%) | 18,377,084 | 18 | 17,242,284 |
| CollectReward with Warmup Range (30% ~ 100%) | 20,711,864 | 18 | 19,516,556 |
| CollectReward with Warmup Range (100% ~) | 13,459,597 | -6 | 12,524,895 |
| CollectReward with Warmup Range 2nd (100% ~) | 13,344,244 | 0 | 12,409,563 |
| CreateExternalIncentive | 3,861,310 | 66,273 | 3,187,626 |
| EndExternalIncentive | 2,324,144 | -1,979 | 2,116,125 |
| EndExternalIncentive (unclaimablePeriods=100) | 2,364,056 | 147 | 2,145,917 |
| EndExternalIncentive (unclaimablePeriods=10) | 2,313,759 | 141 | 2,097,868 |
| EndExternalIncentive (unclaimablePeriods=50) | 2,326,189 | 141 | 2,110,298 |
| Swap (halving, 10 staked tick-crosses) | 106,454,463 | 3,489 | 102,157,435 |
| Swap (halving, 1 staked tick-cross) | 32,206,394 | 2,789 | 30,531,514 |
| Swap (halving, 50 staked tick-crosses) | 446,498,777 | 6,366 | 430,859,823 |
| Swap (no halving, 10 staked tick-crosses) | 94,279,583 | -7,350 | 90,379,305 |
| Swap (no halving, 1 staked tick-cross) | 26,010,727 | -7,708 | 24,612,312 |
| Swap (no halving, 50 staked tick-crosses) | 407,749,575 | -6,002 | 393,042,013 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 1) | 110,358,552 | 34,662 | 105,714,270 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 2) | 131,917,735 | 15,195 | 127,223,844 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 3) | 132,794,959 | 14,651 | 128,106,024 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 4) | 137,012,073 | 14,630 | 132,289,101 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 5) | 134,206,868 | 57,442 | 129,292,266 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 6) | 137,642,343 | 15,209 | 132,826,340 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 7) | 133,747,407 | 14,740 | 128,952,423 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 8) | 138,800,911 | 35,395 | 133,831,701 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 9) | 133,752,928 | 14,981 | 128,953,598 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 10) | 137,858,914 | 14,736 | 133,025,666 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 11) | 134,934,670 | 35,356 | 129,981,023 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 12) | 137,987,864 | 14,970 | 133,150,315 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 13) | 134,071,938 | 14,742 | 129,255,383 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 14) | 140,531,225 | 80,756 | 135,323,964 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 15) | 134,569,134 | 15,463 | 129,663,660 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 16) | 138,644,373 | 14,731 | 133,705,021 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 17) | 135,717,654 | 35,401 | 130,657,938 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 18) | 138,697,302 | 14,970 | 133,753,712 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 19) | 134,717,858 | 14,751 | 129,795,217 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 20) | 141,258,264 | 58,739 | 136,017,090 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 21) | 134,632,688 | 15,232 | 129,711,988 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 22) | 138,815,750 | 14,719 | 133,861,213 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 23) | 135,785,129 | 35,412 | 130,710,190 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 24) | 138,889,042 | 14,969 | 133,930,218 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 25) | 134,947,835 | 14,741 | 130,010,006 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 26) | 141,357,784 | 58,689 | 136,100,430 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 27) | 134,869,452 | 15,221 | 129,933,573 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 28) | 138,959,464 | 14,729 | 133,989,720 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 29) | 136,029,277 | 35,401 | 130,939,168 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 30) | 138,992,524 | 14,969 | 134,018,550 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 31) | 135,084,136 | 14,741 | 130,131,157 |
| Long-history accumulated-reward Reverse swap (10 staked tick-crosses, visit 32) | 142,898,398 | 104,110 | 137,409,074 |
| Long-history accumulated-reward Swap (10 staked tick-crosses, visit 33) | 135,459,299 | 15,715 | 130,420,055 |
| Accumulated-reward Swap (10 staked tick-crosses, first visit) | 110,358,026 | 34,662 | 105,714,270 |
| Accumulated-reward Reverse swap (10 staked tick-crosses, reverse visit) | 131,917,735 | 15,195 | 127,223,844 |
| Accumulated-reward Swap (10 staked tick-crosses, third visit) | 132,794,959 | 14,651 | 128,106,024 |
| Accumulated-reward Swap (1 staked tick-cross, first visit) | 31,640,298 | 5,450 | 30,045,508 |
| Accumulated-reward Reverse swap (1 staked tick-cross, reverse visit) | 33,547,147 | 3,390 | 32,093,636 |
| Accumulated-reward Swap (1 staked tick-cross, third visit) | 35,502,728 | 3,341 | 34,023,073 |
| Accumulated-reward Swap (50 staked tick-crosses, first visit) | 469,330,995 | 165,003 | 452,352,415 |
| Accumulated-reward Reverse swap (50 staked tick-crosses, reverse visit) | 578,234,242 | 68,151 | 560,352,491 |
| Accumulated-reward Swap (50 staked tick-crosses, third visit) | 575,194,422 | 65,368 | 557,449,708 |
| No-cross control (boundary staked=false) | 15,229,635 | 0 | 14,374,631 |
| No-cross control (boundary staked=true) | 15,414,465 | 0 | 14,475,581 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
