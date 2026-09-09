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
| Mint (fee:3000, wide range) | 31,555,824 | 22,702 | 29,304,202 |
| Swap (gns -> wugnot, fee:500) | 47,050,917 | 0 | 44,151,584 |
| DecreaseLiquidity | 25,630,642 | 18 | 24,170,632 |
| IncreaseLiquidity | 23,148,004 | -2,084 | 22,239,125 |
| Mint (bar:foo:500) | 29,749,971 | 22,689 | 27,402,585 |
| CollectFee (with unwrap) | 7,921,428 | 44 | 5,945,168 |
| DecreaseLiquidity (w. Remove) | 22,338,410 | 62 | 19,417,426 |
| Mint (reposition) | 30,576,495 | 8,619 | 29,418,394 |
| SetPoolTier (tier 1) | 4,030,825 | 47,025 | 1,842,521 |
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
| Remaining staker deposit liquidity allocation StakeToken | 10,675,746 | 23,375 | 9,732,829 |
| Remaining staker deposit liquidity repeat zero reward 1 | 2,280,074 | 30 | 2,071,459 |
| Remaining staker deposit liquidity repeat accrued 1 call 1 | 13,869,873 | 9,060 | 12,493,747 |
| Remaining staker deposit liquidity repeat accrued 10 call 1 | 13,762,917 | 40 | 12,757,419 |
| Remaining staker deposit liquidity repeat accrued 10 call 2 | 13,762,654 | 0 | 12,757,419 |
| Remaining staker deposit liquidity repeat accrued 10 call 3 | 13,763,141 | 0 | 12,757,906 |
| Remaining staker deposit liquidity repeat accrued 10 call 4 | 13,761,680 | 0 | 12,756,445 |
| Remaining staker deposit liquidity repeat accrued 10 call 5 | 13,762,167 | 0 | 12,756,932 |
| Remaining staker deposit liquidity repeat accrued 10 call 6 | 13,763,141 | 0 | 12,757,906 |
| Remaining staker deposit liquidity repeat accrued 10 call 7 | 13,763,141 | 0 | 12,757,906 |
| Remaining staker deposit liquidity repeat accrued 10 call 8 | 13,761,680 | 0 | 12,756,445 |
| Remaining staker deposit liquidity repeat accrued 10 call 9 | 13,764,976 | 0 | 12,759,740 |
| Remaining staker deposit liquidity repeat accrued 10 call 10 | 13,788,934 | 68 | 12,783,173 |
| Remaining staker deposit liquidity repeat accrued 100 call 1 | 13,767,630 | 4 | 12,761,201 |
| Remaining staker deposit liquidity repeat accrued 100 call 2 | 13,767,385 | 0 | 12,761,201 |
| Remaining staker deposit liquidity repeat accrued 100 call 3 | 13,767,385 | 0 | 12,761,201 |
| Remaining staker deposit liquidity repeat accrued 100 call 4 | 13,767,385 | 0 | 12,761,201 |
| Remaining staker deposit liquidity repeat accrued 100 call 5 | 13,767,385 | 0 | 12,761,201 |
| Remaining staker deposit liquidity repeat accrued 100 call 6 | 13,762,629 | 0 | 12,756,445 |
| Remaining staker deposit liquidity repeat accrued 100 call 7 | 13,762,142 | 0 | 12,755,958 |
| Remaining staker deposit liquidity repeat accrued 100 call 8 | 13,765,437 | 0 | 12,759,253 |
| Remaining staker deposit liquidity repeat accrued 100 call 9 | 13,765,924 | 0 | 12,759,740 |
| Remaining staker deposit liquidity repeat accrued 100 call 10 | 13,788,870 | 0 | 12,782,686 |
| Remaining staker deposit liquidity repeat accrued 100 call 11 | 13,766,898 | 0 | 12,760,714 |
| Remaining staker deposit liquidity repeat accrued 100 call 12 | 13,766,898 | 0 | 12,760,714 |
| Remaining staker deposit liquidity repeat accrued 100 call 13 | 13,767,385 | 0 | 12,761,201 |
| Remaining staker deposit liquidity repeat accrued 100 call 14 | 13,765,924 | 0 | 12,759,740 |
| Remaining staker deposit liquidity repeat accrued 100 call 15 | 13,765,437 | 0 | 12,759,253 |
| Remaining staker deposit liquidity repeat accrued 100 call 16 | 13,765,924 | 0 | 12,759,740 |
| Remaining staker deposit liquidity repeat accrued 100 call 17 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 18 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 19 | 13,767,434 | 0 | 12,761,250 |
| Remaining staker deposit liquidity repeat accrued 100 call 20 | 13,790,380 | 0 | 12,784,196 |
| Remaining staker deposit liquidity repeat accrued 100 call 21 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 22 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 23 | 13,764,626 | 0 | 12,758,442 |
| Remaining staker deposit liquidity repeat accrued 100 call 24 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 25 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 26 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 27 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 28 | 13,766,460 | 0 | 12,760,276 |
| Remaining staker deposit liquidity repeat accrued 100 call 29 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 30 | 13,790,380 | 0 | 12,784,196 |
| Remaining staker deposit liquidity repeat accrued 100 call 31 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 32 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 33 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 34 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 35 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 36 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 37 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 38 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 39 | 13,763,165 | 0 | 12,756,981 |
| Remaining staker deposit liquidity repeat accrued 100 call 40 | 13,786,598 | 0 | 12,780,414 |
| Remaining staker deposit liquidity repeat accrued 100 call 41 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 42 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 43 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 44 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 45 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 46 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 47 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 48 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 49 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 50 | 13,790,380 | 0 | 12,784,196 |
| Remaining staker deposit liquidity repeat accrued 100 call 51 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 52 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 53 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 54 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 55 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 56 | 13,763,652 | 0 | 12,757,468 |
| Remaining staker deposit liquidity repeat accrued 100 call 57 | 13,766,460 | 0 | 12,760,276 |
| Remaining staker deposit liquidity repeat accrued 100 call 58 | 13,766,460 | 0 | 12,760,276 |
| Remaining staker deposit liquidity repeat accrued 100 call 59 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 60 | 13,789,893 | 0 | 12,783,709 |
| Remaining staker deposit liquidity repeat accrued 100 call 61 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 62 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 63 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 64 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 65 | 13,766,460 | 0 | 12,760,276 |
| Remaining staker deposit liquidity repeat accrued 100 call 66 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 67 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 68 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 69 | 13,767,434 | 0 | 12,761,250 |
| Remaining staker deposit liquidity repeat accrued 100 call 70 | 13,790,380 | 0 | 12,784,196 |
| Remaining staker deposit liquidity repeat accrued 100 call 71 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 72 | 13,763,559 | 0 | 12,757,375 |
| Remaining staker deposit liquidity repeat accrued 100 call 73 | 13,764,626 | 0 | 12,758,442 |
| Remaining staker deposit liquidity repeat accrued 100 call 74 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 75 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 76 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 77 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 78 | 13,766,460 | 0 | 12,760,276 |
| Remaining staker deposit liquidity repeat accrued 100 call 79 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 80 | 13,790,380 | 0 | 12,784,196 |
| Remaining staker deposit liquidity repeat accrued 100 call 81 | 13,767,921 | 0 | 12,761,737 |
| Remaining staker deposit liquidity repeat accrued 100 call 82 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 83 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 84 | 13,768,408 | 0 | 12,762,224 |
| Remaining staker deposit liquidity repeat accrued 100 call 85 | 13,767,434 | 0 | 12,761,250 |
| Remaining staker deposit liquidity repeat accrued 100 call 86 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 87 | 13,766,947 | 0 | 12,760,763 |
| Remaining staker deposit liquidity repeat accrued 100 call 88 | 13,768,988 | 0 | 12,762,804 |
| Remaining staker deposit liquidity repeat accrued 100 call 89 | 13,764,719 | 0 | 12,758,535 |
| Remaining staker deposit liquidity repeat accrued 100 call 90 | 13,787,665 | 0 | 12,781,481 |
| Remaining staker deposit liquidity repeat accrued 100 call 91 | 13,768,988 | 0 | 12,762,804 |
| Remaining staker deposit liquidity repeat accrued 100 call 92 | 13,768,988 | 0 | 12,762,804 |
| Remaining staker deposit liquidity repeat accrued 100 call 93 | 13,769,475 | 0 | 12,763,291 |
| Remaining staker deposit liquidity repeat accrued 100 call 94 | 13,768,988 | 0 | 12,762,804 |
| Remaining staker deposit liquidity repeat accrued 100 call 95 | 13,768,988 | 0 | 12,762,804 |
| Remaining staker deposit liquidity repeat accrued 100 call 96 | 13,769,475 | 0 | 12,763,291 |
| Remaining staker deposit liquidity repeat accrued 100 call 97 | 13,769,475 | 0 | 12,763,291 |
| Remaining staker deposit liquidity repeat accrued 100 call 98 | 13,768,014 | 0 | 12,761,830 |
| Remaining staker deposit liquidity repeat accrued 100 call 99 | 13,768,014 | 0 | 12,761,830 |
| Remaining staker deposit liquidity repeat accrued 100 call 100 | 13,791,447 | 0 | 12,785,263 |
| Remaining staker deposit liquidity query 1 | 209,592 | 0 | 197,178 |
| Remaining staker deposit liquidity query 10 | 1,666,931 | 0 | 1,598,387 |
| Remaining staker deposit liquidity query 100 | 16,242,161 | 0 | 15,595,997 |
| Remaining staker deposit liquidity lifecycle UnStakeToken | 14,378,660 | -14,655 | 13,285,384 |
| Remaining staker incentive rate allocation CreateExternalIncentive | 3,486,007 | 21,290 | 3,036,750 |
| Remaining staker incentive rate allocation CreateExternalIncentive sibling | 3,596,310 | 2,992 | 3,218,215 |
| Remaining staker incentive rate query 1 | 301,950 | 82 | 204,193 |
| Remaining staker incentive rate query 10 | 1,776,472 | 0 | 1,708,031 |
| Remaining staker incentive rate query 100 | 17,382,472 | 0 | 16,732,181 |
| Remaining staker incentive rate lifecycle CancelExternalIncentive before start | 1,678,552 | -2,766 | 1,421,416 |
| Remaining staker incentive rate repeat pre-start zero 1 | 2,274,145 | 30 | 2,067,329 |
| Remaining staker incentive rate repeat accrued 1 call 1 | 10,430,315 | 9,565 | 9,371,241 |
| Remaining staker incentive rate repeat accrued 10 call 1 | 9,943,042 | 61 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 10 call 2 | 9,944,043 | 1 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 10 call 3 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 10 call 4 | 10,007,017 | 0 | 9,366,894 |
| Remaining staker incentive rate repeat accrued 10 call 5 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 10 call 6 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 10 call 7 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 10 call 8 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 10 call 9 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 10 call 10 | 9,939,681 | 0 | 9,299,558 |
| Remaining staker incentive rate repeat accrued 100 call 1 | 9,940,748 | 0 | 9,300,625 |
| Remaining staker incentive rate repeat accrued 100 call 2 | 9,943,069 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 3 | 9,942,582 | 0 | 9,302,459 |
| Remaining staker incentive rate repeat accrued 100 call 4 | 10,006,530 | 0 | 9,366,407 |
| Remaining staker incentive rate repeat accrued 100 call 5 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 6 | 9,944,043 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 7 | 9,944,043 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 8 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 9 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 10 | 9,943,069 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 11 | 9,943,069 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 12 | 9,943,069 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 13 | 9,943,069 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 14 | 10,007,017 | 0 | 9,366,894 |
| Remaining staker incentive rate repeat accrued 100 call 15 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 16 | 9,944,530 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 17 | 9,940,748 | 0 | 9,300,625 |
| Remaining staker incentive rate repeat accrued 100 call 18 | 9,941,385 | 35 | 9,301,112 |
| Remaining staker incentive rate repeat accrued 100 call 19 | 9,944,343 | 11 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 20 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 21 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 22 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 23 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 24 | 10,006,830 | 0 | 9,366,407 |
| Remaining staker incentive rate repeat accrued 100 call 25 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 26 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 27 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 28 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 29 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 30 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 31 | 9,943,856 | 0 | 9,303,433 |
| Remaining staker incentive rate repeat accrued 100 call 32 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 33 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 34 | 9,939,587 | 0 | 9,299,164 |
| Remaining staker incentive rate repeat accrued 100 call 35 | 10,006,830 | 0 | 9,366,407 |
| Remaining staker incentive rate repeat accrued 100 call 36 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 37 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 38 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 39 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 40 | 9,942,882 | 0 | 9,302,459 |
| Remaining staker incentive rate repeat accrued 100 call 41 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 42 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 43 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 44 | 9,943,856 | 0 | 9,303,433 |
| Remaining staker incentive rate repeat accrued 100 call 45 | 10,007,317 | 0 | 9,366,894 |
| Remaining staker incentive rate repeat accrued 100 call 46 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 47 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 48 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 49 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 50 | 9,941,048 | 0 | 9,300,625 |
| Remaining staker incentive rate repeat accrued 100 call 51 | 9,941,535 | 0 | 9,301,112 |
| Remaining staker incentive rate repeat accrued 100 call 52 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 53 | 9,942,882 | 0 | 9,302,459 |
| Remaining staker incentive rate repeat accrued 100 call 54 | 9,942,882 | 0 | 9,302,459 |
| Remaining staker incentive rate repeat accrued 100 call 55 | 10,007,317 | 0 | 9,366,894 |
| Remaining staker incentive rate repeat accrued 100 call 56 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 57 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 58 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 59 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 60 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 61 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 62 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 63 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 64 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 65 | 10,007,317 | 0 | 9,366,894 |
| Remaining staker incentive rate repeat accrued 100 call 66 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 67 | 9,941,048 | 0 | 9,300,625 |
| Remaining staker incentive rate repeat accrued 100 call 68 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 69 | 9,943,856 | 0 | 9,303,433 |
| Remaining staker incentive rate repeat accrued 100 call 70 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 71 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 72 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 73 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 74 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 75 | 10,007,317 | 0 | 9,366,894 |
| Remaining staker incentive rate repeat accrued 100 call 76 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 77 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 78 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 79 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 80 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 81 | 9,943,856 | 0 | 9,303,433 |
| Remaining staker incentive rate repeat accrued 100 call 82 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 83 | 9,939,587 | 0 | 9,299,164 |
| Remaining staker incentive rate repeat accrued 100 call 84 | 9,939,587 | 0 | 9,299,164 |
| Remaining staker incentive rate repeat accrued 100 call 85 | 10,006,830 | 0 | 9,366,407 |
| Remaining staker incentive rate repeat accrued 100 call 86 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 87 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 88 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 89 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 90 | 9,942,882 | 0 | 9,302,459 |
| Remaining staker incentive rate repeat accrued 100 call 91 | 9,944,343 | 0 | 9,303,920 |
| Remaining staker incentive rate repeat accrued 100 call 92 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 93 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 94 | 9,943,369 | 0 | 9,302,946 |
| Remaining staker incentive rate repeat accrued 100 call 95 | 10,007,317 | 0 | 9,366,894 |
| Remaining staker incentive rate repeat accrued 100 call 96 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 97 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 98 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 99 | 9,944,830 | 0 | 9,304,407 |
| Remaining staker incentive rate repeat accrued 100 call 100 | 9,941,048 | 0 | 9,300,625 |
| Remaining staker incentive rate lifecycle EndExternalIncentive | 1,998,246 | -2,035 | 1,816,182 |
| Remaining staker incentive rate lifecycle UnStakeToken cleanup | 37,670,017 | -15,142 | 35,592,547 |
| Remaining staker tick gross allocation first boundary StakeToken | 9,713,312 | 30,064 | 9,005,171 |
| Remaining staker tick gross allocation shared boundary StakeToken | 9,876,503 | 4,905 | 9,147,034 |
| Remaining staker tick gross repeat crossing 1 call 1 | 36,870,765 | 1,318 | 34,237,727 |
| Remaining staker tick gross repeat crossing 10 call 1 | 36,762,684 | 11,016 | 35,144,930 |
| Remaining staker tick gross repeat crossing 10 call 2 | 37,551,897 | -7,871 | 35,987,432 |
| Remaining staker tick gross repeat crossing 10 call 3 | 36,957,815 | 7,950 | 35,388,451 |
| Remaining staker tick gross repeat crossing 10 call 4 | 37,575,720 | -7,891 | 36,011,052 |
| Remaining staker tick gross repeat crossing 10 call 5 | 36,975,062 | 7,902 | 35,405,587 |
| Remaining staker tick gross repeat crossing 10 call 6 | 37,575,233 | -7,902 | 36,010,565 |
| Remaining staker tick gross repeat crossing 10 call 7 | 36,975,549 | 7,902 | 35,406,074 |
| Remaining staker tick gross repeat crossing 10 call 8 | 37,575,720 | -7,902 | 36,011,052 |
| Remaining staker tick gross repeat crossing 10 call 9 | 36,975,549 | 7,902 | 35,406,074 |
| Remaining staker tick gross repeat crossing 10 call 10 | 37,572,912 | -7,902 | 36,008,244 |
| Remaining staker tick gross repeat crossing 100 call 1 | 36,972,523 | 7,902 | 35,402,779 |
| Remaining staker tick gross repeat crossing 100 call 2 | 37,576,207 | -7,902 | 36,011,539 |
| Remaining staker tick gross repeat crossing 100 call 3 | 36,977,016 | 7,902 | 35,407,535 |
| Remaining staker tick gross repeat crossing 100 call 4 | 37,576,207 | -7,902 | 36,011,539 |
| Remaining staker tick gross repeat crossing 100 call 5 | 36,972,260 | 7,902 | 35,402,779 |
| Remaining staker tick gross repeat crossing 100 call 6 | 37,572,912 | -7,902 | 36,008,244 |
| Remaining staker tick gross repeat crossing 100 call 7 | 36,976,529 | 7,902 | 35,407,048 |
| Remaining staker tick gross repeat crossing 100 call 8 | 37,575,233 | -7,902 | 36,010,565 |
| Remaining staker tick gross repeat crossing 100 call 9 | 36,978,363 | 7,902 | 35,408,882 |
| Remaining staker tick gross repeat crossing 100 call 10 | 37,579,502 | -7,902 | 36,014,834 |
| Remaining staker tick gross repeat crossing 100 call 11 | 36,979,824 | 7,902 | 35,410,343 |
| Remaining staker tick gross repeat crossing 100 call 12 | 37,579,015 | -7,902 | 36,014,347 |
| Remaining staker tick gross repeat crossing 100 call 13 | 36,978,850 | 7,902 | 35,409,369 |
| Remaining staker tick gross repeat crossing 100 call 14 | 37,575,720 | -7,902 | 36,011,052 |
| Remaining staker tick gross repeat crossing 100 call 15 | 36,979,824 | 7,902 | 35,410,343 |
| Remaining staker tick gross repeat crossing 100 call 16 | 37,576,207 | -7,902 | 36,011,539 |
| Remaining staker tick gross repeat crossing 100 call 17 | 36,976,529 | 7,902 | 35,407,048 |
| Remaining staker tick gross repeat crossing 100 call 18 | 37,579,989 | -7,902 | 36,015,321 |
| Remaining staker tick gross repeat crossing 100 call 19 | 36,972,747 | 7,902 | 35,403,266 |
| Remaining staker tick gross repeat crossing 100 call 20 | 37,579,989 | -7,902 | 36,015,321 |
| Remaining staker tick gross repeat crossing 100 call 21 | 36,976,529 | 7,902 | 35,407,048 |
| Remaining staker tick gross repeat crossing 100 call 22 | 37,575,720 | -7,902 | 36,011,052 |
| Remaining staker tick gross repeat crossing 100 call 23 | 36,978,850 | 7,902 | 35,409,369 |
| Remaining staker tick gross repeat crossing 100 call 24 | 37,575,720 | -7,902 | 36,011,052 |
| Remaining staker tick gross repeat crossing 100 call 25 | 36,979,824 | 7,902 | 35,410,343 |
| Remaining staker tick gross repeat crossing 100 call 26 | 37,578,528 | -7,902 | 36,013,860 |
| Remaining staker tick gross repeat crossing 100 call 27 | 36,978,850 | 7,902 | 35,409,369 |
| Remaining staker tick gross repeat crossing 100 call 28 | 37,579,015 | -7,902 | 36,014,347 |
| Remaining staker tick gross repeat crossing 100 call 29 | 36,985,941 | 7,904 | 35,416,446 |
| Remaining staker tick gross repeat crossing 100 call 30 | 37,605,356 | -7,903 | 36,040,682 |
| Remaining staker tick gross repeat crossing 100 call 31 | 36,996,974 | 7,903 | 35,427,479 |
| Remaining staker tick gross repeat crossing 100 call 32 | 37,602,274 | -7,875 | 36,037,387 |
| Remaining staker tick gross repeat crossing 100 call 33 | 36,994,899 | 7,938 | 35,425,158 |
| Remaining staker tick gross repeat crossing 100 call 34 | 37,606,801 | -7,886 | 36,041,656 |
| Remaining staker tick gross repeat crossing 100 call 35 | 36,998,906 | 7,903 | 35,428,940 |
| Remaining staker tick gross repeat crossing 100 call 36 | 37,606,801 | -7,903 | 36,041,656 |
| Remaining staker tick gross repeat crossing 100 call 37 | 36,995,124 | 7,903 | 35,425,158 |
| Remaining staker tick gross repeat crossing 100 call 38 | 37,602,532 | -7,903 | 36,037,387 |
| Remaining staker tick gross repeat crossing 100 call 39 | 36,998,419 | 7,903 | 35,428,453 |
| Remaining staker tick gross repeat crossing 100 call 40 | 37,605,827 | -7,903 | 36,040,682 |
| Remaining staker tick gross repeat crossing 100 call 41 | 36,997,932 | 7,903 | 35,427,966 |
| Remaining staker tick gross repeat crossing 100 call 42 | 37,606,314 | -7,903 | 36,041,169 |
| Remaining staker tick gross repeat crossing 100 call 43 | 36,998,906 | 7,903 | 35,428,940 |
| Remaining staker tick gross repeat crossing 100 call 44 | 37,606,314 | -7,903 | 36,041,169 |
| Remaining staker tick gross repeat crossing 100 call 45 | 36,990,368 | 7,903 | 35,420,402 |
| Remaining staker tick gross repeat crossing 100 call 46 | 37,605,827 | -7,903 | 36,040,682 |
| Remaining staker tick gross repeat crossing 100 call 47 | 36,998,419 | 7,903 | 35,428,453 |
| Remaining staker tick gross repeat crossing 100 call 48 | 37,606,314 | -7,903 | 36,041,169 |
| Remaining staker tick gross repeat crossing 100 call 49 | 36,997,445 | 7,903 | 35,427,479 |
| Remaining staker tick gross repeat crossing 100 call 50 | 37,606,344 | -7,898 | 36,041,169 |
| Remaining staker tick gross repeat crossing 100 call 51 | 36,999,050 | 7,917 | 35,428,940 |
| Remaining staker tick gross repeat crossing 100 call 52 | 37,606,413 | -7,917 | 36,041,169 |
| Remaining staker tick gross repeat crossing 100 call 53 | 36,995,268 | 7,917 | 35,425,158 |
| Remaining staker tick gross repeat crossing 100 call 54 | 37,602,631 | -7,917 | 36,037,387 |
| Remaining staker tick gross repeat crossing 100 call 55 | 36,998,076 | 7,917 | 35,427,966 |
| Remaining staker tick gross repeat crossing 100 call 56 | 37,605,926 | -7,917 | 36,040,682 |
| Remaining staker tick gross repeat crossing 100 call 57 | 36,998,563 | 7,917 | 35,428,453 |
| Remaining staker tick gross repeat crossing 100 call 58 | 37,602,144 | -7,917 | 36,036,900 |
| Remaining staker tick gross repeat crossing 100 call 59 | 36,998,569 | 7,919 | 35,428,453 |
| Remaining staker tick gross repeat crossing 100 call 60 | 37,606,569 | -7,897 | 36,041,169 |
| Remaining staker tick gross repeat crossing 100 call 61 | 36,997,312 | 7,917 | 35,426,992 |
| Remaining staker tick gross repeat crossing 100 call 62 | 37,605,649 | -7,917 | 36,040,195 |
| Remaining staker tick gross repeat crossing 100 call 63 | 36,998,773 | 7,917 | 35,428,453 |
| Remaining staker tick gross repeat crossing 100 call 64 | 37,607,110 | -7,917 | 36,041,656 |
| Remaining staker tick gross repeat crossing 100 call 65 | 36,998,286 | 7,917 | 35,427,966 |
| Remaining staker tick gross repeat crossing 100 call 66 | 37,607,110 | -7,917 | 36,041,656 |
| Remaining staker tick gross repeat crossing 100 call 67 | 36,999,260 | 7,917 | 35,428,940 |
| Remaining staker tick gross repeat crossing 100 call 68 | 37,602,841 | -7,917 | 36,037,387 |
| Remaining staker tick gross repeat crossing 100 call 69 | 36,997,799 | 7,917 | 35,427,479 |
| Remaining staker tick gross repeat crossing 100 call 70 | 37,606,623 | -7,917 | 36,041,169 |
| Remaining staker tick gross repeat crossing 100 call 71 | 36,991,209 | 7,917 | 35,420,889 |
| Remaining staker tick gross repeat crossing 100 call 72 | 37,606,136 | -7,917 | 36,040,682 |
| Remaining staker tick gross repeat crossing 100 call 73 | 36,997,312 | 7,917 | 35,426,992 |
| Remaining staker tick gross repeat crossing 100 call 74 | 37,606,136 | -7,917 | 36,040,682 |
| Remaining staker tick gross repeat crossing 100 call 75 | 36,991,696 | 7,917 | 35,421,376 |
| Remaining staker tick gross repeat crossing 100 call 76 | 37,606,623 | -7,917 | 36,041,169 |
| Remaining staker tick gross repeat crossing 100 call 77 | 36,997,312 | 7,917 | 35,426,992 |
| Remaining staker tick gross repeat crossing 100 call 78 | 37,602,841 | -7,917 | 36,037,387 |
| Remaining staker tick gross repeat crossing 100 call 79 | 36,994,504 | 7,917 | 35,424,184 |
| Remaining staker tick gross repeat crossing 100 call 80 | 37,606,136 | -7,917 | 36,040,682 |
| Remaining staker tick gross repeat crossing 100 call 81 | 36,999,260 | 7,917 | 35,428,940 |
| Remaining staker tick gross repeat crossing 100 call 82 | 37,606,623 | -7,917 | 36,041,169 |
| Remaining staker tick gross repeat crossing 100 call 83 | 36,993,437 | 7,917 | 35,423,117 |
| Remaining staker tick gross repeat crossing 100 call 84 | 37,602,261 | -7,917 | 36,036,807 |
| Remaining staker tick gross repeat crossing 100 call 85 | 36,998,773 | 7,917 | 35,428,453 |
| Remaining staker tick gross repeat crossing 100 call 86 | 37,605,162 | -7,917 | 36,039,708 |
| Remaining staker tick gross repeat crossing 100 call 87 | 36,997,799 | 7,917 | 35,427,479 |
| Remaining staker tick gross repeat crossing 100 call 88 | 37,607,110 | -7,917 | 36,041,656 |
| Remaining staker tick gross repeat crossing 100 call 89 | 36,998,773 | 7,917 | 35,428,453 |
| Remaining staker tick gross repeat crossing 100 call 90 | 37,606,136 | -7,917 | 36,040,682 |
| Remaining staker tick gross repeat crossing 100 call 91 | 36,997,799 | 7,917 | 35,427,479 |
| Remaining staker tick gross repeat crossing 100 call 92 | 37,605,649 | -7,917 | 36,040,195 |
| Remaining staker tick gross repeat crossing 100 call 93 | 36,998,286 | 7,917 | 35,427,966 |
| Remaining staker tick gross repeat crossing 100 call 94 | 37,602,841 | -7,917 | 36,037,387 |
| Remaining staker tick gross repeat crossing 100 call 95 | 36,995,478 | 7,917 | 35,425,158 |
| Remaining staker tick gross repeat crossing 100 call 96 | 37,607,110 | -7,917 | 36,041,656 |
| Remaining staker tick gross repeat crossing 100 call 97 | 36,999,260 | 7,917 | 35,428,940 |
| Remaining staker tick gross repeat crossing 100 call 98 | 37,606,623 | -7,917 | 36,041,169 |
| Remaining staker tick gross repeat crossing 100 call 99 | 36,995,478 | 7,917 | 35,425,158 |
| Remaining staker tick gross repeat crossing 100 call 100 | 37,603,328 | -7,917 | 36,037,874 |
| Remaining staker tick gross lifecycle UnStakeToken | 23,921,278 | -21,179 | 22,490,433 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 26,973,688 | 9,054 | 23,470,149 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 31,564,408 | 9,054 | 27,965,525 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 27,038,520 | 9,054 | 23,515,666 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 26,900,262 | 9,054 | 23,396,963 |
| ExactInSwapRoute(grc20) - fee:10000 | 26,212,158 | 9,054 | 22,716,734 |
| ExactInSwapRoute(grc20) - fee:100 | 30,820,182 | 9,054 | 27,229,414 |
| ExactInSwapRoute(grc20) - fee:3000 | 26,285,642 | 9,054 | 22,770,903 |
| ExactInSwapRoute(grc20) - fee:500 | 26,156,036 | 9,054 | 22,660,852 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 28,806,689 | 9,054 | 25,277,331 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 33,248,185 | 9,054 | 29,626,096 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 28,747,537 | 9,054 | 25,198,632 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 28,642,827 | 9,054 | 25,113,477 |
| ExactOutSwapRoute(grc20) - fee:10000 | 28,068,194 | 9,054 | 24,546,956 |
| ExactOutSwapRoute(grc20) - fee:100 | 32,526,994 | 9,054 | 28,913,025 |
| ExactOutSwapRoute(grc20) - fee:3000 | 28,017,694 | 9,054 | 24,476,909 |
| ExactOutSwapRoute(grc20) - fee:500 | 27,921,636 | 9,054 | 24,400,406 |
| BuildSingleHopRoutePath | 204,013 | 0 | 47,814 |
| MultiHop ExactIn (2 hops) | 52,640,611 | 9,061 | 48,288,432 |
| MultiHop ExactOut (2 hops) | 73,105,182 | 76 | 70,765,261 |
| MultiHop ExactIn (3 hops) | 72,264,029 | 33 | 69,731,314 |
| MultiHop ExactOut (3 hops) | 110,815,944 | 0 | 107,483,762 |
| MultiRoute ExactIn (50:50 split) | 71,586,558 | 0 | 68,991,980 |
| MultiRoute ExactOut (50:50 split) | 96,971,305 | 4 | 93,861,429 |
| CollectReward (only Internal Reward) | 13,997,438 | 11,137 | 12,597,573 |
| CollectReward 2nd (only Internal Reward) | 13,778,831 | 40 | 12,766,267 |
| staker CollectReward (1 external-incentive token) | 13,770,787 | 10,026 | 12,469,268 |
| staker CollectReward (2 external-incentive tokens) | 21,120,192 | 4,069 | 19,784,152 |
| staker CollectReward (3 external-incentive tokens) | 28,855,142 | 4,502 | 27,031,474 |
| staker CollectReward (4 external-incentive tokens) | 36,778,307 | 5,046 | 34,431,109 |
| storage growth: CollectReward 20 staked positions | 15,322,698 | 62 | 14,433,456 |
| storage growth: CollectReward 40 staked positions | 15,785,077 | 0 | 14,906,382 |
| storage growth: CollectReward 60 staked positions | 15,787,567 | 0 | 14,908,872 |
| storage growth: CollectReward 80 staked positions | 15,918,844 | 0 | 15,032,792 |
| storage growth: CollectReward 100 staked positions | 15,904,575 | 0 | 15,018,523 |
| CollectReward With External Rewards (1 incentives) | 22,167,303 | 14,734 | 20,142,146 |
| CollectReward With External Rewards 2nd (1 incentives) | 21,500,044 | 31 | 20,017,463 |
| CollectReward With External Rewards (5 incentives) | 53,503,430 | 28,757 | 49,299,433 |
| CollectReward With External Rewards 2nd (5 incentives) | 51,679,811 | 52 | 48,351,533 |
| CollectReward with Warmup Range (30% ~ 30%) | 14,035,434 | 11,119 | 12,629,628 |
| CollectReward with Warmup Range (30% ~ 50%) | 16,054,353 | 58 | 14,981,557 |
| CollectReward with Warmup Range (30% ~ 70%) | 18,359,219 | 18 | 17,226,717 |
| CollectReward with Warmup Range (30% ~ 100%) | 20,688,012 | 18 | 19,495,800 |
| CollectReward with Warmup Range (100% ~) | 13,453,682 | -6 | 12,519,706 |
| CollectReward with Warmup Range 2nd (100% ~) | 13,338,329 | 0 | 12,404,374 |
| CreateExternalIncentive | 3,909,525 | 65,819 | 3,234,195 |
| EndExternalIncentive | 2,534,318 | -1,979 | 2,253,433 |
| EndExternalIncentive (unclaimablePeriods=100) | 2,502,965 | 147 | 2,283,225 |
| EndExternalIncentive (unclaimablePeriods=10) | 2,452,668 | 141 | 2,235,176 |
| EndExternalIncentive (unclaimablePeriods=50) | 2,465,098 | 141 | 2,247,606 |
| Swap (halving, 10 staked tick-crosses) | 106,403,913 | 3,729 | 101,891,195 |
| Swap (halving, 1 staked tick-cross) | 32,197,775 | 2,813 | 30,504,890 |
| Swap (halving, 50 staked tick-crosses) | 445,343,810 | 7,260 | 429,528,623 |
| Swap (no halving, 10 staked tick-crosses) | 94,229,033 | -7,110 | 90,113,065 |
| Swap (no halving, 1 staked tick-cross) | 26,002,108 | -7,684 | 24,585,688 |
| Swap (no halving, 50 staked tick-crosses) | 406,594,608 | -5,108 | 391,710,813 |
| RegisterInitializer (v1) | 71,548 | 0 | 49,682 |
| RegisterInitializer (v2) | 55,268 | 0 | 52,396 |
