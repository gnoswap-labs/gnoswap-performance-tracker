# Gas Report Comparison

- **Latest**: [`e7f750d`](https://github.com/gnoswap-labs/gnoswap/tree/e7f750d)
- **Previous**: [`8bb3a28`](https://github.com/gnoswap-labs/gnoswap/tree/8bb3a28)

| Name | Metric | Latest | Previous | Change | % |
|------|--------|--------|----------|--------|---|
| **Mint Position(for stress swap)** | Gas Used | 13,840,345 | 13,840,345 | 0 |  0.00% |
| | Storage Diff | 27,408 | 27,408 | 0 |  0.00% |
| | CPU Cycles | 10,080,538 | 10,080,538 | 0 |  0.00% |
| **Stress ExactInSwapRoute(grc20) gns->wugnot** | Gas Used | 1,568,648,278 | 1,568,545,878 | +102,400 | ⚠️ 0.01% |
| | Storage Diff | 13,627 | 13,627 | 0 |  0.00% |
| | CPU Cycles | 1,558,793,211 | 1,558,793,211 | 0 |  0.00% |
| **Stress ExactInSwapRoute(grc20) wugnot->gns** | Gas Used | 1,566,057,028 | 1,566,039,796 | +17,232 | ⚠️ 0.00% |
| | Storage Diff | 8,404 | 8,404 | 0 |  0.00% |
| | CPU Cycles | 1,562,607,264 | 1,562,607,264 | 0 |  0.00% |
| **Stress ExactInSwapRoute(grc20) gns->wugnot (accumulate fees)** | Gas Used | 1,566,269,608 | 1,566,252,376 | +17,232 | ⚠️ 0.00% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,563,133,238 | 1,563,133,238 | 0 |  0.00% |
| **Stress ExactOutSwapRoute(grc20) gns->wugnot** | Gas Used | 1,557,283,637 | 1,557,266,405 | +17,232 | ⚠️ 0.00% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,555,852,844 | 1,555,852,844 | 0 |  0.00% |
| **Stress ExactOutSwapRoute(grc20) wugnot->gns** | Gas Used | 1,556,137,874 | 1,556,120,642 | +17,232 | ⚠️ 0.00% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,554,710,177 | 1,554,710,177 | 0 |  0.00% |
| **Stress ExactOutSwapRoute(grc20) gns->wugnot (accumulate fees)** | Gas Used | 1,557,355,868 | 1,557,338,636 | +17,232 | ⚠️ 0.00% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,555,925,075 | 1,555,925,075 | 0 |  0.00% |
| **Stress RandomPositions ExactInSwapRoute gns->wugnot** | Gas Used | 125,002,426 | 124,900,026 | +102,400 | ⚠️ 0.08% |
| | Storage Diff | 7,394 | 7,394 | 0 |  0.00% |
| | CPU Cycles | 116,005,906 | 116,005,906 | 0 |  0.00% |
| **Stress RandomPositions ExactInSwapRoute wugnot->gns** | Gas Used | 122,991,962 | 122,974,730 | +17,232 | ⚠️ 0.01% |
| | Storage Diff | 8,322 | 8,322 | 0 |  0.00% |
| | CPU Cycles | 120,441,081 | 120,441,081 | 0 |  0.00% |
| **Stress RandomPositions ExactOutSwapRoute gns->wugnot** | Gas Used | 116,104,268 | 116,087,036 | +17,232 | ⚠️ 0.01% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 114,679,707 | 114,679,707 | 0 |  0.00% |
| **Stress RandomPositions ExactOutSwapRoute wugnot->gns** | Gas Used | 114,998,691 | 114,981,459 | +17,232 | ⚠️ 0.01% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 113,577,226 | 113,577,226 | 0 |  0.00% |
| **CollectReward (pos=500, tick=500, claim=1, active=1, finished=1000)** | Gas Used | 19,420,809 | 153,431,072 | -134,010,263 | ⚡️ -87.34% |
| | Storage Diff | 9,957 | 9,932 | +25 | ⚠️ 0.25% |
| | CPU Cycles | 14,447,767 | 148,742,896 | -134,295,129 | ⚡️ -90.29% |
| **CollectReward (pos=500, tick=500, claim=1, active=1, finished=100)** | Gas Used | 18,956,856 | 29,947,909 | -10,991,053 | ⚡️ -36.70% |
| | Storage Diff | 9,932 | 9,872 | +60 | ⚠️ 0.61% |
| | CPU Cycles | 14,282,956 | 25,550,139 | -11,267,183 | ⚡️ -44.10% |
| **CollectReward (pos=500, tick=500, claim=1, active=1, finished=10)** | Gas Used | 18,460,295 | 18,792,073 | -331,778 | ⚡️ -1.77% |
| | Storage Diff | 9,949 | 9,949 | 0 |  0.00% |
| | CPU Cycles | 14,107,079 | 14,706,955 | -599,876 | ⚡️ -4.08% |
| **CollectReward (pos=500, tick=500, claim=1, active=1, finished=50)** | Gas Used | 18,764,109 | 23,651,355 | -4,887,246 | ⚡️ -20.66% |
| | Storage Diff | 10,039 | 9,979 | +60 | ⚠️ 0.60% |
| | CPU Cycles | 14,216,953 | 19,379,529 | -5,162,576 | ⚡️ -26.64% |
| **CollectReward (pos=500, tick=500, claim=1)** | Gas Used | 21,675,375 | 21,392,333 | +283,042 | ⚠️ 1.32% |
| | Storage Diff | 7,981 | 7,987 | -6 | ⚡️ -0.08% |
| | CPU Cycles | 16,303,907 | 16,116,785 | +187,122 | ⚠️ 1.16% |
| **CollectReward (pos=500, tick=500, claim=5)** | Gas Used | 81,469,480 | 80,054,270 | +1,415,210 | ⚠️ 1.77% |
| | Storage Diff | 8,058 | 8,064 | -6 | ⚡️ -0.07% |
| | CPU Cycles | 67,484,804 | 66,549,194 | +935,610 | ⚠️ 1.41% |
| **CollectReward (pos=500, tick=500, claim=1, inc=10)** | Gas Used | 145,722,449 | 144,814,937 | +907,512 | ⚠️ 0.63% |
| | Storage Diff | 52,036 | 52,050 | -14 | ⚡️ -0.03% |
| | CPU Cycles | 128,586,001 | 128,084,409 | +501,592 | ⚠️ 0.39% |
| **CollectReward (pos=500, tick=500, claim=5, inc=10)** | Gas Used | 700,294,394 | 695,737,922 | +4,556,472 | ⚠️ 0.65% |
| | Storage Diff | 210,743 | 210,769 | -26 | ⚡️ -0.01% |
| | CPU Cycles | 628,316,258 | 625,789,258 | +2,527,000 | ⚠️ 0.40% |
| **CollectReward (pos=500, tick=500, claim=1, inc=20)** | Gas Used | 272,594,569 | 270,956,754 | +1,637,815 | ⚠️ 0.60% |
| | Storage Diff | 94,021 | 94,036 | -15 | ⚡️ -0.02% |
| | CPU Cycles | 241,911,433 | 240,989,682 | +921,751 | ⚠️ 0.38% |
| **CollectReward (pos=500, tick=500, claim=5, inc=20)** | Gas Used | 1,334,861,238 | 1,326,598,643 | +8,262,595 | ⚠️ 0.62% |
| | Storage Diff | 419,940 | 419,973 | -33 | ⚡️ -0.01% |
| | CPU Cycles | 1,194,962,458 | 1,190,315,623 | +4,646,835 | ⚠️ 0.39% |
| **CollectReward (pos=500, tick=500, claim=1, tier=10)** | Gas Used | 52,637,211 | 52,354,169 | +283,042 | ⚠️ 0.54% |
| | Storage Diff | 7,970 | 7,976 | -6 | ⚡️ -0.08% |
| | CPU Cycles | 47,094,699 | 46,907,577 | +187,122 | ⚠️ 0.40% |
| **CollectReward (pos=500, tick=500, claim=5, tier=10)** | Gas Used | 233,744,392 | 232,329,182 | +1,415,210 | ⚠️ 0.61% |
| | Storage Diff | 8,047 | 8,053 | -6 | ⚡️ -0.07% |
| | CPU Cycles | 219,588,672 | 218,653,062 | +935,610 | ⚠️ 0.43% |
| **CollectReward (pos=500, tick=500, claim=1, tier=1)** | Gas Used | 21,753,176 | 21,470,134 | +283,042 | ⚠️ 1.32% |
| | Storage Diff | 7,963 | 7,969 | -6 | ⚡️ -0.08% |
| | CPU Cycles | 16,361,702 | 16,174,580 | +187,122 | ⚠️ 1.16% |
| **CollectReward (pos=500, tick=500, claim=5, tier=1)** | Gas Used | 81,761,145 | 80,345,935 | +1,415,210 | ⚠️ 1.76% |
| | Storage Diff | 8,040 | 8,046 | -6 | ⚡️ -0.07% |
| | CPU Cycles | 67,756,463 | 66,820,853 | +935,610 | ⚠️ 1.40% |
| **CollectReward (pos=500, tick=500, claim=1, tier=5)** | Gas Used | 35,394,113 | 35,111,071 | +283,042 | ⚠️ 0.81% |
| | Storage Diff | 7,970 | 7,976 | -6 | ⚡️ -0.08% |
| | CPU Cycles | 29,911,965 | 29,724,843 | +187,122 | ⚠️ 0.63% |
| **CollectReward (pos=500, tick=500, claim=5, tier=5)** | Gas Used | 149,006,966 | 147,591,756 | +1,415,210 | ⚠️ 0.96% |
| | Storage Diff | 8,047 | 8,053 | -6 | ⚡️ -0.07% |
| | CPU Cycles | 134,911,610 | 133,976,000 | +935,610 | ⚠️ 0.70% |
| **stress CollectReward (1000 positions)** | Gas Used | 24,075,648 | 23,792,606 | +283,042 | ⚠️ 1.19% |
| | Storage Diff | 10,113 | 10,113 | 0 |  0.00% |
| | CPU Cycles | 19,122,202 | 18,935,080 | +187,122 | ⚠️ 0.99% |
| **stress CollectReward (100 positions)** | Gas Used | 22,966,610 | 22,683,600 | +283,010 | ⚠️ 1.25% |
| | Storage Diff | 10,010 | 10,010 | 0 |  0.00% |
| | CPU Cycles | 18,301,990 | 18,114,868 | +187,122 | ⚠️ 1.03% |
| **stress CollectReward (10 positions)** | Gas Used | 21,785,013 | 21,502,003 | +283,010 | ⚠️ 1.32% |
| | Storage Diff | 9,938 | 9,938 | 0 |  0.00% |
| | CPU Cycles | 17,429,221 | 17,242,099 | +187,122 | ⚠️ 1.09% |
| **stress CollectReward (500 positions)** | Gas Used | 23,709,721 | 23,426,679 | +283,042 | ⚠️ 1.21% |
| | Storage Diff | 10,030 | 10,030 | 0 |  0.00% |
| | CPU Cycles | 18,852,181 | 18,665,059 | +187,122 | ⚠️ 1.00% |
| **CollectReward tick cross (iterations=20)** | Gas Used | 24,493,350 | 24,210,340 | +283,010 | ⚠️ 1.17% |
| | Storage Diff | 7,939 | 7,939 | 0 |  0.00% |
| | CPU Cycles | 18,997,414 | 18,810,292 | +187,122 | ⚠️ 0.99% |
| **CollectReward tick cross (iterations=50)** | Gas Used | 24,872,086 | 24,589,076 | +283,010 | ⚠️ 1.15% |
| | Storage Diff | 7,939 | 7,939 | 0 |  0.00% |
| | CPU Cycles | 19,346,144 | 19,159,022 | +187,122 | ⚠️ 0.98% |
| **stress CreateExternalIncentive (pos=1000, inc=1)** | Gas Used | 3,852,756 | 3,448,087 | +404,669 | ⚠️ 11.74% |
| | Storage Diff | 9,392 | 6,023 | +3,369 | ⚠️ 55.94% |
| | CPU Cycles | 2,105,890 | 1,896,577 | +209,313 | ⚠️ 11.04% |
| **stress CreateExternalIncentive (pos=100, inc=1)** | Gas Used | 3,840,977 | 3,437,232 | +403,745 | ⚠️ 11.75% |
| | Storage Diff | 9,310 | 5,963 | +3,347 | ⚠️ 56.13% |
| | CPU Cycles | 2,103,775 | 1,894,462 | +209,313 | ⚠️ 11.05% |
| **stress StakeToken (pos=1000, inc=100)** | Gas Used | 35,556,798 | 16,972,071 | +18,584,727 | ⚠️ 109.50% |
| | Storage Diff | 228,915 | 20,296 | +208,619 | ⚠️ 1027.88% |
| | CPU Cycles | 25,128,703 | 9,799,832 | +15,328,871 | ⚠️ 156.42% |
| **stress StakeToken (pos=1000, inc=10)** | Gas Used | 18,355,809 | 16,952,953 | +1,402,856 | ⚠️ 8.27% |
| | Storage Diff | 40,993 | 20,296 | +20,697 | ⚠️ 101.98% |
| | CPU Cycles | 10,819,714 | 9,781,162 | +1,038,552 | ⚠️ 10.62% |
| **stress StakeToken (pos=1000, inc=5)** | Gas Used | 17,717,267 | 16,934,283 | +782,984 | ⚠️ 4.62% |
| | Storage Diff | 30,561 | 20,296 | +10,265 | ⚠️ 50.58% |
| | CPU Cycles | 10,341,684 | 9,762,492 | +579,192 | ⚠️ 5.93% |
| **stress StakeToken (pos=100, inc=100)** | Gas Used | 34,015,715 | 15,450,188 | +18,565,527 | ⚠️ 120.16% |
| | Storage Diff | 227,585 | 20,166 | +207,419 | ⚠️ 1028.56% |
| | CPU Cycles | 24,590,784 | 9,261,913 | +15,328,871 | ⚠️ 165.50% |
| **stress StakeToken (pos=100, inc=10)** | Gas Used | 16,832,006 | 15,420,646 | +1,411,360 | ⚠️ 9.15% |
| | Storage Diff | 40,743 | 20,152 | +20,591 | ⚠️ 102.18% |
| | CPU Cycles | 10,281,795 | 9,243,243 | +1,038,552 | ⚠️ 11.24% |
| **stress StakeToken (pos=100, inc=5)** | Gas Used | 16,194,424 | 15,401,976 | +792,448 | ⚠️ 5.15% |
| | Storage Diff | 30,400 | 20,152 | +10,248 | ⚠️ 50.85% |
| | CPU Cycles | 9,803,765 | 9,224,573 | +579,192 | ⚠️ 6.28% |
