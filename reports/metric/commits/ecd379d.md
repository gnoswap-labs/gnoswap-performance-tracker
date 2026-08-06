| Name | Gas Used | Storage Diff | CPU Cycles |
|------|----------|--------------|------------|
| TickMathGetSqrtRatioAtTick (minTick) | 1,789,878 | 0 | 1,583,571 |
| TickMathGetSqrtRatioAtTick (maxTick) | 2,190,403 | 0 | 2,035,580 |
| TickMathGetSqrtRatioAtTick (zero) | 357,521 | 0 | 325,234 |
| TickMathGetSqrtRatioAtTick | 1,627,126 | 0 | 1,521,109 |
| TickMathGetTickAtSqrtRatio | 4,100,894 | 0 | 3,765,639 |
| GetLiquidityForAmounts | 3,379,269 | 0 | 3,137,602 |
| GetAmountsForLiquidity | 3,136,874 | 0 | 2,923,208 |
| LiquidityMathAddDelta (positive) | 477,719 | 0 | 430,660 |
| LiquidityMathAddDelta (negative) | 502,167 | 0 | 464,497 |
| LiquidityMathAddDelta | 466,037 | 0 | 430,660 |
| GetAmount0Delta | 3,812,363 | 0 | 3,331,396 |
| GetAmount1Delta | 2,446,777 | 0 | 2,283,199 |
| SwapMathComputeSwapStep | 4,477,522 | 0 | 4,166,469 |
| Propose Community Pool Spend | 4,033,744 | 20,561 | 3,296,776 |
| Propose Parameter Change | 4,659,850 | 19,533 | 3,879,995 |
| Vote | 1,111,428 | 4,486 | 880,730 |
| Execute | 2,653,210 | 76 | 1,389,440 |
| Propose Text | 3,495,324 | 18,334 | 2,897,832 |
| Propose Text with Inactive: 100 | 3,954,650 | 8,501 | 3,401,716 |
| CollectUndelegatedGns (100 delegations, 1 withdraws) | 90,786,636 | 0 | 75,496,530 |
| CollectUndelegatedGns (10 delegations, 10 withdraws) | 10,636,415 | 0 | 8,742,424 |
| CollectUndelegatedGns (10 delegations, 1 withdraws) | 3,129,980 | 0 | 2,467,894 |
| CollectUndelegatedGns (10 delegations, 50 withdraws) | 43,997,015 | 0 | 36,629,224 |
| CollectUndelegatedGns (10 delegations, 5 withdraws) | 6,466,040 | 0 | 5,256,574 |
| CollectUndelegatedGns (1 delegation, 10 withdraws) | 681,374 | 0 | 556,372 |
| CollectUndelegatedGns (1 delegation, 1 withdraws) | 449,444 | 0 | 360,730 |
| CollectUndelegatedGns (1 delegation, 50 withdraws) | 1,712,174 | 0 | 1,425,892 |
| CollectUndelegatedGns (1 delegation, 5 withdraws) | 552,524 | 0 | 447,682 |
| CollectReward (100 delegations, 1 withdraws) | 3,641,259 | 2,410 | 2,788,429 |
| CollectReward (10 delegations, 10 withdraws) | 3,641,076 | 2,398 | 2,788,429 |
| CollectReward (10 delegations, 1 withdraws) | 3,637,288 | 2,398 | 2,784,643 |
| CollectReward (10 delegations, 50 withdraws) | 3,640,009 | 2,398 | 2,787,362 |
| CollectReward (10 delegations, 5 withdraws) | 3,634,085 | 2,398 | 2,781,440 |
| CollectReward (1 delegation, 10 withdraws) | 3,711,208 | 2,470 | 2,784,643 |
| CollectReward (1 delegation, 1 withdraws) | 3,898,808 | 2,470 | 2,958,393 |
| CollectReward (1 delegation, 50 withdraws) | 3,708,005 | 2,470 | 2,781,440 |
| CollectReward (1 delegation, 5 withdraws) | 3,709,162 | 2,470 | 2,782,597 |
| gov/staker CollectReward (1 protocol-fee tokens) | 3,900,929 | 442 | 2,966,268 |
| gov/staker CollectReward (2 protocol-fee tokens) | 6,042,943 | -1,683 | 4,952,876 |
| gov/staker CollectReward (3 protocol-fee tokens) | 8,306,308 | -3,726 | 6,944,325 |
| gov/staker CollectReward (4 protocol-fee tokens) | 10,570,009 | -5,769 | 8,934,277 |
| gov/staker CollectReward (4 protocol-fee tokens but zero amount) | 6,242,391 | 0 | 5,074,500 |
| Delegate | 5,512,998 | 38,287 | 2,204,507 |
| Undelegate | 3,480,282 | 840 | 2,539,363 |
| Undelegate (5 delegations, cached external calls) | 15,564,336 | 3,510 | 11,511,025 |
| Delegate (cached external calls) | 4,106,952 | 3,210 | 3,137,836 |
| Undelegate (early exit, 3 of 10 delegations) | 10,243,544 | 2,088 | 7,682,019 |
| Redelegate | 6,661,162 | 1,423 | 4,923,373 |
| Redelegate (50 of 100 delegations, optimized) | 185,049,672 | -118,830 | 139,297,140 |
| Undelegate (50 delegatees, large AVL traversal) | 3,668,269 | 708 | 2,741,737 |
| CollectDepositGns (deposit 1/5, remaining 4) | 8,280,477 | 1,850 | 6,674,626 |
| CollectDepositGns (deposit 2/5, remaining 3) | 7,771,075 | -2,257 | 6,366,590 |
| CollectDepositGns (deposit 3/5, remaining 2) | 7,747,349 | -2,257 | 6,346,173 |
| CollectDepositGns (deposit 4/5, remaining 1) | 7,752,957 | -2,257 | 6,353,704 |
| CollectDepositGns (deposit 5/5, remaining 0) | 7,623,670 | -8,456 | 6,253,175 |
| Launchpad CollectDepositGns | 8,151,411 | -4,155 | 6,578,871 |
| CollectProtocolFee (1 token) | 3,776,636 | 4,500 | 2,914,831 |
| CollectProtocolFee (2 tokens) | 5,829,569 | 8,911 | 4,702,204 |
| CollectProtocolFee (5 tokens) | 12,016,875 | 22,144 | 10,077,230 |
| Launchpad CollectRewardByDepositId | 3,486,994 | 2,070 | 2,954,184 |
| Create Launchpad Project | 9,143,300 | 30,768 | 6,215,506 |
| Launchpad DepositGns | 6,587,263 | 24,240 | 4,147,906 |
| Launchpad TransferLeftFromProjectByAdmin | 1,373,718 | 41 | 1,094,986 |
| CreatePool | 6,887,464 | 15,286 | 5,806,860 |
| Mint (fee:3000, wide range) | 32,706,380 | 24,717 | 28,990,897 |
| Swap (gns -> wugnot, fee:500) | 49,873,775 | 6 | 44,669,702 |
| DecreaseLiquidity | 28,539,678 | -2,101 | 25,342,909 |
| IncreaseLiquidity | 24,260,372 | -2,084 | 22,062,952 |
| Mint (bar:foo:500) | 30,772,169 | 24,702 | 27,050,139 |
| CollectFee (with unwrap) | 9,310,942 | 44 | 6,817,051 |
| DecreaseLiquidity (w. Remove) | 25,145,344 | 72 | 20,768,337 |
| Mint (reposition) | 31,757,785 | 8,609 | 29,075,831 |
| SetPoolTier (tier 1) | 6,205,818 | 45,443 | 3,742,758 |
| StakeToken | 18,727,907 | 22,308 | 16,243,797 |
| ExactInSingleSwapRoute(grc20) - fee:10000 | 29,311,009 | 8,961 | 24,347,448 |
| ExactInSingleSwapRoute(grc20) - fee:100 | 34,231,302 | 8,961 | 28,926,294 |
| ExactInSingleSwapRoute(grc20) - fee:3000 | 29,382,274 | 8,961 | 24,396,961 |
| ExactInSingleSwapRoute(grc20) - fee:500 | 29,236,986 | 8,961 | 24,278,430 |
| ExactInSwapRoute(grc20) - fee:10000 | 28,483,629 | 8,961 | 23,586,563 |
| ExactInSwapRoute(grc20) - fee:100 | 33,422,798 | 8,961 | 28,182,993 |
| ExactInSwapRoute(grc20) - fee:3000 | 28,564,332 | 8,961 | 23,644,868 |
| ExactInSwapRoute(grc20) - fee:500 | 28,428,482 | 8,961 | 23,535,129 |
| ExactOutSingleSwapRoute(grc20) - fee:10000 | 31,259,398 | 8,961 | 26,179,913 |
| ExactOutSingleSwapRoute(grc20) - fee:100 | 36,013,727 | 8,961 | 30,605,998 |
| ExactOutSingleSwapRoute(grc20) - fee:3000 | 31,198,263 | 8,961 | 26,103,880 |
| ExactOutSingleSwapRoute(grc20) - fee:500 | 31,089,003 | 8,961 | 26,019,617 |
| ExactOutSwapRoute(grc20) - fee:10000 | 30,455,485 | 8,961 | 25,441,268 |
| ExactOutSwapRoute(grc20) - fee:100 | 35,228,690 | 8,961 | 29,884,937 |
| ExactOutSwapRoute(grc20) - fee:3000 | 30,403,788 | 8,961 | 25,374,027 |
| ExactOutSwapRoute(grc20) - fee:500 | 30,303,966 | 8,961 | 25,298,556 |
| BuildSingleHopRoutePath | 203,722 | 0 | 48,894 |
| MultiHop ExactIn (2 hops) | 56,740,122 | 8,974 | 49,412,974 |
| MultiHop ExactOut (2 hops) | 79,516,481 | 76 | 72,843,696 |
| MultiHop ExactIn (3 hops) | 78,661,516 | 45 | 71,687,772 |
| MultiHop ExactOut (3 hops) | 121,163,339 | 2 | 111,248,988 |
| MultiRoute ExactIn (50:50 split) | 77,936,022 | 6 | 70,943,202 |
| MultiRoute ExactOut (50:50 split) | 105,698,335 | 4 | 96,794,082 |
| CollectReward (only Internal Reward) | 26,257,214 | 11,046 | 22,787,488 |
| CollectReward 2nd (only Internal Reward) | 25,889,300 | 40 | 22,751,226 |
| staker CollectReward (1 external-incentive token) | 31,493,280 | 9,936 | 27,728,390 |
| staker CollectReward (2 external-incentive tokens) | 48,168,466 | 3,982 | 42,825,446 |
| staker CollectReward (3 external-incentive tokens) | 65,104,242 | 4,415 | 57,857,234 |
| staker CollectReward (4 external-incentive tokens) | 82,242,579 | 4,959 | 73,039,297 |
| storage growth: CollectReward 20 staked positions | 27,787,969 | 62 | 24,643,483 |
| storage growth: CollectReward 40 staked positions | 28,263,974 | 0 | 25,102,770 |
| storage growth: CollectReward 60 staked positions | 28,265,977 | 0 | 25,104,773 |
| storage growth: CollectReward 80 staked positions | 28,402,424 | 0 | 25,226,723 |
| storage growth: CollectReward 100 staked positions | 28,390,271 | 0 | 25,213,800 |
| CollectReward with Warmup Range (30% ~ 30%) | 26,291,336 | 11,028 | 22,814,437 |
| CollectReward with Warmup Range (30% ~ 50%) | 31,513,946 | 58 | 27,885,453 |
| CollectReward with Warmup Range (30% ~ 70%) | 36,978,641 | 18 | 32,859,776 |
| CollectReward with Warmup Range (30% ~ 100%) | 42,455,998 | 18 | 37,846,962 |
| CollectReward with Warmup Range (100% ~) | 25,655,018 | -6 | 22,622,027 |
| CollectReward with Warmup Range 2nd (100% ~) | 25,549,442 | 0 | 22,515,653 |
| RegisterInitializer (v1) | 78,331 | 0 | 52,412 |
| RegisterInitializer (v2) | 62,245 | 0 | 55,126 |
