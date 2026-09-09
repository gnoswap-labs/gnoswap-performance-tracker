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
| CollectDepositGns (deposit 1/5, remaining 4) | 7,837,227 | 1,850 | 6,666,988 |
| CollectDepositGns (deposit 2/5, remaining 3) | 7,496,970 | -2,257 | 6,443,819 |
| CollectDepositGns (deposit 3/5, remaining 2) | 7,470,590 | -2,257 | 6,419,824 |
| CollectDepositGns (deposit 4/5, remaining 1) | 7,476,036 | -2,257 | 6,427,655 |
| CollectDepositGns (deposit 5/5, remaining 0) | 7,348,393 | -8,456 | 6,323,078 |
| Launchpad CollectDepositGns | 7,704,469 | -4,155 | 6,563,857 |
| CollectProtocolFee (1 token) | 3,584,812 | 4,426 | 2,932,053 |
| CollectProtocolFee (2 tokens) | 5,670,124 | 8,750 | 4,794,387 |
| CollectProtocolFee (5 tokens) | 11,964,755 | 21,724 | 10,396,093 |
| Launchpad CollectProtocolFee (tokens: 10) | 22,358,495 | 43,713 | 19,585,903 |
| Launchpad CollectRewardByDepositId | 3,305,847 | 2,070 | 2,934,105 |
| Create Launchpad Project | 8,702,888 | 31,284 | 6,296,309 |
| Launchpad DepositGns | 6,610,266 | 24,246 | 4,302,687 |
| Remaining launch allocation n=100 | 6,412,980 | 30,304 | 5,160,781 |
| Remaining launch deposit seed n=100 | 9,407,299 | 25,327 | 6,870,840 |
| Remaining launch deposit index=0 n=100 | 8,795,597 | 2,027 | 7,709,626 |
| Remaining launch deposit index=1 n=100 | 8,789,877 | 1,883 | 7,708,032 |
| Remaining launch deposit index=2 n=100 | 8,796,778 | 1,883 | 7,713,991 |
| Remaining launch deposit index=3 n=100 | 8,797,233 | 1,883 | 7,713,504 |
| Remaining launch deposit index=4 n=100 | 8,802,218 | 1,883 | 7,717,547 |
| Remaining launch deposit index=5 n=100 | 8,803,160 | 1,883 | 7,717,547 |
| Remaining launch deposit index=6 n=100 | 8,810,548 | 1,883 | 7,723,993 |
| Remaining launch deposit index=7 n=100 | 8,811,003 | 1,883 | 7,723,506 |
| Remaining launch deposit index=8 n=100 | 8,840,570 | 1,982 | 7,733,305 |
| Remaining launch deposit index=9 n=100 | 8,835,656 | 1,886 | 7,727,443 |
| Remaining launch deposit index=10 n=100 | 8,838,291 | 1,886 | 7,729,130 |
| Remaining launch deposit index=11 n=100 | 8,843,730 | 1,944 | 7,733,399 |
| Remaining launch deposit index=12 n=100 | 8,845,596 | 1,880 | 7,733,891 |
| Remaining launch deposit index=13 n=100 | 8,847,031 | 1,874 | 7,734,378 |
| Remaining launch deposit index=14 n=100 | 8,847,984 | 1,874 | 7,734,383 |
| Remaining launch deposit index=15 n=100 | 9,136,331 | 15,048 | 7,955,440 |
| Remaining launch deposit index=16 n=100 | 8,896,324 | 1,970 | 7,770,415 |
| Remaining launch deposit index=17 n=100 | 8,891,316 | 1,874 | 7,764,459 |
| Remaining launch deposit index=18 n=100 | 8,895,224 | 1,874 | 7,769,771 |
| Remaining launch deposit index=19 n=100 | 8,897,146 | 1,874 | 7,770,745 |
| Remaining launch deposit index=20 n=100 | 8,891,651 | 1,874 | 7,764,302 |
| Remaining launch deposit index=21 n=100 | 8,899,534 | 1,874 | 7,771,237 |
| Remaining launch deposit index=22 n=100 | 8,899,500 | 1,874 | 7,770,255 |
| Remaining launch deposit index=23 n=100 | 9,202,166 | 8,566 | 8,021,081 |
| Remaining launch deposit index=24 n=100 | 8,889,585 | 1,922 | 7,764,786 |
| Remaining launch deposit index=25 n=100 | 8,895,515 | 1,874 | 7,769,768 |
| Remaining launch deposit index=26 n=100 | 8,897,442 | 1,874 | 7,770,747 |
| Remaining launch deposit index=27 n=100 | 8,898,390 | 1,874 | 7,770,747 |
| Remaining launch deposit index=28 n=100 | 8,896,332 | 1,874 | 7,770,093 |
| Remaining launch deposit index=29 n=100 | 8,897,282 | 1,874 | 7,770,095 |
| Remaining launch deposit index=30 n=100 | 8,895,427 | 1,874 | 7,767,292 |
| Remaining launch deposit index=31 n=100 | 9,203,896 | 8,554 | 8,021,413 |
| Remaining launch deposit index=32 n=100 | 8,894,761 | 1,922 | 7,771,072 |
| Remaining launch deposit index=33 n=100 | 8,902,157 | 1,874 | 7,777,520 |
| Remaining launch deposit index=34 n=100 | 8,896,662 | 1,874 | 7,771,077 |
| Remaining launch deposit index=35 n=100 | 8,897,610 | 1,874 | 7,771,077 |
| Remaining launch deposit index=36 n=100 | 8,903,535 | 1,874 | 7,776,054 |
| Remaining launch deposit index=37 n=100 | 8,904,501 | 1,880 | 7,776,054 |
| Remaining launch deposit index=38 n=100 | 8,903,914 | 1,874 | 7,776,871 |
| Remaining launch deposit index=39 n=100 | 9,211,111 | 8,554 | 8,027,212 |
| Remaining launch deposit index=40 n=100 | 8,893,995 | 1,922 | 7,771,404 |
| Remaining launch deposit index=41 n=100 | 8,894,943 | 1,874 | 7,771,404 |
| Remaining launch deposit index=42 n=100 | 8,900,868 | 1,874 | 7,776,381 |
| Remaining launch deposit index=43 n=100 | 8,901,329 | 1,874 | 7,775,894 |
| Remaining launch deposit index=44 n=100 | 8,903,256 | 1,874 | 7,776,873 |
| Remaining launch deposit index=45 n=100 | 8,904,204 | 1,874 | 7,776,873 |
| Remaining launch deposit index=46 n=100 | 8,905,152 | 1,874 | 7,776,873 |
| Remaining launch deposit index=47 n=100 | 9,212,990 | 8,554 | 8,027,699 |
| Remaining launch deposit index=48 n=100 | 8,897,213 | 1,922 | 7,775,732 |
| Remaining launch deposit index=49 n=100 | 8,908,893 | 1,874 | 7,786,461 |
| Remaining launch deposit index=50 n=100 | 8,910,333 | 1,874 | 7,786,953 |
| Remaining launch deposit index=51 n=100 | 8,911,287 | 1,875 | 7,786,953 |
| Remaining launch deposit index=52 n=100 | 8,911,754 | 1,876 | 7,786,466 |
| Remaining launch deposit index=53 n=100 | 8,912,819 | 1,909 | 7,786,466 |
| Remaining launch deposit index=54 n=100 | 8,914,758 | 1,896 | 7,787,445 |
| Remaining launch deposit index=55 n=100 | 9,224,740 | 8,608 | 8,037,784 |
| Remaining launch deposit index=56 n=100 | 8,908,925 | 1,946 | 7,785,974 |
| Remaining launch deposit index=57 n=100 | 8,910,366 | 1,898 | 7,786,461 |
| Remaining launch deposit index=58 n=100 | 8,903,342 | 1,898 | 7,780,835 |
| Remaining launch deposit index=59 n=100 | 8,903,811 | 1,898 | 7,780,350 |
| Remaining launch deposit index=60 n=100 | 8,911,213 | 1,898 | 7,786,798 |
| Remaining launch deposit index=61 n=100 | 8,912,652 | 1,898 | 7,787,283 |
| Remaining launch deposit index=62 n=100 | 8,913,114 | 1,898 | 7,786,791 |
| Remaining launch deposit index=63 n=100 | 9,226,207 | 8,600 | 8,037,619 |
| Remaining launch deposit index=64 n=100 | 8,915,107 | 1,946 | 7,793,239 |
| Remaining launch deposit index=65 n=100 | 8,916,061 | 1,898 | 7,793,239 |
| Remaining launch deposit index=66 n=100 | 8,910,572 | 1,898 | 7,786,796 |
| Remaining launch deposit index=67 n=100 | 8,911,526 | 1,898 | 7,786,796 |
| Remaining launch deposit index=68 n=100 | 8,915,435 | 1,898 | 7,792,103 |
| Remaining launch deposit index=69 n=100 | 8,916,391 | 1,898 | 7,792,105 |
| Remaining launch deposit index=70 n=100 | 8,917,837 | 1,898 | 7,792,597 |
| Remaining launch deposit index=71 n=100 | 9,233,505 | 8,600 | 8,043,423 |
| Remaining launch deposit index=72 n=100 | 8,906,907 | 1,946 | 7,786,149 |
| Remaining launch deposit index=73 n=100 | 8,907,374 | 1,898 | 7,785,662 |
| Remaining launch deposit index=74 n=100 | 8,915,258 | 1,898 | 7,792,592 |
| Remaining launch deposit index=75 n=100 | 8,912,430 | 1,898 | 7,788,810 |
| Remaining launch deposit index=76 n=100 | 8,917,166 | 1,898 | 7,792,592 |
| Remaining launch deposit index=77 n=100 | 8,917,633 | 1,898 | 7,792,105 |
| Remaining launch deposit index=78 n=100 | 8,916,565 | 1,898 | 7,792,435 |
| Remaining launch deposit index=79 n=100 | 9,235,230 | 8,600 | 8,043,750 |
| Remaining launch deposit index=80 n=100 | 8,906,623 | 1,946 | 7,786,963 |
| Remaining launch deposit index=81 n=100 | 8,906,114 | 1,898 | 7,785,500 |
| Remaining launch deposit index=82 n=100 | 8,914,003 | 1,898 | 7,792,435 |
| Remaining launch deposit index=83 n=100 | 8,915,933 | 1,898 | 7,793,411 |
| Remaining launch deposit index=84 n=100 | 8,916,400 | 1,898 | 7,792,924 |
| Remaining launch deposit index=85 n=100 | 8,914,059 | 1,898 | 7,789,629 |
| Remaining launch deposit index=86 n=100 | 8,918,308 | 1,898 | 7,792,924 |
| Remaining launch deposit index=87 n=100 | 9,236,171 | 8,600 | 8,043,263 |
| Remaining launch deposit index=88 n=100 | 8,901,816 | 1,946 | 7,783,254 |
| Remaining launch deposit index=89 n=100 | 8,903,744 | 1,898 | 7,784,228 |
| Remaining launch deposit index=90 n=100 | 8,905,185 | 1,898 | 7,784,715 |
| Remaining launch deposit index=91 n=100 | 8,905,167 | 1,898 | 7,783,743 |
| Remaining launch deposit index=92 n=100 | 8,906,608 | 1,898 | 7,784,230 |
| Remaining launch deposit index=93 n=100 | 8,907,562 | 1,898 | 7,784,230 |
| Remaining launch deposit index=94 n=100 | 8,915,451 | 1,898 | 7,791,165 |
| Remaining launch deposit index=95 n=100 | 9,164,022 | 8,320 | 7,970,526 |
| Remaining launch deposit index=96 n=100 | 8,880,110 | 1,946 | 7,766,972 |
| Remaining launch deposit index=97 n=100 | 8,892,361 | 1,898 | 7,778,269 |
| Remaining launch deposit index=98 n=100 | 8,945,332 | 1,883 | 7,810,515 |
| Remaining launch deposit index=99 n=100 | 8,945,687 | 1,859 | 7,810,030 |
| Remaining launch query getters n=100 | 14,183,325 | 0 | 13,675,702 |
| Remaining launch claim index=0 n=100 | 3,142,712 | 2,046 | 2,844,013 |
| Remaining launch claim index=1 n=100 | 2,775,914 | 12 | 2,555,623 |
| Remaining launch claim index=2 n=100 | 2,799,734 | 12 | 2,579,443 |
| Remaining launch claim index=3 n=100 | 2,776,894 | 12 | 2,556,603 |
| Remaining launch claim index=4 n=100 | 2,787,822 | 12 | 2,567,531 |
| Remaining launch claim index=5 n=100 | 2,775,914 | 12 | 2,555,623 |
| Remaining launch claim index=6 n=100 | 2,787,822 | 12 | 2,567,531 |
| Remaining launch claim index=7 n=100 | 2,800,771 | 31 | 2,580,423 |
| Remaining launch claim index=8 n=100 | 2,797,887 | 20 | 2,577,515 |
| Remaining launch claim index=9 n=100 | 2,798,871 | 12 | 2,578,499 |
| Remaining launch claim index=10 n=100 | 2,786,964 | 14 | 2,566,583 |
| Remaining launch claim index=11 n=100 | 2,797,906 | 14 | 2,577,519 |
| Remaining launch claim index=12 n=100 | 2,798,886 | 12 | 2,578,499 |
| Remaining launch claim index=13 n=100 | 2,786,970 | 12 | 2,566,583 |
| Remaining launch claim index=14 n=100 | 2,786,970 | 12 | 2,566,583 |
| Remaining launch claim index=15 n=100 | 2,797,906 | 12 | 2,577,519 |
| Remaining launch claim index=16 n=100 | 2,798,886 | 12 | 2,578,499 |
| Remaining launch claim index=17 n=100 | 2,786,970 | 12 | 2,566,583 |
| Remaining launch claim index=18 n=100 | 2,787,946 | 12 | 2,567,559 |
| Remaining launch claim index=19 n=100 | 2,786,970 | 12 | 2,566,583 |
| Remaining launch claim index=20 n=100 | 2,787,950 | 12 | 2,567,563 |
| Remaining launch claim index=21 n=100 | 2,787,950 | 12 | 2,567,563 |
| Remaining launch claim index=22 n=100 | 2,785,994 | 12 | 2,565,607 |
| Remaining launch claim index=23 n=100 | 2,786,974 | 12 | 2,566,587 |
| Remaining launch claim index=24 n=100 | 2,775,058 | 12 | 2,554,671 |
| Remaining launch claim index=25 n=100 | 2,775,058 | 12 | 2,554,671 |
| Remaining launch claim index=26 n=100 | 2,776,038 | 12 | 2,555,651 |
| Remaining launch claim index=27 n=100 | 2,775,054 | 12 | 2,554,667 |
| Remaining launch claim index=28 n=100 | 2,776,034 | 12 | 2,555,647 |
| Remaining launch claim index=29 n=100 | 2,797,906 | 12 | 2,577,519 |
| Remaining launch claim index=30 n=100 | 2,798,886 | 12 | 2,578,499 |
| Remaining launch claim index=31 n=100 | 2,786,970 | 12 | 2,566,583 |
| Remaining launch claim index=32 n=100 | 2,786,970 | 12 | 2,566,583 |
| Remaining launch claim index=33 n=100 | 2,787,950 | 12 | 2,567,563 |
| Remaining launch claim index=34 n=100 | 2,786,970 | 12 | 2,566,583 |
| Remaining launch claim index=35 n=100 | 2,787,950 | 12 | 2,567,563 |
| Remaining launch claim index=36 n=100 | 2,787,950 | 12 | 2,567,563 |
| Remaining launch claim index=37 n=100 | 2,798,882 | 12 | 2,578,495 |
| Remaining launch claim index=38 n=100 | 2,787,946 | 12 | 2,567,559 |
| Remaining launch claim index=39 n=100 | 2,787,950 | 12 | 2,567,563 |
| Remaining launch claim index=40 n=100 | 2,788,930 | 12 | 2,568,543 |
| Remaining launch claim index=41 n=100 | 2,787,950 | 12 | 2,567,563 |
| Remaining launch claim index=42 n=100 | 2,788,930 | 12 | 2,568,543 |
| Remaining launch claim index=43 n=100 | 2,788,930 | 12 | 2,568,543 |
| Remaining launch claim index=44 n=100 | 2,786,970 | 12 | 2,566,583 |
| Remaining launch claim index=45 n=100 | 2,787,950 | 12 | 2,567,563 |
| Remaining launch claim index=46 n=100 | 2,776,034 | 12 | 2,555,647 |
| Remaining launch claim index=47 n=100 | 2,776,034 | 12 | 2,555,647 |
| Remaining launch claim index=48 n=100 | 2,776,034 | 12 | 2,555,647 |
| Remaining launch claim index=49 n=100 | 2,777,014 | 12 | 2,556,627 |
| Remaining launch claim index=50 n=100 | 2,777,014 | 12 | 2,556,627 |
| Remaining launch claim index=51 n=100 | 2,797,906 | 12 | 2,577,519 |
| Remaining launch claim index=52 n=100 | 2,798,886 | 12 | 2,578,499 |
| Remaining launch claim index=53 n=100 | 2,787,009 | 12 | 2,566,583 |
| Remaining launch claim index=54 n=100 | 2,787,009 | 12 | 2,566,583 |
| Remaining launch claim index=55 n=100 | 2,787,995 | 12 | 2,567,563 |
| Remaining launch claim index=56 n=100 | 2,787,015 | 12 | 2,566,583 |
| Remaining launch claim index=57 n=100 | 2,787,995 | 12 | 2,567,563 |
| Remaining launch claim index=58 n=100 | 2,798,931 | 12 | 2,578,499 |
| Remaining launch claim index=59 n=100 | 2,799,911 | 12 | 2,579,479 |
| Remaining launch claim index=60 n=100 | 2,787,995 | 12 | 2,567,563 |
| Remaining launch claim index=61 n=100 | 2,787,995 | 12 | 2,567,563 |
| Remaining launch claim index=62 n=100 | 2,788,975 | 12 | 2,568,543 |
| Remaining launch claim index=63 n=100 | 2,787,995 | 12 | 2,567,563 |
| Remaining launch claim index=64 n=100 | 2,788,975 | 12 | 2,568,543 |
| Remaining launch claim index=65 n=100 | 2,788,975 | 12 | 2,568,543 |
| Remaining launch claim index=66 n=100 | 2,787,015 | 12 | 2,566,583 |
| Remaining launch claim index=67 n=100 | 2,787,995 | 12 | 2,567,563 |
| Remaining launch claim index=68 n=100 | 2,776,079 | 12 | 2,555,647 |
| Remaining launch claim index=69 n=100 | 2,777,059 | 12 | 2,556,627 |
| Remaining launch claim index=70 n=100 | 2,776,083 | 12 | 2,555,651 |
| Remaining launch claim index=71 n=100 | 2,777,063 | 12 | 2,556,631 |
| Remaining launch claim index=72 n=100 | 2,777,063 | 12 | 2,556,631 |
| Remaining launch claim index=73 n=100 | 2,798,931 | 12 | 2,578,499 |
| Remaining launch claim index=74 n=100 | 2,799,911 | 12 | 2,579,479 |
| Remaining launch claim index=75 n=100 | 2,787,995 | 12 | 2,567,563 |
| Remaining launch claim index=76 n=100 | 2,787,995 | 12 | 2,567,563 |
| Remaining launch claim index=77 n=100 | 2,788,975 | 12 | 2,568,543 |
| Remaining launch claim index=78 n=100 | 2,788,971 | 12 | 2,568,539 |
| Remaining launch claim index=79 n=100 | 2,788,975 | 12 | 2,568,543 |
| Remaining launch claim index=80 n=100 | 2,799,911 | 12 | 2,579,479 |
| Remaining launch claim index=81 n=100 | 2,800,891 | 12 | 2,580,459 |
| Remaining launch claim index=82 n=100 | 2,800,891 | 12 | 2,580,459 |
| Remaining launch claim index=83 n=100 | 2,801,871 | 12 | 2,581,439 |
| Remaining launch claim index=84 n=100 | 2,800,891 | 12 | 2,580,459 |
| Remaining launch claim index=85 n=100 | 2,801,871 | 12 | 2,581,439 |
| Remaining launch claim index=86 n=100 | 2,801,871 | 12 | 2,581,439 |
| Remaining launch claim index=87 n=100 | 2,802,851 | 12 | 2,582,419 |
| Remaining launch claim index=88 n=100 | 2,801,867 | 12 | 2,581,435 |
| Remaining launch claim index=89 n=100 | 2,801,871 | 12 | 2,581,439 |
| Remaining launch claim index=90 n=100 | 2,802,851 | 12 | 2,582,419 |
| Remaining launch claim index=91 n=100 | 2,801,871 | 12 | 2,581,439 |
| Remaining launch claim index=92 n=100 | 2,802,851 | 12 | 2,582,419 |
| Remaining launch claim index=93 n=100 | 2,802,851 | 12 | 2,582,419 |
| Remaining launch claim index=94 n=100 | 2,776,083 | 12 | 2,555,651 |
| Remaining launch claim index=95 n=100 | 2,867,789 | 18 | 2,556,631 |
| Remaining launch claim index=96 n=100 | 2,855,873 | 18 | 2,544,715 |
| Remaining launch claim index=97 n=100 | 2,855,873 | 18 | 2,544,715 |
| Remaining launch claim index=98 n=100 | 2,881,791 | 18 | 2,565,611 |
| Remaining launch claim index=99 n=100 | 2,893,711 | 18 | 2,577,531 |
| Remaining launch claim repeated-accrued n=100 | 3,115,327 | 0 | 2,840,434 |
| Remaining launch claim repeated-zero-time n=100 | 2,217,186 | 0 | 2,156,180 |
| Remaining launch refund before-withdraw n=100 | 6,482,397 | 2,070 | 5,952,313 |
| Remaining launch withdraw index=0 n=100 | 7,953,671 | -202 | 6,923,329 |
| Remaining launch withdraw index=1 n=100 | 7,772,300 | -5,725 | 6,781,463 |
| Remaining launch withdraw index=2 n=100 | 7,808,428 | -5,719 | 6,822,328 |
| Remaining launch withdraw index=3 n=100 | 7,756,138 | -2,263 | 6,763,395 |
| Remaining launch withdraw index=4 n=100 | 7,774,295 | -5,742 | 6,790,814 |
| Remaining launch withdraw index=5 n=100 | 7,760,945 | -5,730 | 6,780,083 |
| Remaining launch withdraw index=6 n=100 | 7,763,162 | -2,263 | 6,771,511 |
| Remaining launch withdraw index=7 n=100 | 7,688,879 | -2,263 | 6,716,964 |
| Remaining launch withdraw index=8 n=100 | 7,683,445 | -2,276 | 6,712,931 |
| Remaining launch withdraw index=9 n=100 | 7,786,454 | -2,276 | 6,781,984 |
| Remaining launch withdraw index=10 n=100 | 7,775,841 | -2,276 | 6,772,967 |
| Remaining launch withdraw index=11 n=100 | 7,782,367 | -2,276 | 6,781,089 |
| Remaining launch withdraw index=12 n=100 | 7,781,426 | -2,276 | 6,781,744 |
| Remaining launch withdraw index=13 n=100 | 7,770,813 | -2,276 | 6,772,727 |
| Remaining launch withdraw index=14 n=100 | 7,769,224 | -2,247 | 6,772,647 |
| Remaining launch withdraw index=15 n=100 | 7,775,750 | -2,276 | 6,780,769 |
| Remaining launch withdraw index=16 n=100 | 7,780,812 | -5,744 | 6,791,675 |
| Remaining launch withdraw index=17 n=100 | 7,683,219 | -2,276 | 6,706,036 |
| Remaining launch withdraw index=18 n=100 | 7,682,275 | -2,276 | 6,706,688 |
| Remaining launch withdraw index=19 n=100 | 7,679,867 | -2,276 | 6,705,876 |
| Remaining launch withdraw index=20 n=100 | 7,678,926 | -2,276 | 6,706,531 |
| Remaining launch withdraw index=21 n=100 | 7,676,270 | -2,276 | 6,705,471 |
| Remaining launch withdraw index=22 n=100 | 7,673,127 | -2,276 | 6,703,924 |
| Remaining launch withdraw index=23 n=100 | 7,660,270 | -2,276 | 6,692,663 |
| Remaining launch withdraw index=24 n=100 | 7,766,358 | -2,276 | 6,764,033 |
| Remaining launch withdraw index=25 n=100 | 7,764,682 | -2,276 | 6,763,953 |
| Remaining launch withdraw index=26 n=100 | 7,763,741 | -2,276 | 6,764,608 |
| Remaining launch withdraw index=27 n=100 | 7,761,327 | -2,276 | 6,763,790 |
| Remaining launch withdraw index=28 n=100 | 7,760,386 | -2,276 | 6,764,445 |
| Remaining launch withdraw index=29 n=100 | 7,775,114 | -2,276 | 6,780,769 |
| Remaining launch withdraw index=30 n=100 | 7,779,036 | -5,744 | 6,791,555 |
| Remaining launch withdraw index=31 n=100 | 7,682,601 | -2,276 | 6,706,036 |
| Remaining launch withdraw index=32 n=100 | 7,680,925 | -2,276 | 6,705,956 |
| Remaining launch withdraw index=33 n=100 | 7,679,984 | -2,276 | 6,706,611 |
| Remaining launch withdraw index=34 n=100 | 7,677,573 | -2,276 | 6,705,796 |
| Remaining launch withdraw index=35 n=100 | 7,675,652 | -2,276 | 6,705,471 |
| Remaining launch withdraw index=36 n=100 | 7,673,976 | -2,276 | 6,705,391 |
| Remaining launch withdraw index=37 n=100 | 7,668,583 | -2,276 | 6,701,594 |
| Remaining launch withdraw index=38 n=100 | 7,777,130 | -2,276 | 6,773,779 |
| Remaining launch withdraw index=39 n=100 | 7,775,457 | -2,276 | 6,773,702 |
| Remaining launch withdraw index=40 n=100 | 7,774,516 | -2,276 | 6,774,357 |
| Remaining launch withdraw index=41 n=100 | 7,772,105 | -2,276 | 6,773,542 |
| Remaining launch withdraw index=42 n=100 | 7,771,164 | -2,276 | 6,774,197 |
| Remaining launch withdraw index=43 n=100 | 7,769,488 | -2,276 | 6,774,117 |
| Remaining launch withdraw index=44 n=100 | 7,766,342 | -2,276 | 6,772,567 |
| Remaining launch withdraw index=45 n=100 | 7,769,112 | -5,748 | 6,783,233 |
| Remaining launch withdraw index=46 n=100 | 7,673,835 | -2,276 | 6,697,834 |
| Remaining launch withdraw index=47 n=100 | 7,672,159 | -2,276 | 6,697,754 |
| Remaining launch withdraw index=48 n=100 | 7,670,483 | -2,276 | 6,697,674 |
| Remaining launch withdraw index=49 n=100 | 7,669,542 | -2,276 | 6,698,329 |
| Remaining launch refund after-withdraw n=100 | 3,231,739 | 0 | 3,067,455 |
| Remaining launch withdraw index=50 n=100 | 7,657,142 | -2,270 | 6,687,516 |
| Remaining launch withdraw index=51 n=100 | 7,667,883 | -2,276 | 6,699,854 |
| Remaining launch withdraw index=52 n=100 | 7,655,026 | -2,276 | 6,688,593 |
| Remaining launch withdraw index=53 n=100 | 7,761,345 | -2,290 | 6,759,963 |
| Remaining launch withdraw index=54 n=100 | 7,759,678 | -2,290 | 6,759,883 |
| Remaining launch withdraw index=55 n=100 | 7,758,740 | -2,291 | 6,760,538 |
| Remaining launch withdraw index=56 n=100 | 7,756,317 | -2,291 | 6,759,723 |
| Remaining launch withdraw index=57 n=100 | 7,755,364 | -2,291 | 6,760,378 |
| Remaining launch withdraw index=58 n=100 | 7,761,878 | -2,291 | 6,768,500 |
| Remaining launch withdraw index=59 n=100 | 7,763,469 | -5,770 | 6,779,046 |
| Remaining launch withdraw index=60 n=100 | 7,657,432 | -2,291 | 6,681,855 |
| Remaining launch withdraw index=61 n=100 | 7,655,744 | -2,291 | 6,681,775 |
| Remaining launch withdraw index=62 n=100 | 7,654,791 | -2,291 | 6,682,430 |
| Remaining launch withdraw index=63 n=100 | 7,652,368 | -2,291 | 6,681,615 |
| Remaining launch withdraw index=64 n=100 | 7,650,435 | -2,291 | 6,681,290 |
| Remaining launch withdraw index=65 n=100 | 7,648,747 | -2,291 | 6,681,210 |
| Remaining launch withdraw index=66 n=100 | 7,633,673 | -2,291 | 6,667,744 |
| Remaining launch withdraw index=67 n=100 | 7,740,835 | -5,770 | 6,758,077 |
| Remaining launch withdraw index=68 n=100 | 7,647,874 | -2,291 | 6,672,918 |
| Remaining launch withdraw index=69 n=100 | 7,646,921 | -2,291 | 6,673,573 |
| Remaining launch withdraw index=70 n=100 | 7,644,501 | -2,291 | 6,672,761 |
| Remaining launch withdraw index=71 n=100 | 7,643,548 | -2,291 | 6,673,416 |
| Remaining launch withdraw index=72 n=100 | 7,640,880 | -2,291 | 6,672,356 |
| Remaining launch withdraw index=73 n=100 | 7,655,593 | -2,291 | 6,688,677 |
| Remaining launch withdraw index=74 n=100 | 7,642,724 | -2,291 | 6,677,416 |
| Remaining launch withdraw index=75 n=100 | 7,748,926 | -2,291 | 6,748,786 |
| Remaining launch withdraw index=76 n=100 | 7,747,238 | -2,291 | 6,748,706 |
| Remaining launch withdraw index=77 n=100 | 7,746,285 | -2,291 | 6,749,361 |
| Remaining launch withdraw index=78 n=100 | 7,744,594 | -2,291 | 6,749,278 |
| Remaining launch withdraw index=79 n=100 | 7,742,909 | -2,291 | 6,749,201 |
| Remaining launch withdraw index=80 n=100 | 7,749,423 | -2,291 | 6,757,323 |
| Remaining launch withdraw index=81 n=100 | 7,748,722 | -5,770 | 6,767,629 |
| Remaining launch withdraw index=82 n=100 | 7,653,950 | -2,291 | 6,679,615 |
| Remaining launch withdraw index=83 n=100 | 7,652,997 | -2,291 | 6,680,270 |
| Remaining launch withdraw index=84 n=100 | 7,650,574 | -2,291 | 6,679,455 |
| Remaining launch withdraw index=85 n=100 | 7,649,621 | -2,291 | 6,680,110 |
| Remaining launch withdraw index=86 n=100 | 7,646,953 | -2,291 | 6,679,050 |
| Remaining launch withdraw index=87 n=100 | 7,646,000 | -2,291 | 6,679,705 |
| Remaining launch withdraw index=88 n=100 | 7,631,658 | -2,291 | 6,666,971 |
| Remaining launch withdraw index=89 n=100 | 7,719,775 | -8,913 | 6,756,970 |
| Remaining launch withdraw index=90 n=100 | 7,575,434 | -2,291 | 6,618,530 |
| Remaining launch withdraw index=91 n=100 | 7,573,011 | -2,291 | 6,617,715 |
| Remaining launch withdraw index=92 n=100 | 7,560,142 | -2,291 | 6,606,454 |
| Remaining launch withdraw index=93 n=100 | 7,558,454 | -2,291 | 6,606,374 |
| Remaining launch withdraw index=94 n=100 | 7,537,670 | -2,291 | 6,587,198 |
| Remaining launch withdraw index=95 n=100 | 7,623,198 | -2,285 | 6,584,784 |
| Remaining launch withdraw index=96 n=100 | 7,610,570 | -2,285 | 6,573,764 |
| Remaining launch withdraw index=97 n=100 | 7,596,966 | -2,285 | 6,561,768 |
| Remaining launch withdraw index=98 n=100 | 7,635,561 | -2,285 | 6,577,524 |
| Remaining launch withdraw index=99 n=100 | 7,642,015 | -2,285 | 6,586,384 |
| Remaining launch withdraw seed n=100 | 7,402,794 | -8,814 | 6,476,668 |
| Remaining launch allocation n=10 | 6,412,980 | 30,304 | 5,160,781 |
| Remaining launch deposit seed n=10 | 9,407,299 | 25,327 | 6,870,840 |
| Remaining launch deposit index=0 n=10 | 8,795,597 | 2,027 | 7,709,626 |
| Remaining launch deposit index=1 n=10 | 8,789,877 | 1,883 | 7,708,032 |
| Remaining launch deposit index=2 n=10 | 8,796,778 | 1,883 | 7,713,991 |
| Remaining launch deposit index=3 n=10 | 8,797,233 | 1,883 | 7,713,504 |
| Remaining launch deposit index=4 n=10 | 8,802,218 | 1,883 | 7,717,547 |
| Remaining launch deposit index=5 n=10 | 8,803,160 | 1,883 | 7,717,547 |
| Remaining launch deposit index=6 n=10 | 8,810,548 | 1,883 | 7,723,993 |
| Remaining launch deposit index=7 n=10 | 8,811,003 | 1,883 | 7,723,506 |
| Remaining launch deposit index=8 n=10 | 8,840,570 | 1,982 | 7,733,305 |
| Remaining launch deposit index=9 n=10 | 8,835,656 | 1,886 | 7,727,443 |
| Remaining launch query getters n=10 | 4,732,474 | 0 | 4,595,563 |
| Remaining launch claim index=0 n=10 | 3,349,350 | 2,046 | 2,977,176 |
| Remaining launch claim index=1 n=10 | 2,995,452 | 12 | 2,701,668 |
| Remaining launch claim index=2 n=10 | 2,983,540 | 12 | 2,689,756 |
| Remaining launch claim index=3 n=10 | 2,994,472 | 12 | 2,700,688 |
| Remaining launch claim index=4 n=10 | 2,995,452 | 12 | 2,701,668 |
| Remaining launch claim index=5 n=10 | 2,983,540 | 12 | 2,689,756 |
| Remaining launch claim index=6 n=10 | 2,995,452 | 12 | 2,701,668 |
| Remaining launch claim index=7 n=10 | 2,996,489 | 31 | 2,702,648 |
| Remaining launch claim index=8 n=10 | 2,994,565 | 26 | 2,700,700 |
| Remaining launch claim index=9 n=10 | 2,982,653 | 18 | 2,688,788 |
| Remaining launch claim repeated-accrued n=10 | 3,317,992 | 2 | 2,969,628 |
| Remaining launch claim repeated-zero-time n=10 | 2,369,716 | 0 | 2,306,670 |
| Remaining launch refund before-withdraw n=10 | 6,473,406 | 2,045 | 5,944,012 |
| Remaining launch withdraw index=0 n=10 | 7,812,108 | -226 | 6,685,229 |
| Remaining launch withdraw index=1 n=10 | 7,630,543 | -2,269 | 6,544,419 |
| Remaining launch withdraw index=2 n=10 | 7,607,232 | -2,275 | 6,523,493 |
| Remaining launch withdraw index=3 n=10 | 7,612,966 | -2,275 | 6,531,612 |
| Remaining launch withdraw index=4 n=10 | 7,612,216 | -2,275 | 6,533,247 |
| Remaining launch refund after-withdraw n=10 | 3,221,798 | -6 | 3,057,711 |
| Remaining launch withdraw index=5 n=10 | 7,597,748 | -2,269 | 6,521,164 |
| Remaining launch withdraw index=6 n=10 | 7,602,256 | -2,261 | 6,528,015 |
| Remaining launch withdraw index=7 n=10 | 7,588,659 | -2,260 | 6,516,758 |
| Remaining launch withdraw index=8 n=10 | 7,587,268 | -2,270 | 6,515,385 |
| Remaining launch withdraw index=9 n=10 | 7,575,866 | -2,270 | 6,506,371 |
| Remaining launch withdraw seed n=10 | 7,456,419 | -8,582 | 6,405,624 |
| Remaining launch allocation n=1 | 6,412,980 | 30,304 | 5,160,781 |
| Remaining launch deposit seed n=1 | 9,407,299 | 25,327 | 6,870,840 |
| Remaining launch deposit index=0 n=1 | 8,795,597 | 2,027 | 7,709,626 |
| Remaining launch query getters n=1 | 4,061,396 | 0 | 3,950,181 |
| Remaining launch claim index=0 n=1 | 3,317,045 | 2,052 | 2,951,997 |
| Remaining launch claim repeated-accrued n=1 | 3,289,566 | 0 | 2,948,418 |
| Remaining launch claim repeated-zero-time n=1 | 2,348,054 | 0 | 2,285,006 |
| Remaining launch refund before-withdraw n=1 | 6,491,282 | 2,028 | 5,961,739 |
| Remaining launch withdraw index=0 n=1 | 7,783,066 | -220 | 6,686,091 |
| Remaining launch refund after-withdraw n=1 | 2,844,127 | 0 | 2,761,528 |
| Remaining launch withdraw seed n=1 | 7,488,708 | -10,413 | 6,453,110 |
| Launchpad TransferLeftFromProjectByAdmin | 1,268,570 | 41 | 1,078,780 |
| CreatePool | 6,718,538 | 25,361 | 5,871,037 |
| Mint (fee:3000, wide range) | 31,555,824 | 22,702 | 29,304,202 |
| Swap (gns -> wugnot, fee:500) | 47,051,058 | 0 | 44,151,584 |
| DecreaseLiquidity | 25,630,642 | 18 | 24,170,632 |
| IncreaseLiquidity | 23,148,004 | -2,084 | 22,239,125 |
| Mint (bar:foo:500) | 29,749,971 | 22,689 | 27,402,585 |
| CollectFee (with unwrap) | 7,921,569 | 44 | 5,945,168 |
| DecreaseLiquidity (w. Remove) | 22,338,551 | 62 | 19,417,426 |
| Mint (reposition) | 30,576,495 | 8,619 | 29,418,394 |
| SetPoolTier (tier 1) | 4,030,471 | 47,025 | 1,842,521 |
| StakeToken | 10,617,932 | 23,393 | 9,715,027 |
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
| ExactInSingleSwapRoute(grc20) - fee:3000 | 27,038,166 | 9,054 | 23,515,666 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 26,900,403 | 9,054 | 23,396,963 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,212,299 | 9,054 | 22,716,734 |
| ExactInSwapRoute(grc20) - fee:100 | 30,820,323 | 9,054 | 27,229,414 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,285,288 | 9,054 | 22,770,903 |
| ExactInSwapRoute(grc20) - fee:500 | 26,156,177 | 9,054 | 22,660,852 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,806,830 | 9,054 | 25,277,331 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,248,326 | 9,054 | 29,626,096 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 28,747,183 | 9,054 | 25,198,632 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,642,968 | 9,054 | 25,113,477 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,068,335 | 9,054 | 24,546,956 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,527,135 | 9,054 | 28,913,025 |
| ExactOutSwapRoute(grc20) - fee:3000 | 28,017,340 | 9,054 | 24,476,909 |
| ExactOutSwapRoute(grc20) - fee:500 | 27,921,777 | 9,054 | 24,400,406 |
| BuildSingleHopRoutePath | 204,013 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 52,640,752 | 9,061 | 48,288,432 |
| MultiHop ExactOut (2 hops) | 73,105,182 | 76 | 70,765,261 |
| MultiHop ExactIn (3 hops) | 72,264,029 | 33 | 69,731,314 |
| MultiHop ExactOut (3 hops) | 110,815,944 | 0 | 107,483,762 |
| MultiRoute ExactIn (50:50 split) | 71,586,063 | 0 | 68,991,980 |
| MultiRoute ExactOut (50:50 split) | 96,971,305 | 4 | 93,861,429 |
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
| Swap (halving, 10 staked tick-crosses) | 106,403,913 | 3,729 | 101,891,195 |
| Swap (halving, 1 staked tick-cross) | 32,197,775 | 2,813 | 30,504,890 |
| Swap (halving, 50 staked tick-crosses) | 445,343,810 | 7,260 | 429,528,623 |
| Swap (no halving, 10 staked tick-crosses) | 94,229,033 | -7,110 | 90,113,065 |
| Swap (no halving, 1 staked tick-cross) | 26,002,108 | -7,684 | 24,585,688 |
| Swap (no halving, 50 staked tick-crosses) | 406,594,608 | -5,108 | 391,710,813 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
