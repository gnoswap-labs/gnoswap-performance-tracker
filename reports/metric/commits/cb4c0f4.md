| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| TickMathGetSqrtRatioAtTick (minTick) | 1,676,939 | 0 | 1,556,899 |
| TickMathGetSqrtRatioAtTick (maxTick) | 2,049,072 | 0 | 2,001,198 |
| TickMathGetSqrtRatioAtTick (zero) | 325,020 | 0 | 313,552 |
| TickMathGetSqrtRatioAtTick | 1,518,101 | 0 | 1,492,947 |
| TickMathGetTickAtSqrtRatio | 3,853,772 | 0 | 3,724,667 |
| GetLiquidityForAmounts | 3,201,753 | 0 | 3,144,600 |
| GetAmountsForLiquidity | 2,971,743 | 0 | 2,928,656 |
| LiquidityMathAddDelta (positive) | 439,765 | 0 | 422,318 |
| LiquidityMathAddDelta (negative) | 461,806 | 0 | 454,865 |
| LiquidityMathAddDelta | 428,083 | 0 | 422,318 |
| GetAmount0Delta | 3,618,508 | 0 | 3,319,474 |
| GetAmount1Delta | 2,319,968 | 0 | 2,289,267 |
| SwapMathComputeSwapStep | 4,222,958 | 0 | 4,148,057 |
| Propose Community Pool Spend | 2,416,712 | 20,560 | 1,950,260 |
| Propose Parameter Change | 2,962,770 | 19,532 | 2,526,339 |
| Vote | 991,024 | 4,488 | 834,207 |
| Execute | 2,498,343 | 76 | 1,327,012 |
| Propose Text | 1,902,349 | 18,333 | 1,557,687 |
| Propose Text with Inactive: 100 | 2,318,377 | 8,501 | 2,055,081 |
| CollectUndelegatedGns (100 delegations, 1 withdraws) | 30,392,172 | 0 | 26,775,817 |
| CollectUndelegatedGns (10 delegations, 10 withdraws) | 5,113,781 | 105 | 4,267,051 |
| CollectUndelegatedGns (10 delegations, 1 withdraws) | 2,827,251 | 0 | 2,362,831 |
| CollectUndelegatedGns (10 delegations, 50 withdraws) | 15,279,251 | 628 | 12,730,251 |
| CollectUndelegatedGns (10 delegations, 5 withdraws) | 3,843,691 | 160 | 3,209,151 |
| CollectUndelegatedGns (1 delegation, 10 withdraws) | 649,817 | 0 | 554,325 |
| CollectUndelegatedGns (1 delegation, 1 withdraws) | 421,269 | 0 | 363,903 |
| CollectUndelegatedGns (1 delegation, 50 withdraws) | 1,665,974 | 0 | 1,400,645 |
| CollectUndelegatedGns (1 delegation, 5 withdraws) | 522,853 | 0 | 448,535 |
| CollectReward (100 delegations, 1 withdraws) | 3,262,033 | 2,316 | 2,878,234 |
| CollectReward (10 delegations, 10 withdraws) | 3,261,919 | 2,305 | 2,878,234 |
| CollectReward (10 delegations, 1 withdraws) | 3,258,131 | 2,305 | 2,874,448 |
| CollectReward (10 delegations, 50 withdraws) | 3,260,852 | 2,305 | 2,877,167 |
| CollectReward (10 delegations, 5 withdraws) | 3,254,928 | 2,305 | 2,871,245 |
| CollectReward (1 delegation, 10 withdraws) | 3,332,051 | 2,353 | 2,874,448 |
| CollectReward (1 delegation, 1 withdraws) | 3,507,637 | 2,353 | 3,046,568 |
| CollectReward (1 delegation, 50 withdraws) | 3,328,848 | 2,353 | 2,871,245 |
| CollectReward (1 delegation, 5 withdraws) | 3,330,005 | 2,353 | 2,872,402 |
| gov/staker CollectReward (1 protocol-fee tokens) | 3,532,040 | 326 | 3,075,840 |
| gov/staker CollectReward (2 protocol-fee tokens) | 5,607,667 | -1,860 | 5,142,371 |
| gov/staker CollectReward (3 protocol-fee tokens) | 7,802,181 | -3,992 | 7,213,904 |
| gov/staker CollectReward (4 protocol-fee tokens) | 10,003,731 | -6,122 | 9,289,944 |
| gov/staker CollectReward (4 protocol-fee tokens but zero amount) | 1,542,617 | 0 | 1,298,865 |
| Delegate | 5,045,837 | 37,040 | 1,997,994 |
| Undelegate | 2,184,389 | 804 | 1,684,731 |
| Undelegate (5 delegations, cached external calls) | 9,321,604 | 3,450 | 7,369,045 |
| Delegate (cached external calls) | 2,986,194 | 2,802 | 2,406,369 |
| Undelegate (early exit, 3 of 10 delegations) | 6,507,156 | 2,052 | 5,284,971 |
| Redelegate | 4,231,899 | 1,399 | 3,256,578 |
| Redelegate (50 of 100 delegations, optimized) | 122,741,679 | -98,852 | 97,611,238 |
| Undelegate (50 delegatees, large AVL traversal) | 2,341,309 | 715 | 1,890,639 |
| GovDebtIncrement tokens=bar users=0 operation=query control=empty repeats=1 | 227,473 | 0 | 170,507 |
| GovDebtIncrement tokens=bar users=1 operation=delegate index=0 repeats=1 | 7,716,218 | 35,210 | 6,335,605 |
| GovDebtIncrement tokens=bar users=1 operation=query control=present-zero repeats=1 | 492,780 | 0 | 461,163 |
| GovDebtIncrement tokens=bar users=1 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 5,533,510 | 4,189 | 5,046,693 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=1 repeats=1 | 4,468,923 | 12,507 | 3,752,423 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=2 repeats=1 | 8,477,030 | 12,381 | 7,304,852 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=3 repeats=1 | 8,775,994 | 12,363 | 7,566,864 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=4 repeats=1 | 8,637,227 | 12,387 | 7,440,100 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=5 repeats=1 | 8,699,213 | 12,375 | 7,494,878 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=6 repeats=1 | 8,614,041 | 12,393 | 7,417,628 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=7 repeats=1 | 8,598,307 | 12,398 | 7,398,490 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=8 repeats=1 | 8,891,028 | 12,399 | 7,647,350 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=9 repeats=1 | 8,844,040 | 12,454 | 7,593,875 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=10 repeats=1 | 8,826,381 | 12,490 | 7,568,226 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=11 repeats=1 | 8,853,773 | 12,443 | 7,596,190 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=12 repeats=1 | 8,960,707 | 12,413 | 7,680,994 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=13 repeats=1 | 8,820,241 | 12,429 | 7,553,595 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=14 repeats=1 | 8,795,144 | 12,429 | 7,525,358 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=15 repeats=1 | 8,860,184 | 12,397 | 7,583,190 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=16 repeats=1 | 9,649,097 | 45,329 | 8,198,341 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=17 repeats=1 | 9,010,956 | 12,559 | 7,736,127 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=18 repeats=1 | 9,033,213 | 12,355 | 7,735,232 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=19 repeats=1 | 9,121,518 | 12,361 | 7,805,848 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=20 repeats=1 | 9,164,973 | 12,469 | 7,849,175 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=21 repeats=1 | 9,083,899 | 12,421 | 7,773,428 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=22 repeats=1 | 9,215,649 | 12,397 | 7,886,604 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=23 repeats=1 | 9,269,324 | 12,415 | 7,928,573 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=24 repeats=1 | 9,261,183 | 15,803 | 7,906,471 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=25 repeats=1 | 9,201,986 | 12,421 | 7,863,858 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=26 repeats=1 | 9,121,893 | 12,373 | 7,793,558 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=27 repeats=1 | 9,582,206 | 22,464 | 8,165,591 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=28 repeats=1 | 9,057,266 | 12,431 | 7,753,611 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=29 repeats=1 | 9,166,660 | 12,412 | 7,850,214 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=30 repeats=1 | 9,150,645 | 12,644 | 7,839,354 |
| GovDebtIncrement tokens=bar users=32 operation=delegate index=31 repeats=1 | 9,341,942 | 15,849 | 7,988,902 |
| GovDebtIncrement tokens=bar users=32 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 5,400,409 | -62 | 4,999,135 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=32 repeats=1 | 5,171,423 | 15,841 | 4,303,020 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=33 repeats=1 | 9,188,587 | 12,510 | 7,865,337 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=34 repeats=1 | 9,115,232 | 12,505 | 7,796,619 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=35 repeats=1 | 9,067,839 | 12,462 | 7,753,632 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=36 repeats=1 | 9,153,597 | 12,462 | 7,822,986 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=37 repeats=1 | 9,531,168 | 22,572 | 8,122,045 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=38 repeats=1 | 9,230,594 | 12,459 | 7,904,438 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=39 repeats=1 | 9,252,685 | 12,417 | 7,922,316 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=40 repeats=1 | 9,513,717 | 15,828 | 8,114,538 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=41 repeats=1 | 9,259,651 | 12,492 | 7,904,506 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=42 repeats=1 | 9,244,890 | 12,420 | 7,886,437 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=43 repeats=1 | 9,210,546 | 12,426 | 7,844,901 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=44 repeats=1 | 9,228,779 | 12,450 | 7,858,208 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=45 repeats=1 | 9,492,848 | 12,414 | 8,082,207 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=46 repeats=1 | 9,809,957 | 25,530 | 8,355,733 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=47 repeats=1 | 9,186,805 | 12,456 | 7,857,803 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=48 repeats=1 | 9,378,322 | 15,789 | 8,005,757 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=49 repeats=1 | 9,271,704 | 12,438 | 7,919,927 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=50 repeats=1 | 9,252,409 | 12,426 | 7,899,481 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=51 repeats=1 | 9,350,868 | 12,444 | 7,978,334 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=52 repeats=1 | 9,295,953 | 12,414 | 7,933,898 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=53 repeats=1 | 9,322,306 | 12,414 | 7,947,731 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=54 repeats=1 | 9,335,602 | 12,480 | 7,945,740 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=55 repeats=1 | 9,563,598 | 22,224 | 8,157,035 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=56 repeats=1 | 9,228,319 | 15,741 | 7,893,903 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=57 repeats=1 | 8,994,373 | 12,456 | 7,692,140 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=58 repeats=1 | 8,930,950 | 12,438 | 7,623,820 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=59 repeats=1 | 9,032,334 | 12,414 | 7,708,152 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=60 repeats=1 | 9,011,873 | 12,417 | 7,709,688 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=61 repeats=1 | 9,275,574 | 15,765 | 7,917,242 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=62 repeats=1 | 8,972,891 | 12,447 | 7,667,928 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=63 repeats=1 | 9,254,835 | 12,413 | 7,911,667 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=64 repeats=1 | 9,504,417 | 31,386 | 8,040,965 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=65 repeats=1 | 9,076,964 | 12,478 | 7,759,092 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=66 repeats=1 | 9,592,508 | 22,236 | 8,210,322 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=67 repeats=1 | 9,056,845 | 12,580 | 7,745,209 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=68 repeats=1 | 8,944,647 | 12,442 | 7,659,273 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=69 repeats=1 | 9,191,713 | 12,436 | 7,868,445 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=70 repeats=1 | 9,015,651 | 12,574 | 7,725,184 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=71 repeats=1 | 9,093,657 | 12,520 | 7,780,833 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=72 repeats=1 | 9,157,626 | 15,835 | 7,828,946 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=73 repeats=1 | 9,131,148 | 12,526 | 7,808,399 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=74 repeats=1 | 9,130,265 | 12,544 | 7,800,396 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=75 repeats=1 | 9,047,839 | 12,478 | 7,725,984 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=76 repeats=1 | 9,236,346 | 15,772 | 7,886,205 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=77 repeats=1 | 9,434,723 | 22,573 | 8,035,367 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=78 repeats=1 | 8,896,275 | 12,483 | 7,609,999 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=79 repeats=1 | 9,089,598 | 12,450 | 7,773,836 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=80 repeats=1 | 9,201,539 | 15,837 | 7,846,874 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=81 repeats=1 | 9,142,578 | 12,505 | 7,804,168 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=82 repeats=1 | 9,053,954 | 12,424 | 7,732,695 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=83 repeats=1 | 9,236,856 | 12,442 | 7,887,342 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=84 repeats=1 | 8,936,667 | 12,463 | 7,624,424 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=85 repeats=1 | 8,933,200 | 12,417 | 7,621,909 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=86 repeats=1 | 9,283,098 | 22,199 | 7,923,476 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=87 repeats=1 | 8,905,815 | 12,435 | 7,623,783 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=88 repeats=1 | 8,938,080 | 15,833 | 7,620,204 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=89 repeats=1 | 8,918,845 | 12,460 | 7,614,084 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=90 repeats=1 | 8,724,460 | 12,526 | 7,457,466 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=91 repeats=1 | 9,115,500 | 15,822 | 7,779,719 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=92 repeats=1 | 9,005,157 | 12,502 | 7,698,175 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=93 repeats=1 | 8,924,542 | 12,509 | 7,623,796 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=94 repeats=1 | 8,839,112 | 12,521 | 7,540,021 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=95 repeats=1 | 8,946,307 | 12,472 | 7,631,435 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=96 repeats=1 | 9,120,063 | 15,675 | 7,773,380 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=97 repeats=1 | 9,420,734 | 22,573 | 8,022,221 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=98 repeats=1 | 8,824,690 | 12,480 | 7,536,357 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=99 repeats=1 | 8,915,140 | 12,421 | 7,607,882 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=100 repeats=1 | 8,994,719 | 12,482 | 7,667,048 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=101 repeats=1 | 9,136,399 | 12,443 | 7,783,135 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=102 repeats=1 | 8,852,869 | 12,409 | 7,538,213 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=103 repeats=1 | 8,946,035 | 12,413 | 7,617,481 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=104 repeats=1 | 9,573,695 | 22,251 | 8,131,379 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=105 repeats=1 | 8,964,299 | 12,426 | 7,647,718 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=106 repeats=1 | 8,857,777 | 15,714 | 7,560,618 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=107 repeats=1 | 8,962,667 | 15,686 | 7,651,279 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=108 repeats=1 | 8,818,705 | 12,467 | 7,539,907 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=109 repeats=1 | 8,820,218 | 12,427 | 7,538,228 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=110 repeats=1 | 8,853,010 | 12,444 | 7,562,183 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=111 repeats=1 | 8,986,979 | 12,429 | 7,680,152 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=112 repeats=1 | 8,971,659 | 12,436 | 7,662,094 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=113 repeats=1 | 9,445,817 | 22,285 | 8,037,412 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=114 repeats=1 | 8,951,245 | 12,555 | 7,638,357 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=115 repeats=1 | 9,144,291 | 15,848 | 7,781,113 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=116 repeats=1 | 8,786,655 | 12,517 | 7,499,960 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=117 repeats=1 | 8,963,419 | 12,504 | 7,646,073 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=118 repeats=1 | 8,784,365 | 12,478 | 7,497,317 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=119 repeats=1 | 8,909,874 | 12,483 | 7,598,320 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=120 repeats=1 | 8,808,698 | 12,431 | 7,523,027 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=121 repeats=1 | 8,796,384 | 15,748 | 7,514,548 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=122 repeats=1 | 8,551,926 | 12,460 | 7,306,929 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=123 repeats=1 | 8,844,910 | 15,779 | 7,546,310 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=124 repeats=1 | 8,544,603 | 12,470 | 7,291,063 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=125 repeats=1 | 9,149,928 | 22,231 | 7,785,450 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=126 repeats=1 | 8,539,867 | 12,552 | 7,309,958 |
| GovDebtIncrement tokens=bar users=128 operation=delegate index=127 repeats=1 | 8,627,965 | 20,561 | 7,336,070 |
| GovDebtIncrement tokens=bar users=128 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 5,259,132 | -96 | 4,886,787 |
| GovDebtIncrement tokens=bar users=128 operation=claim-noop window_repeats=1 index=0 repeats=1 | 2,073,303 | 0 | 1,890,660 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-partial index=0 repeats=1 | 3,365,365 | 1,545 | 2,926,875 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=0 repeats=1 | 6,976,766 | 1,511 | 6,213,705 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=1 repeats=1 | 7,345,860 | 1,546 | 6,577,862 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=2 repeats=1 | 7,336,103 | 1,546 | 6,566,950 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=3 repeats=1 | 7,357,549 | 1,546 | 6,587,253 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=4 repeats=1 | 7,437,743 | 1,570 | 6,583,480 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=5 repeats=1 | 7,448,235 | 1,570 | 6,592,823 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=6 repeats=1 | 7,369,266 | 1,546 | 6,595,523 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=7 repeats=1 | 7,500,362 | 4,858 | 6,698,818 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=8 repeats=1 | 7,348,704 | 1,570 | 6,581,846 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=9 repeats=1 | 7,369,758 | 1,546 | 6,601,749 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=10 repeats=1 | 7,362,504 | 1,546 | 6,593,349 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=11 repeats=1 | 7,350,280 | 1,546 | 6,579,976 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=12 repeats=1 | 7,449,226 | 1,546 | 6,593,371 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=13 repeats=1 | 7,471,271 | 1,546 | 6,614,267 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=14 repeats=1 | 7,369,793 | 1,546 | 6,596,042 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=15 repeats=1 | 7,370,787 | 1,546 | 6,595,887 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=16 repeats=1 | 7,473,493 | 1,546 | 6,613,045 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=17 repeats=1 | 7,457,905 | 1,546 | 6,598,450 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=18 repeats=1 | 7,452,358 | 1,546 | 6,591,754 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=19 repeats=1 | 7,468,593 | 1,558 | 6,606,840 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=20 repeats=1 | 7,386,636 | 1,546 | 6,605,994 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=21 repeats=1 | 7,398,116 | 1,546 | 6,616,325 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=22 repeats=1 | 7,502,231 | 4,858 | 6,692,390 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=23 repeats=1 | 7,373,273 | 1,570 | 6,598,373 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=24 repeats=1 | 7,356,306 | 1,546 | 6,580,251 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=25 repeats=1 | 7,378,719 | 1,546 | 6,601,521 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=26 repeats=1 | 7,383,779 | 1,546 | 6,605,432 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=27 repeats=1 | 7,368,621 | 1,529 | 6,589,125 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=28 repeats=1 | 7,376,547 | 1,516 | 6,595,880 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=29 repeats=1 | 7,377,448 | 1,516 | 6,595,632 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=30 repeats=1 | 7,370,449 | 1,516 | 6,587,490 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=31 repeats=1 | 7,371,840 | 1,517 | 6,587,729 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=32 repeats=1 | 7,366,311 | 1,516 | 6,581,048 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=33 repeats=1 | 7,381,807 | 1,516 | 6,595,395 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=34 repeats=1 | 7,383,933 | 1,516 | 6,596,372 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=35 repeats=1 | 7,369,507 | 1,516 | 6,580,797 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=36 repeats=1 | 7,393,515 | 1,516 | 6,603,656 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=37 repeats=1 | 7,579,478 | 4,864 | 6,678,496 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=38 repeats=1 | 7,456,069 | 1,540 | 6,589,479 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=39 repeats=1 | 7,451,219 | 1,516 | 6,583,480 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=40 repeats=1 | 7,372,899 | 1,516 | 6,587,627 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=41 repeats=1 | 7,472,917 | 1,516 | 6,603,684 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=42 repeats=1 | 7,374,946 | 1,516 | 6,587,376 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=43 repeats=1 | 7,468,388 | 1,516 | 6,596,857 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=44 repeats=1 | 7,468,312 | 1,516 | 6,595,632 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=45 repeats=1 | 7,475,169 | 1,516 | 6,601,340 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=46 repeats=1 | 7,467,690 | 1,516 | 6,592,712 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=47 repeats=1 | 7,485,623 | 1,516 | 6,609,496 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=48 repeats=1 | 7,482,252 | 1,516 | 6,604,976 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=49 repeats=1 | 7,482,176 | 1,516 | 6,603,751 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=50 repeats=1 | 7,474,224 | 1,516 | 6,594,650 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=51 repeats=1 | 7,480,694 | 1,516 | 6,599,971 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=52 repeats=1 | 7,605,387 | 4,828 | 6,696,104 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=53 repeats=1 | 7,469,967 | 1,540 | 6,596,135 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=54 repeats=1 | 7,475,973 | 1,516 | 6,600,992 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=55 repeats=1 | 7,462,524 | 1,516 | 6,586,394 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=56 repeats=1 | 7,481,447 | 1,516 | 6,604,168 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=57 repeats=1 | 7,466,534 | 1,516 | 6,588,106 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=58 repeats=1 | 7,496,561 | 1,516 | 6,612,190 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=59 repeats=1 | 7,502,688 | 1,516 | 6,617,168 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=60 repeats=1 | 7,506,803 | 1,518 | 6,624,118 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=61 repeats=1 | 7,654,746 | 9,575 | 6,695,615 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=62 repeats=1 | 7,446,477 | 1,540 | 6,592,067 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=63 repeats=1 | 7,454,827 | 1,516 | 6,599,268 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=64 repeats=1 | 7,449,741 | 1,516 | 6,593,033 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=65 repeats=1 | 7,452,605 | 1,516 | 6,594,748 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=66 repeats=1 | 7,450,222 | 1,516 | 6,591,216 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=67 repeats=1 | 7,594,261 | 4,840 | 6,706,440 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=68 repeats=1 | 7,434,655 | 1,540 | 6,582,282 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=69 repeats=1 | 7,448,182 | 1,528 | 6,594,660 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=70 repeats=1 | 7,339,564 | 1,516 | 6,568,767 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=71 repeats=1 | 7,354,331 | 1,516 | 6,582,385 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=72 repeats=1 | 7,340,639 | 1,516 | 6,567,544 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=73 repeats=1 | 7,362,445 | 1,516 | 6,588,201 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=74 repeats=1 | 7,381,092 | 1,516 | 6,605,699 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=75 repeats=1 | 7,378,375 | 1,516 | 6,601,833 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=76 repeats=1 | 7,357,261 | 1,516 | 6,579,570 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=77 repeats=1 | 7,454,589 | 1,552 | 6,592,943 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=78 repeats=1 | 7,372,085 | 1,516 | 6,592,096 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=79 repeats=1 | 7,371,914 | 1,516 | 6,590,776 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=80 repeats=1 | 7,391,287 | 1,516 | 6,609,000 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=81 repeats=1 | 7,477,051 | 1,516 | 6,608,871 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=82 repeats=1 | 7,522,223 | 4,828 | 6,709,717 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=83 repeats=1 | 7,450,038 | 1,540 | 6,588,749 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=84 repeats=1 | 7,439,356 | 1,516 | 6,576,918 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=85 repeats=1 | 7,457,657 | 1,516 | 6,594,070 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=86 repeats=1 | 7,461,259 | 1,516 | 6,596,523 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=87 repeats=1 | 7,447,072 | 1,516 | 6,581,187 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=88 repeats=1 | 7,468,143 | 1,516 | 6,601,109 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=89 repeats=1 | 7,454,202 | 1,528 | 6,586,019 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=90 repeats=1 | 7,385,202 | 1,516 | 6,600,614 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=91 repeats=1 | 7,409,360 | 1,516 | 6,623,623 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=92 repeats=1 | 7,410,019 | 1,516 | 6,623,133 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=93 repeats=1 | 7,396,573 | 1,516 | 6,608,538 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=94 repeats=1 | 7,397,725 | 1,517 | 6,608,538 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=95 repeats=1 | 7,398,376 | 1,516 | 6,608,040 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=96 repeats=1 | 7,430,137 | 1,522 | 6,616,050 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=97 repeats=1 | 7,613,028 | 4,834 | 6,685,670 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=98 repeats=1 | 7,486,679 | 1,546 | 6,595,537 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=99 repeats=1 | 7,531,790 | 1,534 | 6,636,908 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=100 repeats=1 | 7,533,003 | 1,522 | 6,638,622 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=101 repeats=1 | 7,533,904 | 1,522 | 6,638,374 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=102 repeats=1 | 7,534,327 | 1,522 | 6,637,648 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=103 repeats=1 | 7,541,774 | 1,522 | 6,643,946 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=104 repeats=1 | 7,542,923 | 1,522 | 6,643,946 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=105 repeats=1 | 7,540,292 | 1,528 | 6,664,499 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=106 repeats=1 | 7,546,754 | 1,516 | 6,664,502 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=107 repeats=1 | 7,523,747 | 1,528 | 6,645,656 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=108 repeats=1 | 7,544,317 | 1,516 | 6,659,767 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=109 repeats=1 | 7,542,658 | 1,516 | 6,656,959 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=110 repeats=1 | 7,549,304 | 1,516 | 6,662,456 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=111 repeats=1 | 7,556,025 | 1,516 | 6,668,028 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=112 repeats=1 | 7,887,331 | 11,609 | 6,929,585 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=113 repeats=1 | 7,567,488 | 1,588 | 6,680,977 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=114 repeats=1 | 7,587,896 | 1,516 | 6,699,952 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=115 repeats=1 | 7,589,296 | 1,528 | 6,700,203 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=116 repeats=1 | 7,591,909 | 1,516 | 6,701,667 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=117 repeats=1 | 7,592,081 | 1,528 | 6,700,690 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=118 repeats=1 | 7,598,707 | 1,516 | 6,706,167 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=119 repeats=1 | 7,606,064 | 1,528 | 6,712,375 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=120 repeats=1 | 7,600,818 | 1,516 | 6,709,190 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=121 repeats=1 | 7,588,594 | 1,516 | 6,695,817 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=122 repeats=1 | 7,586,451 | 1,516 | 6,692,525 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=123 repeats=1 | 7,638,137 | 1,524 | 6,716,875 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=124 repeats=1 | 7,809,421 | 9,581 | 6,811,617 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=125 repeats=1 | 7,570,380 | 1,558 | 6,677,393 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=126 repeats=1 | 7,592,940 | 1,522 | 6,698,804 |
| GovDebtIncrement tokens=bar users=128 operation=undelegate-full index=127 repeats=1 | 7,652,536 | 4,853 | 6,731,460 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=0 repeats=1 | 5,352,759 | -8,363 | 4,744,185 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=0 repeats=1 | 2,422,392 | 0 | 2,199,561 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=1 repeats=1 | 2,179,507 | -2,163 | 1,909,299 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=1 repeats=1 | 2,980,150 | 2,178 | 2,697,592 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=2 repeats=1 | 2,187,713 | -5,623 | 1,922,045 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=2 repeats=1 | 3,095,751 | 2,178 | 2,795,880 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=3 repeats=1 | 2,368,633 | -5,612 | 2,083,728 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=3 repeats=1 | 3,119,546 | 2,191 | 2,818,759 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=4 repeats=1 | 2,358,620 | -2,152 | 2,033,549 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=4 repeats=1 | 3,114,986 | 2,185 | 2,737,958 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=5 repeats=1 | 2,297,962 | -5,630 | 1,992,338 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=5 repeats=1 | 3,192,265 | 2,178 | 2,802,213 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=6 repeats=1 | 2,166,091 | -5,618 | 1,910,101 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=6 repeats=1 | 3,104,233 | 2,178 | 2,796,941 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=7 repeats=1 | 2,155,087 | -2,163 | 1,888,460 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=7 repeats=1 | 3,115,339 | 2,178 | 2,808,041 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=8 repeats=1 | 2,210,850 | -2,163 | 1,940,241 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=8 repeats=1 | 3,280,816 | 2,178 | 2,951,710 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=9 repeats=1 | 2,380,607 | -2,177 | 2,086,541 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=9 repeats=1 | 3,307,556 | 2,185 | 2,973,367 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=10 repeats=1 | 2,214,659 | -2,172 | 1,948,209 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=10 repeats=1 | 3,155,123 | 2,178 | 2,840,507 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=11 repeats=1 | 2,339,536 | -2,154 | 2,047,312 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=11 repeats=1 | 3,241,188 | 2,185 | 2,914,999 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=12 repeats=1 | 2,322,901 | -2,184 | 2,006,307 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=12 repeats=1 | 3,278,424 | 2,191 | 2,871,971 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=13 repeats=1 | 2,341,864 | -2,184 | 2,030,245 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=13 repeats=1 | 3,430,430 | 2,185 | 3,008,796 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=14 repeats=1 | 2,282,378 | -2,185 | 2,009,405 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=14 repeats=1 | 3,287,261 | 2,185 | 2,953,695 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=15 repeats=1 | 2,314,088 | -2,184 | 2,024,957 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=15 repeats=1 | 3,333,357 | 2,191 | 2,996,125 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=16 repeats=1 | 2,376,584 | -2,190 | 2,047,057 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=16 repeats=1 | 3,422,322 | 2,172 | 2,997,464 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=17 repeats=1 | 2,180,092 | -2,183 | 1,875,385 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=17 repeats=1 | 3,407,984 | 2,184 | 2,989,944 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=18 repeats=1 | 2,227,479 | -2,202 | 1,920,111 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=18 repeats=1 | 3,285,352 | 2,178 | 2,888,388 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=19 repeats=1 | 2,223,389 | -2,177 | 1,918,584 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=19 repeats=1 | 3,463,338 | 2,178 | 3,045,488 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=20 repeats=1 | 2,303,130 | -2,190 | 2,019,161 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=20 repeats=1 | 3,335,485 | 2,179 | 2,991,828 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=21 repeats=1 | 2,249,302 | -2,171 | 1,971,031 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=21 repeats=1 | 3,307,466 | 2,184 | 2,962,329 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=22 repeats=1 | 2,426,989 | -2,182 | 2,126,948 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=22 repeats=1 | 3,441,384 | 2,185 | 3,080,219 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=23 repeats=1 | 2,559,390 | -2,184 | 2,224,429 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=23 repeats=1 | 3,409,322 | 2,185 | 3,051,765 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=24 repeats=1 | 2,330,807 | -2,165 | 2,025,482 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=24 repeats=1 | 3,284,344 | 2,184 | 2,939,201 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=25 repeats=1 | 2,442,246 | -2,183 | 2,130,507 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=25 repeats=1 | 3,454,058 | 2,185 | 3,092,864 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=26 repeats=1 | 2,356,450 | -2,202 | 2,052,915 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=26 repeats=1 | 3,312,372 | 2,178 | 2,967,177 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=27 repeats=1 | 2,285,965 | -2,183 | 1,992,462 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=27 repeats=1 | 3,295,422 | 2,178 | 2,950,285 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=28 repeats=1 | 2,547,220 | -2,192 | 2,222,673 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=28 repeats=1 | 3,443,972 | 2,191 | 3,082,760 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=29 repeats=1 | 2,483,196 | -5,615 | 2,181,677 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=29 repeats=1 | 3,441,053 | 2,191 | 3,079,870 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=30 repeats=1 | 2,329,400 | -2,207 | 2,044,611 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=30 repeats=1 | 3,393,642 | 2,167 | 3,035,986 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=31 repeats=1 | 2,366,477 | -2,180 | 2,079,605 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=31 repeats=1 | 3,433,861 | 2,191 | 3,072,626 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=32 repeats=1 | 2,273,263 | -2,187 | 1,998,893 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=32 repeats=1 | 3,383,226 | 2,191 | 3,025,628 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=33 repeats=1 | 2,322,656 | -2,187 | 2,041,313 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=33 repeats=1 | 3,391,748 | 2,191 | 3,034,179 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=34 repeats=1 | 2,223,017 | -2,189 | 1,955,841 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=34 repeats=1 | 3,432,027 | 2,166 | 3,067,802 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=35 repeats=1 | 2,255,258 | -2,187 | 1,984,785 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=35 repeats=1 | 3,436,206 | 2,185 | 3,066,898 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=36 repeats=1 | 2,497,999 | -2,192 | 2,180,560 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=36 repeats=1 | 3,349,535 | 2,184 | 2,991,829 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=37 repeats=1 | 2,382,729 | -2,157 | 2,034,685 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=37 repeats=1 | 3,416,383 | 2,178 | 2,975,917 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=38 repeats=1 | 2,483,010 | -2,194 | 2,127,688 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=38 repeats=1 | 3,572,243 | 2,226 | 3,115,640 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=39 repeats=1 | 2,481,424 | -2,193 | 2,127,584 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=39 repeats=1 | 3,572,363 | 2,239 | 3,115,628 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=40 repeats=1 | 2,390,757 | -2,188 | 2,079,129 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=40 repeats=1 | 3,310,159 | 2,202 | 2,962,886 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=41 repeats=1 | 2,531,808 | -2,169 | 2,169,944 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=41 repeats=1 | 3,502,744 | 2,197 | 3,060,530 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=42 repeats=1 | 2,384,484 | -2,187 | 2,076,557 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=42 repeats=1 | 3,382,771 | 2,196 | 3,021,819 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=43 repeats=1 | 2,616,767 | -2,187 | 2,246,708 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=43 repeats=1 | 3,609,276 | 2,197 | 3,149,512 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=44 repeats=1 | 2,512,187 | -5,668 | 2,168,039 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=44 repeats=1 | 3,560,617 | 2,197 | 3,104,519 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=45 repeats=1 | 2,403,788 | -2,187 | 2,075,498 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=45 repeats=1 | 3,608,673 | 2,203 | 3,148,909 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=46 repeats=1 | 2,453,303 | -2,200 | 2,119,030 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=46 repeats=1 | 3,610,624 | 2,191 | 3,150,819 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=47 repeats=1 | 2,413,634 | -2,187 | 2,088,255 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=47 repeats=1 | 3,627,233 | 2,209 | 3,167,358 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=48 repeats=1 | 2,255,686 | -2,188 | 1,947,605 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=48 repeats=1 | 3,478,651 | 2,202 | 3,034,887 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=49 repeats=1 | 2,412,036 | -2,187 | 2,088,554 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=49 repeats=1 | 3,619,408 | 2,197 | 3,159,644 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=50 repeats=1 | 2,457,579 | -2,170 | 2,127,187 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=50 repeats=1 | 3,641,647 | 2,197 | 3,179,618 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=51 repeats=1 | 2,632,239 | -2,174 | 2,267,395 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=51 repeats=1 | 3,650,676 | 2,203 | 3,187,892 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=52 repeats=1 | 2,543,300 | -2,181 | 2,180,339 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=52 repeats=1 | 3,653,016 | 2,203 | 3,190,179 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=53 repeats=1 | 2,548,097 | -2,193 | 2,186,647 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=53 repeats=1 | 3,662,756 | 2,203 | 3,199,948 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=54 repeats=1 | 2,401,882 | -2,195 | 2,057,718 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=54 repeats=1 | 3,521,282 | 2,184 | 3,074,235 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=55 repeats=1 | 2,652,024 | -2,193 | 2,271,581 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=55 repeats=1 | 3,609,489 | 2,197 | 3,150,284 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=56 repeats=1 | 2,594,704 | -2,181 | 2,230,187 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=56 repeats=1 | 3,663,157 | 2,197 | 3,200,337 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=57 repeats=1 | 2,531,075 | -2,194 | 2,175,510 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=57 repeats=1 | 3,591,288 | 2,197 | 3,133,056 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=58 repeats=1 | 2,441,852 | -5,680 | 2,107,278 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=58 repeats=1 | 3,524,016 | 2,196 | 3,067,737 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=59 repeats=1 | 2,440,150 | -2,193 | 2,103,135 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=59 repeats=1 | 3,621,725 | 2,197 | 3,153,317 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=60 repeats=1 | 2,352,591 | -2,200 | 2,030,228 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=60 repeats=1 | 3,610,667 | 2,197 | 3,143,644 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=61 repeats=1 | 2,482,798 | -2,187 | 2,143,437 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=61 repeats=1 | 3,643,335 | 2,203 | 3,172,675 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=62 repeats=1 | 2,434,267 | -2,181 | 2,104,773 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=62 repeats=1 | 3,560,570 | 2,203 | 3,097,714 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=63 repeats=1 | 2,437,890 | -2,193 | 2,109,924 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=63 repeats=1 | 3,703,287 | 2,197 | 3,224,431 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=64 repeats=1 | 2,422,715 | -2,188 | 2,096,289 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=64 repeats=1 | 3,699,364 | 2,197 | 3,220,537 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=65 repeats=1 | 2,508,385 | -2,186 | 2,158,320 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=65 repeats=1 | 3,658,542 | 2,203 | 3,183,294 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=66 repeats=1 | 2,541,773 | -5,693 | 2,198,507 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=66 repeats=1 | 3,691,255 | 2,191 | 3,212,375 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=67 repeats=1 | 2,341,921 | -2,194 | 2,015,469 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=67 repeats=1 | 3,678,830 | 2,190 | 3,197,414 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=68 repeats=1 | 2,335,888 | -2,199 | 2,011,278 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=68 repeats=1 | 3,544,870 | 2,196 | 3,081,814 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=69 repeats=1 | 2,431,450 | -2,187 | 2,101,036 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=69 repeats=1 | 3,698,675 | 2,197 | 3,219,619 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=70 repeats=1 | 2,313,055 | -2,221 | 2,032,206 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=70 repeats=1 | 3,547,655 | 2,191 | 3,160,611 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=71 repeats=1 | 2,327,164 | -2,193 | 2,044,073 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=71 repeats=1 | 3,510,716 | 2,203 | 3,127,355 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=72 repeats=1 | 2,306,642 | -2,187 | 2,028,762 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=72 repeats=1 | 3,542,170 | 2,203 | 3,155,172 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=73 repeats=1 | 2,454,735 | -2,211 | 2,145,868 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=73 repeats=1 | 3,511,088 | 2,197 | 3,127,698 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=74 repeats=1 | 2,320,789 | -2,187 | 2,018,153 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=74 repeats=1 | 3,422,282 | 2,196 | 3,051,330 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=75 repeats=1 | 2,406,429 | -2,193 | 2,096,871 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=75 repeats=1 | 3,512,679 | 2,197 | 3,129,277 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=76 repeats=1 | 2,415,671 | -2,205 | 2,098,308 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=76 repeats=1 | 3,403,023 | 2,196 | 3,031,972 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=77 repeats=1 | 2,351,488 | -2,169 | 2,013,050 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=77 repeats=1 | 3,493,015 | 2,190 | 3,039,216 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=78 repeats=1 | 2,370,985 | -2,207 | 2,064,557 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=78 repeats=1 | 3,414,116 | 2,172 | 3,043,106 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=79 repeats=1 | 2,406,746 | -2,199 | 2,095,942 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=79 repeats=1 | 3,483,603 | 2,190 | 3,098,195 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=80 repeats=1 | 2,397,935 | -5,680 | 2,104,842 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=80 repeats=1 | 3,494,703 | 2,184 | 3,109,295 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=81 repeats=1 | 2,516,979 | -2,193 | 2,168,204 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=81 repeats=1 | 3,711,080 | 2,197 | 3,224,928 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=82 repeats=1 | 2,487,594 | -2,193 | 2,179,764 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=82 repeats=1 | 3,635,448 | 2,203 | 3,234,028 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=83 repeats=1 | 2,417,671 | -2,187 | 2,082,938 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=83 repeats=1 | 3,663,413 | 2,203 | 3,180,915 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=84 repeats=1 | 2,299,519 | -2,213 | 1,978,681 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=84 repeats=1 | 3,557,275 | 2,178 | 3,087,123 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=85 repeats=1 | 2,470,798 | -2,187 | 2,129,921 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=85 repeats=1 | 3,668,901 | 2,197 | 3,186,328 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=86 repeats=1 | 2,453,126 | -2,193 | 2,119,108 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=86 repeats=1 | 3,668,898 | 2,203 | 3,186,342 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=87 repeats=1 | 2,369,560 | -2,192 | 2,032,988 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=87 repeats=1 | 3,551,410 | 2,196 | 3,081,333 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=88 repeats=1 | 2,526,674 | -5,680 | 2,180,609 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=88 repeats=1 | 3,662,409 | 2,191 | 3,179,923 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=89 repeats=1 | 2,360,518 | -2,187 | 2,030,902 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=89 repeats=1 | 3,650,353 | 2,203 | 3,167,867 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=90 repeats=1 | 2,282,569 | -2,207 | 2,003,717 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=90 repeats=1 | 3,507,182 | 2,191 | 3,123,838 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=91 repeats=1 | 2,283,740 | -2,193 | 2,003,176 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=91 repeats=1 | 3,491,769 | 2,196 | 3,106,419 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=92 repeats=1 | 2,373,572 | -2,187 | 2,085,765 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=92 repeats=1 | 3,636,805 | 2,197 | 3,235,397 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=93 repeats=1 | 2,324,247 | -2,206 | 2,041,576 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=93 repeats=1 | 3,581,587 | 2,197 | 3,183,787 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=94 repeats=1 | 2,212,573 | -2,187 | 1,943,855 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=94 repeats=1 | 3,479,725 | 2,196 | 3,094,375 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=95 repeats=1 | 2,381,832 | -2,192 | 2,084,617 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=95 repeats=1 | 3,674,906 | 2,190 | 3,266,082 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=96 repeats=1 | 2,372,126 | -5,325 | 2,087,363 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=96 repeats=1 | 3,549,482 | 2,190 | 3,151,533 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=97 repeats=1 | 2,255,766 | -2,193 | 1,944,653 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=97 repeats=1 | 3,618,438 | 2,190 | 3,136,601 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=98 repeats=1 | 2,217,320 | -2,212 | 1,915,318 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=98 repeats=1 | 3,537,423 | 2,184 | 3,076,157 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=99 repeats=1 | 2,392,925 | -2,187 | 2,069,273 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=99 repeats=1 | 3,666,829 | 2,197 | 3,189,826 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=100 repeats=1 | 2,426,408 | -2,205 | 2,097,530 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=100 repeats=1 | 3,673,964 | 2,203 | 3,200,952 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=101 repeats=1 | 2,479,015 | -2,199 | 2,144,084 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=101 repeats=1 | 3,672,996 | 2,203 | 3,199,984 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=102 repeats=1 | 2,578,386 | -2,200 | 2,232,262 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=102 repeats=1 | 3,721,643 | 2,197 | 3,244,953 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=103 repeats=1 | 2,529,677 | -5,667 | 2,188,684 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=103 repeats=1 | 3,673,020 | 2,203 | 3,199,984 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=104 repeats=1 | 2,333,072 | -2,206 | 2,010,218 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=104 repeats=1 | 3,575,024 | 2,184 | 3,114,404 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=105 repeats=1 | 2,381,344 | -2,188 | 2,056,092 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=105 repeats=1 | 3,685,064 | 2,197 | 3,212,052 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=106 repeats=1 | 2,487,443 | -2,207 | 2,148,789 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=106 repeats=1 | 3,752,705 | 2,197 | 3,269,742 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=107 repeats=1 | 2,429,830 | -2,182 | 2,098,941 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=107 repeats=1 | 3,704,929 | 2,197 | 3,225,829 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=108 repeats=1 | 2,433,133 | -2,195 | 2,102,151 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=108 repeats=1 | 3,724,873 | 2,197 | 3,240,434 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=109 repeats=1 | 2,384,288 | -2,194 | 2,062,186 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=109 repeats=1 | 3,722,307 | 2,203 | 3,237,897 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=110 repeats=1 | 2,432,707 | -2,201 | 2,104,642 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=110 repeats=1 | 3,772,290 | 2,197 | 3,284,185 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=111 repeats=1 | 2,539,324 | -2,200 | 2,185,755 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=111 repeats=1 | 3,725,250 | 2,203 | 3,240,811 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=112 repeats=1 | 2,531,035 | -9,104 | 2,199,307 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=112 repeats=1 | 3,771,310 | 2,197 | 3,283,205 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=113 repeats=1 | 2,331,460 | -2,194 | 2,012,247 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=113 repeats=1 | 3,728,181 | 2,203 | 3,243,713 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=114 repeats=1 | 2,372,824 | -2,207 | 2,051,447 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=114 repeats=1 | 3,624,610 | 2,197 | 3,152,329 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=115 repeats=1 | 2,380,021 | -2,194 | 2,054,757 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=115 repeats=1 | 3,723,299 | 2,197 | 3,238,889 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=116 repeats=1 | 2,278,774 | -2,195 | 1,971,387 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=116 repeats=1 | 3,774,253 | 2,197 | 3,286,119 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=117 repeats=1 | 2,280,280 | -2,188 | 1,973,335 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=117 repeats=1 | 3,727,213 | 2,203 | 3,242,745 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=118 repeats=1 | 2,333,613 | -2,213 | 2,020,618 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=118 repeats=1 | 3,729,767 | 2,197 | 3,245,270 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=119 repeats=1 | 2,274,856 | -2,188 | 1,971,888 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=119 repeats=1 | 3,730,227 | 2,203 | 3,245,759 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=120 repeats=1 | 2,165,026 | -2,207 | 1,877,648 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=120 repeats=1 | 3,570,047 | 2,196 | 3,112,765 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=121 repeats=1 | 2,251,526 | -2,194 | 1,956,102 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=121 repeats=1 | 3,623,761 | 2,197 | 3,157,758 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=122 repeats=1 | 2,165,553 | -2,206 | 1,879,515 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=122 repeats=1 | 3,627,687 | 2,190 | 3,161,614 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=123 repeats=1 | 2,221,636 | -2,194 | 1,932,374 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=123 repeats=1 | 3,736,116 | 2,197 | 3,257,943 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=124 repeats=1 | 2,216,188 | -2,201 | 1,928,428 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=124 repeats=1 | 3,733,538 | 2,197 | 3,255,406 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=125 repeats=1 | 2,154,479 | -2,186 | 1,875,873 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=125 repeats=1 | 3,732,570 | 2,203 | 3,254,438 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=126 repeats=1 | 2,060,365 | -2,201 | 1,795,336 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=126 repeats=1 | 3,640,759 | 2,184 | 3,174,674 |
| GovDebtIncrement tokens=bar users=128 operation=withdraw index=127 repeats=1 | 2,164,097 | -4,636 | 1,897,137 |
| GovDebtIncrement tokens=bar users=128 operation=claim-final index=127 repeats=1 | 3,686,372 | 2,197 | 3,212,354 |
| GovDebtIncrement tokens=bar users=128 operation=restake index=0 repeats=1 | 4,479,683 | 6,483 | 3,824,542 |
| GovDebtIncrement tokens=bar-baz users=0 operation=query control=empty repeats=1 | 227,473 | 0 | 170,507 |
| GovDebtIncrement tokens=bar-baz users=1 operation=delegate index=0 repeats=1 | 7,716,218 | 35,210 | 6,335,605 |
| GovDebtIncrement tokens=bar-baz users=1 operation=query control=present-zero repeats=1 | 492,780 | 0 | 461,163 |
| GovDebtIncrement tokens=bar-baz users=1 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 7,655,981 | 6,486 | 7,044,893 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=1 repeats=1 | 4,552,346 | 13,634 | 3,828,764 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=2 repeats=1 | 8,560,453 | 13,508 | 7,381,193 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=3 repeats=1 | 8,859,417 | 13,490 | 7,643,205 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=4 repeats=1 | 8,720,650 | 13,514 | 7,516,441 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=5 repeats=1 | 8,782,636 | 13,502 | 7,571,219 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=6 repeats=1 | 8,697,464 | 13,520 | 7,493,969 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=7 repeats=1 | 8,681,730 | 13,525 | 7,474,831 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=8 repeats=1 | 8,974,451 | 13,526 | 7,723,691 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=9 repeats=1 | 8,927,463 | 13,581 | 7,670,216 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=10 repeats=1 | 8,909,804 | 13,617 | 7,644,567 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=11 repeats=1 | 8,937,196 | 13,570 | 7,672,531 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=12 repeats=1 | 9,044,130 | 13,540 | 7,757,335 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=13 repeats=1 | 8,903,664 | 13,556 | 7,629,936 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=14 repeats=1 | 8,878,567 | 13,556 | 7,601,699 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=15 repeats=1 | 8,943,607 | 13,524 | 7,659,531 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=16 repeats=1 | 9,732,520 | 46,456 | 8,274,682 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=17 repeats=1 | 9,094,379 | 13,686 | 7,812,468 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=18 repeats=1 | 9,116,636 | 13,482 | 7,811,573 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=19 repeats=1 | 9,204,941 | 13,488 | 7,882,189 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=20 repeats=1 | 9,248,396 | 13,596 | 7,925,516 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=21 repeats=1 | 9,167,322 | 13,548 | 7,849,769 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=22 repeats=1 | 9,299,072 | 13,524 | 7,962,945 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=23 repeats=1 | 9,352,747 | 13,542 | 8,004,914 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=24 repeats=1 | 9,344,606 | 16,930 | 7,982,812 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=25 repeats=1 | 9,285,409 | 13,548 | 7,940,199 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=26 repeats=1 | 9,205,466 | 13,546 | 7,869,899 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=27 repeats=1 | 9,665,998 | 23,697 | 8,241,932 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=28 repeats=1 | 9,140,776 | 13,562 | 7,829,952 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=29 repeats=1 | 9,250,179 | 13,548 | 7,926,555 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=30 repeats=1 | 9,234,224 | 13,780 | 7,915,695 |
| GovDebtIncrement tokens=bar-baz users=32 operation=delegate index=31 repeats=1 | 9,425,536 | 16,985 | 8,065,243 |
| GovDebtIncrement tokens=bar-baz users=32 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 7,537,222 | -136 | 7,005,182 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=32 repeats=1 | 5,255,011 | 16,977 | 4,379,361 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=33 repeats=1 | 9,272,175 | 13,646 | 7,941,678 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=34 repeats=1 | 9,198,838 | 13,641 | 7,872,960 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=35 repeats=1 | 9,151,445 | 13,598 | 7,829,973 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=36 repeats=1 | 9,237,185 | 13,598 | 7,899,327 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=37 repeats=1 | 9,614,792 | 23,693 | 8,198,386 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=38 repeats=1 | 9,314,119 | 13,592 | 7,980,779 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=39 repeats=1 | 9,336,210 | 13,550 | 7,998,657 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=40 repeats=1 | 9,597,236 | 16,964 | 8,190,879 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=41 repeats=1 | 9,343,179 | 13,628 | 7,980,847 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=42 repeats=1 | 9,328,418 | 13,556 | 7,962,778 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=43 repeats=1 | 9,294,083 | 13,562 | 7,921,242 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=44 repeats=1 | 9,312,334 | 13,586 | 7,934,549 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=45 repeats=1 | 9,576,403 | 13,550 | 8,158,548 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=46 repeats=1 | 9,893,476 | 26,654 | 8,432,074 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=47 repeats=1 | 9,270,324 | 13,592 | 7,934,144 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=48 repeats=1 | 9,461,877 | 16,925 | 8,082,098 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=49 repeats=1 | 9,355,268 | 13,574 | 7,996,268 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=50 repeats=1 | 9,335,982 | 13,562 | 7,975,822 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=51 repeats=1 | 9,434,450 | 13,580 | 8,054,675 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=52 repeats=1 | 9,379,535 | 13,550 | 8,010,239 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=53 repeats=1 | 9,405,897 | 13,550 | 8,024,072 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=54 repeats=1 | 9,419,211 | 13,616 | 8,022,081 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=55 repeats=1 | 9,647,153 | 23,336 | 8,233,376 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=56 repeats=1 | 9,311,838 | 16,877 | 7,970,244 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=57 repeats=1 | 9,077,910 | 13,592 | 7,768,481 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=58 repeats=1 | 9,014,523 | 13,574 | 7,700,161 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=59 repeats=1 | 9,115,916 | 13,550 | 7,784,493 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=60 repeats=1 | 9,095,398 | 13,550 | 7,786,029 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=61 repeats=1 | 9,359,099 | 16,898 | 7,993,583 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=62 repeats=1 | 9,056,416 | 13,580 | 7,744,269 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=63 repeats=1 | 9,338,360 | 13,546 | 7,988,008 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=64 repeats=1 | 9,587,948 | 32,519 | 8,117,306 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=65 repeats=1 | 9,160,483 | 13,611 | 7,835,433 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=66 repeats=1 | 9,676,027 | 23,369 | 8,286,663 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=67 repeats=1 | 9,140,295 | 13,713 | 7,821,550 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=68 repeats=1 | 9,028,166 | 13,575 | 7,735,614 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=69 repeats=1 | 9,275,232 | 13,569 | 7,944,786 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=70 repeats=1 | 9,099,101 | 13,707 | 7,801,525 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=71 repeats=1 | 9,177,107 | 13,653 | 7,857,174 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=72 repeats=1 | 9,241,076 | 16,968 | 7,905,287 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=73 repeats=1 | 9,214,598 | 13,659 | 7,884,740 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=74 repeats=1 | 9,213,715 | 13,677 | 7,876,737 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=75 repeats=1 | 9,131,289 | 13,611 | 7,802,325 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=76 repeats=1 | 9,319,796 | 16,905 | 7,962,546 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=77 repeats=1 | 9,518,191 | 23,706 | 8,111,708 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=78 repeats=1 | 8,979,725 | 13,616 | 7,686,340 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=79 repeats=1 | 9,173,048 | 13,583 | 7,850,177 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=80 repeats=1 | 9,284,989 | 16,970 | 7,923,215 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=81 repeats=1 | 9,226,028 | 13,638 | 7,880,509 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=82 repeats=1 | 9,137,404 | 13,557 | 7,809,036 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=83 repeats=1 | 9,320,306 | 13,575 | 7,963,683 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=84 repeats=1 | 9,020,117 | 13,596 | 7,700,765 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=85 repeats=1 | 9,016,650 | 13,550 | 7,698,250 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=86 repeats=1 | 9,366,566 | 23,332 | 7,999,817 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=87 repeats=1 | 8,989,265 | 13,568 | 7,700,124 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=88 repeats=1 | 9,021,530 | 16,966 | 7,696,545 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=89 repeats=1 | 9,002,295 | 13,593 | 7,690,425 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=90 repeats=1 | 8,807,910 | 13,659 | 7,533,807 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=91 repeats=1 | 9,198,950 | 16,955 | 7,856,060 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=92 repeats=1 | 9,088,607 | 13,635 | 7,774,516 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=93 repeats=1 | 9,007,992 | 13,642 | 7,700,137 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=94 repeats=1 | 8,922,562 | 13,654 | 7,616,362 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=95 repeats=1 | 9,029,757 | 13,605 | 7,707,776 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=96 repeats=1 | 9,203,513 | 16,808 | 7,849,721 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=97 repeats=1 | 9,504,202 | 23,706 | 8,098,562 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=98 repeats=1 | 8,908,140 | 13,613 | 7,612,698 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=99 repeats=1 | 8,998,590 | 13,554 | 7,684,223 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=100 repeats=1 | 9,078,304 | 13,618 | 7,743,389 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=101 repeats=1 | 9,219,993 | 13,579 | 7,859,476 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=102 repeats=1 | 8,936,454 | 13,545 | 7,614,554 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=103 repeats=1 | 9,029,629 | 13,549 | 7,693,822 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=104 repeats=1 | 9,657,262 | 23,363 | 8,207,720 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=105 repeats=1 | 9,047,857 | 13,562 | 7,724,059 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=106 repeats=1 | 8,941,290 | 16,850 | 7,636,959 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=107 repeats=1 | 9,046,189 | 16,822 | 7,727,620 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=108 repeats=1 | 8,902,218 | 13,603 | 7,616,248 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=109 repeats=1 | 8,903,740 | 13,563 | 7,614,569 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=110 repeats=1 | 8,936,523 | 13,580 | 7,638,524 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=111 repeats=1 | 9,070,501 | 13,565 | 7,756,493 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=112 repeats=1 | 9,055,172 | 13,572 | 7,738,435 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=113 repeats=1 | 9,529,321 | 23,394 | 8,113,753 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=114 repeats=1 | 9,034,695 | 13,688 | 7,714,698 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=115 repeats=1 | 9,227,741 | 16,981 | 7,857,454 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=116 repeats=1 | 8,870,105 | 13,650 | 7,576,301 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=117 repeats=1 | 9,046,869 | 13,637 | 7,722,414 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=118 repeats=1 | 8,867,815 | 13,611 | 7,573,658 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=119 repeats=1 | 8,993,324 | 13,616 | 7,674,661 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=120 repeats=1 | 8,892,148 | 13,564 | 7,599,368 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=121 repeats=1 | 8,879,834 | 16,881 | 7,590,889 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=122 repeats=1 | 8,635,376 | 13,593 | 7,383,270 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=123 repeats=1 | 8,928,360 | 16,912 | 7,622,651 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=124 repeats=1 | 8,628,053 | 13,603 | 7,367,404 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=125 repeats=1 | 9,233,396 | 23,364 | 7,861,791 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=126 repeats=1 | 8,623,317 | 13,685 | 7,386,299 |
| GovDebtIncrement tokens=bar-baz users=128 operation=delegate index=127 repeats=1 | 8,711,415 | 21,694 | 7,412,411 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 7,398,247 | -191 | 6,895,111 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-noop window_repeats=1 index=0 repeats=1 | 2,151,992 | 0 | 1,961,889 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-partial index=0 repeats=1 | 3,444,054 | 1,545 | 2,998,104 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=0 repeats=1 | 7,055,455 | 1,511 | 6,284,934 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=1 repeats=1 | 7,794,638 | 1,552 | 7,012,539 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=2 repeats=1 | 7,784,881 | 1,552 | 7,001,627 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=3 repeats=1 | 7,806,327 | 1,552 | 7,021,930 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=4 repeats=1 | 7,886,527 | 1,576 | 7,018,157 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=5 repeats=1 | 7,897,019 | 1,576 | 7,027,500 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=6 repeats=1 | 7,818,044 | 1,552 | 7,030,200 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=7 repeats=1 | 7,949,140 | 4,864 | 7,133,495 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=8 repeats=1 | 7,797,482 | 1,576 | 7,016,523 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=9 repeats=1 | 7,818,536 | 1,552 | 7,036,426 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=10 repeats=1 | 7,811,282 | 1,552 | 7,028,026 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=11 repeats=1 | 7,799,058 | 1,552 | 7,014,653 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=12 repeats=1 | 7,898,010 | 1,552 | 7,028,048 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=13 repeats=1 | 7,920,055 | 1,552 | 7,048,944 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=14 repeats=1 | 7,818,571 | 1,552 | 7,030,719 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=15 repeats=1 | 7,819,565 | 1,552 | 7,030,564 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=16 repeats=1 | 7,922,277 | 1,552 | 7,047,722 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=17 repeats=1 | 7,906,689 | 1,552 | 7,033,127 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=18 repeats=1 | 7,901,142 | 1,552 | 7,026,431 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=19 repeats=1 | 7,917,377 | 1,564 | 7,041,517 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=20 repeats=1 | 7,835,414 | 1,552 | 7,040,671 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=21 repeats=1 | 7,846,894 | 1,552 | 7,051,002 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=22 repeats=1 | 7,951,009 | 4,864 | 7,127,067 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=23 repeats=1 | 7,822,051 | 1,576 | 7,033,050 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=24 repeats=1 | 7,805,084 | 1,552 | 7,014,928 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=25 repeats=1 | 7,827,497 | 1,552 | 7,036,198 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=26 repeats=1 | 7,832,569 | 1,521 | 7,040,109 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=27 repeats=1 | 7,817,423 | 1,516 | 7,023,802 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=28 repeats=1 | 7,825,325 | 1,516 | 7,030,557 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=29 repeats=1 | 7,826,226 | 1,516 | 7,030,309 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=30 repeats=1 | 7,819,233 | 1,516 | 7,022,167 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=31 repeats=1 | 7,820,624 | 1,517 | 7,022,406 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=32 repeats=1 | 7,814,608 | 1,516 | 7,015,238 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=33 repeats=1 | 7,830,104 | 1,516 | 7,029,585 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=34 repeats=1 | 7,832,230 | 1,516 | 7,030,562 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=35 repeats=1 | 7,817,804 | 1,516 | 7,014,987 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=36 repeats=1 | 7,841,812 | 1,516 | 7,037,846 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=37 repeats=1 | 8,027,775 | 4,864 | 7,112,686 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=38 repeats=1 | 7,904,366 | 1,540 | 7,023,669 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=39 repeats=1 | 7,899,516 | 1,516 | 7,017,670 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=40 repeats=1 | 7,821,190 | 1,516 | 7,021,817 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=41 repeats=1 | 7,921,214 | 1,516 | 7,037,874 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=42 repeats=1 | 7,823,237 | 1,516 | 7,021,566 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=43 repeats=1 | 7,916,685 | 1,516 | 7,031,047 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=44 repeats=1 | 7,916,609 | 1,516 | 7,029,822 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=45 repeats=1 | 7,923,466 | 1,516 | 7,035,530 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=46 repeats=1 | 7,915,987 | 1,516 | 7,026,902 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=47 repeats=1 | 7,933,920 | 1,516 | 7,043,686 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=48 repeats=1 | 7,930,549 | 1,516 | 7,039,166 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=49 repeats=1 | 7,930,473 | 1,516 | 7,037,941 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=50 repeats=1 | 7,922,521 | 1,516 | 7,028,840 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=51 repeats=1 | 7,928,991 | 1,516 | 7,034,161 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=52 repeats=1 | 8,053,684 | 4,828 | 7,130,294 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=53 repeats=1 | 7,918,264 | 1,540 | 7,030,325 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=54 repeats=1 | 7,924,270 | 1,516 | 7,035,182 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=55 repeats=1 | 7,910,821 | 1,516 | 7,020,584 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=56 repeats=1 | 7,929,744 | 1,516 | 7,038,358 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=57 repeats=1 | 7,914,831 | 1,516 | 7,022,296 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=58 repeats=1 | 7,944,858 | 1,516 | 7,046,380 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=59 repeats=1 | 7,950,985 | 1,516 | 7,051,358 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=60 repeats=1 | 7,955,100 | 1,518 | 7,058,308 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=61 repeats=1 | 8,103,043 | 9,575 | 7,129,805 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=62 repeats=1 | 7,894,774 | 1,540 | 7,026,257 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=63 repeats=1 | 7,903,124 | 1,516 | 7,033,458 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=64 repeats=1 | 7,898,038 | 1,516 | 7,027,223 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=65 repeats=1 | 7,900,902 | 1,516 | 7,028,938 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=66 repeats=1 | 7,898,519 | 1,516 | 7,025,406 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=67 repeats=1 | 8,042,558 | 4,840 | 7,140,630 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=68 repeats=1 | 7,882,994 | 1,540 | 7,016,472 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=69 repeats=1 | 7,896,521 | 1,528 | 7,028,850 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=70 repeats=1 | 7,787,855 | 1,516 | 7,002,957 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=71 repeats=1 | 7,802,622 | 1,516 | 7,016,575 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=72 repeats=1 | 7,788,930 | 1,516 | 7,001,734 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=73 repeats=1 | 7,810,736 | 1,516 | 7,022,391 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=74 repeats=1 | 7,829,383 | 1,516 | 7,039,889 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=75 repeats=1 | 7,826,666 | 1,516 | 7,036,023 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=76 repeats=1 | 7,805,552 | 1,516 | 7,013,760 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=77 repeats=1 | 7,902,886 | 1,552 | 7,027,133 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=78 repeats=1 | 7,820,376 | 1,516 | 7,026,286 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=79 repeats=1 | 7,820,205 | 1,516 | 7,024,966 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=80 repeats=1 | 7,839,578 | 1,516 | 7,043,190 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=81 repeats=1 | 7,925,348 | 1,516 | 7,043,061 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=82 repeats=1 | 7,970,514 | 4,828 | 7,143,907 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=83 repeats=1 | 7,898,335 | 1,540 | 7,022,939 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=84 repeats=1 | 7,887,653 | 1,516 | 7,011,108 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=85 repeats=1 | 7,905,954 | 1,516 | 7,028,260 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=86 repeats=1 | 7,909,556 | 1,516 | 7,030,713 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=87 repeats=1 | 7,895,369 | 1,516 | 7,015,377 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=88 repeats=1 | 7,916,440 | 1,516 | 7,035,299 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=89 repeats=1 | 7,902,499 | 1,528 | 7,020,209 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=90 repeats=1 | 7,833,493 | 1,516 | 7,034,804 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=91 repeats=1 | 7,857,651 | 1,516 | 7,057,813 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=92 repeats=1 | 7,858,310 | 1,516 | 7,057,323 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=93 repeats=1 | 7,844,864 | 1,516 | 7,042,728 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=94 repeats=1 | 7,846,016 | 1,517 | 7,042,728 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=95 repeats=1 | 7,846,667 | 1,516 | 7,042,230 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=96 repeats=1 | 7,878,428 | 1,522 | 7,050,240 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=97 repeats=1 | 8,061,325 | 4,834 | 7,119,860 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=98 repeats=1 | 7,934,976 | 1,546 | 7,029,727 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=99 repeats=1 | 7,980,087 | 1,534 | 7,071,098 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=100 repeats=1 | 7,981,324 | 1,522 | 7,072,812 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=101 repeats=1 | 7,982,225 | 1,522 | 7,072,564 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=102 repeats=1 | 7,982,648 | 1,522 | 7,071,838 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=103 repeats=1 | 7,990,095 | 1,522 | 7,078,136 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=104 repeats=1 | 7,991,244 | 1,522 | 7,078,136 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=105 repeats=1 | 7,988,613 | 1,528 | 7,098,689 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=106 repeats=1 | 7,995,051 | 1,516 | 7,098,692 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=107 repeats=1 | 7,972,068 | 1,528 | 7,079,846 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=108 repeats=1 | 7,992,614 | 1,516 | 7,093,957 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=109 repeats=1 | 7,990,955 | 1,516 | 7,091,149 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=110 repeats=1 | 7,997,601 | 1,516 | 7,096,646 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=111 repeats=1 | 8,004,322 | 1,516 | 7,102,218 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=112 repeats=1 | 8,335,628 | 11,609 | 7,363,775 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=113 repeats=1 | 8,015,785 | 1,588 | 7,115,167 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=114 repeats=1 | 8,036,193 | 1,516 | 7,134,142 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=115 repeats=1 | 8,037,593 | 1,528 | 7,134,393 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=116 repeats=1 | 8,040,206 | 1,516 | 7,135,857 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=117 repeats=1 | 8,040,378 | 1,528 | 7,134,880 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=118 repeats=1 | 8,047,004 | 1,516 | 7,140,357 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=119 repeats=1 | 8,054,361 | 1,528 | 7,146,565 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=120 repeats=1 | 8,049,115 | 1,516 | 7,143,380 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=121 repeats=1 | 8,036,891 | 1,516 | 7,130,007 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=122 repeats=1 | 8,034,748 | 1,516 | 7,126,715 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=123 repeats=1 | 8,086,434 | 1,524 | 7,151,065 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=124 repeats=1 | 8,257,718 | 9,581 | 7,245,807 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=125 repeats=1 | 8,018,677 | 1,558 | 7,111,583 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=126 repeats=1 | 8,041,237 | 1,522 | 7,132,994 |
| GovDebtIncrement tokens=bar-baz users=128 operation=undelegate-full index=127 repeats=1 | 8,100,833 | 4,853 | 7,165,650 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=0 repeats=1 | 5,352,759 | -8,363 | 4,744,185 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=0 repeats=1 | 2,511,887 | 0 | 2,281,084 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=1 repeats=1 | 2,179,507 | -2,163 | 1,909,299 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=1 repeats=1 | 3,574,292 | 4,355 | 3,231,092 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=2 repeats=1 | 2,187,719 | -5,623 | 1,922,045 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=2 repeats=1 | 3,789,612 | 4,355 | 3,417,497 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=3 repeats=1 | 2,368,633 | -5,612 | 2,083,728 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=3 repeats=1 | 3,826,120 | 4,374 | 3,452,167 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=4 repeats=1 | 2,358,623 | -2,152 | 2,033,549 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=4 repeats=1 | 3,736,143 | 4,362 | 3,292,491 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=5 repeats=1 | 2,297,965 | -5,630 | 1,992,338 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=5 repeats=1 | 3,859,495 | 4,355 | 3,395,442 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=6 repeats=1 | 2,166,091 | -5,618 | 1,910,101 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=6 repeats=1 | 3,773,420 | 4,355 | 3,392,104 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=7 repeats=1 | 2,155,087 | -2,163 | 1,888,460 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=7 repeats=1 | 3,784,538 | 4,355 | 3,403,216 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=8 repeats=1 | 2,210,850 | -2,163 | 1,940,241 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=8 repeats=1 | 4,105,573 | 4,355 | 3,686,311 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=9 repeats=1 | 2,380,607 | -2,177 | 2,086,541 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=9 repeats=1 | 4,147,969 | 4,362 | 3,718,541 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=10 repeats=1 | 2,214,659 | -2,172 | 1,948,209 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=10 repeats=1 | 3,847,020 | 4,355 | 3,456,703 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=11 repeats=1 | 2,339,536 | -2,154 | 2,047,312 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=11 repeats=1 | 4,030,238 | 4,362 | 3,616,775 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=12 repeats=1 | 2,322,904 | -2,184 | 2,006,307 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=12 repeats=1 | 4,018,363 | 4,374 | 3,528,797 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=13 repeats=1 | 2,341,867 | -2,184 | 2,030,245 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=13 repeats=1 | 4,313,238 | 4,362 | 3,793,281 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=14 repeats=1 | 2,282,378 | -2,185 | 2,009,405 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=14 repeats=1 | 4,122,384 | 4,362 | 3,694,167 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=15 repeats=1 | 2,314,094 | -2,184 | 2,024,957 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=15 repeats=1 | 4,215,556 | 4,374 | 3,780,007 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=16 repeats=1 | 2,376,593 | -2,190 | 2,047,057 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=16 repeats=1 | 4,272,730 | 4,343 | 3,752,264 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=17 repeats=1 | 2,180,101 | -2,183 | 1,875,385 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=17 repeats=1 | 4,258,987 | 4,367 | 3,745,448 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=18 repeats=1 | 2,227,488 | -2,202 | 1,920,111 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=18 repeats=1 | 4,021,016 | 4,355 | 3,545,238 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=19 repeats=1 | 2,223,398 | -2,177 | 1,918,584 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=19 repeats=1 | 4,341,871 | 4,355 | 3,829,997 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=20 repeats=1 | 2,303,136 | -2,190 | 2,019,161 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=20 repeats=1 | 4,178,833 | 4,350 | 3,736,168 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=21 repeats=1 | 2,249,308 | -2,171 | 1,971,031 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=21 repeats=1 | 4,099,746 | 4,367 | 3,659,797 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=22 repeats=1 | 2,426,995 | -2,182 | 2,126,948 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=22 repeats=1 | 4,377,881 | 4,362 | 3,906,665 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=23 repeats=1 | 2,559,396 | -2,184 | 2,224,429 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=23 repeats=1 | 4,300,718 | 4,362 | 3,836,747 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=24 repeats=1 | 2,330,813 | -2,165 | 2,025,482 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=24 repeats=1 | 4,076,648 | 4,367 | 3,636,693 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=25 repeats=1 | 2,442,252 | -2,183 | 2,130,507 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=25 repeats=1 | 4,391,170 | 4,362 | 3,919,925 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=26 repeats=1 | 2,356,456 | -2,202 | 2,052,915 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=26 repeats=1 | 4,106,639 | 4,355 | 3,666,591 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=27 repeats=1 | 2,286,037 | -2,186 | 1,992,462 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=27 repeats=1 | 4,087,744 | 4,355 | 3,647,777 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=28 repeats=1 | 2,547,220 | -2,192 | 2,222,673 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=28 repeats=1 | 4,381,084 | 4,374 | 3,909,821 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=29 repeats=1 | 2,483,196 | -5,615 | 2,181,677 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=29 repeats=1 | 4,378,177 | 4,374 | 3,906,943 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=30 repeats=1 | 2,329,403 | -2,207 | 2,044,611 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=30 repeats=1 | 4,289,573 | 4,326 | 3,825,439 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=31 repeats=1 | 2,366,480 | -2,180 | 2,079,605 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=31 repeats=1 | 4,372,942 | 4,374 | 3,901,621 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=32 repeats=1 | 2,273,266 | -2,187 | 1,998,893 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=32 repeats=1 | 4,270,692 | 4,374 | 3,806,645 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=33 repeats=1 | 2,322,659 | -2,187 | 2,041,313 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=33 repeats=1 | 4,276,648 | 4,374 | 3,812,659 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=34 repeats=1 | 2,223,020 | -2,189 | 1,955,841 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=34 repeats=1 | 4,332,206 | 4,331 | 3,860,610 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=35 repeats=1 | 2,255,261 | -2,187 | 1,984,785 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=35 repeats=1 | 4,352,632 | 4,362 | 3,870,870 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=36 repeats=1 | 2,498,002 | -2,192 | 2,180,560 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=36 repeats=1 | 4,166,242 | 4,367 | 3,707,684 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=37 repeats=1 | 2,382,732 | -2,157 | 2,034,685 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=37 repeats=1 | 4,231,139 | 4,355 | 3,689,850 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=38 repeats=1 | 2,483,013 | -2,194 | 2,127,688 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=38 repeats=1 | 4,529,868 | 4,403 | 3,957,232 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=39 repeats=1 | 2,481,427 | -2,193 | 2,127,584 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=39 repeats=1 | 4,529,976 | 4,422 | 3,957,208 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=40 repeats=1 | 2,390,757 | -2,188 | 2,079,129 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=40 repeats=1 | 4,118,761 | 4,407 | 3,674,897 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=41 repeats=1 | 2,531,811 | -2,169 | 2,169,944 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=41 repeats=1 | 4,408,628 | 4,417 | 3,858,121 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=42 repeats=1 | 2,384,484 | -2,187 | 2,076,557 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=42 repeats=1 | 4,239,532 | 4,391 | 3,774,448 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=43 repeats=1 | 2,616,770 | -2,187 | 2,246,708 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=43 repeats=1 | 4,609,205 | 4,386 | 4,029,800 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=44 repeats=1 | 2,512,190 | -5,668 | 2,168,039 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=44 repeats=1 | 4,512,867 | 4,386 | 3,940,794 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=45 repeats=1 | 2,403,791 | -2,187 | 2,075,498 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=45 repeats=1 | 4,607,999 | 4,398 | 4,028,594 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=46 repeats=1 | 2,453,306 | -2,200 | 2,119,030 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=46 repeats=1 | 4,609,950 | 4,374 | 4,030,492 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=47 repeats=1 | 2,413,637 | -2,187 | 2,088,255 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=47 repeats=1 | 4,629,149 | 4,410 | 4,049,580 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=48 repeats=1 | 2,255,689 | -2,188 | 1,947,605 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=48 repeats=1 | 4,335,442 | 4,403 | 3,787,540 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=49 repeats=1 | 2,412,039 | -2,187 | 2,088,554 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=49 repeats=1 | 4,619,361 | 4,386 | 4,039,956 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=50 repeats=1 | 2,457,582 | -2,170 | 2,127,187 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=50 repeats=1 | 4,654,289 | 4,386 | 4,071,697 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=51 repeats=1 | 2,632,242 | -2,174 | 2,267,395 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=51 repeats=1 | 4,675,278 | 4,398 | 4,091,147 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=52 repeats=1 | 2,543,303 | -2,181 | 2,180,339 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=52 repeats=1 | 4,677,027 | 4,398 | 4,092,819 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=53 repeats=1 | 2,548,100 | -2,193 | 2,186,647 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=53 repeats=1 | 4,687,370 | 4,398 | 4,103,191 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=54 repeats=1 | 2,401,885 | -2,195 | 2,057,718 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=54 repeats=1 | 4,402,734 | 4,367 | 3,849,843 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=55 repeats=1 | 2,652,027 | -2,193 | 2,271,581 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=55 repeats=1 | 4,590,953 | 4,386 | 4,014,009 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=56 repeats=1 | 2,594,707 | -2,181 | 2,230,187 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=56 repeats=1 | 4,687,192 | 4,386 | 4,102,989 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=57 repeats=1 | 2,531,078 | -2,194 | 2,175,510 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=57 repeats=1 | 4,555,522 | 4,386 | 3,980,495 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=58 repeats=1 | 2,441,855 | -5,680 | 2,107,278 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=58 repeats=1 | 4,378,856 | 4,391 | 3,818,456 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=59 repeats=1 | 2,440,153 | -2,193 | 2,103,135 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=59 repeats=1 | 4,574,011 | 4,386 | 3,989,616 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=60 repeats=1 | 2,352,594 | -2,200 | 2,030,228 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=60 repeats=1 | 4,571,160 | 4,416 | 3,983,799 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=61 repeats=1 | 2,482,801 | -2,187 | 2,143,437 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=61 repeats=1 | 4,649,568 | 4,398 | 4,054,909 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=62 repeats=1 | 2,434,270 | -2,181 | 2,104,773 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=62 repeats=1 | 4,471,970 | 4,398 | 3,892,919 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=63 repeats=1 | 2,437,893 | -2,193 | 2,109,924 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=63 repeats=1 | 4,758,375 | 4,386 | 4,147,295 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=64 repeats=1 | 2,422,718 | -2,188 | 2,096,289 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=64 repeats=1 | 4,752,489 | 4,386 | 4,141,467 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=65 repeats=1 | 2,508,388 | -2,186 | 2,158,320 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=65 repeats=1 | 4,667,914 | 4,398 | 4,064,079 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=66 repeats=1 | 2,541,776 | -5,693 | 2,198,507 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=66 repeats=1 | 4,746,379 | 4,374 | 4,135,251 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=67 repeats=1 | 2,341,924 | -2,194 | 2,015,469 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=67 repeats=1 | 4,686,866 | 4,379 | 4,076,868 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=68 repeats=1 | 2,335,909 | -2,199 | 2,011,278 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=68 repeats=1 | 4,454,373 | 4,391 | 3,875,109 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=69 repeats=1 | 2,431,471 | -2,187 | 2,101,036 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=69 repeats=1 | 4,751,866 | 4,386 | 4,140,573 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=70 repeats=1 | 2,313,055 | -2,221 | 2,032,206 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=70 repeats=1 | 4,555,845 | 4,374 | 4,044,767 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=71 repeats=1 | 2,327,164 | -2,193 | 2,044,073 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=71 repeats=1 | 4,471,854 | 4,398 | 3,968,113 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=72 repeats=1 | 2,306,642 | -2,187 | 2,028,762 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=72 repeats=1 | 4,547,806 | 4,398 | 4,036,791 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=73 repeats=1 | 2,454,735 | -2,211 | 2,145,868 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=73 repeats=1 | 4,471,623 | 4,386 | 3,967,853 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=74 repeats=1 | 2,320,789 | -2,187 | 2,018,153 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=74 repeats=1 | 4,283,444 | 4,391 | 3,803,995 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=75 repeats=1 | 2,406,429 | -2,193 | 2,096,871 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=75 repeats=1 | 4,473,829 | 4,386 | 3,970,035 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=76 repeats=1 | 2,415,671 | -2,205 | 2,098,308 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=76 repeats=1 | 4,266,136 | 4,391 | 3,786,547 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=77 repeats=1 | 2,351,491 | -2,169 | 2,013,050 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=77 repeats=1 | 4,354,183 | 4,379 | 3,791,869 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=78 repeats=1 | 2,370,985 | -2,207 | 2,064,557 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=78 repeats=1 | 4,277,229 | 4,343 | 3,797,693 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=79 repeats=1 | 2,406,746 | -2,199 | 2,095,942 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=79 repeats=1 | 4,393,082 | 4,379 | 3,891,478 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=80 repeats=1 | 2,397,935 | -5,680 | 2,104,842 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=80 repeats=1 | 4,404,194 | 4,367 | 3,902,590 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=81 repeats=1 | 2,516,982 | -2,193 | 2,168,204 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=81 repeats=1 | 4,764,265 | 4,386 | 4,145,882 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=82 repeats=1 | 2,487,594 | -2,193 | 2,179,764 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=82 repeats=1 | 4,688,615 | 4,398 | 4,154,958 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=83 repeats=1 | 2,417,674 | -2,187 | 2,082,938 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=83 repeats=1 | 4,668,931 | 4,398 | 4,057,856 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=84 repeats=1 | 2,299,522 | -2,213 | 1,978,681 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=84 repeats=1 | 4,466,772 | 4,355 | 3,880,418 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=85 repeats=1 | 2,470,801 | -2,187 | 2,129,921 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=85 repeats=1 | 4,678,936 | 4,386 | 4,067,740 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=86 repeats=1 | 2,453,129 | -2,193 | 2,119,108 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=86 repeats=1 | 4,676,970 | 4,398 | 4,065,808 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=87 repeats=1 | 2,369,563 | -2,192 | 2,032,988 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=87 repeats=1 | 4,456,993 | 4,391 | 3,870,760 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=88 repeats=1 | 2,526,677 | -5,680 | 2,180,609 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=88 repeats=1 | 4,667,903 | 4,374 | 4,056,852 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=89 repeats=1 | 2,360,521 | -2,187 | 2,030,902 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=89 repeats=1 | 4,655,859 | 4,398 | 4,044,808 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=90 repeats=1 | 2,282,569 | -2,207 | 2,003,717 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=90 repeats=1 | 4,465,766 | 4,374 | 3,962,059 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=91 repeats=1 | 2,283,740 | -2,193 | 2,003,176 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=91 repeats=1 | 4,399,297 | 4,391 | 3,897,780 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=92 repeats=1 | 2,373,572 | -2,187 | 2,085,765 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=92 repeats=1 | 4,689,369 | 4,386 | 4,155,736 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=93 repeats=1 | 2,324,247 | -2,206 | 2,041,576 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=93 repeats=1 | 4,589,050 | 4,386 | 4,062,662 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=94 repeats=1 | 2,212,573 | -2,187 | 1,943,855 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=94 repeats=1 | 4,387,277 | 4,391 | 3,885,760 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=95 repeats=1 | 2,381,832 | -2,192 | 2,084,617 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=95 repeats=1 | 4,740,762 | 4,379 | 4,198,791 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=96 repeats=1 | 2,372,126 | -5,325 | 2,087,363 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=96 repeats=1 | 4,487,963 | 4,379 | 3,967,771 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=97 repeats=1 | 2,255,769 | -2,193 | 1,944,653 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=97 repeats=1 | 4,554,974 | 4,379 | 3,950,917 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=98 repeats=1 | 2,217,323 | -2,212 | 1,915,318 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=98 repeats=1 | 4,427,581 | 4,367 | 3,851,765 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=99 repeats=1 | 2,392,928 | -2,187 | 2,069,273 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=99 repeats=1 | 4,700,149 | 4,386 | 4,093,093 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=100 repeats=1 | 2,426,423 | -2,205 | 2,097,530 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=100 repeats=1 | 4,697,851 | 4,398 | 4,098,914 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=101 repeats=1 | 2,479,030 | -2,199 | 2,144,084 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=101 repeats=1 | 4,696,895 | 4,398 | 4,097,958 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=102 repeats=1 | 2,578,401 | -2,200 | 2,232,262 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=102 repeats=1 | 4,793,209 | 4,386 | 4,186,916 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=103 repeats=1 | 2,529,692 | -5,667 | 2,188,684 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=103 repeats=1 | 4,696,943 | 4,398 | 4,097,958 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=104 repeats=1 | 2,333,087 | -2,206 | 2,010,218 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=104 repeats=1 | 4,500,951 | 4,367 | 3,926,798 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=105 repeats=1 | 2,381,359 | -2,188 | 2,056,092 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=105 repeats=1 | 4,708,963 | 4,386 | 4,110,026 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=106 repeats=1 | 2,487,446 | -2,207 | 2,148,789 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=106 repeats=1 | 4,836,960 | 4,386 | 4,223,484 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=107 repeats=1 | 2,429,845 | -2,182 | 2,098,941 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=107 repeats=1 | 4,757,830 | 4,386 | 4,146,746 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=108 repeats=1 | 2,433,136 | -2,195 | 2,102,151 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=108 repeats=1 | 4,780,316 | 4,386 | 4,163,888 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=109 repeats=1 | 2,384,291 | -2,194 | 2,062,186 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=109 repeats=1 | 4,775,184 | 4,398 | 4,158,814 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=110 repeats=1 | 2,432,710 | -2,201 | 2,104,642 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=110 repeats=1 | 4,872,219 | 4,386 | 4,248,488 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=111 repeats=1 | 2,539,327 | -2,200 | 2,185,755 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=111 repeats=1 | 4,778,139 | 4,398 | 4,161,740 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=112 repeats=1 | 2,531,038 | -9,104 | 2,199,307 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=112 repeats=1 | 4,871,239 | 4,386 | 4,247,508 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=113 repeats=1 | 2,331,463 | -2,194 | 2,012,247 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=113 repeats=1 | 4,783,021 | 4,398 | 4,166,564 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=114 repeats=1 | 2,372,827 | -2,207 | 2,051,447 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=114 repeats=1 | 4,579,790 | 4,386 | 3,987,678 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=115 repeats=1 | 2,380,024 | -2,194 | 2,054,757 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=115 repeats=1 | 4,776,188 | 4,386 | 4,159,818 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=116 repeats=1 | 2,278,777 | -2,195 | 1,971,387 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=116 repeats=1 | 4,876,145 | 4,386 | 4,252,356 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=117 repeats=1 | 2,280,283 | -2,188 | 1,973,335 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=117 repeats=1 | 4,782,065 | 4,398 | 4,165,608 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=118 repeats=1 | 2,333,616 | -2,213 | 2,020,618 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=118 repeats=1 | 4,787,173 | 4,386 | 4,170,658 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=119 repeats=1 | 2,274,859 | -2,188 | 1,971,888 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=119 repeats=1 | 4,785,067 | 4,398 | 4,168,610 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=120 repeats=1 | 2,165,029 | -2,207 | 1,877,648 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=120 repeats=1 | 4,474,759 | 4,391 | 3,909,406 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=121 repeats=1 | 2,251,529 | -2,194 | 1,956,102 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=121 repeats=1 | 4,574,588 | 4,386 | 3,993,107 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=122 repeats=1 | 2,165,556 | -2,206 | 1,879,515 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=122 repeats=1 | 4,580,489 | 4,379 | 3,998,897 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=123 repeats=1 | 2,221,639 | -2,194 | 1,932,374 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=123 repeats=1 | 4,787,230 | 4,386 | 4,181,409 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=124 repeats=1 | 2,216,191 | -2,201 | 1,928,428 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=124 repeats=1 | 4,782,074 | 4,386 | 4,176,335 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=125 repeats=1 | 2,154,482 | -2,186 | 1,875,873 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=125 repeats=1 | 4,781,118 | 4,398 | 4,175,379 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=126 repeats=1 | 2,060,368 | -2,201 | 1,795,336 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=126 repeats=1 | 4,593,585 | 4,367 | 4,011,969 |
| GovDebtIncrement tokens=bar-baz users=128 operation=withdraw index=127 repeats=1 | 2,164,100 | -4,636 | 1,897,137 |
| GovDebtIncrement tokens=bar-baz users=128 operation=claim-final index=127 repeats=1 | 4,685,791 | 4,386 | 4,088,309 |
| GovDebtIncrement tokens=bar-baz users=128 operation=restake index=0 repeats=1 | 4,558,372 | 6,483 | 3,895,771 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=0 operation=query control=empty repeats=1 | 227,473 | 0 | 170,507 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=1 operation=delegate index=0 repeats=1 | 7,716,218 | 35,210 | 6,335,605 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=1 operation=query control=present-zero repeats=1 | 492,780 | 0 | 461,163 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=1 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 11,922,391 | 11,074 | 11,058,591 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=1 repeats=1 | 4,719,192 | 15,888 | 3,981,446 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=2 repeats=1 | 8,727,299 | 15,762 | 7,533,875 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=3 repeats=1 | 9,026,263 | 15,744 | 7,795,887 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=4 repeats=1 | 8,887,496 | 15,768 | 7,669,123 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=5 repeats=1 | 8,949,482 | 15,756 | 7,723,901 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=6 repeats=1 | 8,864,310 | 15,774 | 7,646,651 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=7 repeats=1 | 8,848,576 | 15,779 | 7,627,513 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=8 repeats=1 | 9,141,297 | 15,780 | 7,876,373 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=9 repeats=1 | 9,094,309 | 15,835 | 7,822,898 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=10 repeats=1 | 9,076,650 | 15,871 | 7,797,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=11 repeats=1 | 9,104,042 | 15,824 | 7,825,213 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=12 repeats=1 | 9,210,976 | 15,794 | 7,910,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=13 repeats=1 | 9,070,510 | 15,810 | 7,782,618 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=14 repeats=1 | 9,045,413 | 15,810 | 7,754,381 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=15 repeats=1 | 9,110,453 | 15,778 | 7,812,213 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=16 repeats=1 | 9,899,366 | 48,710 | 8,427,364 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=17 repeats=1 | 9,261,225 | 15,940 | 7,965,150 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=18 repeats=1 | 9,283,482 | 15,736 | 7,964,255 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=19 repeats=1 | 9,371,787 | 15,742 | 8,034,871 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=20 repeats=1 | 9,415,242 | 15,850 | 8,078,198 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=21 repeats=1 | 9,334,168 | 15,802 | 8,002,451 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=22 repeats=1 | 9,465,918 | 15,778 | 8,115,627 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=23 repeats=1 | 9,519,803 | 15,862 | 8,157,596 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=24 repeats=1 | 9,511,812 | 19,287 | 8,135,494 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=25 repeats=1 | 9,452,621 | 15,890 | 8,092,881 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=26 repeats=1 | 9,372,534 | 15,842 | 8,022,581 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=27 repeats=1 | 9,833,024 | 25,964 | 8,394,614 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=28 repeats=1 | 9,307,748 | 15,829 | 7,982,634 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=29 repeats=1 | 9,417,151 | 15,815 | 8,079,237 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=30 repeats=1 | 9,401,187 | 16,047 | 8,068,377 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=delegate index=31 repeats=1 | 9,592,508 | 19,252 | 8,217,925 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=32 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 11,836,231 | -282 | 11,034,574 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=32 repeats=1 | 5,421,992 | 19,239 | 4,532,043 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=33 repeats=1 | 9,439,087 | 15,912 | 8,094,360 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=34 repeats=1 | 9,365,750 | 15,907 | 8,025,642 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=35 repeats=1 | 9,318,357 | 15,864 | 7,982,655 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=36 repeats=1 | 9,404,097 | 15,864 | 8,052,009 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=37 repeats=1 | 9,781,740 | 25,959 | 8,351,068 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=38 repeats=1 | 9,481,031 | 15,858 | 8,133,461 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=39 repeats=1 | 9,503,122 | 15,816 | 8,151,339 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=40 repeats=1 | 9,764,163 | 19,230 | 8,343,561 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=41 repeats=1 | 9,510,100 | 15,894 | 8,133,529 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=42 repeats=1 | 9,495,339 | 15,822 | 8,115,460 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=43 repeats=1 | 9,461,004 | 15,828 | 8,073,924 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=44 repeats=1 | 9,479,255 | 15,852 | 8,087,231 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=45 repeats=1 | 9,743,324 | 15,816 | 8,311,230 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=46 repeats=1 | 10,060,397 | 28,920 | 8,584,756 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=47 repeats=1 | 9,437,218 | 15,858 | 8,086,826 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=48 repeats=1 | 9,628,771 | 19,191 | 8,234,780 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=49 repeats=1 | 9,522,162 | 15,840 | 8,148,950 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=50 repeats=1 | 9,502,876 | 15,828 | 8,128,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=51 repeats=1 | 9,601,344 | 15,846 | 8,207,357 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=52 repeats=1 | 9,546,429 | 15,816 | 8,162,921 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=53 repeats=1 | 9,572,791 | 15,816 | 8,176,754 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=54 repeats=1 | 9,586,105 | 15,882 | 8,174,763 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=55 repeats=1 | 9,814,047 | 25,602 | 8,386,058 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=56 repeats=1 | 9,478,732 | 19,143 | 8,122,926 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=57 repeats=1 | 9,244,804 | 15,858 | 7,921,163 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=58 repeats=1 | 9,181,417 | 15,840 | 7,852,843 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=59 repeats=1 | 9,282,810 | 15,816 | 7,937,175 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=60 repeats=1 | 9,262,310 | 15,816 | 7,938,711 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=61 repeats=1 | 9,526,011 | 19,164 | 8,146,265 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=62 repeats=1 | 9,223,328 | 15,846 | 7,896,951 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=63 repeats=1 | 9,505,272 | 15,812 | 8,140,690 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=64 repeats=1 | 9,754,869 | 34,785 | 8,269,988 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=65 repeats=1 | 9,327,386 | 15,877 | 7,988,115 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=66 repeats=1 | 9,842,930 | 25,635 | 8,439,345 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=67 repeats=1 | 9,307,180 | 15,979 | 7,974,232 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=68 repeats=1 | 9,195,069 | 15,841 | 7,888,296 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=69 repeats=1 | 9,442,135 | 15,835 | 8,097,468 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=70 repeats=1 | 9,266,013 | 15,973 | 7,954,207 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=71 repeats=1 | 9,344,019 | 15,919 | 8,009,856 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=72 repeats=1 | 9,407,988 | 19,234 | 8,057,969 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=73 repeats=1 | 9,381,510 | 15,925 | 8,037,422 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=74 repeats=1 | 9,380,627 | 15,943 | 8,029,419 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=75 repeats=1 | 9,298,201 | 15,877 | 7,955,007 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=76 repeats=1 | 9,486,708 | 19,171 | 8,115,228 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=77 repeats=1 | 9,685,103 | 25,972 | 8,264,390 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=78 repeats=1 | 9,146,610 | 15,882 | 7,839,022 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=79 repeats=1 | 9,339,933 | 15,849 | 8,002,859 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=80 repeats=1 | 9,451,874 | 19,236 | 8,075,897 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=81 repeats=1 | 9,392,913 | 15,904 | 8,033,191 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=82 repeats=1 | 9,304,289 | 15,823 | 7,961,718 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=83 repeats=1 | 9,487,191 | 15,841 | 8,116,365 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=84 repeats=1 | 9,187,002 | 15,862 | 7,853,447 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=85 repeats=1 | 9,183,535 | 15,816 | 7,850,932 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=86 repeats=1 | 9,533,451 | 25,598 | 8,152,499 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=87 repeats=1 | 9,156,150 | 15,834 | 7,852,806 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=88 repeats=1 | 9,188,415 | 19,232 | 7,849,227 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=89 repeats=1 | 9,169,180 | 15,859 | 7,843,107 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=90 repeats=1 | 8,974,795 | 15,925 | 7,686,489 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=91 repeats=1 | 9,365,835 | 19,221 | 8,008,742 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=92 repeats=1 | 9,255,492 | 15,901 | 7,927,198 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=93 repeats=1 | 9,174,877 | 15,908 | 7,852,819 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=94 repeats=1 | 9,089,447 | 15,920 | 7,769,044 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=95 repeats=1 | 9,196,642 | 15,871 | 7,860,458 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=96 repeats=1 | 9,370,398 | 19,074 | 8,002,403 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=97 repeats=1 | 9,671,087 | 25,972 | 8,251,244 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=98 repeats=1 | 9,075,025 | 15,879 | 7,765,380 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=99 repeats=1 | 9,165,475 | 15,820 | 7,836,905 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=100 repeats=1 | 9,245,189 | 15,884 | 7,896,071 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=101 repeats=1 | 9,386,878 | 15,845 | 8,012,158 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=102 repeats=1 | 9,103,339 | 15,811 | 7,767,236 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=103 repeats=1 | 9,196,514 | 15,815 | 7,846,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=104 repeats=1 | 9,824,147 | 25,629 | 8,360,402 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=105 repeats=1 | 9,214,742 | 15,828 | 7,876,741 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=106 repeats=1 | 9,108,175 | 19,116 | 7,789,641 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=107 repeats=1 | 9,213,080 | 19,088 | 7,880,302 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=108 repeats=1 | 9,069,103 | 15,869 | 7,768,930 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=109 repeats=1 | 9,070,625 | 15,829 | 7,767,251 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=110 repeats=1 | 9,103,408 | 15,846 | 7,791,206 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=111 repeats=1 | 9,237,386 | 15,831 | 7,909,175 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=112 repeats=1 | 9,222,057 | 15,838 | 7,891,117 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=113 repeats=1 | 9,696,206 | 25,660 | 8,266,435 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=114 repeats=1 | 9,201,580 | 15,954 | 7,867,380 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=115 repeats=1 | 9,394,632 | 19,247 | 8,010,136 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=116 repeats=1 | 9,036,990 | 15,916 | 7,728,983 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=117 repeats=1 | 9,213,754 | 15,903 | 7,875,096 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=118 repeats=1 | 9,034,700 | 15,877 | 7,726,340 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=119 repeats=1 | 9,160,209 | 15,882 | 7,827,343 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=120 repeats=1 | 9,059,033 | 15,830 | 7,752,050 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=121 repeats=1 | 9,046,719 | 19,147 | 7,743,571 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=122 repeats=1 | 8,802,261 | 15,859 | 7,535,952 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=123 repeats=1 | 9,095,251 | 19,178 | 7,775,333 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=124 repeats=1 | 8,794,938 | 15,869 | 7,520,086 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=125 repeats=1 | 9,400,281 | 25,630 | 8,014,473 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=126 repeats=1 | 8,790,202 | 15,951 | 7,538,981 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=delegate index=127 repeats=1 | 8,878,300 | 23,960 | 7,565,093 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 12,057,079 | -377 | 11,283,957 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1 index=0 repeats=1 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=10 index=0 repeats=10 | 11,892,507 | -377 | 11,119,656 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=10 index=1 repeats=10 | 11,888,462 | -377 | 11,115,874 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=10 index=2 repeats=10 | 11,891,757 | -377 | 11,119,169 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=10 index=3 repeats=10 | 11,894,192 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=10 index=4 repeats=10 | 11,894,192 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=10 index=5 repeats=10 | 11,894,192 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=10 index=6 repeats=10 | 11,890,410 | -377 | 11,117,822 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=10 index=7 repeats=10 | 11,893,705 | -377 | 11,121,117 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=10 index=8 repeats=10 | 11,890,410 | -377 | 11,117,822 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=10 index=9 repeats=10 | 11,894,192 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=10 index=0 repeats=10 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=10 index=1 repeats=10 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=10 index=2 repeats=10 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=10 index=3 repeats=10 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=10 index=4 repeats=10 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=10 index=5 repeats=10 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=10 index=6 repeats=10 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=10 index=7 repeats=10 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=10 index=8 repeats=10 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=10 index=9 repeats=10 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=0 repeats=100 | 11,894,455 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=1 repeats=100 | 11,881,012 | -377 | 11,108,424 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=2 repeats=100 | 11,880,612 | -371 | 11,107,937 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=3 repeats=100 | 11,892,766 | -359 | 11,119,770 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=4 repeats=100 | 11,896,584 | -377 | 11,123,552 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=5 repeats=100 | 11,892,802 | -377 | 11,119,770 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=6 repeats=100 | 11,896,584 | -377 | 11,123,552 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=7 repeats=100 | 11,897,071 | -377 | 11,124,039 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=8 repeats=100 | 11,897,071 | -377 | 11,124,039 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=9 repeats=100 | 11,894,636 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=10 repeats=100 | 11,894,149 | -377 | 11,121,117 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=11 repeats=100 | 11,894,636 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=12 repeats=100 | 11,894,636 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=13 repeats=100 | 11,894,149 | -377 | 11,121,117 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=14 repeats=100 | 11,894,636 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=15 repeats=100 | 11,894,636 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=16 repeats=100 | 11,894,636 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=17 repeats=100 | 11,894,149 | -377 | 11,121,117 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=18 repeats=100 | 11,881,456 | -377 | 11,108,424 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=19 repeats=100 | 11,878,161 | -377 | 11,105,129 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=20 repeats=100 | 11,863,521 | -377 | 11,090,489 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=21 repeats=100 | 11,880,969 | -377 | 11,107,937 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=22 repeats=100 | 11,881,456 | -377 | 11,108,424 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=23 repeats=100 | 11,881,456 | -377 | 11,108,424 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=24 repeats=100 | 11,894,636 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=25 repeats=100 | 11,894,636 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=26 repeats=100 | 11,890,854 | -377 | 11,117,822 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=27 repeats=100 | 11,894,636 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=28 repeats=100 | 11,894,636 | -377 | 11,121,604 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=29 repeats=100 | 11,892,688 | -377 | 11,119,656 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=30 repeats=100 | 11,889,393 | -377 | 11,116,361 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=31 repeats=100 | 11,892,688 | -377 | 11,119,656 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=32 repeats=100 | 11,893,175 | -377 | 11,120,143 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=33 repeats=100 | 11,892,688 | -377 | 11,119,656 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=34 repeats=100 | 11,892,201 | -377 | 11,119,169 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=35 repeats=100 | 11,875,726 | -377 | 11,102,694 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=36 repeats=100 | 11,880,044 | -377 | 11,107,012 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=37 repeats=100 | 11,891,877 | -377 | 11,118,845 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=38 repeats=100 | 11,895,172 | -377 | 11,122,140 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=39 repeats=100 | 11,895,172 | -377 | 11,122,140 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=40 repeats=100 | 11,895,172 | -377 | 11,122,140 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=41 repeats=100 | 11,895,172 | -377 | 11,122,140 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=42 repeats=100 | 11,891,877 | -377 | 11,118,845 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=43 repeats=100 | 11,896,146 | -377 | 11,123,114 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=44 repeats=100 | 11,892,364 | -377 | 11,119,332 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=45 repeats=100 | 11,895,659 | -377 | 11,122,627 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=46 repeats=100 | 11,896,146 | -377 | 11,123,114 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=47 repeats=100 | 11,895,659 | -377 | 11,122,627 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=48 repeats=100 | 11,895,659 | -377 | 11,122,627 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=49 repeats=100 | 11,895,172 | -377 | 11,122,140 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=50 repeats=100 | 11,895,659 | -377 | 11,122,627 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=51 repeats=100 | 11,890,810 | -377 | 11,117,778 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=52 repeats=100 | 11,881,505 | -377 | 11,108,473 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=53 repeats=100 | 11,876,263 | -377 | 11,103,231 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=54 repeats=100 | 11,895,172 | -377 | 11,122,140 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=55 repeats=100 | 11,895,172 | -377 | 11,122,140 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=56 repeats=100 | 11,893,224 | -377 | 11,120,192 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=57 repeats=100 | 11,893,711 | -377 | 11,120,679 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=58 repeats=100 | 11,871,020 | -377 | 11,097,988 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=59 repeats=100 | 11,878,096 | -377 | 11,105,064 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=60 repeats=100 | 11,878,583 | -377 | 11,105,551 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=61 repeats=100 | 11,878,592 | -375 | 11,105,551 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=62 repeats=100 | 11,891,772 | -377 | 11,118,731 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=63 repeats=100 | 11,891,772 | -377 | 11,118,731 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=64 repeats=100 | 11,891,772 | -377 | 11,118,731 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=65 repeats=100 | 11,887,990 | -377 | 11,114,949 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=66 repeats=100 | 11,891,285 | -377 | 11,118,244 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=67 repeats=100 | 11,891,772 | -377 | 11,118,731 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=68 repeats=100 | 11,891,772 | -377 | 11,118,731 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=69 repeats=100 | 11,875,297 | -377 | 11,102,256 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=70 repeats=100 | 11,893,233 | -377 | 11,120,192 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=71 repeats=100 | 11,894,207 | -377 | 11,121,166 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=72 repeats=100 | 11,893,720 | -377 | 11,120,679 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=73 repeats=100 | 11,893,233 | -377 | 11,120,192 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=74 repeats=100 | 11,890,819 | -377 | 11,117,778 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=75 repeats=100 | 11,895,181 | -377 | 11,122,140 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=76 repeats=100 | 11,891,886 | -377 | 11,118,845 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=77 repeats=100 | 11,893,233 | -377 | 11,120,192 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=78 repeats=100 | 11,893,720 | -377 | 11,120,679 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=79 repeats=100 | 11,893,720 | -377 | 11,120,679 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=80 repeats=100 | 11,893,720 | -377 | 11,120,679 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=81 repeats=100 | 11,889,938 | -377 | 11,116,897 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=82 repeats=100 | 11,895,668 | -377 | 11,122,627 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=83 repeats=100 | 11,909,227 | -377 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=84 repeats=100 | 11,912,522 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=85 repeats=100 | 11,913,496 | -377 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=86 repeats=100 | 11,899,829 | -377 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=87 repeats=100 | 11,914,957 | -377 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=88 repeats=100 | 11,914,470 | -377 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=89 repeats=100 | 11,914,470 | -377 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=90 repeats=100 | 11,911,175 | -377 | 11,137,850 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=91 repeats=100 | 11,914,470 | -377 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=92 repeats=100 | 11,915,444 | -377 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=93 repeats=100 | 11,914,957 | -377 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=94 repeats=100 | 11,914,470 | -377 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=95 repeats=100 | 11,914,470 | -377 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=96 repeats=100 | 11,895,561 | -377 | 11,122,236 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=97 repeats=100 | 11,894,099 | -377 | 11,120,774 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=98 repeats=100 | 11,897,394 | -377 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=100 index=99 repeats=100 | 11,897,881 | -377 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=0 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=1 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=2 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=3 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=4 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=5 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=6 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=7 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=8 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=9 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=10 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=11 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=12 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=13 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=14 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=15 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=16 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=17 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=18 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=19 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=20 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=21 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=22 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=23 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=24 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=25 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=26 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=27 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=28 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=29 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=30 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=31 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=32 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=33 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=34 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=35 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=36 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=37 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=38 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=39 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=40 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=41 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=42 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=43 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=44 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=45 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=46 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=47 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=48 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=49 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=50 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=51 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=52 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=53 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=54 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=55 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=56 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=57 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=58 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=59 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=60 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=61 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=62 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=63 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=64 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=65 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=66 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=67 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=68 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=69 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=70 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=71 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=72 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=73 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=74 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=75 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=76 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=77 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=78 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=79 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=80 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=81 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=82 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=83 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=84 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=85 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=86 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=87 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=88 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=89 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=90 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=91 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=92 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=93 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=94 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=95 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=96 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=97 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=98 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=100 index=99 repeats=100 | 2,327,734 | 0 | 2,122,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=0 repeats=1000 | 11,911,811 | -377 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=1 repeats=1000 | 11,911,061 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=2 repeats=1000 | 11,897,394 | -377 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=3 repeats=1000 | 11,898,368 | -377 | 11,125,043 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=4 repeats=1000 | 11,909,714 | -377 | 11,136,389 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=5 repeats=1000 | 11,913,009 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=6 repeats=1000 | 11,913,009 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=7 repeats=1000 | 11,913,009 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=8 repeats=1000 | 11,909,714 | -377 | 11,136,389 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=9 repeats=1000 | 11,912,522 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=10 repeats=1000 | 11,912,522 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=11 repeats=1000 | 11,912,522 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=12 repeats=1000 | 11,912,035 | -377 | 11,138,710 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=13 repeats=1000 | 11,913,009 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=14 repeats=1000 | 11,912,522 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=15 repeats=1000 | 11,909,714 | -377 | 11,136,389 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=16 repeats=1000 | 11,913,496 | -377 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=17 repeats=1000 | 11,911,548 | -377 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=18 repeats=1000 | 11,911,061 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=19 repeats=1000 | 11,897,881 | -377 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=20 repeats=1000 | 11,894,099 | -377 | 11,120,774 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=21 repeats=1000 | 11,913,009 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=22 repeats=1000 | 11,909,290 | -356 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=23 repeats=1000 | 11,912,750 | -330 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=24 repeats=1000 | 11,913,255 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=25 repeats=1000 | 11,910,820 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=26 repeats=1000 | 11,910,820 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=27 repeats=1000 | 11,907,525 | -377 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=28 repeats=1000 | 11,911,307 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=29 repeats=1000 | 11,908,012 | -377 | 11,134,441 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=30 repeats=1000 | 11,910,820 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=31 repeats=1000 | 11,911,307 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=32 repeats=1000 | 11,911,307 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=33 repeats=1000 | 11,912,768 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=34 repeats=1000 | 11,893,859 | -377 | 11,120,288 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=35 repeats=1000 | 11,898,127 | -377 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=36 repeats=1000 | 11,876,316 | -377 | 11,102,745 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=37 repeats=1000 | 11,884,460 | -377 | 11,110,889 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=38 repeats=1000 | 11,913,255 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=39 repeats=1000 | 11,913,742 | -377 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=40 repeats=1000 | 11,913,255 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=41 repeats=1000 | 11,912,768 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=42 repeats=1000 | 11,913,742 | -377 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=43 repeats=1000 | 11,909,960 | -377 | 11,136,389 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=44 repeats=1000 | 11,912,768 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=45 repeats=1000 | 11,911,307 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=46 repeats=1000 | 11,911,307 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=47 repeats=1000 | 11,911,307 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=48 repeats=1000 | 11,910,820 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=49 repeats=1000 | 11,910,820 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=50 repeats=1000 | 11,910,820 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=51 repeats=1000 | 11,910,820 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=52 repeats=1000 | 11,911,394 | -371 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=53 repeats=1000 | 11,898,535 | -359 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=54 repeats=1000 | 11,891,008 | -377 | 11,116,993 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=55 repeats=1000 | 11,915,647 | -377 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=56 repeats=1000 | 11,916,134 | -377 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=57 repeats=1000 | 11,915,647 | -377 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=58 repeats=1000 | 11,915,647 | -377 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=59 repeats=1000 | 11,911,865 | -377 | 11,137,850 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=60 repeats=1000 | 11,915,647 | -377 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=61 repeats=1000 | 11,911,865 | -377 | 11,137,850 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=62 repeats=1000 | 11,915,160 | -377 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=63 repeats=1000 | 11,916,134 | -377 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=64 repeats=1000 | 11,915,647 | -377 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=65 repeats=1000 | 11,913,212 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=66 repeats=1000 | 11,909,917 | -377 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=67 repeats=1000 | 11,913,212 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=68 repeats=1000 | 11,909,917 | -377 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=69 repeats=1000 | 11,912,725 | -377 | 11,138,710 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=70 repeats=1000 | 11,901,006 | -377 | 11,126,991 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=71 repeats=1000 | 11,915,647 | -377 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=72 repeats=1000 | 11,900,519 | -377 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=73 repeats=1000 | 11,900,032 | -377 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=74 repeats=1000 | 11,900,519 | -377 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=75 repeats=1000 | 11,893,442 | -377 | 11,119,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=76 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=77 repeats=1000 | 11,914,186 | -377 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=78 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=79 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=80 repeats=1000 | 11,913,212 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=81 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=82 repeats=1000 | 11,907,969 | -377 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=83 repeats=1000 | 11,910,777 | -377 | 11,136,762 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=84 repeats=1000 | 11,911,751 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=85 repeats=1000 | 11,911,751 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=86 repeats=1000 | 11,911,264 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=87 repeats=1000 | 11,898,571 | -377 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=88 repeats=1000 | 11,914,186 | -377 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=89 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=90 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=91 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=92 repeats=1000 | 11,914,186 | -377 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=93 repeats=1000 | 11,908,456 | -377 | 11,134,441 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=94 repeats=1000 | 11,911,264 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=95 repeats=1000 | 11,911,751 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=96 repeats=1000 | 11,911,264 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=97 repeats=1000 | 11,911,264 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=98 repeats=1000 | 11,907,969 | -377 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=99 repeats=1000 | 11,911,264 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=100 repeats=1000 | 11,908,456 | -377 | 11,134,441 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=101 repeats=1000 | 11,911,751 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=102 repeats=1000 | 11,912,238 | -377 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=103 repeats=1000 | 11,898,571 | -377 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=104 repeats=1000 | 11,898,084 | -377 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=105 repeats=1000 | 11,909,917 | -377 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=106 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=107 repeats=1000 | 11,909,917 | -377 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=108 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=109 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=110 repeats=1000 | 11,898,571 | -377 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=111 repeats=1000 | 11,900,519 | -377 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=112 repeats=1000 | 11,900,032 | -377 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=113 repeats=1000 | 11,898,571 | -377 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=114 repeats=1000 | 11,903,607 | -377 | 11,129,592 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=115 repeats=1000 | 11,911,751 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=116 repeats=1000 | 11,912,238 | -377 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=117 repeats=1000 | 11,911,751 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=118 repeats=1000 | 11,911,751 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=119 repeats=1000 | 11,911,264 | -377 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=120 repeats=1000 | 11,898,084 | -377 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=121 repeats=1000 | 11,894,789 | -377 | 11,120,774 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=122 repeats=1000 | 11,912,725 | -377 | 11,138,710 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=123 repeats=1000 | 11,914,186 | -377 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=124 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=125 repeats=1000 | 11,913,212 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=126 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=127 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=128 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=129 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=130 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=131 repeats=1000 | 11,914,186 | -377 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=132 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=133 repeats=1000 | 11,913,212 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=134 repeats=1000 | 11,911,751 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=135 repeats=1000 | 11,911,751 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=136 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=137 repeats=1000 | 11,896,737 | -377 | 11,122,722 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=138 repeats=1000 | 11,900,032 | -377 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=139 repeats=1000 | 11,911,865 | -377 | 11,137,850 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=140 repeats=1000 | 11,915,160 | -377 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=141 repeats=1000 | 11,915,160 | -377 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=142 repeats=1000 | 11,915,647 | -377 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=143 repeats=1000 | 11,915,160 | -377 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=144 repeats=1000 | 11,911,865 | -377 | 11,137,850 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=145 repeats=1000 | 11,915,647 | -377 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=146 repeats=1000 | 11,909,917 | -377 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=147 repeats=1000 | 11,914,186 | -377 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=148 repeats=1000 | 11,899,058 | -377 | 11,125,043 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=149 repeats=1000 | 11,898,571 | -377 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=150 repeats=1000 | 11,898,571 | -377 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=151 repeats=1000 | 11,898,084 | -377 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=152 repeats=1000 | 11,911,751 | -377 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=153 repeats=1000 | 11,907,969 | -377 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=154 repeats=1000 | 11,897,597 | -377 | 11,123,582 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=155 repeats=1000 | 11,894,303 | -377 | 11,120,288 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=156 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=157 repeats=1000 | 11,913,699 | -377 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=158 repeats=1000 | 11,913,212 | -377 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=159 repeats=1000 | 11,913,753 | -369 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=160 repeats=1000 | 11,905,627 | -381 | 11,131,540 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=161 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=162 repeats=1000 | 11,912,310 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=163 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=164 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=165 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=166 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=167 repeats=1000 | 11,908,041 | -381 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=168 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=169 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=170 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=171 repeats=1000 | 11,898,643 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=172 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=173 repeats=1000 | 11,914,258 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=174 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=175 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=176 repeats=1000 | 11,909,989 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=177 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=178 repeats=1000 | 11,910,476 | -381 | 11,136,389 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=179 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=180 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=181 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=182 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=183 repeats=1000 | 11,909,989 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=184 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=185 repeats=1000 | 11,910,476 | -381 | 11,136,389 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=186 repeats=1000 | 11,899,130 | -381 | 11,125,043 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=187 repeats=1000 | 11,899,130 | -381 | 11,125,043 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=188 repeats=1000 | 11,885,463 | -381 | 11,111,376 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=189 repeats=1000 | 11,900,591 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=190 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=191 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=192 repeats=1000 | 11,909,989 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=193 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=194 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=195 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=196 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=197 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=198 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=199 repeats=1000 | 11,906,694 | -381 | 11,132,607 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=200 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=201 repeats=1000 | 11,914,258 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=202 repeats=1000 | 11,912,310 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=203 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=204 repeats=1000 | 11,898,156 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=205 repeats=1000 | 11,898,643 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=206 repeats=1000 | 11,909,989 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=207 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=208 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=209 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=210 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=211 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=212 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=213 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=214 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=215 repeats=1000 | 11,908,041 | -381 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=216 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=217 repeats=1000 | 11,910,476 | -381 | 11,136,389 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=218 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=219 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=220 repeats=1000 | 11,912,310 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=221 repeats=1000 | 11,898,643 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=222 repeats=1000 | 11,894,861 | -381 | 11,120,774 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=223 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=224 repeats=1000 | 11,894,861 | -381 | 11,120,774 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=225 repeats=1000 | 11,898,156 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=226 repeats=1000 | 11,898,643 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=227 repeats=1000 | 11,900,591 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=228 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=229 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=230 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=231 repeats=1000 | 11,908,041 | -381 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=232 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=233 repeats=1000 | 11,912,310 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=234 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=235 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=236 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=237 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=238 repeats=1000 | 11,891,079 | -381 | 11,116,992 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=239 repeats=1000 | 11,898,156 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=240 repeats=1000 | 11,915,719 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=241 repeats=1000 | 11,916,206 | -381 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=242 repeats=1000 | 11,915,719 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=243 repeats=1000 | 11,915,232 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=244 repeats=1000 | 11,916,206 | -381 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=245 repeats=1000 | 11,907,575 | -381 | 11,133,488 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=246 repeats=1000 | 11,915,232 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=247 repeats=1000 | 11,916,206 | -381 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=248 repeats=1000 | 11,915,719 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=249 repeats=1000 | 11,915,719 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=250 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=251 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=252 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=253 repeats=1000 | 11,912,797 | -381 | 11,138,710 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=254 repeats=1000 | 11,908,435 | -381 | 11,134,348 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=255 repeats=1000 | 11,900,591 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=256 repeats=1000 | 11,900,591 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=257 repeats=1000 | 11,916,206 | -381 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=258 repeats=1000 | 11,916,206 | -381 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=259 repeats=1000 | 11,915,719 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=260 repeats=1000 | 11,915,719 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=261 repeats=1000 | 11,911,937 | -381 | 11,137,850 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=262 repeats=1000 | 11,901,078 | -381 | 11,126,991 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=263 repeats=1000 | 11,897,296 | -381 | 11,123,209 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=264 repeats=1000 | 11,900,104 | -381 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=265 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=266 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=267 repeats=1000 | 11,912,797 | -381 | 11,138,710 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=268 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=269 repeats=1000 | 11,913,284 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=270 repeats=1000 | 11,908,041 | -381 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=271 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=272 repeats=1000 | 11,898,643 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=273 repeats=1000 | 11,881,195 | -381 | 11,107,108 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=274 repeats=1000 | 11,913,771 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=275 repeats=1000 | 11,911,336 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=276 repeats=1000 | 11,911,823 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=277 repeats=1000 | 11,904,259 | -381 | 11,130,172 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=278 repeats=1000 | 11,912,075 | -370 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=279 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=280 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=281 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=282 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=283 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=284 repeats=1000 | 11,904,514 | -381 | 11,130,172 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=285 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=286 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=287 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=288 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=289 repeats=1000 | 11,898,411 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=290 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=291 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=292 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=293 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=294 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=295 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=296 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=297 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=298 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=299 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=300 repeats=1000 | 11,893,168 | -381 | 11,118,826 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=301 repeats=1000 | 11,896,950 | -381 | 11,122,608 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=302 repeats=1000 | 11,893,655 | -381 | 11,119,313 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=303 repeats=1000 | 11,909,643 | -381 | 11,135,301 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=304 repeats=1000 | 11,910,617 | -381 | 11,136,275 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=305 repeats=1000 | 11,896,950 | -381 | 11,122,608 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=306 repeats=1000 | 11,896,463 | -381 | 11,122,121 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=307 repeats=1000 | 11,908,296 | -381 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=308 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=309 repeats=1000 | 11,910,244 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=310 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=311 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=312 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=313 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=314 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=315 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=316 repeats=1000 | 11,906,949 | -381 | 11,132,607 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=317 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=318 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=319 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=320 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=321 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=322 repeats=1000 | 11,898,411 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=323 repeats=1000 | 11,891,334 | -381 | 11,116,992 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=324 repeats=1000 | 11,913,052 | -381 | 11,138,710 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=325 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=326 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=327 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=328 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=329 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=330 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=331 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=332 repeats=1000 | 11,916,461 | -381 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=333 repeats=1000 | 11,916,461 | -381 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=334 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=335 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=336 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=337 repeats=1000 | 11,882,911 | -381 | 11,108,569 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=338 repeats=1000 | 11,898,411 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=339 repeats=1000 | 11,881,449 | -381 | 11,107,107 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=340 repeats=1000 | 11,885,718 | -381 | 11,111,376 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=341 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=342 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=343 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=344 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=345 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=346 repeats=1000 | 11,908,296 | -381 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=347 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=348 repeats=1000 | 11,908,783 | -381 | 11,134,441 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=349 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=350 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=351 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=352 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=353 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=354 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=355 repeats=1000 | 11,904,514 | -381 | 11,130,172 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=356 repeats=1000 | 11,898,898 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=357 repeats=1000 | 11,899,385 | -381 | 11,125,043 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=358 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=359 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=360 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=361 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=362 repeats=1000 | 11,906,462 | -381 | 11,132,120 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=363 repeats=1000 | 11,913,052 | -381 | 11,138,710 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=364 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=365 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=366 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=367 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=368 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=369 repeats=1000 | 11,908,690 | -381 | 11,134,348 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=370 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=371 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=372 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=373 repeats=1000 | 11,900,846 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=374 repeats=1000 | 11,882,911 | -381 | 11,108,569 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=375 repeats=1000 | 11,896,578 | -381 | 11,122,236 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=376 repeats=1000 | 11,900,846 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=377 repeats=1000 | 11,900,359 | -381 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=378 repeats=1000 | 11,897,064 | -381 | 11,122,722 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=379 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=380 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=381 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=382 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=383 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=384 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=385 repeats=1000 | 11,910,244 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=386 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=387 repeats=1000 | 11,908,783 | -381 | 11,134,441 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=388 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=389 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=390 repeats=1000 | 11,900,846 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=391 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=392 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=393 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=394 repeats=1000 | 11,907,343 | -381 | 11,133,001 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=395 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=396 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=397 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=398 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=399 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=400 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=401 repeats=1000 | 11,908,897 | -381 | 11,134,555 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=402 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=403 repeats=1000 | 11,916,461 | -381 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=404 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=405 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=406 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=407 repeats=1000 | 11,900,846 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=408 repeats=1000 | 11,911,705 | -381 | 11,137,363 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=409 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=410 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=411 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=412 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=413 repeats=1000 | 11,894,143 | -381 | 11,119,801 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=414 repeats=1000 | 11,899,385 | -381 | 11,125,043 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=415 repeats=1000 | 11,898,898 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=416 repeats=1000 | 11,898,411 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=417 repeats=1000 | 11,908,783 | -381 | 11,134,441 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=418 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=419 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=420 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=421 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=422 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=423 repeats=1000 | 11,898,411 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=424 repeats=1000 | 11,894,629 | -381 | 11,120,287 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=425 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=426 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=427 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=428 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=429 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=430 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=431 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=432 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=433 repeats=1000 | 11,910,244 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=434 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=435 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=436 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=437 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=438 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=439 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=440 repeats=1000 | 11,891,821 | -381 | 11,117,479 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=441 repeats=1000 | 11,898,898 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=442 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=443 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=444 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=445 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=446 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=447 repeats=1000 | 11,906,462 | -381 | 11,132,120 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=448 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=449 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=450 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=451 repeats=1000 | 11,894,630 | -381 | 11,120,288 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=452 repeats=1000 | 11,898,411 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=453 repeats=1000 | 11,898,411 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=454 repeats=1000 | 11,891,614 | -381 | 11,117,272 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=455 repeats=1000 | 11,909,156 | -381 | 11,134,814 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=456 repeats=1000 | 11,906,835 | -381 | 11,132,493 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=457 repeats=1000 | 11,896,950 | -381 | 11,122,608 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=458 repeats=1000 | 11,896,463 | -381 | 11,122,121 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=459 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=460 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=461 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=462 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=463 repeats=1000 | 11,908,296 | -381 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=464 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=465 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=466 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=467 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=468 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=469 repeats=1000 | 11,910,130 | -381 | 11,135,788 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=470 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=471 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=472 repeats=1000 | 11,908,783 | -381 | 11,134,441 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=473 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=474 repeats=1000 | 11,898,898 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=475 repeats=1000 | 11,894,630 | -381 | 11,120,288 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=476 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=477 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=478 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=479 repeats=1000 | 11,904,514 | -381 | 11,130,172 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=480 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=481 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=482 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=483 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=484 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=485 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=486 repeats=1000 | 11,906,949 | -381 | 11,132,607 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=487 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=488 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=489 repeats=1000 | 11,898,898 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=490 repeats=1000 | 11,898,898 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=491 repeats=1000 | 11,885,231 | -381 | 11,110,889 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=492 repeats=1000 | 11,900,359 | -381 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=493 repeats=1000 | 11,909,757 | -381 | 11,135,415 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=494 repeats=1000 | 11,913,052 | -381 | 11,138,710 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=495 repeats=1000 | 11,910,244 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=496 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=497 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=498 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=499 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=500 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=501 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=502 repeats=1000 | 11,910,244 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=503 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=504 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=505 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=506 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=507 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=508 repeats=1000 | 11,899,872 | -381 | 11,125,530 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=509 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=510 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=511 repeats=1000 | 11,912,679 | -381 | 11,138,337 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=512 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=513 repeats=1000 | 11,916,461 | -381 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=514 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=515 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=516 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=517 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=518 repeats=1000 | 11,908,410 | -381 | 11,134,068 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=519 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=520 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=521 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=522 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=523 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=524 repeats=1000 | 11,900,846 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=525 repeats=1000 | 11,893,282 | -381 | 11,118,940 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=526 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=527 repeats=1000 | 11,901,333 | -381 | 11,126,991 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=528 repeats=1000 | 11,900,846 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=529 repeats=1000 | 11,900,359 | -381 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=530 repeats=1000 | 11,900,359 | -381 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=531 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=532 repeats=1000 | 11,909,757 | -381 | 11,135,415 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=533 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=534 repeats=1000 | 11,907,716 | -381 | 11,133,374 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=535 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=536 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=537 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=538 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=539 repeats=1000 | 11,903,447 | -381 | 11,129,105 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=540 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=541 repeats=1000 | 11,895,603 | -381 | 11,121,261 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=542 repeats=1000 | 11,898,898 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=543 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=544 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=545 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=546 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=547 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=548 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=549 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=550 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=551 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=552 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=553 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=554 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=555 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=556 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=557 repeats=1000 | 11,907,436 | -381 | 11,133,094 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=558 repeats=1000 | 11,901,333 | -381 | 11,126,991 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=559 repeats=1000 | 11,901,333 | -381 | 11,126,991 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=560 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=561 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=562 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=563 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=564 repeats=1000 | 11,908,410 | -381 | 11,134,068 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=565 repeats=1000 | 11,900,359 | -381 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=566 repeats=1000 | 11,900,846 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=567 repeats=1000 | 11,898,411 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=568 repeats=1000 | 11,897,924 | -381 | 11,123,582 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=569 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=570 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=571 repeats=1000 | 11,908,296 | -381 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=572 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=573 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=574 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=575 repeats=1000 | 11,898,898 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=576 repeats=1000 | 11,894,143 | -381 | 11,119,801 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=577 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=578 repeats=1000 | 11,909,757 | -381 | 11,135,415 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=579 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=580 repeats=1000 | 11,910,244 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=581 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=582 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=583 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=584 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=585 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=586 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=587 repeats=1000 | 11,910,244 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=588 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=589 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=590 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=591 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=592 repeats=1000 | 11,898,898 | -381 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=593 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=594 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=595 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=596 repeats=1000 | 11,906,949 | -381 | 11,132,607 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=597 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=598 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=599 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=600 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=601 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=602 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=603 repeats=1000 | 11,889,386 | -381 | 11,115,044 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=604 repeats=1000 | 11,896,463 | -381 | 11,122,121 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=605 repeats=1000 | 11,897,437 | -381 | 11,123,095 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=606 repeats=1000 | 11,896,950 | -381 | 11,122,608 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=607 repeats=1000 | 11,910,130 | -381 | 11,135,788 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=608 repeats=1000 | 11,909,643 | -381 | 11,135,301 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=609 repeats=1000 | 11,896,950 | -381 | 11,122,608 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=610 repeats=1000 | 11,907,809 | -381 | 11,133,467 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=611 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=612 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=613 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=614 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=615 repeats=1000 | 11,909,643 | -381 | 11,135,301 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=616 repeats=1000 | 11,910,130 | -381 | 11,135,788 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=617 repeats=1000 | 11,905,861 | -381 | 11,131,519 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=618 repeats=1000 | 11,909,643 | -381 | 11,135,301 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=619 repeats=1000 | 11,906,835 | -381 | 11,132,493 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=620 repeats=1000 | 11,910,130 | -381 | 11,135,788 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=621 repeats=1000 | 11,910,130 | -381 | 11,135,788 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=622 repeats=1000 | 11,909,643 | -381 | 11,135,301 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=623 repeats=1000 | 11,910,130 | -381 | 11,135,788 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=624 repeats=1000 | 11,909,643 | -381 | 11,135,301 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=625 repeats=1000 | 11,896,463 | -381 | 11,122,121 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=626 repeats=1000 | 11,893,655 | -381 | 11,119,313 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=627 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=628 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=629 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=630 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=631 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=632 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=633 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=634 repeats=1000 | 11,916,461 | -381 | 11,142,119 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=635 repeats=1000 | 11,909,177 | -381 | 11,134,835 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=636 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=637 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=638 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=639 repeats=1000 | 11,911,104 | -381 | 11,136,762 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=640 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=641 repeats=1000 | 11,896,950 | -381 | 11,122,608 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=642 repeats=1000 | 11,879,128 | -381 | 11,104,786 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=643 repeats=1000 | 11,886,205 | -381 | 11,111,863 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=644 repeats=1000 | 11,901,333 | -381 | 11,126,991 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=645 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=646 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=647 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=648 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=649 repeats=1000 | 11,909,757 | -381 | 11,135,415 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=650 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=651 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=652 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=653 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=654 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=655 repeats=1000 | 11,915,974 | -381 | 11,141,632 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=656 repeats=1000 | 11,912,192 | -381 | 11,137,850 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=657 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=658 repeats=1000 | 11,912,679 | -381 | 11,138,337 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=659 repeats=1000 | 11,900,846 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=660 repeats=1000 | 11,900,359 | -381 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=661 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=662 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=663 repeats=1000 | 11,909,177 | -381 | 11,134,835 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=664 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=665 repeats=1000 | 11,910,244 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=666 repeats=1000 | 11,914,513 | -381 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=667 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=668 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=669 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=670 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=671 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=672 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=673 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=674 repeats=1000 | 11,909,177 | -381 | 11,134,835 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=675 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=676 repeats=1000 | 11,900,846 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=677 repeats=1000 | 11,896,091 | -381 | 11,121,749 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=678 repeats=1000 | 11,915,487 | -381 | 11,141,145 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=679 repeats=1000 | 11,900,359 | -381 | 11,126,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=680 repeats=1000 | 11,900,846 | -381 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=681 repeats=1000 | 11,893,769 | -381 | 11,119,427 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=682 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=683 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=684 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=685 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=686 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=687 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=688 repeats=1000 | 11,907,809 | -381 | 11,133,467 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=689 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=690 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=691 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=692 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=693 repeats=1000 | 11,898,411 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=694 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=695 repeats=1000 | 11,909,757 | -381 | 11,135,415 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=696 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=697 repeats=1000 | 11,910,244 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=698 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=699 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=700 repeats=1000 | 11,913,539 | -381 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=701 repeats=1000 | 11,914,026 | -381 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=702 repeats=1000 | 11,910,244 | -381 | 11,135,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=703 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=704 repeats=1000 | 11,908,783 | -381 | 11,134,441 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=705 repeats=1000 | 11,912,565 | -381 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=706 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=707 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=708 repeats=1000 | 11,912,078 | -381 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=709 repeats=1000 | 11,911,591 | -381 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=710 repeats=1000 | 11,898,411 | -381 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=711 repeats=1000 | 11,913,551 | -378 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=712 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=713 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=714 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=715 repeats=1000 | 11,914,525 | -380 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=716 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=717 repeats=1000 | 11,898,910 | -380 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=718 repeats=1000 | 11,898,423 | -380 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=719 repeats=1000 | 11,899,397 | -380 | 11,125,043 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=720 repeats=1000 | 11,905,013 | -380 | 11,130,659 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=721 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=722 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=723 repeats=1000 | 11,913,551 | -380 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=724 repeats=1000 | 11,913,551 | -380 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=725 repeats=1000 | 11,913,064 | -380 | 11,138,710 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=726 repeats=1000 | 11,900,858 | -380 | 11,126,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=727 repeats=1000 | 11,891,346 | -380 | 11,116,992 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=728 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=729 repeats=1000 | 11,914,525 | -380 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=730 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=731 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=732 repeats=1000 | 11,911,603 | -380 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=733 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=734 repeats=1000 | 11,907,821 | -380 | 11,133,467 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=735 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=736 repeats=1000 | 11,908,308 | -380 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=737 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=738 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=739 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=740 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=741 repeats=1000 | 11,907,821 | -380 | 11,133,467 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=742 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=743 repeats=1000 | 11,895,615 | -380 | 11,121,261 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=744 repeats=1000 | 11,898,910 | -380 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=745 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=746 repeats=1000 | 11,913,551 | -380 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=747 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=748 repeats=1000 | 11,908,702 | -380 | 11,134,348 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=749 repeats=1000 | 11,913,064 | -380 | 11,138,710 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=750 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=751 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=752 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=753 repeats=1000 | 11,912,090 | -380 | 11,137,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=754 repeats=1000 | 11,879,514 | -380 | 11,105,160 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=755 repeats=1000 | 11,897,449 | -380 | 11,123,095 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=756 repeats=1000 | 11,898,910 | -380 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=757 repeats=1000 | 11,898,423 | -380 | 11,124,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=758 repeats=1000 | 11,912,577 | -380 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=759 repeats=1000 | 11,908,308 | -380 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=760 repeats=1000 | 11,898,910 | -380 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=761 repeats=1000 | 11,898,910 | -380 | 11,124,556 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=762 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=763 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=764 repeats=1000 | 11,913,551 | -380 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=765 repeats=1000 | 11,914,525 | -380 | 11,140,171 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=766 repeats=1000 | 11,906,961 | -380 | 11,132,607 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=767 repeats=1000 | 11,913,551 | -380 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=768 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=769 repeats=1000 | 11,914,038 | -380 | 11,139,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=770 repeats=1000 | 11,913,551 | -380 | 11,139,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=771 repeats=1000 | 11,911,603 | -380 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=772 repeats=1000 | 11,911,603 | -380 | 11,137,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=773 repeats=1000 | 11,908,308 | -380 | 11,133,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=774 repeats=1000 | 11,912,577 | -380 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=775 repeats=1000 | 11,907,728 | -380 | 11,133,374 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=776 repeats=1000 | 11,912,577 | -380 | 11,138,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=777 repeats=1000 | 11,902,161 | -380 | 11,127,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=778 repeats=1000 | 11,897,406 | -380 | 11,123,052 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=779 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=780 repeats=1000 | 11,913,020 | -380 | 11,138,666 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=781 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=782 repeats=1000 | 11,913,507 | -380 | 11,139,153 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=783 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=784 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=785 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=786 repeats=1000 | 11,917,776 | -380 | 11,143,422 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=787 repeats=1000 | 11,913,507 | -380 | 11,139,153 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=788 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=789 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=790 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=791 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=792 repeats=1000 | 11,895,945 | -380 | 11,121,591 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=793 repeats=1000 | 11,900,213 | -380 | 11,125,859 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=794 repeats=1000 | 11,887,033 | -380 | 11,112,679 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=795 repeats=1000 | 11,901,674 | -380 | 11,127,320 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=796 repeats=1000 | 11,914,854 | -380 | 11,140,500 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=797 repeats=1000 | 11,915,828 | -380 | 11,141,474 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=798 repeats=1000 | 11,911,559 | -380 | 11,137,205 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=799 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=800 repeats=1000 | 11,915,828 | -380 | 11,141,474 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=801 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=802 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=803 repeats=1000 | 11,914,854 | -380 | 11,140,500 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=804 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=805 repeats=1000 | 11,910,212 | -380 | 11,135,858 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=806 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=807 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=808 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=809 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=810 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=811 repeats=1000 | 11,904,109 | -380 | 11,129,755 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=812 repeats=1000 | 11,914,968 | -380 | 11,140,614 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=813 repeats=1000 | 11,919,724 | -380 | 11,145,370 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=814 repeats=1000 | 11,914,875 | -380 | 11,140,521 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=815 repeats=1000 | 11,919,724 | -380 | 11,145,370 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=816 repeats=1000 | 11,919,237 | -380 | 11,144,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=817 repeats=1000 | 11,918,750 | -380 | 11,144,396 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=818 repeats=1000 | 11,919,237 | -380 | 11,144,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=819 repeats=1000 | 11,913,020 | -380 | 11,138,666 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=820 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=821 repeats=1000 | 11,913,507 | -380 | 11,139,153 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=822 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=823 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=824 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=825 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=826 repeats=1000 | 11,913,020 | -380 | 11,138,666 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=827 repeats=1000 | 11,904,109 | -380 | 11,129,755 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=828 repeats=1000 | 11,904,109 | -380 | 11,129,755 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=829 repeats=1000 | 11,919,724 | -380 | 11,145,370 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=830 repeats=1000 | 11,899,841 | -380 | 11,125,487 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=831 repeats=1000 | 11,904,109 | -380 | 11,129,755 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=832 repeats=1000 | 11,904,109 | -380 | 11,129,755 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=833 repeats=1000 | 11,903,622 | -380 | 11,129,268 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=834 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=835 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=836 repeats=1000 | 11,917,776 | -380 | 11,143,422 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=837 repeats=1000 | 11,913,507 | -380 | 11,139,153 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=838 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=839 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=840 repeats=1000 | 11,914,854 | -380 | 11,140,500 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=841 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=842 repeats=1000 | 11,914,854 | -380 | 11,140,500 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=843 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=844 repeats=1000 | 11,898,379 | -380 | 11,124,025 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=845 repeats=1000 | 11,902,161 | -380 | 11,127,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=846 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=847 repeats=1000 | 11,917,776 | -380 | 11,143,422 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=848 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=849 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=850 repeats=1000 | 11,917,776 | -380 | 11,143,422 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=851 repeats=1000 | 11,913,507 | -380 | 11,139,153 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=852 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=853 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=854 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=855 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=856 repeats=1000 | 11,914,854 | -380 | 11,140,500 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=857 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=858 repeats=1000 | 11,911,072 | -380 | 11,136,718 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=859 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=860 repeats=1000 | 11,912,046 | -380 | 11,137,692 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=861 repeats=1000 | 11,902,161 | -380 | 11,127,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=862 repeats=1000 | 11,902,161 | -380 | 11,127,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=863 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=864 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=865 repeats=1000 | 11,913,507 | -380 | 11,139,153 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=866 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=867 repeats=1000 | 11,911,559 | -380 | 11,137,205 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=868 repeats=1000 | 11,895,945 | -380 | 11,121,591 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=869 repeats=1000 | 11,900,213 | -380 | 11,125,859 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=870 repeats=1000 | 11,900,213 | -380 | 11,125,859 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=871 repeats=1000 | 11,900,700 | -380 | 11,126,346 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=872 repeats=1000 | 11,908,544 | -380 | 11,134,190 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=873 repeats=1000 | 11,913,393 | -380 | 11,139,039 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=874 repeats=1000 | 11,913,393 | -380 | 11,139,039 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=875 repeats=1000 | 11,913,393 | -380 | 11,139,039 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=876 repeats=1000 | 11,909,611 | -380 | 11,135,257 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=877 repeats=1000 | 11,912,906 | -380 | 11,138,552 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=878 repeats=1000 | 11,900,213 | -380 | 11,125,859 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=879 repeats=1000 | 11,895,458 | -380 | 11,121,104 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=880 repeats=1000 | 11,914,367 | -380 | 11,140,013 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=881 repeats=1000 | 11,914,367 | -380 | 11,140,013 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=882 repeats=1000 | 11,914,854 | -380 | 11,140,500 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=883 repeats=1000 | 11,911,559 | -380 | 11,137,205 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=884 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=885 repeats=1000 | 11,919,724 | -380 | 11,145,370 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=886 repeats=1000 | 11,919,724 | -380 | 11,145,370 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=887 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=888 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=889 repeats=1000 | 11,917,776 | -380 | 11,143,422 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=890 repeats=1000 | 11,913,507 | -380 | 11,139,153 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=891 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=892 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=893 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=894 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=895 repeats=1000 | 11,903,622 | -380 | 11,129,268 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=896 repeats=1000 | 11,918,750 | -380 | 11,144,396 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=897 repeats=1000 | 11,914,968 | -380 | 11,140,614 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=898 repeats=1000 | 11,918,750 | -380 | 11,144,396 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=899 repeats=1000 | 11,915,942 | -380 | 11,141,588 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=900 repeats=1000 | 11,919,237 | -380 | 11,144,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=901 repeats=1000 | 11,919,237 | -380 | 11,144,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=902 repeats=1000 | 11,918,750 | -380 | 11,144,396 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=903 repeats=1000 | 11,919,237 | -380 | 11,144,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=904 repeats=1000 | 11,915,455 | -380 | 11,141,101 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=905 repeats=1000 | 11,919,237 | -380 | 11,144,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=906 repeats=1000 | 11,896,059 | -380 | 11,121,705 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=907 repeats=1000 | 11,904,596 | -380 | 11,130,242 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=908 repeats=1000 | 11,902,161 | -380 | 11,127,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=909 repeats=1000 | 11,901,674 | -380 | 11,127,320 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=910 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=911 repeats=1000 | 11,911,072 | -380 | 11,136,718 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=912 repeats=1000 | 11,902,161 | -380 | 11,127,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=913 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=914 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=915 repeats=1000 | 11,912,440 | -380 | 11,138,086 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=916 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=917 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=918 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=919 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=920 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=921 repeats=1000 | 11,915,828 | -380 | 11,141,474 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=922 repeats=1000 | 11,911,559 | -380 | 11,137,205 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=923 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=924 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=925 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=926 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=927 repeats=1000 | 11,914,854 | -380 | 11,140,500 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=928 repeats=1000 | 11,902,648 | -380 | 11,128,294 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=929 repeats=1000 | 11,898,379 | -380 | 11,124,025 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=930 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=931 repeats=1000 | 11,917,776 | -380 | 11,143,422 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=932 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=933 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=934 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=935 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=936 repeats=1000 | 11,911,559 | -380 | 11,137,205 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=937 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=938 repeats=1000 | 11,911,559 | -380 | 11,137,205 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=939 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=940 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=941 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=942 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=943 repeats=1000 | 11,911,559 | -380 | 11,137,205 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=944 repeats=1000 | 11,900,700 | -380 | 11,126,346 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=945 repeats=1000 | 11,883,738 | -380 | 11,109,384 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=946 repeats=1000 | 11,887,520 | -380 | 11,113,166 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=947 repeats=1000 | 11,902,161 | -380 | 11,127,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=948 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=949 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=950 repeats=1000 | 11,913,020 | -380 | 11,138,666 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=951 repeats=1000 | 11,916,315 | -380 | 11,141,961 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=952 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=953 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=954 repeats=1000 | 11,908,078 | -380 | 11,133,724 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=955 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=956 repeats=1000 | 11,915,828 | -380 | 11,141,474 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=957 repeats=1000 | 11,910,979 | -380 | 11,136,625 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=958 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=959 repeats=1000 | 11,915,828 | -380 | 11,141,474 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=960 repeats=1000 | 11,915,828 | -380 | 11,141,474 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=961 repeats=1000 | 11,911,559 | -380 | 11,137,205 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=962 repeats=1000 | 11,902,161 | -380 | 11,127,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=963 repeats=1000 | 11,902,161 | -380 | 11,127,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=964 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=965 repeats=1000 | 11,918,750 | -380 | 11,144,396 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=966 repeats=1000 | 11,918,263 | -380 | 11,143,909 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=967 repeats=1000 | 11,919,724 | -380 | 11,145,370 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=968 repeats=1000 | 11,915,455 | -380 | 11,141,101 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=969 repeats=1000 | 11,918,750 | -380 | 11,144,396 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=970 repeats=1000 | 11,919,724 | -380 | 11,145,370 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=971 repeats=1000 | 11,919,237 | -380 | 11,144,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=972 repeats=1000 | 11,918,750 | -380 | 11,144,396 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=973 repeats=1000 | 11,918,750 | -380 | 11,144,396 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=974 repeats=1000 | 11,919,237 | -380 | 11,144,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=975 repeats=1000 | 11,915,942 | -380 | 11,141,588 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=976 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=977 repeats=1000 | 11,913,507 | -380 | 11,139,153 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=978 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=979 repeats=1000 | 11,904,109 | -380 | 11,129,755 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=980 repeats=1000 | 11,899,841 | -380 | 11,125,487 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=981 repeats=1000 | 11,919,237 | -380 | 11,144,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=982 repeats=1000 | 11,899,840 | -380 | 11,125,486 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=983 repeats=1000 | 11,904,109 | -380 | 11,129,755 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=984 repeats=1000 | 11,900,814 | -380 | 11,126,460 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=985 repeats=1000 | 11,902,161 | -380 | 11,127,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=986 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=987 repeats=1000 | 11,914,854 | -380 | 11,140,500 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=988 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=989 repeats=1000 | 11,911,072 | -380 | 11,136,718 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=990 repeats=1000 | 11,914,854 | -380 | 11,140,500 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=991 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=992 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=993 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=994 repeats=1000 | 11,914,854 | -380 | 11,140,500 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=995 repeats=1000 | 11,915,341 | -380 | 11,140,987 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=996 repeats=1000 | 11,898,379 | -380 | 11,124,025 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=997 repeats=1000 | 11,916,802 | -380 | 11,142,448 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=998 repeats=1000 | 11,917,289 | -380 | 11,142,935 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-accrued window_repeats=1000 index=999 repeats=1000 | 11,917,776 | -380 | 11,143,422 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=0 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=1 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=2 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=3 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=4 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=5 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=6 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=7 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=8 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=9 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=10 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=11 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=12 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=13 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=14 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=15 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=16 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=17 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=18 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=19 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=20 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=21 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=22 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=23 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=24 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=25 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=26 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=27 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=28 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=29 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=30 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=31 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=32 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=33 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=34 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=35 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=36 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=37 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=38 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=39 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=40 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=41 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=42 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=43 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=44 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=45 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=46 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=47 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=48 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=49 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=50 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=51 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=52 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=53 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=54 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=55 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=56 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=57 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=58 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=59 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=60 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=61 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=62 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=63 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=64 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=65 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=66 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=67 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=68 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=69 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=70 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=71 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=72 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=73 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=74 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=75 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=76 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=77 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=78 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=79 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=80 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=81 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=82 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=83 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=84 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=85 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=86 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=87 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=88 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=89 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=90 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=91 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=92 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=93 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=94 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=95 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=96 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=97 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=98 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=99 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=100 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=101 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=102 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=103 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=104 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=105 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=106 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=107 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=108 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=109 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=110 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=111 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=112 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=113 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=114 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=115 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=116 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=117 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=118 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=119 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=120 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=121 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=122 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=123 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=124 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=125 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=126 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=127 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=128 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=129 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=130 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=131 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=132 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=133 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=134 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=135 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=136 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=137 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=138 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=139 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=140 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=141 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=142 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=143 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=144 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=145 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=146 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=147 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=148 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=149 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=150 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=151 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=152 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=153 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=154 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=155 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=156 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=157 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=158 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=159 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=160 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=161 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=162 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=163 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=164 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=165 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=166 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=167 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=168 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=169 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=170 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=171 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=172 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=173 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=174 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=175 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=176 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=177 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=178 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=179 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=180 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=181 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=182 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=183 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=184 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=185 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=186 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=187 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=188 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=189 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=190 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=191 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=192 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=193 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=194 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=195 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=196 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=197 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=198 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=199 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=200 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=201 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=202 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=203 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=204 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=205 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=206 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=207 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=208 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=209 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=210 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=211 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=212 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=213 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=214 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=215 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=216 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=217 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=218 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=219 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=220 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=221 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=222 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=223 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=224 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=225 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=226 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=227 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=228 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=229 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=230 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=231 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=232 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=233 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=234 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=235 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=236 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=237 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=238 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=239 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=240 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=241 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=242 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=243 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=244 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=245 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=246 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=247 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=248 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=249 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=250 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=251 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=252 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=253 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=254 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=255 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=256 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=257 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=258 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=259 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=260 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=261 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=262 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=263 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=264 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=265 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=266 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=267 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=268 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=269 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=270 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=271 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=272 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=273 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=274 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=275 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=276 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=277 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=278 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=279 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=280 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=281 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=282 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=283 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=284 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=285 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=286 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=287 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=288 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=289 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=290 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=291 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=292 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=293 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=294 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=295 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=296 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=297 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=298 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=299 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=300 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=301 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=302 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=303 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=304 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=305 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=306 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=307 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=308 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=309 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=310 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=311 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=312 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=313 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=314 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=315 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=316 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=317 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=318 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=319 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=320 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=321 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=322 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=323 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=324 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=325 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=326 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=327 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=328 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=329 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=330 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=331 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=332 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=333 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=334 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=335 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=336 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=337 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=338 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=339 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=340 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=341 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=342 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=343 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=344 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=345 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=346 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=347 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=348 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=349 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=350 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=351 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=352 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=353 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=354 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=355 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=356 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=357 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=358 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=359 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=360 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=361 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=362 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=363 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=364 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=365 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=366 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=367 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=368 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=369 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=370 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=371 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=372 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=373 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=374 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=375 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=376 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=377 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=378 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=379 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=380 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=381 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=382 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=383 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=384 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=385 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=386 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=387 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=388 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=389 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=390 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=391 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=392 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=393 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=394 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=395 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=396 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=397 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=398 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=399 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=400 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=401 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=402 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=403 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=404 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=405 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=406 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=407 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=408 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=409 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=410 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=411 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=412 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=413 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=414 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=415 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=416 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=417 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=418 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=419 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=420 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=421 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=422 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=423 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=424 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=425 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=426 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=427 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=428 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=429 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=430 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=431 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=432 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=433 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=434 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=435 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=436 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=437 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=438 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=439 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=440 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=441 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=442 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=443 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=444 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=445 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=446 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=447 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=448 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=449 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=450 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=451 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=452 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=453 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=454 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=455 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=456 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=457 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=458 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=459 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=460 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=461 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=462 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=463 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=464 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=465 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=466 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=467 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=468 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=469 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=470 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=471 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=472 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=473 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=474 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=475 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=476 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=477 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=478 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=479 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=480 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=481 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=482 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=483 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=484 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=485 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=486 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=487 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=488 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=489 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=490 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=491 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=492 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=493 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=494 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=495 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=496 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=497 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=498 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=499 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=500 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=501 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=502 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=503 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=504 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=505 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=506 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=507 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=508 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=509 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=510 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=511 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=512 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=513 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=514 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=515 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=516 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=517 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=518 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=519 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=520 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=521 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=522 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=523 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=524 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=525 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=526 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=527 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=528 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=529 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=530 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=531 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=532 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=533 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=534 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=535 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=536 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=537 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=538 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=539 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=540 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=541 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=542 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=543 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=544 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=545 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=546 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=547 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=548 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=549 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=550 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=551 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=552 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=553 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=554 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=555 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=556 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=557 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=558 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=559 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=560 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=561 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=562 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=563 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=564 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=565 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=566 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=567 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=568 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=569 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=570 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=571 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=572 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=573 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=574 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=575 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=576 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=577 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=578 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=579 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=580 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=581 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=582 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=583 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=584 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=585 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=586 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=587 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=588 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=589 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=590 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=591 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=592 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=593 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=594 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=595 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=596 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=597 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=598 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=599 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=600 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=601 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=602 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=603 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=604 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=605 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=606 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=607 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=608 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=609 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=610 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=611 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=612 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=613 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=614 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=615 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=616 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=617 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=618 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=619 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=620 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=621 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=622 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=623 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=624 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=625 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=626 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=627 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=628 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=629 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=630 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=631 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=632 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=633 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=634 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=635 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=636 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=637 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=638 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=639 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=640 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=641 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=642 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=643 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=644 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=645 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=646 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=647 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=648 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=649 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=650 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=651 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=652 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=653 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=654 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=655 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=656 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=657 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=658 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=659 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=660 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=661 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=662 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=663 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=664 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=665 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=666 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=667 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=668 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=669 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=670 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=671 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=672 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=673 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=674 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=675 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=676 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=677 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=678 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=679 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=680 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=681 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=682 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=683 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=684 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=685 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=686 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=687 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=688 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=689 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=690 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=691 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=692 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=693 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=694 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=695 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=696 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=697 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=698 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=699 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=700 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=701 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=702 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=703 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=704 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=705 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=706 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=707 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=708 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=709 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=710 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=711 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=712 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=713 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=714 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=715 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=716 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=717 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=718 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=719 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=720 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=721 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=722 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=723 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=724 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=725 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=726 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=727 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=728 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=729 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=730 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=731 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=732 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=733 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=734 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=735 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=736 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=737 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=738 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=739 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=740 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=741 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=742 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=743 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=744 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=745 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=746 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=747 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=748 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=749 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=750 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=751 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=752 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=753 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=754 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=755 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=756 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=757 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=758 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=759 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=760 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=761 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=762 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=763 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=764 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=765 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=766 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=767 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=768 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=769 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=770 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=771 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=772 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=773 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=774 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=775 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=776 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=777 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=778 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=779 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=780 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=781 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=782 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=783 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=784 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=785 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=786 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=787 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=788 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=789 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=790 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=791 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=792 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=793 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=794 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=795 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=796 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=797 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=798 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=799 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=800 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=801 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=802 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=803 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=804 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=805 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=806 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=807 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=808 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=809 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=810 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=811 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=812 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=813 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=814 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=815 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=816 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=817 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=818 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=819 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=820 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=821 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=822 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=823 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=824 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=825 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=826 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=827 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=828 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=829 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=830 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=831 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=832 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=833 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=834 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=835 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=836 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=837 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=838 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=839 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=840 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=841 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=842 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=843 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=844 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=845 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=846 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=847 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=848 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=849 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=850 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=851 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=852 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=853 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=854 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=855 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=856 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=857 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=858 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=859 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=860 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=861 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=862 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=863 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=864 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=865 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=866 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=867 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=868 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=869 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=870 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=871 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=872 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=873 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=874 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=875 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=876 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=877 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=878 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=879 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=880 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=881 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=882 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=883 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=884 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=885 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=886 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=887 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=888 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=889 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=890 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=891 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=892 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=893 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=894 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=895 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=896 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=897 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=898 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=899 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=900 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=901 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=902 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=903 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=904 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=905 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=906 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=907 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=908 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=909 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=910 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=911 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=912 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=913 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=914 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=915 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=916 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=917 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=918 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=919 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=920 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=921 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=922 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=923 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=924 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=925 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=926 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=927 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=928 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=929 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=930 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=931 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=932 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=933 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=934 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=935 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=936 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=937 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=938 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=939 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=940 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=941 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=942 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=943 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=944 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=945 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=946 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=947 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=948 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=949 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=950 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=951 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=952 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=953 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=954 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=955 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=956 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=957 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=958 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=959 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=960 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=961 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=962 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=963 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=964 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=965 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=966 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=967 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=968 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=969 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=970 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=971 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=972 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=973 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=974 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=975 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=976 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=977 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=978 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=979 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=980 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=981 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=982 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=983 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=984 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=985 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=986 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=987 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=988 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=989 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=990 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=991 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=992 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=993 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=994 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=995 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=996 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=997 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=998 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-noop window_repeats=1000 index=999 repeats=1000 | 2,331,721 | 0 | 2,126,165 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-partial index=0 repeats=1 | 3,623,993 | 1,581 | 3,162,380 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=0 repeats=1 | 7,240,706 | 1,518 | 6,454,507 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=1 repeats=1 | 8,808,523 | 1,622 | 7,997,467 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=2 repeats=1 | 8,803,528 | 1,622 | 7,991,311 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=3 repeats=1 | 8,824,006 | 1,622 | 8,010,640 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=4 repeats=1 | 8,908,075 | 1,662 | 8,010,649 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=5 repeats=1 | 8,922,865 | 1,717 | 8,023,774 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=6 repeats=1 | 8,836,404 | 1,622 | 8,018,910 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=7 repeats=1 | 8,967,136 | 4,965 | 8,121,718 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=8 repeats=1 | 8,815,869 | 1,651 | 8,005,233 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=9 repeats=1 | 8,836,442 | 1,623 | 8,024,649 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=10 repeats=1 | 8,831,142 | 1,623 | 8,018,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=11 repeats=1 | 8,814,655 | 1,623 | 8,000,555 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=12 repeats=1 | 8,916,502 | 1,629 | 8,016,758 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=13 repeats=1 | 8,939,040 | 1,623 | 8,038,141 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=14 repeats=1 | 8,840,382 | 1,623 | 8,022,817 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=15 repeats=1 | 8,841,289 | 1,623 | 8,022,569 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=16 repeats=1 | 8,942,254 | 1,623 | 8,037,893 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=17 repeats=1 | 8,926,672 | 1,629 | 8,023,298 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=18 repeats=1 | 8,920,644 | 1,623 | 8,016,115 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=19 repeats=1 | 8,937,372 | 1,635 | 8,031,688 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=20 repeats=1 | 8,853,386 | 1,623 | 8,028,894 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=21 repeats=1 | 8,864,872 | 1,623 | 8,039,225 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=22 repeats=1 | 8,969,164 | 4,959 | 8,115,290 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=23 repeats=1 | 8,843,793 | 1,608 | 8,025,055 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=24 repeats=1 | 8,823,059 | 1,575 | 8,003,151 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=25 repeats=1 | 8,842,670 | 1,575 | 8,021,613 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=26 repeats=1 | 8,846,762 | 1,575 | 8,024,550 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=27 repeats=1 | 8,835,398 | 1,575 | 8,012,025 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=28 repeats=1 | 8,843,793 | 1,575 | 8,019,267 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=29 repeats=1 | 8,840,431 | 1,575 | 8,014,750 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=30 repeats=1 | 8,837,716 | 1,576 | 8,010,877 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=31 repeats=1 | 8,838,136 | 1,575 | 8,010,142 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=32 repeats=1 | 8,828,828 | 1,575 | 7,999,679 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=33 repeats=1 | 8,848,112 | 1,575 | 8,017,808 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=34 repeats=1 | 8,850,244 | 1,575 | 8,018,785 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=35 repeats=1 | 8,834,850 | 1,575 | 8,002,236 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=36 repeats=1 | 8,859,838 | 1,575 | 8,026,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=37 repeats=1 | 9,046,062 | 4,953 | 8,100,909 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=38 repeats=1 | 8,921,469 | 1,609 | 8,010,918 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=39 repeats=1 | 8,925,163 | 1,575 | 8,013,457 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=40 repeats=1 | 8,839,198 | 1,575 | 8,010,040 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=41 repeats=1 | 8,939,796 | 1,575 | 8,026,584 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=42 repeats=1 | 8,840,283 | 1,575 | 8,008,815 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=43 repeats=1 | 8,934,792 | 1,575 | 8,019,270 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=44 repeats=1 | 8,930,940 | 1,575 | 8,014,263 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=45 repeats=1 | 8,939,637 | 1,575 | 8,021,805 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=46 repeats=1 | 8,941,769 | 1,575 | 8,022,782 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=47 repeats=1 | 8,947,202 | 1,575 | 8,027,060 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=48 repeats=1 | 8,951,981 | 1,575 | 8,030,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=49 repeats=1 | 8,952,398 | 1,575 | 8,029,946 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=50 repeats=1 | 8,939,696 | 1,575 | 8,016,089 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=51 repeats=1 | 8,946,659 | 1,575 | 8,021,897 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=52 repeats=1 | 9,071,532 | 4,911 | 8,118,030 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=53 repeats=1 | 8,940,658 | 1,603 | 8,022,817 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=54 repeats=1 | 8,941,914 | 1,575 | 8,022,918 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=55 repeats=1 | 8,928,958 | 1,575 | 8,008,807 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=56 repeats=1 | 8,946,426 | 1,575 | 8,025,120 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=57 repeats=1 | 8,932,006 | 1,575 | 8,009,545 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=58 repeats=1 | 8,962,526 | 1,581 | 8,034,116 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=59 repeats=1 | 8,968,659 | 1,575 | 8,039,094 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=60 repeats=1 | 8,972,780 | 1,577 | 8,046,044 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=61 repeats=1 | 9,117,857 | 9,713 | 8,114,246 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=62 repeats=1 | 8,908,050 | 1,604 | 8,009,724 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=63 repeats=1 | 8,921,649 | 1,576 | 8,022,168 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=64 repeats=1 | 8,918,890 | 1,576 | 8,018,254 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=65 repeats=1 | 8,921,760 | 1,576 | 8,019,969 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=66 repeats=1 | 8,916,088 | 1,576 | 8,013,142 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=67 repeats=1 | 9,052,163 | 4,924 | 8,120,222 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=68 repeats=1 | 8,900,058 | 1,610 | 8,003,721 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=69 repeats=1 | 8,914,078 | 1,588 | 8,016,586 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=70 repeats=1 | 8,805,325 | 1,576 | 7,990,693 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=71 repeats=1 | 8,820,098 | 1,576 | 8,004,311 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=72 repeats=1 | 8,801,656 | 1,576 | 7,984,714 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=73 repeats=1 | 8,828,224 | 1,576 | 8,010,127 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=74 repeats=1 | 8,851,146 | 1,576 | 8,031,894 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=75 repeats=1 | 8,843,679 | 1,576 | 8,023,272 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=76 repeats=1 | 8,822,571 | 1,576 | 8,001,009 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=77 repeats=1 | 8,917,190 | 1,618 | 8,011,574 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=78 repeats=1 | 8,840,702 | 1,576 | 8,016,830 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=79 repeats=1 | 8,842,091 | 1,576 | 8,017,064 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=80 repeats=1 | 8,857,108 | 1,576 | 8,030,926 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=81 repeats=1 | 8,938,209 | 1,582 | 8,026,041 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=82 repeats=1 | 8,988,717 | 4,912 | 8,132,130 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=83 repeats=1 | 8,916,896 | 1,604 | 8,011,649 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=84 repeats=1 | 8,904,179 | 1,576 | 7,997,777 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=85 repeats=1 | 8,923,553 | 1,576 | 8,015,996 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=86 repeats=1 | 8,927,648 | 1,576 | 8,018,936 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=87 repeats=1 | 8,912,980 | 1,576 | 8,003,113 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=88 repeats=1 | 8,933,570 | 1,576 | 8,022,548 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=89 repeats=1 | 8,920,122 | 1,588 | 8,007,945 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=90 repeats=1 | 8,852,015 | 1,576 | 8,023,514 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=91 repeats=1 | 8,874,231 | 1,576 | 8,044,575 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=92 repeats=1 | 8,875,383 | 1,576 | 8,044,572 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=93 repeats=1 | 8,862,433 | 1,577 | 8,030,464 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=94 repeats=1 | 8,863,101 | 1,576 | 8,029,977 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=95 repeats=1 | 8,864,732 | 1,576 | 8,030,453 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=96 repeats=1 | 8,895,549 | 1,589 | 8,037,489 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=97 repeats=1 | 9,079,681 | 4,924 | 8,108,083 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=98 repeats=1 | 8,953,122 | 1,610 | 8,017,950 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=99 repeats=1 | 8,997,752 | 1,597 | 8,058,834 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=100 repeats=1 | 8,998,021 | 1,588 | 8,059,574 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=101 repeats=1 | 8,995,146 | 1,582 | 8,055,544 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=102 repeats=1 | 9,001,305 | 1,582 | 8,060,548 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=103 repeats=1 | 9,007,297 | 1,582 | 8,065,385 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=104 repeats=1 | 9,009,426 | 1,582 | 8,066,359 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=105 repeats=1 | 9,002,995 | 1,588 | 8,083,130 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=106 repeats=1 | 9,014,195 | 1,576 | 8,087,889 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=107 repeats=1 | 8,989,270 | 1,588 | 8,067,095 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=108 repeats=1 | 9,010,309 | 1,576 | 8,081,693 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=109 repeats=1 | 9,011,951 | 1,576 | 8,082,180 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=110 repeats=1 | 9,012,013 | 1,576 | 8,081,087 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=111 repeats=1 | 9,023,496 | 1,576 | 8,091,415 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=112 repeats=1 | 9,354,191 | 11,735 | 8,351,998 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=113 repeats=1 | 9,036,853 | 1,660 | 8,106,198 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=114 repeats=1 | 9,035,657 | 1,576 | 8,103,847 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=115 repeats=1 | 9,039,011 | 1,588 | 8,106,046 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=116 repeats=1 | 9,039,682 | 1,576 | 8,105,562 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=117 repeats=1 | 9,040,834 | 1,588 | 8,105,559 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=118 repeats=1 | 9,042,130 | 1,576 | 8,105,700 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=119 repeats=1 | 9,055,316 | 1,588 | 8,117,731 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=120 repeats=1 | 9,049,102 | 1,576 | 8,113,572 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=121 repeats=1 | 9,033,102 | 1,576 | 8,096,417 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=122 repeats=1 | 9,034,747 | 1,576 | 8,096,907 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=123 repeats=1 | 9,086,950 | 1,587 | 8,121,744 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=124 repeats=1 | 9,258,356 | 9,713 | 8,215,999 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=125 repeats=1 | 9,019,019 | 1,622 | 8,082,262 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=126 repeats=1 | 9,041,585 | 1,582 | 8,103,673 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=undelegate-full index=127 repeats=1 | 9,101,370 | 4,939 | 8,136,329 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=0 repeats=1 | 5,359,073 | -8,346 | 4,749,482 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=0 repeats=1 | 2,696,016 | 0 | 2,448,891 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=1 repeats=1 | 2,179,828 | -2,148 | 1,909,299 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=1 repeats=1 | 4,835,404 | 8,809 | 4,369,029 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=2 repeats=1 | 2,188,112 | -5,620 | 1,922,045 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=2 repeats=1 | 5,250,444 | 8,809 | 4,731,668 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=3 repeats=1 | 2,369,002 | -5,599 | 2,083,728 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=3 repeats=1 | 5,312,378 | 8,844 | 4,789,920 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=4 repeats=1 | 2,359,028 | -2,129 | 2,033,549 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=4 repeats=1 | 5,051,636 | 8,816 | 4,472,494 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=5 repeats=1 | 2,298,367 | -5,617 | 1,992,338 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=5 repeats=1 | 5,267,416 | 8,809 | 4,652,837 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=6 repeats=1 | 2,166,448 | -5,605 | 1,910,101 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=6 repeats=1 | 5,185,186 | 8,809 | 4,653,367 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=7 repeats=1 | 2,155,453 | -2,149 | 1,888,460 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=7 repeats=1 | 5,196,328 | 8,809 | 4,664,503 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=8 repeats=1 | 2,211,219 | -2,149 | 1,940,241 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=8 repeats=1 | 5,830,807 | 8,809 | 5,228,496 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=9 repeats=1 | 2,381,054 | -2,166 | 2,086,541 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=9 repeats=1 | 5,904,767 | 8,816 | 5,281,872 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=10 repeats=1 | 2,215,010 | -2,161 | 1,948,209 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=10 repeats=1 | 5,306,282 | 8,809 | 4,762,078 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=11 repeats=1 | 2,339,962 | -2,140 | 2,047,312 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=11 repeats=1 | 5,684,058 | 8,816 | 5,093,310 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=12 repeats=1 | 2,323,318 | -2,170 | 2,006,307 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=12 repeats=1 | 5,574,030 | 8,844 | 4,915,432 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=13 repeats=1 | 2,342,275 | -2,173 | 2,030,245 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=13 repeats=1 | 6,154,895 | 8,816 | 5,435,234 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=14 repeats=1 | 2,282,741 | -2,174 | 2,009,405 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=14 repeats=1 | 5,868,602 | 8,816 | 5,248,094 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=15 repeats=1 | 2,314,592 | -2,173 | 2,024,957 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=15 repeats=1 | 6,055,926 | 8,844 | 5,420,754 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=16 repeats=1 | 2,377,124 | -2,179 | 2,047,057 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=16 repeats=1 | 6,049,617 | 8,781 | 5,334,847 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=17 repeats=1 | 2,180,596 | -2,169 | 1,875,385 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=17 repeats=1 | 6,030,530 | 8,837 | 5,322,937 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=18 repeats=1 | 2,227,947 | -2,191 | 1,920,111 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=18 repeats=1 | 5,561,347 | 8,809 | 4,925,419 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=19 repeats=1 | 2,223,881 | -2,166 | 1,918,584 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=19 repeats=1 | 6,168,222 | 8,809 | 5,465,496 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=20 repeats=1 | 2,303,634 | -2,179 | 2,019,161 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=20 repeats=1 | 5,935,279 | 8,788 | 5,291,329 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=21 repeats=1 | 2,249,800 | -2,160 | 1,971,031 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=21 repeats=1 | 5,754,086 | 8,837 | 5,121,214 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=22 repeats=1 | 2,427,529 | -2,171 | 2,126,948 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=22 repeats=1 | 6,320,907 | 8,816 | 5,626,038 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=23 repeats=1 | 2,560,032 | -2,173 | 2,224,429 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=23 repeats=1 | 6,153,554 | 8,816 | 5,473,192 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=24 repeats=1 | 2,331,449 | -2,158 | 2,025,482 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=24 repeats=1 | 5,731,048 | 8,837 | 5,098,158 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=25 repeats=1 | 2,442,903 | -2,176 | 2,130,507 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=25 repeats=1 | 6,335,438 | 8,816 | 5,640,528 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=26 repeats=1 | 2,357,062 | -2,195 | 2,052,915 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=26 repeats=1 | 5,764,929 | 8,809 | 5,131,900 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=27 repeats=1 | 2,286,565 | -2,176 | 1,992,462 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=27 repeats=1 | 5,742,132 | 8,809 | 5,109,242 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=28 repeats=1 | 2,547,769 | -2,182 | 2,222,673 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=28 repeats=1 | 6,325,340 | 8,844 | 5,630,424 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=29 repeats=1 | 2,483,688 | -5,613 | 2,181,677 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=29 repeats=1 | 6,322,457 | 8,844 | 5,627,570 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=30 repeats=1 | 2,329,859 | -2,197 | 2,044,611 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=30 repeats=1 | 6,151,455 | 8,732 | 5,470,826 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=31 repeats=1 | 2,366,927 | -2,170 | 2,079,605 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=31 repeats=1 | 6,321,124 | 8,844 | 5,626,092 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=32 repeats=1 | 2,273,707 | -2,176 | 1,998,893 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=32 repeats=1 | 6,141,652 | 8,844 | 5,461,168 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=33 repeats=1 | 2,323,094 | -2,176 | 2,041,313 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=33 repeats=1 | 6,142,476 | 8,844 | 5,462,108 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=34 repeats=1 | 2,223,449 | -2,178 | 1,955,841 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=34 repeats=1 | 6,228,622 | 8,753 | 5,538,715 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=35 repeats=1 | 2,255,714 | -2,176 | 1,984,785 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=35 repeats=1 | 6,281,794 | 8,816 | 5,571,303 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=36 repeats=1 | 2,498,488 | -2,181 | 2,180,560 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=36 repeats=1 | 5,895,714 | 8,837 | 5,231,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=37 repeats=1 | 2,383,335 | -2,143 | 2,034,685 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=37 repeats=1 | 5,956,790 | 8,809 | 5,210,205 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=38 repeats=1 | 2,483,640 | -2,180 | 2,127,688 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=38 repeats=1 | 6,541,386 | 8,816 | 5,732,905 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=39 repeats=1 | 2,482,048 | -2,182 | 2,127,584 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=39 repeats=1 | 6,541,338 | 8,844 | 5,732,857 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=40 repeats=1 | 2,391,273 | -2,177 | 2,079,129 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=40 repeats=1 | 5,831,240 | 8,781 | 5,191,408 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=41 repeats=1 | 2,532,390 | -2,158 | 2,169,944 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=41 repeats=1 | 6,315,593 | 8,816 | 5,545,792 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=42 repeats=1 | 2,385,018 | -2,176 | 2,076,557 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=42 repeats=1 | 6,048,164 | 8,837 | 5,372,195 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=43 repeats=1 | 2,617,367 | -2,176 | 2,246,708 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=43 repeats=1 | 6,704,374 | 8,816 | 5,882,865 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=44 repeats=1 | 2,512,742 | -5,661 | 2,168,039 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=44 repeats=1 | 6,512,678 | 8,816 | 5,705,833 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=45 repeats=1 | 2,404,313 | -2,176 | 2,075,498 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=45 repeats=1 | 6,701,962 | 8,844 | 5,880,453 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=46 repeats=1 | 2,453,822 | -2,189 | 2,119,030 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=46 repeats=1 | 6,703,865 | 8,788 | 5,882,327 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=47 repeats=1 | 2,414,147 | -2,176 | 2,088,255 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=47 repeats=1 | 6,728,196 | 8,872 | 5,906,513 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=48 repeats=1 | 2,256,163 | -2,177 | 1,947,605 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=48 repeats=1 | 6,144,203 | 8,809 | 5,385,335 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=49 repeats=1 | 2,412,537 | -2,176 | 2,088,554 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=49 repeats=1 | 6,714,578 | 8,816 | 5,893,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=50 repeats=1 | 2,458,074 | -2,159 | 2,127,187 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=50 repeats=1 | 6,774,884 | 8,816 | 5,948,344 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=51 repeats=1 | 2,632,797 | -2,163 | 2,267,395 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=51 repeats=1 | 6,819,793 | 8,844 | 5,990,146 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=52 repeats=1 | 2,543,930 | -2,170 | 2,180,339 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=52 repeats=1 | 6,820,264 | 8,844 | 5,990,588 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=53 repeats=1 | 2,548,721 | -2,182 | 2,186,647 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=53 repeats=1 | 6,831,813 | 8,844 | 6,002,166 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=54 repeats=1 | 2,402,470 | -2,184 | 2,057,718 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=54 repeats=1 | 6,260,817 | 8,781 | 5,493,548 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=55 repeats=1 | 2,652,636 | -2,182 | 2,271,581 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=55 repeats=1 | 6,649,192 | 8,816 | 5,833,948 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=56 repeats=1 | 2,595,310 | -2,170 | 2,230,187 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=56 repeats=1 | 6,830,429 | 8,816 | 6,000,782 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=57 repeats=1 | 2,531,675 | -2,183 | 2,175,510 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=57 repeats=1 | 6,579,157 | 8,816 | 5,767,862 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=58 repeats=1 | 2,442,404 | -5,670 | 2,107,278 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=58 repeats=1 | 6,183,709 | 8,837 | 5,412,383 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=59 repeats=1 | 2,440,705 | -2,182 | 2,103,135 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=59 repeats=1 | 6,573,888 | 8,816 | 5,754,703 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=60 repeats=1 | 2,353,140 | -2,189 | 2,030,228 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=60 repeats=1 | 6,587,691 | 8,816 | 5,756,598 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=61 repeats=1 | 2,483,341 | -2,176 | 2,143,437 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=61 repeats=1 | 6,757,507 | 8,844 | 5,911,866 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=62 repeats=1 | 2,434,804 | -2,170 | 2,104,773 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=62 repeats=1 | 6,390,243 | 8,844 | 5,575,818 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=63 repeats=1 | 2,438,421 | -2,182 | 2,109,924 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=63 repeats=1 | 6,964,156 | 8,816 | 6,085,512 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=64 repeats=1 | 2,423,240 | -2,177 | 2,096,289 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=64 repeats=1 | 6,954,344 | 8,816 | 6,075,816 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=65 repeats=1 | 2,508,973 | -2,175 | 2,158,320 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=65 repeats=1 | 6,782,263 | 8,844 | 5,918,138 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=66 repeats=1 | 2,542,352 | -5,686 | 2,198,507 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=66 repeats=1 | 6,952,136 | 8,788 | 6,073,492 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=67 repeats=1 | 2,342,476 | -2,183 | 2,015,469 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=67 repeats=1 | 6,798,477 | 8,809 | 5,928,265 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=68 repeats=1 | 2,336,431 | -2,185 | 2,011,278 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=68 repeats=1 | 6,368,780 | 8,809 | 5,554,188 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=69 repeats=1 | 2,432,017 | -2,176 | 2,101,036 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=69 repeats=1 | 6,953,781 | 8,816 | 6,074,970 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=70 repeats=1 | 2,313,550 | -2,210 | 2,032,206 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=70 repeats=1 | 6,667,593 | 8,732 | 5,905,568 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=71 repeats=1 | 2,327,653 | -2,182 | 2,044,073 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=71 repeats=1 | 6,489,450 | 8,844 | 5,742,118 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=72 repeats=1 | 2,307,125 | -2,176 | 2,028,762 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=72 repeats=1 | 6,654,398 | 8,844 | 5,892,518 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=73 repeats=1 | 2,455,281 | -2,200 | 2,145,868 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=73 repeats=1 | 6,488,013 | 8,816 | 5,740,652 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=74 repeats=1 | 2,321,377 | -2,176 | 2,018,153 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=74 repeats=1 | 6,100,908 | 8,837 | 5,401,814 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=75 repeats=1 | 2,407,041 | -2,182 | 2,096,871 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=75 repeats=1 | 6,491,401 | 8,816 | 5,744,040 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=76 repeats=1 | 2,416,247 | -2,194 | 2,098,308 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=76 repeats=1 | 6,087,454 | 8,837 | 5,388,186 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=77 repeats=1 | 2,352,103 | -2,155 | 2,013,050 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=77 repeats=1 | 6,171,686 | 8,809 | 5,389,664 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=78 repeats=1 | 2,371,549 | -2,196 | 2,064,557 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=78 repeats=1 | 6,098,595 | 8,725 | 5,399,356 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=79 repeats=1 | 2,407,334 | -2,188 | 2,095,942 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=79 repeats=1 | 6,307,342 | 8,809 | 5,570,533 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=80 repeats=1 | 2,398,469 | -5,673 | 2,104,842 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=80 repeats=1 | 6,318,478 | 8,781 | 5,581,669 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=81 repeats=1 | 2,517,564 | -2,179 | 2,168,204 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=81 repeats=1 | 6,966,138 | 8,816 | 6,080,279 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=82 repeats=1 | 2,488,131 | -2,182 | 2,179,764 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=82 repeats=1 | 6,890,335 | 8,844 | 6,089,307 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=83 repeats=1 | 2,418,244 | -2,176 | 2,082,938 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=83 repeats=1 | 6,775,422 | 8,844 | 5,904,227 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=84 repeats=1 | 2,300,056 | -2,202 | 1,978,681 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=84 repeats=1 | 6,381,137 | 8,753 | 5,559,497 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=85 repeats=1 | 2,471,359 | -2,176 | 2,129,921 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=85 repeats=1 | 6,794,509 | 8,816 | 5,923,053 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=86 repeats=1 | 2,453,681 | -2,182 | 2,119,108 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=86 repeats=1 | 6,788,569 | 8,844 | 5,917,229 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=87 repeats=1 | 2,370,148 | -2,181 | 2,032,988 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=87 repeats=1 | 6,363,482 | 8,837 | 5,542,103 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=88 repeats=1 | 2,527,277 | -5,673 | 2,180,609 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=88 repeats=1 | 6,774,394 | 8,788 | 5,903,199 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=89 repeats=1 | 2,361,103 | -2,176 | 2,030,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=89 repeats=1 | 6,762,374 | 8,844 | 5,891,179 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=90 repeats=1 | 2,283,076 | -2,196 | 2,003,717 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=90 repeats=1 | 6,478,206 | 8,788 | 5,730,990 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=91 repeats=1 | 2,284,241 | -2,182 | 2,003,176 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=91 repeats=1 | 6,309,655 | 8,837 | 5,572,991 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=92 repeats=1 | 2,374,097 | -2,176 | 2,085,765 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=92 repeats=1 | 6,889,931 | 8,816 | 6,088,903 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=93 repeats=1 | 2,324,766 | -2,195 | 2,041,576 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=93 repeats=1 | 6,699,410 | 8,816 | 5,912,901 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=94 repeats=1 | 2,213,056 | -2,176 | 1,943,855 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=94 repeats=1 | 6,297,683 | 8,837 | 5,561,019 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=95 repeats=1 | 2,382,384 | -2,180 | 2,084,617 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=95 repeats=1 | 6,967,938 | 8,809 | 6,156,698 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=96 repeats=1 | 2,372,660 | -5,318 | 2,087,363 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=96 repeats=1 | 6,460,341 | 8,809 | 5,692,736 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=97 repeats=1 | 2,256,327 | -2,179 | 1,944,653 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=97 repeats=1 | 6,523,531 | 8,809 | 5,672,038 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=98 repeats=1 | 2,217,815 | -2,201 | 1,915,318 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=98 repeats=1 | 6,303,190 | 8,781 | 5,495,470 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=99 repeats=1 | 2,393,516 | -2,176 | 2,069,273 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=99 repeats=1 | 6,862,214 | 8,816 | 5,992,116 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=100 repeats=1 | 2,427,005 | -2,191 | 2,097,530 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=100 repeats=1 | 6,840,966 | 8,844 | 5,987,327 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=101 repeats=1 | 2,479,606 | -2,188 | 2,144,084 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=101 repeats=1 | 6,840,034 | 8,844 | 5,986,395 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=102 repeats=1 | 2,578,971 | -2,189 | 2,232,262 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=102 repeats=1 | 7,031,634 | 8,816 | 6,163,331 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=103 repeats=1 | 2,530,310 | -5,660 | 2,188,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=103 repeats=1 | 6,840,034 | 8,844 | 5,986,395 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=104 repeats=1 | 2,333,663 | -2,195 | 2,010,218 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=104 repeats=1 | 6,448,014 | 8,781 | 5,644,075 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=105 repeats=1 | 2,381,959 | -2,177 | 2,056,092 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=105 repeats=1 | 6,852,102 | 8,816 | 5,998,463 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=106 repeats=1 | 2,488,040 | -2,196 | 2,148,789 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=106 repeats=1 | 7,100,763 | 8,816 | 6,223,457 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=107 repeats=1 | 2,430,433 | -2,171 | 2,098,941 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=107 repeats=1 | 6,959,009 | 8,816 | 6,081,069 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=108 repeats=1 | 2,433,718 | -2,184 | 2,102,151 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=108 repeats=1 | 6,986,627 | 8,816 | 6,103,285 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=109 repeats=1 | 2,384,867 | -2,183 | 2,062,186 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=109 repeats=1 | 6,976,363 | 8,844 | 6,093,137 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=110 repeats=1 | 2,433,280 | -2,190 | 2,104,642 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=110 repeats=1 | 7,167,502 | 8,816 | 6,269,583 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=111 repeats=1 | 2,539,960 | -2,189 | 2,185,755 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=111 repeats=1 | 6,979,342 | 8,844 | 6,096,087 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=112 repeats=1 | 2,531,638 | -9,102 | 2,199,307 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=112 repeats=1 | 7,173,026 | 8,816 | 6,275,105 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=113 repeats=1 | 2,332,057 | -2,183 | 2,012,247 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=113 repeats=1 | 6,994,630 | 8,844 | 6,111,257 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=114 repeats=1 | 2,373,415 | -2,196 | 2,051,447 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=114 repeats=1 | 6,591,947 | 8,816 | 5,757,367 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=115 repeats=1 | 2,380,606 | -2,183 | 2,054,757 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=115 repeats=1 | 6,983,895 | 8,816 | 6,100,667 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=116 repeats=1 | 2,279,353 | -2,184 | 1,971,387 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=116 repeats=1 | 7,181,858 | 8,816 | 6,283,821 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=117 repeats=1 | 2,280,853 | -2,177 | 1,973,335 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=117 repeats=1 | 6,993,698 | 8,844 | 6,110,325 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=118 repeats=1 | 2,334,180 | -2,202 | 2,020,618 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=118 repeats=1 | 7,003,914 | 8,816 | 6,120,425 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=119 repeats=1 | 2,275,417 | -2,177 | 1,971,888 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=119 repeats=1 | 6,994,630 | 8,844 | 6,111,257 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=120 repeats=1 | 2,165,551 | -2,196 | 1,877,648 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=120 repeats=1 | 6,383,766 | 8,809 | 5,599,633 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=121 repeats=1 | 2,252,075 | -2,183 | 1,956,102 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=121 repeats=1 | 6,575,957 | 8,816 | 5,760,750 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=122 repeats=1 | 2,166,066 | -2,195 | 1,879,515 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=122 repeats=1 | 6,585,760 | 8,809 | 5,770,408 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=123 repeats=1 | 2,222,173 | -2,183 | 1,932,374 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=123 repeats=1 | 6,989,257 | 8,816 | 6,125,286 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=124 repeats=1 | 2,216,719 | -2,190 | 1,928,428 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=124 repeats=1 | 6,978,993 | 8,816 | 6,115,138 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=125 repeats=1 | 2,155,004 | -2,175 | 1,875,873 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=125 repeats=1 | 6,978,061 | 8,844 | 6,114,206 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=126 repeats=1 | 2,060,854 | -2,190 | 1,795,336 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=126 repeats=1 | 6,598,856 | 8,781 | 5,783,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=withdraw index=127 repeats=1 | 2,164,598 | -4,629 | 1,897,137 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=claim-final index=127 repeats=1 | 6,784,380 | 8,816 | 5,937,164 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=128 operation=restake index=0 repeats=1 | 4,721,747 | 6,516 | 4,042,990 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=admin operation=create-project repeats=1 | 6,120,418 | 32,743 | 4,969,610 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=launchpad operation=deposit-gns repeats=1 | 11,421,157 | 21,522 | 10,083,371 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=launchpad operation=reward-claim repeats=1 | 3,221,310 | 2,058 | 2,917,796 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=launchpad operation=withdraw-deposit repeats=1 | 20,539,405 | -7,236 | 18,687,400 |
| GovDebtIncrement tokens=bar-baz-foo-qux users=admin operation=project-refund repeats=1 | 1,351,896 | -1 | 1,212,855 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=0 operation=query control=empty repeats=1 | 227,473 | 0 | 170,507 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=1 operation=delegate index=0 repeats=1 | 7,716,218 | 35,210 | 6,335,605 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=1 operation=query control=present-zero repeats=1 | 492,780 | 0 | 461,163 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=1 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 11,922,391 | 11,074 | 11,058,591 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=1 repeats=1 | 4,719,192 | 15,888 | 3,981,446 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=2 repeats=1 | 8,727,299 | 15,762 | 7,533,875 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=3 repeats=1 | 9,026,263 | 15,744 | 7,795,887 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=4 repeats=1 | 8,887,496 | 15,768 | 7,669,123 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=5 repeats=1 | 8,949,482 | 15,756 | 7,723,901 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=6 repeats=1 | 8,864,310 | 15,774 | 7,646,651 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=7 repeats=1 | 8,848,576 | 15,779 | 7,627,513 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=8 repeats=1 | 9,141,297 | 15,780 | 7,876,373 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=9 repeats=1 | 9,094,309 | 15,835 | 7,822,898 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=10 repeats=1 | 9,076,650 | 15,871 | 7,797,249 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=11 repeats=1 | 9,104,042 | 15,824 | 7,825,213 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=12 repeats=1 | 9,210,976 | 15,794 | 7,910,017 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=13 repeats=1 | 9,070,510 | 15,810 | 7,782,618 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=14 repeats=1 | 9,045,413 | 15,810 | 7,754,381 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=15 repeats=1 | 9,110,453 | 15,778 | 7,812,213 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=16 repeats=1 | 9,899,366 | 48,710 | 8,427,364 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=17 repeats=1 | 9,261,225 | 15,940 | 7,965,150 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=18 repeats=1 | 9,283,482 | 15,736 | 7,964,255 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=19 repeats=1 | 9,371,787 | 15,742 | 8,034,871 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=20 repeats=1 | 9,415,242 | 15,850 | 8,078,198 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=21 repeats=1 | 9,334,168 | 15,802 | 8,002,451 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=22 repeats=1 | 9,465,918 | 15,778 | 8,115,627 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=23 repeats=1 | 9,519,803 | 15,862 | 8,157,596 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=24 repeats=1 | 9,511,812 | 19,287 | 8,135,494 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=25 repeats=1 | 9,452,621 | 15,890 | 8,092,881 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=26 repeats=1 | 9,372,534 | 15,842 | 8,022,581 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=27 repeats=1 | 9,833,024 | 25,964 | 8,394,614 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=28 repeats=1 | 9,307,748 | 15,829 | 7,982,634 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=29 repeats=1 | 9,417,151 | 15,815 | 8,079,237 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=30 repeats=1 | 9,401,187 | 16,047 | 8,068,377 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=delegate index=31 repeats=1 | 9,592,508 | 19,252 | 8,217,925 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=32 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 11,836,231 | -282 | 11,034,574 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=32 repeats=1 | 5,421,992 | 19,239 | 4,532,043 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=33 repeats=1 | 9,439,087 | 15,912 | 8,094,360 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=34 repeats=1 | 9,365,750 | 15,907 | 8,025,642 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=35 repeats=1 | 9,318,357 | 15,864 | 7,982,655 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=36 repeats=1 | 9,404,097 | 15,864 | 8,052,009 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=37 repeats=1 | 9,781,740 | 25,959 | 8,351,068 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=38 repeats=1 | 9,481,031 | 15,858 | 8,133,461 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=39 repeats=1 | 9,503,122 | 15,816 | 8,151,339 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=40 repeats=1 | 9,764,163 | 19,230 | 8,343,561 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=41 repeats=1 | 9,510,100 | 15,894 | 8,133,529 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=42 repeats=1 | 9,495,339 | 15,822 | 8,115,460 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=43 repeats=1 | 9,461,004 | 15,828 | 8,073,924 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=44 repeats=1 | 9,479,255 | 15,852 | 8,087,231 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=45 repeats=1 | 9,743,324 | 15,816 | 8,311,230 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=46 repeats=1 | 10,060,397 | 28,920 | 8,584,756 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=47 repeats=1 | 9,437,218 | 15,858 | 8,086,826 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=48 repeats=1 | 9,628,771 | 19,191 | 8,234,780 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=49 repeats=1 | 9,522,162 | 15,840 | 8,148,950 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=50 repeats=1 | 9,502,876 | 15,828 | 8,128,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=51 repeats=1 | 9,601,344 | 15,846 | 8,207,357 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=52 repeats=1 | 9,546,429 | 15,816 | 8,162,921 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=53 repeats=1 | 9,572,791 | 15,816 | 8,176,754 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=54 repeats=1 | 9,586,105 | 15,882 | 8,174,763 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=55 repeats=1 | 9,814,047 | 25,602 | 8,386,058 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=56 repeats=1 | 9,478,732 | 19,143 | 8,122,926 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=57 repeats=1 | 9,244,804 | 15,858 | 7,921,163 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=58 repeats=1 | 9,181,417 | 15,840 | 7,852,843 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=59 repeats=1 | 9,282,810 | 15,816 | 7,937,175 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=60 repeats=1 | 9,262,310 | 15,816 | 7,938,711 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=61 repeats=1 | 9,526,011 | 19,164 | 8,146,265 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=62 repeats=1 | 9,223,328 | 15,846 | 7,896,951 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=63 repeats=1 | 9,505,272 | 15,812 | 8,140,690 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=64 repeats=1 | 9,754,869 | 34,785 | 8,269,988 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=65 repeats=1 | 9,327,386 | 15,877 | 7,988,115 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=66 repeats=1 | 9,842,930 | 25,635 | 8,439,345 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=67 repeats=1 | 9,307,180 | 15,979 | 7,974,232 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=68 repeats=1 | 9,195,069 | 15,841 | 7,888,296 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=69 repeats=1 | 9,442,135 | 15,835 | 8,097,468 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=70 repeats=1 | 9,266,013 | 15,973 | 7,954,207 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=71 repeats=1 | 9,344,019 | 15,919 | 8,009,856 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=72 repeats=1 | 9,407,988 | 19,234 | 8,057,969 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=73 repeats=1 | 9,381,510 | 15,925 | 8,037,422 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=74 repeats=1 | 9,380,627 | 15,943 | 8,029,419 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=75 repeats=1 | 9,298,201 | 15,877 | 7,955,007 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=76 repeats=1 | 9,486,708 | 19,171 | 8,115,228 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=77 repeats=1 | 9,685,103 | 25,972 | 8,264,390 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=78 repeats=1 | 9,146,610 | 15,882 | 7,839,022 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=79 repeats=1 | 9,339,933 | 15,849 | 8,002,859 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=80 repeats=1 | 9,451,874 | 19,236 | 8,075,897 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=81 repeats=1 | 9,392,913 | 15,904 | 8,033,191 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=82 repeats=1 | 9,304,289 | 15,823 | 7,961,718 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=83 repeats=1 | 9,487,191 | 15,841 | 8,116,365 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=84 repeats=1 | 9,187,002 | 15,862 | 7,853,447 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=85 repeats=1 | 9,183,535 | 15,816 | 7,850,932 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=86 repeats=1 | 9,533,451 | 25,598 | 8,152,499 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=87 repeats=1 | 9,156,150 | 15,834 | 7,852,806 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=88 repeats=1 | 9,188,415 | 19,232 | 7,849,227 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=89 repeats=1 | 9,169,180 | 15,859 | 7,843,107 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=90 repeats=1 | 8,974,795 | 15,925 | 7,686,489 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=91 repeats=1 | 9,365,835 | 19,221 | 8,008,742 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=92 repeats=1 | 9,255,492 | 15,901 | 7,927,198 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=93 repeats=1 | 9,174,877 | 15,908 | 7,852,819 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=94 repeats=1 | 9,089,447 | 15,920 | 7,769,044 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=95 repeats=1 | 9,196,642 | 15,871 | 7,860,458 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=96 repeats=1 | 9,370,398 | 19,074 | 8,002,403 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=97 repeats=1 | 9,671,087 | 25,972 | 8,251,244 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=98 repeats=1 | 9,075,025 | 15,879 | 7,765,380 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=99 repeats=1 | 9,165,475 | 15,820 | 7,836,905 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=100 repeats=1 | 9,245,189 | 15,884 | 7,896,071 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=101 repeats=1 | 9,386,878 | 15,845 | 8,012,158 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=102 repeats=1 | 9,103,339 | 15,811 | 7,767,236 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=103 repeats=1 | 9,196,514 | 15,815 | 7,846,504 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=104 repeats=1 | 9,824,147 | 25,629 | 8,360,402 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=105 repeats=1 | 9,214,742 | 15,828 | 7,876,741 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=106 repeats=1 | 9,108,175 | 19,116 | 7,789,641 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=107 repeats=1 | 9,213,080 | 19,088 | 7,880,302 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=108 repeats=1 | 9,069,103 | 15,869 | 7,768,930 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=109 repeats=1 | 9,070,625 | 15,829 | 7,767,251 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=110 repeats=1 | 9,103,408 | 15,846 | 7,791,206 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=111 repeats=1 | 9,237,386 | 15,831 | 7,909,175 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=112 repeats=1 | 9,222,057 | 15,838 | 7,891,117 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=113 repeats=1 | 9,696,206 | 25,660 | 8,266,435 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=114 repeats=1 | 9,201,580 | 15,954 | 7,867,380 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=115 repeats=1 | 9,394,632 | 19,247 | 8,010,136 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=116 repeats=1 | 9,036,990 | 15,916 | 7,728,983 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=117 repeats=1 | 9,213,754 | 15,903 | 7,875,096 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=118 repeats=1 | 9,034,700 | 15,877 | 7,726,340 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=119 repeats=1 | 9,160,209 | 15,882 | 7,827,343 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=120 repeats=1 | 9,059,033 | 15,830 | 7,752,050 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=121 repeats=1 | 9,046,719 | 19,147 | 7,743,571 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=122 repeats=1 | 8,802,261 | 15,859 | 7,535,952 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=123 repeats=1 | 9,095,251 | 19,178 | 7,775,333 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=124 repeats=1 | 8,794,938 | 15,869 | 7,520,086 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=125 repeats=1 | 9,400,281 | 25,630 | 8,014,473 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=126 repeats=1 | 8,790,202 | 15,951 | 7,538,981 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=delegate index=127 repeats=1 | 8,878,300 | 23,960 | 7,565,093 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-accrued window_repeats=1 index=0 repeats=1 | 12,057,079 | -377 | 11,283,957 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-noop window_repeats=1 index=0 repeats=1 | 2,309,370 | 0 | 2,104,347 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-partial index=0 repeats=1 | 3,601,432 | 1,545 | 3,140,562 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=0 repeats=1 | 7,212,833 | 1,511 | 6,427,392 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=1 repeats=1 | 8,782,974 | 1,564 | 7,972,673 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=2 repeats=1 | 8,773,217 | 1,564 | 7,961,761 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=3 repeats=1 | 8,794,663 | 1,564 | 7,982,064 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=4 repeats=1 | 8,874,863 | 1,588 | 7,978,291 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=5 repeats=1 | 8,885,355 | 1,588 | 7,987,634 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=6 repeats=1 | 8,806,380 | 1,564 | 7,990,334 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=7 repeats=1 | 8,937,476 | 4,876 | 8,093,629 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=8 repeats=1 | 8,785,818 | 1,588 | 7,976,657 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=9 repeats=1 | 8,806,872 | 1,564 | 7,996,560 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=10 repeats=1 | 8,799,618 | 1,564 | 7,988,160 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=11 repeats=1 | 8,787,394 | 1,564 | 7,974,787 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=12 repeats=1 | 8,886,346 | 1,564 | 7,988,182 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=13 repeats=1 | 8,908,391 | 1,564 | 8,009,078 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=14 repeats=1 | 8,806,907 | 1,564 | 7,990,853 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=15 repeats=1 | 8,807,901 | 1,564 | 7,990,698 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=16 repeats=1 | 8,910,613 | 1,564 | 8,007,856 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=17 repeats=1 | 8,895,025 | 1,564 | 7,993,261 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=18 repeats=1 | 8,889,478 | 1,564 | 7,986,565 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=19 repeats=1 | 8,905,713 | 1,576 | 8,001,651 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=20 repeats=1 | 8,823,750 | 1,564 | 8,000,805 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=21 repeats=1 | 8,835,230 | 1,564 | 8,011,136 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=22 repeats=1 | 8,939,345 | 4,876 | 8,087,201 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=23 repeats=1 | 8,810,399 | 1,545 | 7,993,184 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=24 repeats=1 | 8,793,441 | 1,516 | 7,975,062 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=25 repeats=1 | 8,815,854 | 1,516 | 7,996,332 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=26 repeats=1 | 8,820,914 | 1,516 | 8,000,243 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=27 repeats=1 | 8,805,762 | 1,516 | 7,983,936 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=28 repeats=1 | 8,813,664 | 1,516 | 7,990,691 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=29 repeats=1 | 8,814,565 | 1,516 | 7,990,443 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=30 repeats=1 | 8,807,572 | 1,516 | 7,982,301 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=31 repeats=1 | 8,808,963 | 1,517 | 7,982,540 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=32 repeats=1 | 8,803,918 | 1,516 | 7,976,346 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=33 repeats=1 | 8,819,414 | 1,516 | 7,990,693 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=34 repeats=1 | 8,821,540 | 1,516 | 7,991,670 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=35 repeats=1 | 8,807,114 | 1,516 | 7,976,095 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=36 repeats=1 | 8,831,122 | 1,516 | 7,998,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=37 repeats=1 | 9,017,085 | 4,864 | 8,073,794 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=38 repeats=1 | 8,893,676 | 1,540 | 7,984,777 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=39 repeats=1 | 8,888,826 | 1,516 | 7,978,778 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=40 repeats=1 | 8,810,500 | 1,516 | 7,982,925 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=41 repeats=1 | 8,910,524 | 1,516 | 7,998,982 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=42 repeats=1 | 8,812,547 | 1,516 | 7,982,674 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=43 repeats=1 | 8,905,995 | 1,516 | 7,992,155 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=44 repeats=1 | 8,905,919 | 1,516 | 7,990,930 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=45 repeats=1 | 8,912,776 | 1,516 | 7,996,638 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=46 repeats=1 | 8,905,297 | 1,516 | 7,988,010 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=47 repeats=1 | 8,923,230 | 1,516 | 8,004,794 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=48 repeats=1 | 8,919,859 | 1,516 | 8,000,274 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=49 repeats=1 | 8,919,783 | 1,516 | 7,999,049 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=50 repeats=1 | 8,911,831 | 1,516 | 7,989,948 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=51 repeats=1 | 8,918,301 | 1,516 | 7,995,269 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=52 repeats=1 | 9,042,994 | 4,828 | 8,091,402 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=53 repeats=1 | 8,907,574 | 1,540 | 7,991,433 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=54 repeats=1 | 8,913,580 | 1,516 | 7,996,290 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=55 repeats=1 | 8,900,131 | 1,516 | 7,981,692 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=56 repeats=1 | 8,919,054 | 1,516 | 7,999,466 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=57 repeats=1 | 8,904,141 | 1,516 | 7,983,404 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=58 repeats=1 | 8,934,168 | 1,516 | 8,007,488 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=59 repeats=1 | 8,940,295 | 1,516 | 8,012,466 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=60 repeats=1 | 8,944,410 | 1,518 | 8,019,416 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=61 repeats=1 | 9,092,353 | 9,575 | 8,090,913 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=62 repeats=1 | 8,884,084 | 1,540 | 7,987,365 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=63 repeats=1 | 8,892,434 | 1,516 | 7,994,566 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=64 repeats=1 | 8,887,348 | 1,516 | 7,988,331 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=65 repeats=1 | 8,890,212 | 1,516 | 7,990,046 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=66 repeats=1 | 8,887,829 | 1,516 | 7,986,514 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=67 repeats=1 | 9,031,868 | 4,840 | 8,101,738 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=68 repeats=1 | 8,872,316 | 1,540 | 7,977,580 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=69 repeats=1 | 8,885,843 | 1,528 | 7,989,958 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=70 repeats=1 | 8,777,165 | 1,516 | 7,964,065 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=71 repeats=1 | 8,791,932 | 1,516 | 7,977,683 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=72 repeats=1 | 8,778,240 | 1,516 | 7,962,842 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=73 repeats=1 | 8,800,046 | 1,516 | 7,983,499 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=74 repeats=1 | 8,818,693 | 1,516 | 8,000,997 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=75 repeats=1 | 8,815,976 | 1,516 | 7,997,131 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=76 repeats=1 | 8,794,862 | 1,516 | 7,974,868 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=77 repeats=1 | 8,892,202 | 1,552 | 7,988,241 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=78 repeats=1 | 8,809,686 | 1,516 | 7,987,394 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=79 repeats=1 | 8,809,515 | 1,516 | 7,986,074 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=80 repeats=1 | 8,828,888 | 1,516 | 8,004,298 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=81 repeats=1 | 8,914,658 | 1,516 | 8,004,169 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=82 repeats=1 | 8,959,824 | 4,828 | 8,105,015 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=83 repeats=1 | 8,887,645 | 1,540 | 7,984,047 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=84 repeats=1 | 8,876,963 | 1,516 | 7,972,216 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=85 repeats=1 | 8,895,264 | 1,516 | 7,989,368 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=86 repeats=1 | 8,898,866 | 1,516 | 7,991,821 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=87 repeats=1 | 8,884,679 | 1,516 | 7,976,485 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=88 repeats=1 | 8,905,750 | 1,516 | 7,996,407 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=89 repeats=1 | 8,891,809 | 1,528 | 7,981,317 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=90 repeats=1 | 8,822,803 | 1,516 | 7,995,912 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=91 repeats=1 | 8,846,961 | 1,516 | 8,018,921 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=92 repeats=1 | 8,847,620 | 1,516 | 8,018,431 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=93 repeats=1 | 8,834,174 | 1,516 | 8,003,836 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=94 repeats=1 | 8,835,326 | 1,517 | 8,003,836 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=95 repeats=1 | 8,835,977 | 1,516 | 8,003,338 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=96 repeats=1 | 8,867,741 | 1,522 | 8,011,348 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=97 repeats=1 | 9,050,638 | 4,834 | 8,080,968 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=98 repeats=1 | 8,924,289 | 1,546 | 7,990,835 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=99 repeats=1 | 8,969,400 | 1,534 | 8,032,206 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=100 repeats=1 | 8,970,637 | 1,522 | 8,033,920 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=101 repeats=1 | 8,971,538 | 1,522 | 8,033,672 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=102 repeats=1 | 8,971,961 | 1,522 | 8,032,946 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=103 repeats=1 | 8,979,408 | 1,522 | 8,039,244 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=104 repeats=1 | 8,980,557 | 1,522 | 8,039,244 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=105 repeats=1 | 8,977,923 | 1,528 | 8,059,797 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=106 repeats=1 | 8,984,361 | 1,516 | 8,059,800 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=107 repeats=1 | 8,961,378 | 1,528 | 8,040,954 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=108 repeats=1 | 8,981,924 | 1,516 | 8,055,065 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=109 repeats=1 | 8,980,265 | 1,516 | 8,052,257 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=110 repeats=1 | 8,986,911 | 1,516 | 8,057,754 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=111 repeats=1 | 8,993,632 | 1,516 | 8,063,326 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=112 repeats=1 | 9,324,938 | 11,609 | 8,324,883 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=113 repeats=1 | 9,005,095 | 1,588 | 8,076,275 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=114 repeats=1 | 9,025,503 | 1,516 | 8,095,250 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=115 repeats=1 | 9,026,903 | 1,528 | 8,095,501 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=116 repeats=1 | 9,029,516 | 1,516 | 8,096,965 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=117 repeats=1 | 9,029,688 | 1,528 | 8,095,988 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=118 repeats=1 | 9,036,314 | 1,516 | 8,101,465 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=119 repeats=1 | 9,043,671 | 1,528 | 8,107,673 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=120 repeats=1 | 9,038,425 | 1,516 | 8,104,488 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=121 repeats=1 | 9,026,201 | 1,516 | 8,091,115 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=122 repeats=1 | 9,024,058 | 1,516 | 8,087,823 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=123 repeats=1 | 9,075,747 | 1,524 | 8,112,173 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=124 repeats=1 | 9,247,031 | 9,581 | 8,206,915 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=125 repeats=1 | 9,007,990 | 1,558 | 8,072,691 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=126 repeats=1 | 9,030,550 | 1,522 | 8,094,102 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=undelegate-full index=127 repeats=1 | 9,090,146 | 4,853 | 8,126,758 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=0 repeats=1 | 5,352,768 | -8,363 | 4,744,185 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=0 repeats=1 | 2,690,877 | 0 | 2,444,130 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=1 repeats=1 | 2,179,522 | -2,163 | 1,909,299 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=1 repeats=1 | 4,814,335 | 8,709 | 4,349,582 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=2 repeats=1 | 2,187,767 | -5,630 | 1,922,045 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=2 repeats=1 | 5,229,093 | 8,709 | 4,712,221 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=3 repeats=1 | 2,368,633 | -5,612 | 2,083,728 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=3 repeats=1 | 5,291,027 | 8,740 | 4,770,473 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=4 repeats=1 | 2,358,623 | -2,152 | 2,033,549 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=4 repeats=1 | 5,030,204 | 8,716 | 4,453,047 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=5 repeats=1 | 2,297,965 | -5,630 | 1,992,338 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=5 repeats=1 | 5,245,702 | 8,709 | 4,633,390 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=6 repeats=1 | 2,166,091 | -5,618 | 1,910,101 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=6 repeats=1 | 5,163,553 | 8,709 | 4,633,920 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=7 repeats=1 | 2,155,087 | -2,163 | 1,888,460 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=7 repeats=1 | 5,174,695 | 8,709 | 4,645,056 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=8 repeats=1 | 2,210,850 | -2,163 | 1,940,241 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=8 repeats=1 | 5,806,846 | 8,709 | 5,207,003 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=9 repeats=1 | 2,380,607 | -2,177 | 2,086,541 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=9 repeats=1 | 5,880,554 | 8,716 | 5,260,379 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=10 repeats=1 | 2,214,659 | -2,172 | 1,948,209 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=10 repeats=1 | 5,282,573 | 8,709 | 4,740,585 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=11 repeats=1 | 2,339,536 | -2,154 | 2,047,312 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=11 repeats=1 | 5,660,097 | 8,716 | 5,071,817 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=12 repeats=1 | 2,322,904 | -2,184 | 2,006,307 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=12 repeats=1 | 5,549,988 | 8,740 | 4,893,939 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=13 repeats=1 | 2,341,867 | -2,184 | 2,030,245 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=13 repeats=1 | 6,130,601 | 8,716 | 5,413,741 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=14 repeats=1 | 2,282,378 | -2,185 | 2,009,405 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=14 repeats=1 | 5,844,389 | 8,716 | 5,226,601 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=15 repeats=1 | 2,314,142 | -2,184 | 2,024,957 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=15 repeats=1 | 6,031,713 | 8,740 | 5,399,261 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=16 repeats=1 | 2,376,641 | -2,190 | 2,047,057 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=16 repeats=1 | 6,025,293 | 8,685 | 5,313,354 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=17 repeats=1 | 2,180,149 | -2,183 | 1,875,385 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=17 repeats=1 | 6,012,740 | 8,733 | 5,307,946 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=18 repeats=1 | 2,227,536 | -2,202 | 1,920,111 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=18 repeats=1 | 5,544,091 | 8,709 | 4,910,428 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=19 repeats=1 | 2,223,446 | -2,177 | 1,918,584 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=19 repeats=1 | 6,150,684 | 8,709 | 5,450,505 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=20 repeats=1 | 2,303,184 | -2,190 | 2,019,161 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=20 repeats=1 | 5,917,288 | 8,692 | 5,276,338 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=21 repeats=1 | 2,249,356 | -2,171 | 1,971,031 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=21 repeats=1 | 5,736,065 | 8,733 | 5,106,223 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=22 repeats=1 | 2,427,043 | -2,182 | 2,126,948 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=22 repeats=1 | 6,302,634 | 8,716 | 5,611,047 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=23 repeats=1 | 2,559,474 | -2,184 | 2,224,429 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=23 repeats=1 | 6,135,281 | 8,716 | 5,458,201 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=24 repeats=1 | 2,330,927 | -2,169 | 2,025,482 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=24 repeats=1 | 5,713,027 | 8,733 | 5,083,167 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=25 repeats=1 | 2,442,357 | -2,187 | 2,130,507 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=25 repeats=1 | 6,317,165 | 8,716 | 5,625,537 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=26 repeats=1 | 2,356,552 | -2,206 | 2,052,915 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=26 repeats=1 | 5,746,908 | 8,709 | 5,116,909 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=27 repeats=1 | 2,286,061 | -2,187 | 1,992,462 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=27 repeats=1 | 5,724,111 | 8,709 | 5,094,251 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=28 repeats=1 | 2,547,241 | -2,193 | 2,222,673 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=28 repeats=1 | 6,307,067 | 8,740 | 5,615,433 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=29 repeats=1 | 2,483,202 | -5,620 | 2,181,677 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=29 repeats=1 | 6,304,184 | 8,740 | 5,612,579 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=30 repeats=1 | 2,329,406 | -2,208 | 2,044,611 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=30 repeats=1 | 6,133,182 | 8,644 | 5,455,835 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=31 repeats=1 | 2,366,480 | -2,181 | 2,079,605 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=31 repeats=1 | 6,302,851 | 8,740 | 5,611,101 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=32 repeats=1 | 2,273,266 | -2,187 | 1,998,893 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=32 repeats=1 | 6,123,379 | 8,740 | 5,446,177 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=33 repeats=1 | 2,322,659 | -2,187 | 2,041,313 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=33 repeats=1 | 6,124,203 | 8,740 | 5,447,117 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=34 repeats=1 | 2,223,020 | -2,189 | 1,955,841 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=34 repeats=1 | 6,210,319 | 8,661 | 5,523,724 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=35 repeats=1 | 2,255,261 | -2,187 | 1,984,785 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=35 repeats=1 | 6,263,239 | 8,716 | 5,556,312 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=36 repeats=1 | 2,498,002 | -2,192 | 2,180,560 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=36 repeats=1 | 5,877,411 | 8,733 | 5,216,892 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=37 repeats=1 | 2,382,732 | -2,157 | 2,034,685 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=37 repeats=1 | 5,938,406 | 8,709 | 5,195,214 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=38 repeats=1 | 2,483,013 | -2,194 | 2,127,688 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=38 repeats=1 | 6,522,873 | 8,757 | 5,717,914 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=39 repeats=1 | 2,481,427 | -2,193 | 2,127,584 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=39 repeats=1 | 6,522,957 | 8,788 | 5,717,866 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=40 repeats=1 | 2,390,757 | -2,188 | 2,079,129 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=40 repeats=1 | 5,813,732 | 8,817 | 5,176,417 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=41 repeats=1 | 2,531,811 | -2,169 | 2,169,944 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=41 repeats=1 | 6,298,151 | 8,857 | 5,530,801 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=42 repeats=1 | 2,384,484 | -2,187 | 2,076,557 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=42 repeats=1 | 6,030,821 | 8,781 | 5,357,204 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=43 repeats=1 | 2,616,770 | -2,187 | 2,246,708 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=43 repeats=1 | 6,686,818 | 8,764 | 5,867,874 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=44 repeats=1 | 2,512,190 | -5,668 | 2,168,039 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=44 repeats=1 | 6,495,122 | 8,764 | 5,690,842 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=45 repeats=1 | 2,403,791 | -2,187 | 2,075,498 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=45 repeats=1 | 6,684,406 | 8,788 | 5,865,462 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=46 repeats=1 | 2,453,306 | -2,200 | 2,119,030 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=46 repeats=1 | 6,686,357 | 8,740 | 5,867,336 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=47 repeats=1 | 2,413,637 | -2,187 | 2,088,255 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=47 repeats=1 | 6,710,736 | 8,812 | 5,891,522 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=48 repeats=1 | 2,255,689 | -2,188 | 1,947,605 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=48 repeats=1 | 6,126,779 | 8,805 | 5,370,344 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=49 repeats=1 | 2,412,039 | -2,187 | 2,088,554 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=49 repeats=1 | 6,697,022 | 8,764 | 5,878,078 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=50 repeats=1 | 2,457,582 | -2,170 | 2,127,187 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=50 repeats=1 | 6,757,328 | 8,764 | 5,933,353 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=51 repeats=1 | 2,632,242 | -2,174 | 2,267,395 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=51 repeats=1 | 6,802,237 | 8,788 | 5,975,155 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=52 repeats=1 | 2,543,303 | -2,181 | 2,180,339 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=52 repeats=1 | 6,802,804 | 8,788 | 5,975,597 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=53 repeats=1 | 2,548,100 | -2,193 | 2,186,647 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=53 repeats=1 | 6,814,353 | 8,788 | 5,987,175 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=54 repeats=1 | 2,401,885 | -2,195 | 2,057,718 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=54 repeats=1 | 6,243,393 | 8,733 | 5,478,557 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=55 repeats=1 | 2,652,027 | -2,193 | 2,271,581 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=55 repeats=1 | 6,631,636 | 8,764 | 5,818,957 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=56 repeats=1 | 2,594,707 | -2,181 | 2,230,187 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=56 repeats=1 | 6,813,017 | 8,764 | 5,985,791 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=57 repeats=1 | 2,531,078 | -2,194 | 2,175,510 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=57 repeats=1 | 6,561,745 | 8,764 | 5,752,871 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=58 repeats=1 | 2,441,855 | -5,680 | 2,107,278 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=58 repeats=1 | 6,166,291 | 8,781 | 5,397,392 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=59 repeats=1 | 2,440,153 | -2,193 | 2,103,135 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=59 repeats=1 | 6,556,338 | 8,764 | 5,739,712 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=60 repeats=1 | 2,352,594 | -2,200 | 2,030,228 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=60 repeats=1 | 6,569,901 | 8,854 | 5,741,607 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=61 repeats=1 | 2,482,801 | -2,187 | 2,143,437 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=61 repeats=1 | 6,739,789 | 8,788 | 5,896,875 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=62 repeats=1 | 2,434,270 | -2,181 | 2,104,773 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=62 repeats=1 | 6,372,525 | 8,788 | 5,560,827 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=63 repeats=1 | 2,437,893 | -2,193 | 2,109,924 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=63 repeats=1 | 6,946,306 | 8,764 | 6,070,521 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=64 repeats=1 | 2,422,718 | -2,188 | 2,096,289 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=64 repeats=1 | 6,936,494 | 8,764 | 6,060,825 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=65 repeats=1 | 2,508,388 | -2,186 | 2,158,320 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=65 repeats=1 | 6,764,413 | 8,788 | 5,903,147 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=66 repeats=1 | 2,541,776 | -5,693 | 2,198,507 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=66 repeats=1 | 6,934,382 | 8,740 | 6,058,501 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=67 repeats=1 | 2,341,924 | -2,194 | 2,015,469 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=67 repeats=1 | 6,780,693 | 8,757 | 5,913,274 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=68 repeats=1 | 2,335,915 | -2,199 | 2,011,278 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=68 repeats=1 | 6,351,062 | 8,781 | 5,539,197 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=69 repeats=1 | 2,431,477 | -2,187 | 2,101,036 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=69 repeats=1 | 6,935,931 | 8,764 | 6,059,979 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=70 repeats=1 | 2,313,055 | -2,221 | 2,032,206 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=70 repeats=1 | 6,649,992 | 8,740 | 5,890,577 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=71 repeats=1 | 2,327,164 | -2,193 | 2,044,073 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=71 repeats=1 | 6,471,897 | 8,788 | 5,727,127 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=72 repeats=1 | 2,306,642 | -2,187 | 2,028,762 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=72 repeats=1 | 6,636,845 | 8,788 | 5,877,527 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=73 repeats=1 | 2,454,735 | -2,211 | 2,145,868 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=73 repeats=1 | 6,470,460 | 8,764 | 5,725,661 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=74 repeats=1 | 2,320,789 | -2,187 | 2,018,153 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=74 repeats=1 | 6,083,535 | 8,781 | 5,386,823 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=75 repeats=1 | 2,406,429 | -2,193 | 2,096,871 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=75 repeats=1 | 6,473,896 | 8,764 | 5,729,049 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=76 repeats=1 | 2,415,671 | -2,205 | 2,098,308 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=76 repeats=1 | 6,070,129 | 8,781 | 5,373,195 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=77 repeats=1 | 2,351,494 | -2,169 | 2,013,050 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=77 repeats=1 | 6,154,280 | 8,757 | 5,374,673 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=78 repeats=1 | 2,370,985 | -2,207 | 2,064,557 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=78 repeats=1 | 6,081,222 | 8,685 | 5,384,365 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=79 repeats=1 | 2,406,746 | -2,199 | 2,095,942 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=79 repeats=1 | 6,289,807 | 8,757 | 5,555,542 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=80 repeats=1 | 2,397,935 | -5,680 | 2,104,842 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=80 repeats=1 | 6,300,943 | 8,733 | 5,566,678 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=81 repeats=1 | 2,516,982 | -2,193 | 2,168,204 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=81 repeats=1 | 6,948,390 | 8,764 | 6,065,288 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=82 repeats=1 | 2,487,594 | -2,193 | 2,179,764 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=82 repeats=1 | 6,872,716 | 8,788 | 6,074,316 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=83 repeats=1 | 2,417,674 | -2,187 | 2,082,938 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=83 repeats=1 | 6,757,722 | 8,788 | 5,889,236 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=84 repeats=1 | 2,299,522 | -2,213 | 1,978,681 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=84 repeats=1 | 6,363,521 | 8,709 | 5,544,506 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=85 repeats=1 | 2,470,801 | -2,187 | 2,129,921 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=85 repeats=1 | 6,776,761 | 8,764 | 5,908,062 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=86 repeats=1 | 2,453,129 | -2,193 | 2,119,108 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=86 repeats=1 | 6,770,869 | 8,788 | 5,902,238 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=87 repeats=1 | 2,369,563 | -2,192 | 2,032,988 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=87 repeats=1 | 6,345,914 | 8,781 | 5,527,112 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=88 repeats=1 | 2,526,677 | -5,680 | 2,180,609 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=88 repeats=1 | 6,756,646 | 8,740 | 5,888,208 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=89 repeats=1 | 2,360,521 | -2,187 | 2,030,902 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=89 repeats=1 | 6,744,626 | 8,788 | 5,876,188 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=90 repeats=1 | 2,282,569 | -2,207 | 2,003,717 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=90 repeats=1 | 6,460,701 | 8,740 | 5,715,999 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=91 repeats=1 | 2,283,740 | -2,193 | 2,003,176 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=91 repeats=1 | 6,292,120 | 8,781 | 5,558,000 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=92 repeats=1 | 2,373,572 | -2,187 | 2,085,765 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=92 repeats=1 | 6,872,264 | 8,764 | 6,073,912 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=93 repeats=1 | 2,324,247 | -2,206 | 2,041,576 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=93 repeats=1 | 6,681,743 | 8,764 | 5,897,910 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=94 repeats=1 | 2,212,573 | -2,187 | 1,943,855 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=94 repeats=1 | 6,280,148 | 8,781 | 5,546,028 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=95 repeats=1 | 2,381,832 | -2,192 | 2,084,617 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=95 repeats=1 | 6,950,241 | 8,757 | 6,141,707 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=96 repeats=1 | 2,372,126 | -5,325 | 2,087,363 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=96 repeats=1 | 6,442,692 | 8,757 | 5,677,745 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=97 repeats=1 | 2,255,769 | -2,193 | 1,944,653 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=97 repeats=1 | 6,505,801 | 8,757 | 5,657,047 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=98 repeats=1 | 2,217,323 | -2,212 | 1,915,318 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=98 repeats=1 | 6,285,652 | 8,733 | 5,480,479 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=99 repeats=1 | 2,392,928 | -2,187 | 2,069,273 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=99 repeats=1 | 6,844,544 | 8,764 | 5,977,125 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=100 repeats=1 | 2,426,423 | -2,205 | 2,097,530 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=100 repeats=1 | 6,823,332 | 8,788 | 5,972,336 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=101 repeats=1 | 2,479,030 | -2,199 | 2,144,084 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=101 repeats=1 | 6,822,400 | 8,788 | 5,971,404 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=102 repeats=1 | 2,578,401 | -2,200 | 2,232,262 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=102 repeats=1 | 7,014,048 | 8,764 | 6,148,340 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=103 repeats=1 | 2,529,692 | -5,667 | 2,188,684 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=103 repeats=1 | 6,822,496 | 8,788 | 5,971,404 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=104 repeats=1 | 2,333,087 | -2,206 | 2,010,218 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=104 repeats=1 | 6,430,512 | 8,733 | 5,629,084 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=105 repeats=1 | 2,381,359 | -2,188 | 2,056,092 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=105 repeats=1 | 6,834,468 | 8,764 | 5,983,472 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=106 repeats=1 | 2,487,446 | -2,207 | 2,148,789 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=106 repeats=1 | 7,083,225 | 8,764 | 6,208,466 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=107 repeats=1 | 2,429,845 | -2,182 | 2,098,941 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=107 repeats=1 | 6,941,339 | 8,764 | 6,066,078 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=108 repeats=1 | 2,433,136 | -2,195 | 2,102,151 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=108 repeats=1 | 6,968,957 | 8,764 | 6,088,294 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=109 repeats=1 | 2,384,291 | -2,194 | 2,062,186 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=109 repeats=1 | 6,958,693 | 8,788 | 6,078,146 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=110 repeats=1 | 2,432,710 | -2,201 | 2,104,642 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=110 repeats=1 | 7,149,832 | 8,764 | 6,254,592 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=111 repeats=1 | 2,539,327 | -2,200 | 2,185,755 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=111 repeats=1 | 6,961,672 | 8,788 | 6,081,096 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=112 repeats=1 | 2,531,038 | -9,104 | 2,199,307 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=112 repeats=1 | 7,148,852 | 8,764 | 6,253,612 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=113 repeats=1 | 2,331,463 | -2,194 | 2,012,247 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=113 repeats=1 | 6,970,456 | 8,788 | 6,089,764 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=114 repeats=1 | 2,372,827 | -2,207 | 2,051,447 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=114 repeats=1 | 6,567,905 | 8,764 | 5,735,874 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=115 repeats=1 | 2,380,024 | -2,194 | 2,054,757 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=115 repeats=1 | 6,959,721 | 8,764 | 6,079,174 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=116 repeats=1 | 2,278,777 | -2,195 | 1,971,387 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=116 repeats=1 | 7,157,684 | 8,764 | 6,262,328 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=117 repeats=1 | 2,280,283 | -2,188 | 1,973,335 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=117 repeats=1 | 6,969,524 | 8,788 | 6,088,832 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=118 repeats=1 | 2,333,616 | -2,213 | 2,020,618 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=118 repeats=1 | 6,979,740 | 8,764 | 6,098,932 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=119 repeats=1 | 2,274,859 | -2,188 | 1,971,888 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=119 repeats=1 | 6,972,502 | 8,788 | 6,091,810 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=120 repeats=1 | 2,165,029 | -2,207 | 1,877,648 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=120 repeats=1 | 6,361,938 | 8,781 | 5,580,186 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=121 repeats=1 | 2,251,529 | -2,194 | 1,956,102 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=121 repeats=1 | 6,553,997 | 8,764 | 5,741,303 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=122 repeats=1 | 2,165,556 | -2,206 | 1,879,515 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=122 repeats=1 | 6,563,848 | 8,757 | 5,750,961 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=123 repeats=1 | 2,221,639 | -2,194 | 1,932,374 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=123 repeats=1 | 6,967,213 | 8,764 | 6,105,839 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=124 repeats=1 | 2,216,191 | -2,201 | 1,928,428 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=124 repeats=1 | 6,956,901 | 8,764 | 6,095,691 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=125 repeats=1 | 2,154,482 | -2,186 | 1,875,873 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=125 repeats=1 | 6,955,969 | 8,788 | 6,094,759 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=126 repeats=1 | 2,060,368 | -2,201 | 1,795,336 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=126 repeats=1 | 6,576,992 | 8,733 | 5,764,057 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=withdraw index=127 repeats=1 | 2,164,100 | -4,636 | 1,897,137 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=claim-final index=127 repeats=1 | 6,762,384 | 8,764 | 5,917,717 |
| GovDebtIncrement tokens=bar-baz-foo-qux mode=regular users=128 operation=restake index=0 repeats=1 | 4,715,750 | 6,483 | 4,038,229 |
| CollectDepositGns (deposit 1/5, remaining 4) | 7,603,401 | 2,258 | 6,632,652 |
| CollectDepositGns (deposit 2/5, remaining 3) | 7,262,241 | -1,849 | 6,406,539 |
| CollectDepositGns (deposit 3/5, remaining 2) | 7,236,395 | -1,849 | 6,382,544 |
| CollectDepositGns (deposit 4/5, remaining 1) | 7,242,375 | -1,849 | 6,390,375 |
| CollectDepositGns (deposit 5/5, remaining 0) | 7,115,266 | -8,048 | 6,285,798 |
| Launchpad CollectDepositGns | 7,472,779 | -3,771 | 6,529,521 |
| CollectProtocolFee (1 token) | 3,406,828 | 4,384 | 3,023,036 |
| CollectProtocolFee (2 tokens) | 5,379,593 | 8,708 | 4,869,942 |
| CollectProtocolFee (5 tokens) | 11,328,896 | 21,682 | 10,426,836 |
| Launchpad CollectProtocolFee (tokens: 10) | 21,287,171 | 43,671 | 19,707,755 |
| Launchpad CollectRewardByDepositId | 3,230,292 | 2,058 | 2,918,545 |
| Create Launchpad Project | 8,574,473 | 33,729 | 6,169,743 |
| Launchpad DepositGns | 6,460,127 | 23,001 | 4,223,253 |
| Launchpad TransferLeftFromProjectByAdmin | 1,239,409 | 41 | 1,054,929 |
| CreatePool | 6,698,369 | 25,361 | 5,856,139 |
| Mint (fee:3000, wide range) | 31,531,053 | 22,702 | 29,281,928 |
| Swap (gns -> wugnot, fee:500) | 47,019,854 | 0 | 44,126,380 |
| DecreaseLiquidity | 25,591,159 | 18 | 24,138,078 |
| IncreaseLiquidity | 23,116,815 | -2,084 | 22,213,931 |
| Mint (bar:foo:500) | 29,725,411 | 22,689 | 27,383,279 |
| CollectFee (with unwrap) | 7,890,375 | 44 | 5,919,974 |
| DecreaseLiquidity (w. Remove) | 22,307,359 | 62 | 19,392,232 |
| Mint (reposition) | 30,541,804 | 8,619 | 29,387,312 |
| SetPoolTier (tier 1) | 3,999,282 | 47,025 | 1,817,327 |
| StakeToken | 10,581,584 | 23,393 | 9,682,473 |
| UintTree Set (0) | 61,953 | 0 | 42,775 |
| UintTree Get (0) | 44,661 | 0 | 43,491 |
| UintTree Set (1) | 45,843 | 0 | 42,775 |
| UintTree Get (1) | 44,661 | 0 | 43,491 |
| UintTree Set (255) | 45,843 | 0 | 42,775 |
| UintTree Get (255) | 44,661 | 0 | 43,491 |
| UintTree Set (256) | 45,843 | 0 | 42,775 |
| UintTree Get (256) | 44,661 | 0 | 43,491 |
| UintTree Set (65535) | 45,843 | 0 | 42,775 |
| UintTree Get (65535) | 44,661 | 0 | 43,491 |
| UintTree Set (4294967295) | 45,843 | 0 | 42,775 |
| UintTree Get (4294967295) | 44,661 | 0 | 43,491 |
| UintTree Set (9223372036854775807) | 45,843 | 0 | 42,775 |
| UintTree Get (9223372036854775807) | 44,661 | 0 | 43,491 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 26,942,592 | 9,054 | 23,444,915 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,533,312 | 9,054 | 27,940,291 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 27,006,929 | 9,054 | 23,490,432 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 26,869,166 | 9,054 | 23,371,729 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,181,062 | 9,054 | 22,691,500 |
| ExactInSwapRoute(grc20) - fee:100 | 30,789,086 | 9,054 | 27,204,180 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,254,051 | 9,054 | 22,745,669 |
| ExactInSwapRoute(grc20) - fee:500 | 26,124,940 | 9,054 | 22,635,618 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,775,593 | 9,054 | 25,252,097 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,217,089 | 9,054 | 29,600,862 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 28,715,946 | 9,054 | 25,173,398 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,611,731 | 9,054 | 25,088,243 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,037,098 | 9,054 | 24,521,722 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,495,898 | 9,054 | 28,887,791 |
| ExactOutSwapRoute(grc20) - fee:3000 | 27,986,103 | 9,054 | 24,451,675 |
| ExactOutSwapRoute(grc20) - fee:500 | 27,890,540 | 9,054 | 24,375,172 |
| BuildSingleHopRoutePath | 189,533 | 0 | 38,812 |
| MultiHop ExactIn (2 hops) | 52,566,663 | 9,061 | 48,222,817 |
| MultiHop ExactOut (2 hops) | 73,005,122 | 76 | 70,672,884 |
| MultiHop ExactIn (3 hops) | 72,219,347 | 33 | 69,691,368 |
| MultiHop ExactOut (3 hops) | 110,771,254 | 0 | 107,443,808 |
| MultiRoute ExactIn (50:50 split) | 71,501,812 | 0 | 68,914,570 |
| MultiRoute ExactOut (50:50 split) | 96,871,226 | 4 | 93,769,033 |
| CollectReward (only Internal Reward) | 13,959,613 | 11,137 | 12,566,489 |
| CollectReward 2nd (only Internal Reward) | 13,737,495 | 40 | 12,729,295 |
| staker CollectReward (1 external-incentive token) | 13,559,025 | 10,026 | 12,338,932 |
| staker CollectReward (2 external-incentive tokens) | 20,878,387 | 4,069 | 19,551,618 |
| staker CollectReward (3 external-incentive tokens) | 28,514,755 | 4,502 | 26,702,630 |
| staker CollectReward (4 external-incentive tokens) | 36,387,587 | 5,046 | 34,050,889 |
| storage growth: CollectReward 20 staked positions | 15,281,549 | 62 | 14,399,428 |
| storage growth: CollectReward 40 staked positions | 15,743,741 | 0 | 14,869,410 |
| storage growth: CollectReward 60 staked positions | 15,746,231 | 0 | 14,871,900 |
| storage growth: CollectReward 80 staked positions | 15,877,508 | 0 | 14,995,820 |
| storage growth: CollectReward 100 staked positions | 15,863,239 | 0 | 14,981,551 |
| CollectReward With External Rewards (1 incentives) | 22,007,091 | 14,734 | 20,059,686 |
| CollectReward With External Rewards 2nd (1 incentives) | 21,407,586 | 31 | 19,929,115 |
| CollectReward With External Rewards (5 incentives) | 52,943,926 | 28,757 | 48,827,317 |
| CollectReward With External Rewards 2nd (5 incentives) | 51,188,055 | 52 | 47,873,529 |
| CollectReward with Warmup Range (30% ~ 30%) | 13,997,609 | 11,119 | 12,598,544 |
| CollectReward with Warmup Range (30% ~ 50%) | 16,013,017 | 58 | 14,944,585 |
| CollectReward with Warmup Range (30% ~ 70%) | 18,317,883 | 18 | 17,189,745 |
| CollectReward with Warmup Range (30% ~ 100%) | 20,646,676 | 18 | 19,458,828 |
| CollectReward with Warmup Range (100% ~) | 13,412,346 | -6 | 12,482,734 |
| CollectReward with Warmup Range 2nd (100% ~) | 13,296,993 | 0 | 12,367,402 |
| CreateExternalIncentive | 3,827,242 | 66,634 | 3,162,409 |
| EndExternalIncentive | 2,291,901 | -1,979 | 2,091,114 |
| EndExternalIncentive (unclaimablePeriods=100) | 2,331,813 | 147 | 2,120,906 |
| EndExternalIncentive (unclaimablePeriods=10) | 2,281,516 | 141 | 2,072,857 |
| EndExternalIncentive (unclaimablePeriods=50) | 2,293,946 | 141 | 2,085,287 |
| Swap (halving, 10 staked tick-crosses) | 106,350,270 | 3,729 | 101,845,135 |
| Swap (halving, 1 staked tick-cross) | 32,144,132 | 2,813 | 30,458,830 |
| Swap (halving, 50 staked tick-crosses) | 445,290,167 | 7,260 | 429,482,563 |
| Swap (no halving, 10 staked tick-crosses) | 94,175,390 | -7,110 | 90,067,005 |
| Swap (no halving, 1 staked tick-cross) | 25,948,465 | -7,684 | 24,539,628 |
| Swap (no halving, 50 staked tick-crosses) | 406,540,965 | -5,108 | 391,664,753 |
| RegisterInitializer (v1) | 61,704 | 0 | 43,392 |
| RegisterInitializer (v2) | 45,463 | 0 | 43,394 |
