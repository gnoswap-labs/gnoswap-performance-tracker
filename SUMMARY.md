# GnoSwap Performance Summary Report

> Generated: 2025-12-10 12:45:30

## Overview

- **Total Commits**: 13
- **First Commit (Oldest)**: [`e5d1e16`](https://github.com/gnoswap-labs/gnoswap/tree/e5d1e16) - Base
- **Last Commit (Latest)**: [`ba942e9`](https://github.com/gnoswap-labs/gnoswap/tree/ba942e9) - Optimize staker

---

## Commit History

| # | Commit | Description | Report | Diff from Previous | Diff from Base |
|---|--------|-------------|--------|-------------------|----------------|
| 1 | [`e5d1e16`](https://github.com/gnoswap-labs/gnoswap/tree/e5d1e16) | Base | [📊 Report](reports/metric/commits/e5d1e16.md) | _Baseline_ | _Baseline_ |
| 2 | [`9dbd892`](https://github.com/gnoswap-labs/gnoswap/tree/9dbd892) | Optimize Uint256 | [📊 Report](reports/metric/commits/9dbd892.md) | [📈 Diff](reports/metric/compares/diff_9dbd892_e5d1e16.md) | [📊 Diff](reports/metric/compares/diff_9dbd892_e5d1e16.md) |
| 3 | [`31d883d`](https://github.com/gnoswap-labs/gnoswap/tree/31d883d) | Optimize Int256 | [📊 Report](reports/metric/commits/31d883d.md) | [📈 Diff](reports/metric/compares/diff_31d883d_9dbd892.md) | [📊 Diff](reports/metric/compares/diff_31d883d_e5d1e16.md) |
| 4 | [`94d4672`](https://github.com/gnoswap-labs/gnoswap/tree/94d4672) | Optimize Common | [📊 Report](reports/metric/commits/94d4672.md) | [📈 Diff](reports/metric/compares/diff_94d4672_31d883d.md) | [📊 Diff](reports/metric/compares/diff_94d4672_e5d1e16.md) |
| 5 | [`f468996`](https://github.com/gnoswap-labs/gnoswap/tree/f468996) | Optimize Pool | [📊 Report](reports/metric/commits/f468996.md) | [📈 Diff](reports/metric/compares/diff_f468996_94d4672.md) | [📊 Diff](reports/metric/compares/diff_f468996_e5d1e16.md) |
| 6 | [`51813f5`](https://github.com/gnoswap-labs/gnoswap/tree/51813f5) | Make pool use AVL tree | [📊 Report](reports/metric/commits/51813f5.md) | [📈 Diff](reports/metric/compares/diff_51813f5_f468996.md) | [📊 Diff](reports/metric/compares/diff_51813f5_e5d1e16.md) |
| 7 | [`c998399`](https://github.com/gnoswap-labs/gnoswap/tree/c998399) | Replace int256 with int64 for router swap | [📊 Report](reports/metric/commits/c998399.md) | [📈 Diff](reports/metric/compares/diff_c998399_51813f5.md) | [📊 Diff](reports/metric/compares/diff_c998399_e5d1e16.md) |
| 8 | [`aa648b2`](https://github.com/gnoswap-labs/gnoswap/tree/aa648b2) | Optimize KVStore.makeKey | [📊 Report](reports/metric/commits/aa648b2.md) | [📈 Diff](reports/metric/compares/diff_aa648b2_c998399.md) | [📊 Diff](reports/metric/compares/diff_aa648b2_e5d1e16.md) |
| 9 | [`3a818d3`](https://github.com/gnoswap-labs/gnoswap/tree/3a818d3) | Optimize Router | [📊 Report](reports/metric/commits/3a818d3.md) | [📈 Diff](reports/metric/compares/diff_3a818d3_aa648b2.md) | [📊 Diff](reports/metric/compares/diff_3a818d3_e5d1e16.md) |
| 10 | [`9ee6b50`](https://github.com/gnoswap-labs/gnoswap/tree/9ee6b50) | Optimize GNFT | [📊 Report](reports/metric/commits/9ee6b50.md) | [📈 Diff](reports/metric/compares/diff_9ee6b50_3a818d3.md) | [📊 Diff](reports/metric/compares/diff_9ee6b50_e5d1e16.md) |
| 11 | [`a7e1bc3`](https://github.com/gnoswap-labs/gnoswap/tree/a7e1bc3) | Make stake use AVL tree | [📊 Report](reports/metric/commits/a7e1bc3.md) | [📈 Diff](reports/metric/compares/diff_a7e1bc3_9ee6b50.md) | [📊 Diff](reports/metric/compares/diff_a7e1bc3_e5d1e16.md) |
| 12 | [`e59f3c1`](https://github.com/gnoswap-labs/gnoswap/tree/e59f3c1) | Optimize position | [📊 Report](reports/metric/commits/e59f3c1.md) | [📈 Diff](reports/metric/compares/diff_e59f3c1_a7e1bc3.md) | [📊 Diff](reports/metric/compares/diff_e59f3c1_e5d1e16.md) |
| 13 | [`ba942e9`](https://github.com/gnoswap-labs/gnoswap/tree/ba942e9) | Optimize staker | [📊 Report](reports/metric/commits/ba942e9.md) | [📈 Diff](reports/metric/compares/diff_ba942e9_e59f3c1.md) | [📊 Diff](reports/metric/compares/diff_ba942e9_e5d1e16.md) |

---

## Overall Comparison (First → Latest)

**[`e5d1e16` → `ba942e9`](reports/metric/compares/diff_ba942e9_e5d1e16.md)**

This comparison shows the total gas usage changes between the baseline commit and the latest commit.

### Quick Stats

| Metric | Count |
|--------|-------|
| ⚡️ Improvements | 209 |
| ⚠️ Regressions | 4 |

### Detailed Comparison

| Name | Metric | Latest | Previous | Change | % |
|------|--------|--------|----------|--------|---|
| **TickMathGetSqrtRatioAtTick (minTick)** | Gas Used | 1,555,244 | 2,868,084 | -1,312,840 | ⚡️ -45.77% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 677,324 | 1,926,276 | -1,248,952 | ⚡️ -64.84% |
| **TickMathGetSqrtRatioAtTick (maxTick)** | Gas Used | 873,832 | 2,141,817 | -1,267,985 | ⚡️ -59.20% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 863,400 | 2,126,105 | -1,262,705 | ⚡️ -59.39% |
| **TickMathGetSqrtRatioAtTick (zero)** | Gas Used | 134,165 | 137,023 | -2,858 | ⚡️ -2.09% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 134,165 | 137,023 | -2,858 | ⚡️ -2.09% |
| **TickMathGetSqrtRatioAtTick** | Gas Used | 652,352 | 1,429,945 | -777,593 | ⚡️ -54.38% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 641,936 | 1,414,233 | -772,297 | ⚡️ -54.61% |
| **TickMathGetTickAtSqrtRatio** | Gas Used | 1,785,434 | 4,237,459 | -2,452,025 | ⚡️ -57.87% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,628,730 | 3,974,547 | -2,345,817 | ⚡️ -59.02% |
| **GetLiquidityForAmounts** | Gas Used | 1,442,983 | 2,392,306 | -949,323 | ⚡️ -39.68% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,422,279 | 2,360,930 | -938,651 | ⚡️ -39.76% |
| **GetAmountsForLiquidity** | Gas Used | 1,333,931 | 2,148,786 | -814,855 | ⚡️ -37.92% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,333,931 | 2,148,786 | -814,855 | ⚡️ -37.92% |
| **LiquidityMathAddDelta (positive)** | Gas Used | 220,687 | 198,435 | +22,252 | ⚠️ 11.21% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 187,647 | 198,435 | -10,788 | ⚡️ -5.44% |
| **LiquidityMathAddDelta (negative)** | Gas Used | 199,989 | 189,963 | +10,026 | ⚠️ 5.28% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 199,989 | 189,963 | +10,026 | ⚠️ 5.28% |
| **LiquidityMathAddDelta** | Gas Used | 187,647 | 198,435 | -10,788 | ⚡️ -5.44% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 187,647 | 198,435 | -10,788 | ⚡️ -5.44% |
| **IsGNOTPath** | Gas Used | 11,223 | 11,777 | -554 | ⚡️ -4.70% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 11,223 | 11,777 | -554 | ⚡️ -4.70% |
| **IsGNOTNativePath** | Gas Used | 11,175 | 11,175 | 0 |  0.00% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 11,175 | 11,175 | 0 |  0.00% |
| **IsGNOTWrappedPath** | Gas Used | 11,175 | 11,175 | 0 |  0.00% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 11,175 | 11,175 | 0 |  0.00% |
| **ExistsUserSendCoins** | Gas Used | 266,478 | 266,478 | 0 |  0.00% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 18,206 | 18,206 | 0 |  0.00% |
| **GetAmount0Delta** | Gas Used | 3,912,271 | 5,830,275 | -1,918,004 | ⚡️ -32.90% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,486,687 | 3,357,715 | -1,871,028 | ⚡️ -55.72% |
| **GetAmount1Delta** | Gas Used | 1,050,599 | 2,936,180 | -1,885,581 | ⚡️ -64.22% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,040,247 | 2,920,468 | -1,880,221 | ⚡️ -64.38% |
| **SwapMathComputeSwapStep** | Gas Used | 1,879,861 | 5,626,580 | -3,746,719 | ⚡️ -66.59% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,858,997 | 5,595,156 | -3,736,159 | ⚡️ -66.77% |
| **Propose Community Pool Spend** | Gas Used | 971,856 | 1,600,112 | -628,256 | ⚡️ -39.26% |
| | Storage Diff | 14,171 | 14,171 | 0 |  0.00% |
| | CPU Cycles | 586,016 | 1,214,272 | -628,256 | ⚡️ -51.74% |
| **Propose Parameter Change** | Gas Used | 2,188,677 | 2,571,829 | -383,152 | ⚡️ -14.90% |
| | Storage Diff | 14,006 | 14,006 | 0 |  0.00% |
| | CPU Cycles | 1,184,437 | 1,812,693 | -628,256 | ⚡️ -34.66% |
| **Vote** | Gas Used | 316,102 | 394,634 | -78,532 | ⚡️ -19.90% |
| | Storage Diff | 80 | 80 | 0 |  0.00% |
| | CPU Cycles | 195,014 | 273,546 | -78,532 | ⚡️ -28.71% |
| **Execute** | Gas Used | 3,685,070 | 3,799,026 | -113,956 | ⚡️ -3.00% |
| | Storage Diff | 76 | 76 | 0 |  0.00% |
| | CPU Cycles | 567,350 | 688,298 | -120,948 | ⚡️ -17.57% |
| **Propose Text** | Gas Used | 799,599 | 1,427,855 | -628,256 | ⚡️ -44.00% |
| | Storage Diff | 13,545 | 13,545 | 0 |  0.00% |
| | CPU Cycles | 423,455 | 1,051,711 | -628,256 | ⚡️ -59.74% |
| **Delegate** | Gas Used | 8,276,823 | 9,759,051 | -1,482,228 | ⚡️ -15.19% |
| | Storage Diff | 14,944 | 15,294 | -350 | ⚡️ -2.29% |
| | CPU Cycles | 712,233 | 1,498,189 | -785,956 | ⚡️ -52.46% |
| **Undelegate** | Gas Used | 1,715,423 | 2,608,859 | -893,436 | ⚡️ -34.25% |
| | Storage Diff | 1,334 | 1,334 | 0 |  0.00% |
| | CPU Cycles | 552,928 | 1,423,190 | -870,262 | ⚡️ -61.15% |
| **Collect Undelegated GNS** | Gas Used | 106,781 | 185,313 | -78,532 | ⚡️ -42.38% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 106,781 | 185,313 | -78,532 | ⚡️ -42.38% |
| **Redelegate** | Gas Used | 1,912,340 | 3,041,372 | -1,129,032 | ⚡️ -37.12% |
| | Storage Diff | 7,524 | 7,524 | 0 |  0.00% |
| | CPU Cycles | 656,209 | 1,762,067 | -1,105,858 | ⚡️ -62.76% |
| **Create Launchpad Project** | Gas Used | 10,365,967 | 11,474,918 | -1,108,951 | ⚡️ -9.66% |
| | Storage Diff | 28,808 | 31,958 | -3,150 | ⚡️ -9.86% |
| | CPU Cycles | 1,832,491 | 2,424,162 | -591,671 | ⚡️ -24.41% |
| **CreatePool** | Gas Used | 8,562,215 | 12,495,782 | -3,933,567 | ⚡️ -31.48% |
| | Storage Diff | 18,536 | 21,680 | -3,144 | ⚡️ -14.50% |
| | CPU Cycles | 2,298,975 | 5,696,750 | -3,397,775 | ⚡️ -59.64% |
| **Mint (fee:3000, wide range)** | Gas Used | 14,592,477 | 39,087,453 | -24,494,976 | ⚡️ -62.67% |
| | Storage Diff | 40,646 | 52,800 | -12,154 | ⚡️ -23.02% |
| | CPU Cycles | 8,421,071 | 32,659,353 | -24,238,282 | ⚡️ -74.22% |
| **Swap (gns -> wugnot, fee:500)** | Gas Used | 30,811,444 | 81,927,967 | -51,116,523 | ⚡️ -62.39% |
| | Storage Diff | 19,749 | 22,199 | -2,450 | ⚡️ -11.04% |
| | CPU Cycles | 20,616,534 | 71,713,827 | -51,097,293 | ⚡️ -71.25% |
| **DecreaseLiquidity** | Gas Used | 12,625,191 | 24,327,552 | -11,702,361 | ⚡️ -48.10% |
| | Storage Diff | 58 | 72 | -14 | ⚡️ -19.44% |
| | CPU Cycles | 9,830,652 | 21,291,144 | -11,460,492 | ⚡️ -53.83% |
| **IncreaseLiquidity** | Gas Used | 10,546,778 | 23,198,296 | -12,651,518 | ⚡️ -54.54% |
| | Storage Diff | -2,064 | -2,022 | -42 | ⚡️ 2.08% |
| | CPU Cycles | 9,462,514 | 21,925,540 | -12,463,026 | ⚡️ -56.84% |
| **Mint (bar:foo:500)** | Gas Used | 17,323,250 | 39,889,642 | -22,566,392 | ⚡️ -56.57% |
| | Storage Diff | 40,621 | 52,777 | -12,156 | ⚡️ -23.03% |
| | CPU Cycles | 7,493,016 | 29,802,270 | -22,309,254 | ⚡️ -74.86% |
| **Mint (w. GNOT)** | Gas Used | 20,341,781 | 44,188,470 | -23,846,689 | ⚡️ -53.97% |
| | Storage Diff | 39,662 | 51,818 | -12,156 | ⚡️ -23.46% |
| | CPU Cycles | 8,955,633 | 33,194,528 | -24,238,895 | ⚡️ -73.02% |
| **IncreaseLiquidity (w. GNOT)** | Gas Used | 12,144,794 | 27,307,664 | -15,162,870 | ⚡️ -55.53% |
| | Storage Diff | 56 | 98 | -42 | ⚡️ -42.86% |
| | CPU Cycles | 10,808,154 | 25,782,532 | -14,974,378 | ⚡️ -58.08% |
| **DecreaseLiquidity (unwrap=false)** | Gas Used | 15,358,903 | 28,762,263 | -13,403,360 | ⚡️ -46.60% |
| | Storage Diff | 6,396 | 6,369 | +27 | ⚠️ 0.42% |
| | CPU Cycles | 10,431,848 | 23,577,883 | -13,146,035 | ⚡️ -55.76% |
| **CollectFee (with unwrap)** | Gas Used | 3,657,730 | 6,356,955 | -2,699,225 | ⚡️ -42.46% |
| | Storage Diff | 40 | 44 | -4 | ⚡️ -9.09% |
| | CPU Cycles | 2,408,011 | 5,052,786 | -2,644,775 | ⚡️ -52.34% |
| **DecreaseLiquidity (w. Remove)** | Gas Used | 13,302,625 | 24,765,751 | -11,463,126 | ⚡️ -46.29% |
| | Storage Diff | 4,370 | 4,406 | -36 | ⚡️ -0.82% |
| | CPU Cycles | 9,181,538 | 20,382,247 | -11,200,709 | ⚡️ -54.95% |
| **Mint (reposition)** | Gas Used | 9,183,098 | 31,711,435 | -22,528,337 | ⚡️ -71.04% |
| | Storage Diff | 33,728 | 45,256 | -11,528 | ⚡️ -25.47% |
| | CPU Cycles | 7,577,930 | 29,883,427 | -22,305,497 | ⚡️ -74.64% |
| **SetPoolTier (tier 1)** | Gas Used | 4,824,309 | 5,375,292 | -550,983 | ⚡️ -10.25% |
| | Storage Diff | 22,221 | 22,952 | -731 | ⚡️ -3.18% |
| | CPU Cycles | 1,457,487 | 2,281,958 | -824,471 | ⚡️ -36.13% |
| **StakeToken** | Gas Used | 8,303,255 | 11,764,730 | -3,461,475 | ⚡️ -29.42% |
| | Storage Diff | 22,593 | 25,068 | -2,475 | ⚡️ -9.87% |
| | CPU Cycles | 4,642,432 | 7,968,981 | -3,326,549 | ⚡️ -41.74% |
| **ExactInSingleSwapRoute(grc20) - fee:10000** | Gas Used | 28,193,729 | 40,335,056 | -12,141,327 | ⚡️ -30.10% |
| | Storage Diff | 5,002 | 5,352 | -350 | ⚡️ -6.54% |
| | CPU Cycles | 11,317,121 | 23,335,186 | -12,018,065 | ⚡️ -51.50% |
| **ExactInSingleSwapRoute(grc20) - fee:100** | Gas Used | 30,242,572 | 48,837,141 | -18,594,569 | ⚡️ -38.07% |
| | Storage Diff | 7,819 | 8,519 | -700 | ⚡️ -8.22% |
| | CPU Cycles | 13,364,444 | 31,851,655 | -18,487,211 | ⚡️ -58.04% |
| **ExactInSingleSwapRoute(grc20) - fee:3000** | Gas Used | 28,616,724 | 40,817,866 | -12,201,142 | ⚡️ -29.89% |
| | Storage Diff | 5,004 | 5,361 | -357 | ⚡️ -6.66% |
| | CPU Cycles | 11,333,963 | 23,417,331 | -12,083,368 | ⚡️ -51.60% |
| **ExactInSingleSwapRoute(grc20) - fee:500** | Gas Used | 28,074,520 | 40,166,958 | -12,092,438 | ⚡️ -30.11% |
| | Storage Diff | 5,002 | 5,352 | -350 | ⚡️ -6.54% |
| | CPU Cycles | 11,239,560 | 23,229,920 | -11,990,360 | ⚡️ -51.62% |
| **ExactInSingleSwapRoute(ugnot) - fee:10000** | Gas Used | 29,459,505 | 44,260,008 | -14,800,503 | ⚡️ -33.44% |
| | Storage Diff | 7,834 | 8,534 | -700 | ⚡️ -8.20% |
| | CPU Cycles | 12,347,035 | 27,014,292 | -14,667,257 | ⚡️ -54.29% |
| **ExactInSingleSwapRoute(ugnot) - fee:100** | Gas Used | 31,085,358 | 52,746,494 | -21,661,136 | ⚡️ -41.07% |
| | Storage Diff | 10,655 | 11,705 | -1,050 | ⚡️ -8.97% |
| | CPU Cycles | 13,940,056 | 35,467,962 | -21,527,906 | ⚡️ -60.70% |
| **ExactInSingleSwapRoute(ugnot) - fee:3000** | Gas Used | 29,980,307 | 45,037,790 | -15,057,483 | ⚡️ -33.43% |
| | Storage Diff | 7,836 | 8,543 | -707 | ⚡️ -8.28% |
| | CPU Cycles | 12,451,268 | 27,375,697 | -14,924,429 | ⚡️ -54.52% |
| **ExactInSingleSwapRoute(ugnot) - fee:500** | Gas Used | 29,329,588 | 44,018,162 | -14,688,574 | ⚡️ -33.37% |
| | Storage Diff | 7,835 | 8,535 | -700 | ⚡️ -8.20% |
| | CPU Cycles | 12,237,918 | 26,803,838 | -14,565,920 | ⚡️ -54.34% |
| **ExactInSwapRoute(grc20) - fee:10000** | Gas Used | 27,933,438 | 40,101,830 | -12,168,392 | ⚡️ -30.34% |
| | Storage Diff | 5,002 | 5,352 | -350 | ⚡️ -6.54% |
| | CPU Cycles | 11,056,830 | 23,101,960 | -12,045,130 | ⚡️ -52.14% |
| **ExactInSwapRoute(grc20) - fee:100** | Gas Used | 29,988,825 | 48,610,459 | -18,621,634 | ⚡️ -38.31% |
| | Storage Diff | 7,819 | 8,519 | -700 | ⚡️ -8.22% |
| | CPU Cycles | 13,110,697 | 31,624,973 | -18,514,276 | ⚡️ -58.54% |
| **ExactInSwapRoute(grc20) - fee:3000** | Gas Used | 28,359,705 | 40,587,912 | -12,228,207 | ⚡️ -30.13% |
| | Storage Diff | 5,004 | 5,361 | -357 | ⚡️ -6.66% |
| | CPU Cycles | 11,076,944 | 23,187,377 | -12,110,433 | ⚡️ -52.23% |
| **ExactInSwapRoute(grc20) - fee:500** | Gas Used | 27,820,773 | 39,940,276 | -12,119,503 | ⚡️ -30.34% |
| | Storage Diff | 5,002 | 5,352 | -350 | ⚡️ -6.54% |
| | CPU Cycles | 10,985,813 | 23,003,238 | -12,017,425 | ⚡️ -52.24% |
| **ExactInSwapRoute(ugnot) - fee:10000** | Gas Used | 29,199,214 | 44,026,782 | -14,827,568 | ⚡️ -33.68% |
| | Storage Diff | 7,834 | 8,534 | -700 | ⚡️ -8.20% |
| | CPU Cycles | 12,086,744 | 26,781,066 | -14,694,322 | ⚡️ -54.87% |
| **ExactInSwapRoute(ugnot) - fee:100** | Gas Used | 30,831,611 | 52,519,812 | -21,688,201 | ⚡️ -41.30% |
| | Storage Diff | 10,655 | 11,705 | -1,050 | ⚡️ -8.97% |
| | CPU Cycles | 13,686,309 | 35,241,280 | -21,554,971 | ⚡️ -61.16% |
| **ExactInSwapRoute(ugnot) - fee:3000** | Gas Used | 29,723,288 | 44,807,836 | -15,084,548 | ⚡️ -33.66% |
| | Storage Diff | 7,836 | 8,543 | -707 | ⚡️ -8.28% |
| | CPU Cycles | 12,194,249 | 27,145,743 | -14,951,494 | ⚡️ -55.08% |
| **ExactInSwapRoute(ugnot) - fee:500** | Gas Used | 29,075,841 | 43,791,480 | -14,715,639 | ⚡️ -33.60% |
| | Storage Diff | 7,835 | 8,535 | -700 | ⚡️ -8.20% |
| | CPU Cycles | 11,984,171 | 26,577,156 | -14,592,985 | ⚡️ -54.91% |
| **ExactOutSingleSwapRoute(grc20) - fee:10000** | Gas Used | 28,984,085 | 44,502,204 | -15,518,119 | ⚡️ -34.87% |
| | Storage Diff | 5,002 | 5,352 | -350 | ⚡️ -6.54% |
| | CPU Cycles | 12,117,829 | 27,533,758 | -15,415,929 | ⚡️ -55.99% |
| **ExactOutSingleSwapRoute(grc20) - fee:100** | Gas Used | 30,962,191 | 52,676,052 | -21,713,861 | ⚡️ -41.22% |
| | Storage Diff | 7,819 | 8,519 | -700 | ⚡️ -8.22% |
| | CPU Cycles | 14,094,415 | 35,706,278 | -21,611,863 | ⚡️ -60.53% |
| **ExactOutSingleSwapRoute(grc20) - fee:3000** | Gas Used | 29,341,555 | 44,837,966 | -15,496,411 | ⚡️ -34.56% |
| | Storage Diff | 5,004 | 5,361 | -357 | ⚡️ -6.66% |
| | CPU Cycles | 12,079,562 | 27,484,567 | -15,405,005 | ⚡️ -56.05% |
| **ExactOutSingleSwapRoute(grc20) - fee:500** | Gas Used | 28,814,084 | 44,169,905 | -15,355,821 | ⚡️ -34.77% |
| | Storage Diff | 5,002 | 5,352 | -350 | ⚡️ -6.54% |
| | CPU Cycles | 11,999,892 | 27,280,003 | -15,280,111 | ⚡️ -56.01% |
| **ExactOutSingleSwapRoute(ugnot) - fee:10000** | Gas Used | 29,856,755 | 44,599,557 | -14,742,802 | ⚡️ -33.06% |
| | Storage Diff | 7,844 | 8,544 | -700 | ⚡️ -8.19% |
| | CPU Cycles | 12,445,899 | 27,050,095 | -14,604,196 | ⚡️ -53.99% |
| **ExactOutSingleSwapRoute(ugnot) - fee:100** | Gas Used | 31,355,948 | 51,365,291 | -20,009,343 | ⚡️ -38.95% |
| | Storage Diff | 10,665 | 11,715 | -1,050 | ⚡️ -8.96% |
| | CPU Cycles | 13,922,676 | 33,798,725 | -19,876,049 | ⚡️ -58.81% |
| **ExactOutSingleSwapRoute(ugnot) - fee:3000** | Gas Used | 30,282,258 | 45,145,418 | -14,863,160 | ⚡️ -32.92% |
| | Storage Diff | 7,846 | 8,553 | -707 | ⚡️ -8.27% |
| | CPU Cycles | 12,465,249 | 27,195,291 | -14,730,042 | ⚡️ -54.16% |
| **ExactOutSingleSwapRoute(ugnot) - fee:500** | Gas Used | 29,655,390 | 44,144,859 | -14,489,469 | ⚡️ -32.82% |
| | Storage Diff | 7,845 | 8,545 | -700 | ⚡️ -8.19% |
| | CPU Cycles | 12,275,750 | 26,642,501 | -14,366,751 | ⚡️ -53.92% |
| **ExactOutSwapRoute(grc20) - fee:10000** | Gas Used | 28,735,082 | 44,279,086 | -15,544,004 | ⚡️ -35.10% |
| | Storage Diff | 5,002 | 5,352 | -350 | ⚡️ -6.54% |
| | CPU Cycles | 11,868,826 | 27,310,640 | -15,441,814 | ⚡️ -56.54% |
| **ExactOutSwapRoute(grc20) - fee:100** | Gas Used | 30,719,732 | 52,459,478 | -21,739,746 | ⚡️ -41.44% |
| | Storage Diff | 7,819 | 8,519 | -700 | ⚡️ -8.22% |
| | CPU Cycles | 13,851,956 | 35,489,704 | -21,637,748 | ⚡️ -60.97% |
| **ExactOutSwapRoute(grc20) - fee:3000** | Gas Used | 29,095,824 | 44,618,120 | -15,522,296 | ⚡️ -34.79% |
| | Storage Diff | 5,004 | 5,361 | -357 | ⚡️ -6.66% |
| | CPU Cycles | 11,833,831 | 27,264,721 | -15,430,890 | ⚡️ -56.60% |
| **ExactOutSwapRoute(grc20) - fee:500** | Gas Used | 28,571,625 | 43,953,331 | -15,381,706 | ⚡️ -35.00% |
| | Storage Diff | 5,002 | 5,352 | -350 | ⚡️ -6.54% |
| | CPU Cycles | 11,757,433 | 27,063,429 | -15,305,996 | ⚡️ -56.56% |
| **ExactOutSwapRoute(ugnot) - fee:10000** | Gas Used | 29,607,752 | 44,376,439 | -14,768,687 | ⚡️ -33.28% |
| | Storage Diff | 7,844 | 8,544 | -700 | ⚡️ -8.19% |
| | CPU Cycles | 12,196,896 | 26,826,977 | -14,630,081 | ⚡️ -54.53% |
| **ExactOutSwapRoute(ugnot) - fee:100** | Gas Used | 31,113,489 | 51,148,717 | -20,035,228 | ⚡️ -39.17% |
| | Storage Diff | 10,665 | 11,715 | -1,050 | ⚡️ -8.96% |
| | CPU Cycles | 13,680,217 | 33,582,151 | -19,901,934 | ⚡️ -59.26% |
| **ExactOutSwapRoute(ugnot) - fee:3000** | Gas Used | 30,036,527 | 44,925,572 | -14,889,045 | ⚡️ -33.14% |
| | Storage Diff | 7,846 | 8,553 | -707 | ⚡️ -8.27% |
| | CPU Cycles | 12,219,518 | 26,975,445 | -14,755,927 | ⚡️ -54.70% |
| **ExactOutSwapRoute(ugnot) - fee:500** | Gas Used | 29,412,931 | 43,928,285 | -14,515,354 | ⚡️ -33.04% |
| | Storage Diff | 7,845 | 8,545 | -700 | ⚡️ -8.19% |
| | CPU Cycles | 12,033,291 | 26,425,927 | -14,392,636 | ⚡️ -54.46% |
| **BuildSingleHopRoutePath** | Gas Used | 1,710,230 | 2,012,694 | -302,464 | ⚡️ -15.03% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 23,398 | 80,758 | -57,360 | ⚡️ -71.03% |
| **MultiHop ExactIn (2 hops)** | Gas Used | 31,120,652 | 57,322,453 | -26,201,801 | ⚡️ -45.71% |
| | Storage Diff | 10,674 | 11,724 | -1,050 | ⚡️ -8.96% |
| | CPU Cycles | 22,560,598 | 48,799,683 | -26,239,085 | ⚡️ -53.77% |
| **MultiHop ExactOut (2 hops)** | Gas Used | 35,484,313 | 85,947,977 | -50,463,664 | ⚡️ -58.71% |
| | Storage Diff | 26 | 26 | 0 |  0.00% |
| | CPU Cycles | 33,911,183 | 84,518,691 | -50,607,508 | ⚡️ -59.88% |
| **MultiHop ExactIn (3 hops)** | Gas Used | 35,229,817 | 71,637,352 | -36,407,535 | ⚡️ -50.82% |
| | Storage Diff | 5,709 | 6,492 | -783 | ⚡️ -12.06% |
| | CPU Cycles | 32,909,787 | 69,529,104 | -36,619,317 | ⚡️ -52.67% |
| **MultiHop ExactOut (3 hops)** | Gas Used | 54,213,522 | 129,668,111 | -75,454,589 | ⚡️ -58.19% |
| | Storage Diff | 14 | 104 | -90 | ⚡️ -86.54% |
| | CPU Cycles | 52,070,200 | 127,746,107 | -75,675,907 | ⚡️ -59.24% |
| **MultiRoute ExactIn (50:50 split)** | Gas Used | 35,445,335 | 73,186,392 | -37,741,057 | ⚡️ -51.57% |
| | Storage Diff | 2,849 | 3,330 | -481 | ⚡️ -14.44% |
| | CPU Cycles | 32,686,930 | 70,616,233 | -37,929,303 | ⚡️ -53.71% |
| **MultiRoute ExactOut (50:50 split)** | Gas Used | 47,841,387 | 113,684,402 | -65,843,015 | ⚡️ -57.92% |
| | Storage Diff | 2 | 2 | 0 |  0.00% |
| | CPU Cycles | 45,202,660 | 111,267,073 | -66,064,413 | ⚡️ -59.37% |
| **CollectReward (immediately after stake)** | Gas Used | 2,895,057 | 4,486,368 | -1,591,311 | ⚡️ -35.47% |
| | Storage Diff | -6 | -6 | 0 |  0.00% |
| | CPU Cycles | 1,803,397 | 3,301,492 | -1,498,095 | ⚡️ -45.38% |
| **CreateExternalIncentive** | Gas Used | 2,908,707 | 3,119,320 | -210,613 | ⚡️ -6.75% |
| | Storage Diff | 28,114 | 28,826 | -712 | ⚡️ -2.47% |
| | CPU Cycles | 1,407,581 | 1,853,138 | -445,557 | ⚡️ -24.04% |
| **EndExternalIncentive** | Gas Used | 1,261,843 | 1,497,591 | -235,748 | ⚡️ -15.74% |
| | Storage Diff | -1,988 | -1,988 | 0 |  0.00% |
| | CPU Cycles | 561,523 | 797,271 | -235,748 | ⚡️ -29.57% |

---
