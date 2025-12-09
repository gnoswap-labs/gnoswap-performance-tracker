# GnoSwap Performance Summary Report

> Generated: 2025-12-09 19:11:07

## Overview

- **Total Commits**: 12
- **First Commit (Oldest)**: [`e5d1e160`](https://github.com/gnoswap-labs/gnoswap/tree/e5d1e160) - Base
- **Last Commit (Latest)**: [`e59f3c16`](https://github.com/gnoswap-labs/gnoswap/tree/e59f3c16) - Optimize position

---

## Commit History

| # | Commit | Description | Report | Diff from Previous | Diff from Base |
|---|--------|-------------|--------|-------------------|----------------|
| 1 | [`e5d1e160`](https://github.com/gnoswap-labs/gnoswap/tree/e5d1e160) | Base | [📊 Report](reports/commits/e5d1e160.md) | _Baseline_ | _Baseline_ |
| 2 | [`9dbd8927`](https://github.com/gnoswap-labs/gnoswap/tree/9dbd8927) | Optimize Uint256 | [📊 Report](reports/commits/9dbd8927.md) | [📈 Diff](reports/compares/diff_9dbd8927_e5d1e160.md) | [📊 Diff](reports/compares/diff_9dbd8927_e5d1e160.md) |
| 3 | [`31d883d4`](https://github.com/gnoswap-labs/gnoswap/tree/31d883d4) | Optimize Int256 | [📊 Report](reports/commits/31d883d4.md) | [📈 Diff](reports/compares/diff_31d883d4_9dbd8927.md) | [📊 Diff](reports/compares/diff_31d883d4_e5d1e160.md) |
| 4 | [`94d46728`](https://github.com/gnoswap-labs/gnoswap/tree/94d46728) | Optimize Common | [📊 Report](reports/commits/94d46728.md) | [📈 Diff](reports/compares/diff_94d46728_31d883d4.md) | [📊 Diff](reports/compares/diff_94d46728_e5d1e160.md) |
| 5 | [`f468996c`](https://github.com/gnoswap-labs/gnoswap/tree/f468996c) | Optimize Pool | [📊 Report](reports/commits/f468996c.md) | [📈 Diff](reports/compares/diff_f468996c_94d46728.md) | [📊 Diff](reports/compares/diff_f468996c_e5d1e160.md) |
| 6 | [`51813f5d`](https://github.com/gnoswap-labs/gnoswap/tree/51813f5d) | Make pool use AVL tree | [📊 Report](reports/commits/51813f5d.md) | [📈 Diff](reports/compares/diff_51813f5d_f468996c.md) | [📊 Diff](reports/compares/diff_51813f5d_e5d1e160.md) |
| 7 | [`c9983990`](https://github.com/gnoswap-labs/gnoswap/tree/c9983990) | Replace int256 with int64 for router swap | [📊 Report](reports/commits/c9983990.md) | [📈 Diff](reports/compares/diff_c9983990_51813f5d.md) | [📊 Diff](reports/compares/diff_c9983990_e5d1e160.md) |
| 8 | [`aa648b23`](https://github.com/gnoswap-labs/gnoswap/tree/aa648b23) | Optimize KVStore.makeKey | [📊 Report](reports/commits/aa648b23.md) | [📈 Diff](reports/compares/diff_aa648b23_c9983990.md) | [📊 Diff](reports/compares/diff_aa648b23_e5d1e160.md) |
| 9 | [`3a818d3a`](https://github.com/gnoswap-labs/gnoswap/tree/3a818d3a) | Optimize Router | [📊 Report](reports/commits/3a818d3a.md) | [📈 Diff](reports/compares/diff_3a818d3a_aa648b23.md) | [📊 Diff](reports/compares/diff_3a818d3a_e5d1e160.md) |
| 10 | [`9ee6b504`](https://github.com/gnoswap-labs/gnoswap/tree/9ee6b504) | Optimize GNFT | [📊 Report](reports/commits/9ee6b504.md) | [📈 Diff](reports/compares/diff_9ee6b504_3a818d3a.md) | [📊 Diff](reports/compares/diff_9ee6b504_e5d1e160.md) |
| 11 | [`a7e1bc3b`](https://github.com/gnoswap-labs/gnoswap/tree/a7e1bc3b) | Make stake use AVL tree | [📊 Report](reports/commits/a7e1bc3b.md) | [📈 Diff](reports/compares/diff_a7e1bc3b_9ee6b504.md) | [📊 Diff](reports/compares/diff_a7e1bc3b_e5d1e160.md) |
| 12 | [`e59f3c16`](https://github.com/gnoswap-labs/gnoswap/tree/e59f3c16) | Optimize position | [📊 Report](reports/commits/e59f3c16.md) | [📈 Diff](reports/compares/diff_e59f3c16_a7e1bc3b.md) | [📊 Diff](reports/compares/diff_e59f3c16_e5d1e160.md) |

---

## Overall Comparison (First → Latest)

**[`e5d1e160` → `e59f3c16`](reports/compares/diff_e59f3c16_e5d1e160.md)**

This comparison shows the total gas usage changes between the baseline commit and the latest commit.

### Quick Stats

| Metric | Count |
|--------|-------|
| ⚡️ Improvements | 3 |
| ⚠️ Regressions | 227 |

### Detailed Comparison

| Name | Metric | Latest | Previous | Change | % |
|------|--------|--------|----------|--------|---|
| **TickMathGetSqrtRatioAtTick (minTick)** | Gas Used | 1,555,244 | 0 | +1,555,244 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 677,324 | 0 | +677,324 | ⚠️ N/A% |
| **TickMathGetSqrtRatioAtTick (maxTick)** | Gas Used | 873,832 | 0 | +873,832 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 863,400 | 0 | +863,400 | ⚠️ N/A% |
| **TickMathGetSqrtRatioAtTick (zero)** | Gas Used | 134,165 | 0 | +134,165 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 134,165 | 0 | +134,165 | ⚠️ N/A% |
| **TickMathGetSqrtRatioAtTick** | Gas Used | 652,352 | 0 | +652,352 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 641,936 | 0 | +641,936 | ⚠️ N/A% |
| **TickMathGetTickAtSqrtRatio** | Gas Used | 1,785,434 | 0 | +1,785,434 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,628,730 | 0 | +1,628,730 | ⚠️ N/A% |
| **GetLiquidityForAmounts** | Gas Used | 1,442,983 | 0 | +1,442,983 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,422,279 | 0 | +1,422,279 | ⚠️ N/A% |
| **GetAmountsForLiquidity** | Gas Used | 1,333,931 | 0 | +1,333,931 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,333,931 | 0 | +1,333,931 | ⚠️ N/A% |
| **LiquidityMathAddDelta (positive)** | Gas Used | 220,687 | 0 | +220,687 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 187,647 | 0 | +187,647 | ⚠️ N/A% |
| **LiquidityMathAddDelta (negative)** | Gas Used | 199,989 | 0 | +199,989 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 199,989 | 0 | +199,989 | ⚠️ N/A% |
| **LiquidityMathAddDelta** | Gas Used | 187,647 | 0 | +187,647 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 187,647 | 0 | +187,647 | ⚠️ N/A% |
| **IsGNOTPath** | Gas Used | 11,223 | 0 | +11,223 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 11,223 | 0 | +11,223 | ⚠️ N/A% |
| **IsGNOTNativePath** | Gas Used | 11,175 | 0 | +11,175 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 11,175 | 0 | +11,175 | ⚠️ N/A% |
| **IsGNOTWrappedPath** | Gas Used | 11,175 | 0 | +11,175 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 11,175 | 0 | +11,175 | ⚠️ N/A% |
| **ExistsUserSendCoins** | Gas Used | 266,478 | 0 | +266,478 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 18,206 | 0 | +18,206 | ⚠️ N/A% |
| **GetAmount0Delta** | Gas Used | 3,912,271 | 0 | +3,912,271 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,486,687 | 0 | +1,486,687 | ⚠️ N/A% |
| **GetAmount1Delta** | Gas Used | 1,050,599 | 0 | +1,050,599 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,040,247 | 0 | +1,040,247 | ⚠️ N/A% |
| **SwapMathComputeSwapStep** | Gas Used | 1,879,861 | 0 | +1,879,861 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 1,858,997 | 0 | +1,858,997 | ⚠️ N/A% |
| **Propose Community Pool Spend** | Gas Used | 971,856 | 0 | +971,856 | ⚠️ N/A% |
| | Storage Diff | 14,171 | 0 | +14,171 | ⚠️ N/A% |
| | CPU Cycles | 586,016 | 0 | +586,016 | ⚠️ N/A% |
| **Propose Parameter Change** | Gas Used | 2,188,677 | 0 | +2,188,677 | ⚠️ N/A% |
| | Storage Diff | 14,006 | 0 | +14,006 | ⚠️ N/A% |
| | CPU Cycles | 1,184,437 | 0 | +1,184,437 | ⚠️ N/A% |
| **Vote** | Gas Used | 316,102 | 0 | +316,102 | ⚠️ N/A% |
| | Storage Diff | 80 | 0 | +80 | ⚠️ N/A% |
| | CPU Cycles | 195,014 | 0 | +195,014 | ⚠️ N/A% |
| **Execute** | Gas Used | 3,685,070 | 0 | +3,685,070 | ⚠️ N/A% |
| | Storage Diff | 76 | 0 | +76 | ⚠️ N/A% |
| | CPU Cycles | 567,350 | 0 | +567,350 | ⚠️ N/A% |
| **Propose Text** | Gas Used | 799,599 | 0 | +799,599 | ⚠️ N/A% |
| | Storage Diff | 13,545 | 0 | +13,545 | ⚠️ N/A% |
| | CPU Cycles | 423,455 | 0 | +423,455 | ⚠️ N/A% |
| **Delegate** | Gas Used | 8,276,823 | 0 | +8,276,823 | ⚠️ N/A% |
| | Storage Diff | 14,944 | 0 | +14,944 | ⚠️ N/A% |
| | CPU Cycles | 712,233 | 0 | +712,233 | ⚠️ N/A% |
| **Undelegate** | Gas Used | 1,715,423 | 0 | +1,715,423 | ⚠️ N/A% |
| | Storage Diff | 1,334 | 0 | +1,334 | ⚠️ N/A% |
| | CPU Cycles | 552,928 | 0 | +552,928 | ⚠️ N/A% |
| **Collect Undelegated GNS** | Gas Used | 106,781 | 0 | +106,781 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 106,781 | 0 | +106,781 | ⚠️ N/A% |
| **Redelegate** | Gas Used | 1,912,340 | 0 | +1,912,340 | ⚠️ N/A% |
| | Storage Diff | 7,524 | 0 | +7,524 | ⚠️ N/A% |
| | CPU Cycles | 656,209 | 0 | +656,209 | ⚠️ N/A% |
| **Create Launchpad Project** | Gas Used | 10,365,967 | 0 | +10,365,967 | ⚠️ N/A% |
| | Storage Diff | 28,808 | 0 | +28,808 | ⚠️ N/A% |
| | CPU Cycles | 1,832,491 | 0 | +1,832,491 | ⚠️ N/A% |
| **CreatePool** | Gas Used | 8,562,215 | 0 | +8,562,215 | ⚠️ N/A% |
| | Storage Diff | 18,536 | 0 | +18,536 | ⚠️ N/A% |
| | CPU Cycles | 2,298,975 | 0 | +2,298,975 | ⚠️ N/A% |
| **Mint (fee:3000, wide range)** | Gas Used | 14,592,445 | 0 | +14,592,445 | ⚠️ N/A% |
| | Storage Diff | 40,644 | 0 | +40,644 | ⚠️ N/A% |
| | CPU Cycles | 8,421,071 | 0 | +8,421,071 | ⚠️ N/A% |
| **Swap (gns -> wugnot, fee:500)** | Gas Used | 30,808,836 | 0 | +30,808,836 | ⚠️ N/A% |
| | Storage Diff | 19,749 | 0 | +19,749 | ⚠️ N/A% |
| | CPU Cycles | 20,616,534 | 0 | +20,616,534 | ⚠️ N/A% |
| **DecreaseLiquidity** | Gas Used | 12,625,191 | 0 | +12,625,191 | ⚠️ N/A% |
| | Storage Diff | 58 | 0 | +58 | ⚠️ N/A% |
| | CPU Cycles | 9,830,652 | 0 | +9,830,652 | ⚠️ N/A% |
| **IncreaseLiquidity** | Gas Used | 10,546,778 | 0 | +10,546,778 | ⚠️ N/A% |
| | Storage Diff | -2,064 | 0 | -2,064 | ⚡️ N/A% |
| | CPU Cycles | 9,462,514 | 0 | +9,462,514 | ⚠️ N/A% |
| **Mint (bar:foo:500)** | Gas Used | 17,323,250 | 0 | +17,323,250 | ⚠️ N/A% |
| | Storage Diff | 40,621 | 0 | +40,621 | ⚠️ N/A% |
| | CPU Cycles | 7,493,016 | 0 | +7,493,016 | ⚠️ N/A% |
| **Mint (w. GNOT)** | Gas Used | 20,341,781 | 0 | +20,341,781 | ⚠️ N/A% |
| | Storage Diff | 39,662 | 0 | +39,662 | ⚠️ N/A% |
| | CPU Cycles | 8,955,633 | 0 | +8,955,633 | ⚠️ N/A% |
| **IncreaseLiquidity (w. GNOT)** | Gas Used | 12,144,794 | 0 | +12,144,794 | ⚠️ N/A% |
| | Storage Diff | 56 | 0 | +56 | ⚠️ N/A% |
| | CPU Cycles | 10,808,154 | 0 | +10,808,154 | ⚠️ N/A% |
| **DecreaseLiquidity (unwrap=false)** | Gas Used | 15,358,903 | 0 | +15,358,903 | ⚠️ N/A% |
| | Storage Diff | 6,396 | 0 | +6,396 | ⚠️ N/A% |
| | CPU Cycles | 10,431,848 | 0 | +10,431,848 | ⚠️ N/A% |
| **CollectFee (with unwrap)** | Gas Used | 3,657,730 | 0 | +3,657,730 | ⚠️ N/A% |
| | Storage Diff | 40 | 0 | +40 | ⚠️ N/A% |
| | CPU Cycles | 2,408,011 | 0 | +2,408,011 | ⚠️ N/A% |
| **DecreaseLiquidity (w. Remove)** | Gas Used | 13,302,625 | 0 | +13,302,625 | ⚠️ N/A% |
| | Storage Diff | 4,370 | 0 | +4,370 | ⚠️ N/A% |
| | CPU Cycles | 9,181,538 | 0 | +9,181,538 | ⚠️ N/A% |
| **Mint (reposition)** | Gas Used | 9,183,098 | 0 | +9,183,098 | ⚠️ N/A% |
| | Storage Diff | 33,728 | 0 | +33,728 | ⚠️ N/A% |
| | CPU Cycles | 7,577,930 | 0 | +7,577,930 | ⚠️ N/A% |
| **SetPoolTier (tier 1)** | Gas Used | 4,825,875 | 0 | +4,825,875 | ⚠️ N/A% |
| | Storage Diff | 22,221 | 0 | +22,221 | ⚠️ N/A% |
| | CPU Cycles | 1,497,117 | 0 | +1,497,117 | ⚠️ N/A% |
| **StakeToken** | Gas Used | 8,421,462 | 0 | +8,421,462 | ⚠️ N/A% |
| | Storage Diff | 22,593 | 0 | +22,593 | ⚠️ N/A% |
| | CPU Cycles | 4,760,639 | 0 | +4,760,639 | ⚠️ N/A% |
| **ExactInSingleSwapRoute(grc20) - fee:10000** | Gas Used | 28,191,041 | 0 | +28,191,041 | ⚠️ N/A% |
| | Storage Diff | 5,002 | 0 | +5,002 | ⚠️ N/A% |
| | CPU Cycles | 11,317,121 | 0 | +11,317,121 | ⚠️ N/A% |
| **ExactInSingleSwapRoute(grc20) - fee:100** | Gas Used | 30,239,884 | 0 | +30,239,884 | ⚠️ N/A% |
| | Storage Diff | 7,819 | 0 | +7,819 | ⚠️ N/A% |
| | CPU Cycles | 13,364,444 | 0 | +13,364,444 | ⚠️ N/A% |
| **ExactInSingleSwapRoute(grc20) - fee:3000** | Gas Used | 28,614,036 | 0 | +28,614,036 | ⚠️ N/A% |
| | Storage Diff | 5,004 | 0 | +5,004 | ⚠️ N/A% |
| | CPU Cycles | 11,333,963 | 0 | +11,333,963 | ⚠️ N/A% |
| **ExactInSingleSwapRoute(grc20) - fee:500** | Gas Used | 28,071,832 | 0 | +28,071,832 | ⚠️ N/A% |
| | Storage Diff | 5,002 | 0 | +5,002 | ⚠️ N/A% |
| | CPU Cycles | 11,239,560 | 0 | +11,239,560 | ⚠️ N/A% |
| **ExactInSingleSwapRoute(ugnot) - fee:10000** | Gas Used | 29,456,817 | 0 | +29,456,817 | ⚠️ N/A% |
| | Storage Diff | 7,834 | 0 | +7,834 | ⚠️ N/A% |
| | CPU Cycles | 12,347,035 | 0 | +12,347,035 | ⚠️ N/A% |
| **ExactInSingleSwapRoute(ugnot) - fee:100** | Gas Used | 31,082,670 | 0 | +31,082,670 | ⚠️ N/A% |
| | Storage Diff | 10,655 | 0 | +10,655 | ⚠️ N/A% |
| | CPU Cycles | 13,940,056 | 0 | +13,940,056 | ⚠️ N/A% |
| **ExactInSingleSwapRoute(ugnot) - fee:3000** | Gas Used | 29,977,619 | 0 | +29,977,619 | ⚠️ N/A% |
| | Storage Diff | 7,836 | 0 | +7,836 | ⚠️ N/A% |
| | CPU Cycles | 12,451,268 | 0 | +12,451,268 | ⚠️ N/A% |
| **ExactInSingleSwapRoute(ugnot) - fee:500** | Gas Used | 29,326,900 | 0 | +29,326,900 | ⚠️ N/A% |
| | Storage Diff | 7,835 | 0 | +7,835 | ⚠️ N/A% |
| | CPU Cycles | 12,237,918 | 0 | +12,237,918 | ⚠️ N/A% |
| **ExactInSwapRoute(grc20) - fee:10000** | Gas Used | 27,930,750 | 0 | +27,930,750 | ⚠️ N/A% |
| | Storage Diff | 5,002 | 0 | +5,002 | ⚠️ N/A% |
| | CPU Cycles | 11,056,830 | 0 | +11,056,830 | ⚠️ N/A% |
| **ExactInSwapRoute(grc20) - fee:100** | Gas Used | 29,986,137 | 0 | +29,986,137 | ⚠️ N/A% |
| | Storage Diff | 7,819 | 0 | +7,819 | ⚠️ N/A% |
| | CPU Cycles | 13,110,697 | 0 | +13,110,697 | ⚠️ N/A% |
| **ExactInSwapRoute(grc20) - fee:3000** | Gas Used | 28,357,017 | 0 | +28,357,017 | ⚠️ N/A% |
| | Storage Diff | 5,004 | 0 | +5,004 | ⚠️ N/A% |
| | CPU Cycles | 11,076,944 | 0 | +11,076,944 | ⚠️ N/A% |
| **ExactInSwapRoute(grc20) - fee:500** | Gas Used | 27,818,085 | 0 | +27,818,085 | ⚠️ N/A% |
| | Storage Diff | 5,002 | 0 | +5,002 | ⚠️ N/A% |
| | CPU Cycles | 10,985,813 | 0 | +10,985,813 | ⚠️ N/A% |
| **ExactInSwapRoute(ugnot) - fee:10000** | Gas Used | 29,196,526 | 0 | +29,196,526 | ⚠️ N/A% |
| | Storage Diff | 7,834 | 0 | +7,834 | ⚠️ N/A% |
| | CPU Cycles | 12,086,744 | 0 | +12,086,744 | ⚠️ N/A% |
| **ExactInSwapRoute(ugnot) - fee:100** | Gas Used | 30,828,923 | 0 | +30,828,923 | ⚠️ N/A% |
| | Storage Diff | 10,655 | 0 | +10,655 | ⚠️ N/A% |
| | CPU Cycles | 13,686,309 | 0 | +13,686,309 | ⚠️ N/A% |
| **ExactInSwapRoute(ugnot) - fee:3000** | Gas Used | 29,720,600 | 0 | +29,720,600 | ⚠️ N/A% |
| | Storage Diff | 7,836 | 0 | +7,836 | ⚠️ N/A% |
| | CPU Cycles | 12,194,249 | 0 | +12,194,249 | ⚠️ N/A% |
| **ExactInSwapRoute(ugnot) - fee:500** | Gas Used | 29,073,153 | 0 | +29,073,153 | ⚠️ N/A% |
| | Storage Diff | 7,835 | 0 | +7,835 | ⚠️ N/A% |
| | CPU Cycles | 11,984,171 | 0 | +11,984,171 | ⚠️ N/A% |
| **ExactOutSingleSwapRoute(grc20) - fee:10000** | Gas Used | 28,981,397 | 0 | +28,981,397 | ⚠️ N/A% |
| | Storage Diff | 5,002 | 0 | +5,002 | ⚠️ N/A% |
| | CPU Cycles | 12,117,829 | 0 | +12,117,829 | ⚠️ N/A% |
| **ExactOutSingleSwapRoute(grc20) - fee:100** | Gas Used | 30,959,503 | 0 | +30,959,503 | ⚠️ N/A% |
| | Storage Diff | 7,819 | 0 | +7,819 | ⚠️ N/A% |
| | CPU Cycles | 14,094,415 | 0 | +14,094,415 | ⚠️ N/A% |
| **ExactOutSingleSwapRoute(grc20) - fee:3000** | Gas Used | 29,338,867 | 0 | +29,338,867 | ⚠️ N/A% |
| | Storage Diff | 5,004 | 0 | +5,004 | ⚠️ N/A% |
| | CPU Cycles | 12,079,562 | 0 | +12,079,562 | ⚠️ N/A% |
| **ExactOutSingleSwapRoute(grc20) - fee:500** | Gas Used | 28,811,396 | 0 | +28,811,396 | ⚠️ N/A% |
| | Storage Diff | 5,002 | 0 | +5,002 | ⚠️ N/A% |
| | CPU Cycles | 11,999,892 | 0 | +11,999,892 | ⚠️ N/A% |
| **ExactOutSingleSwapRoute(ugnot) - fee:10000** | Gas Used | 29,854,067 | 0 | +29,854,067 | ⚠️ N/A% |
| | Storage Diff | 7,844 | 0 | +7,844 | ⚠️ N/A% |
| | CPU Cycles | 12,445,899 | 0 | +12,445,899 | ⚠️ N/A% |
| **ExactOutSingleSwapRoute(ugnot) - fee:100** | Gas Used | 31,353,260 | 0 | +31,353,260 | ⚠️ N/A% |
| | Storage Diff | 10,665 | 0 | +10,665 | ⚠️ N/A% |
| | CPU Cycles | 13,922,676 | 0 | +13,922,676 | ⚠️ N/A% |
| **ExactOutSingleSwapRoute(ugnot) - fee:3000** | Gas Used | 30,279,570 | 0 | +30,279,570 | ⚠️ N/A% |
| | Storage Diff | 7,846 | 0 | +7,846 | ⚠️ N/A% |
| | CPU Cycles | 12,465,249 | 0 | +12,465,249 | ⚠️ N/A% |
| **ExactOutSingleSwapRoute(ugnot) - fee:500** | Gas Used | 29,652,702 | 0 | +29,652,702 | ⚠️ N/A% |
| | Storage Diff | 7,845 | 0 | +7,845 | ⚠️ N/A% |
| | CPU Cycles | 12,275,750 | 0 | +12,275,750 | ⚠️ N/A% |
| **ExactOutSwapRoute(grc20) - fee:10000** | Gas Used | 28,732,394 | 0 | +28,732,394 | ⚠️ N/A% |
| | Storage Diff | 5,002 | 0 | +5,002 | ⚠️ N/A% |
| | CPU Cycles | 11,868,826 | 0 | +11,868,826 | ⚠️ N/A% |
| **ExactOutSwapRoute(grc20) - fee:100** | Gas Used | 30,717,044 | 0 | +30,717,044 | ⚠️ N/A% |
| | Storage Diff | 7,819 | 0 | +7,819 | ⚠️ N/A% |
| | CPU Cycles | 13,851,956 | 0 | +13,851,956 | ⚠️ N/A% |
| **ExactOutSwapRoute(grc20) - fee:3000** | Gas Used | 29,093,136 | 0 | +29,093,136 | ⚠️ N/A% |
| | Storage Diff | 5,004 | 0 | +5,004 | ⚠️ N/A% |
| | CPU Cycles | 11,833,831 | 0 | +11,833,831 | ⚠️ N/A% |
| **ExactOutSwapRoute(grc20) - fee:500** | Gas Used | 28,568,937 | 0 | +28,568,937 | ⚠️ N/A% |
| | Storage Diff | 5,002 | 0 | +5,002 | ⚠️ N/A% |
| | CPU Cycles | 11,757,433 | 0 | +11,757,433 | ⚠️ N/A% |
| **ExactOutSwapRoute(ugnot) - fee:10000** | Gas Used | 29,605,064 | 0 | +29,605,064 | ⚠️ N/A% |
| | Storage Diff | 7,844 | 0 | +7,844 | ⚠️ N/A% |
| | CPU Cycles | 12,196,896 | 0 | +12,196,896 | ⚠️ N/A% |
| **ExactOutSwapRoute(ugnot) - fee:100** | Gas Used | 31,110,801 | 0 | +31,110,801 | ⚠️ N/A% |
| | Storage Diff | 10,665 | 0 | +10,665 | ⚠️ N/A% |
| | CPU Cycles | 13,680,217 | 0 | +13,680,217 | ⚠️ N/A% |
| **ExactOutSwapRoute(ugnot) - fee:3000** | Gas Used | 30,033,839 | 0 | +30,033,839 | ⚠️ N/A% |
| | Storage Diff | 7,846 | 0 | +7,846 | ⚠️ N/A% |
| | CPU Cycles | 12,219,518 | 0 | +12,219,518 | ⚠️ N/A% |
| **ExactOutSwapRoute(ugnot) - fee:500** | Gas Used | 29,410,243 | 0 | +29,410,243 | ⚠️ N/A% |
| | Storage Diff | 7,845 | 0 | +7,845 | ⚠️ N/A% |
| | CPU Cycles | 12,033,291 | 0 | +12,033,291 | ⚠️ N/A% |
| **BuildSingleHopRoutePath** | Gas Used | 1,710,230 | 0 | +1,710,230 | ⚠️ N/A% |
| | Storage Diff | 0 | 0 | 0 |  0.00% |
| | CPU Cycles | 23,398 | 0 | +23,398 | ⚠️ N/A% |
| **MultiHop ExactIn (2 hops)** | Gas Used | 31,132,044 | 0 | +31,132,044 | ⚠️ N/A% |
| | Storage Diff | 10,674 | 0 | +10,674 | ⚠️ N/A% |
| | CPU Cycles | 22,560,598 | 0 | +22,560,598 | ⚠️ N/A% |
| **MultiHop ExactOut (2 hops)** | Gas Used | 35,484,313 | 0 | +35,484,313 | ⚠️ N/A% |
| | Storage Diff | 26 | 0 | +26 | ⚠️ N/A% |
| | CPU Cycles | 33,911,183 | 0 | +33,911,183 | ⚠️ N/A% |
| **MultiHop ExactIn (3 hops)** | Gas Used | 35,229,817 | 0 | +35,229,817 | ⚠️ N/A% |
| | Storage Diff | 5,709 | 0 | +5,709 | ⚠️ N/A% |
| | CPU Cycles | 32,909,787 | 0 | +32,909,787 | ⚠️ N/A% |
| **MultiHop ExactOut (3 hops)** | Gas Used | 54,213,522 | 0 | +54,213,522 | ⚠️ N/A% |
| | Storage Diff | 14 | 0 | +14 | ⚠️ N/A% |
| | CPU Cycles | 52,070,200 | 0 | +52,070,200 | ⚠️ N/A% |
| **MultiRoute ExactIn (50:50 split)** | Gas Used | 35,444,360 | 0 | +35,444,360 | ⚠️ N/A% |
| | Storage Diff | 2,849 | 0 | +2,849 | ⚠️ N/A% |
| | CPU Cycles | 32,685,955 | 0 | +32,685,955 | ⚠️ N/A% |
| **MultiRoute ExactOut (50:50 split)** | Gas Used | 47,839,057 | 0 | +47,839,057 | ⚠️ N/A% |
| | Storage Diff | 2 | 0 | +2 | ⚠️ N/A% |
| | CPU Cycles | 45,200,330 | 0 | +45,200,330 | ⚠️ N/A% |
| **CollectReward (immediately after stake)** | Gas Used | 3,150,982 | 0 | +3,150,982 | ⚠️ N/A% |
| | Storage Diff | -6 | 0 | -6 | ⚡️ N/A% |
| | CPU Cycles | 1,965,562 | 0 | +1,965,562 | ⚠️ N/A% |
| **CreateExternalIncentive** | Gas Used | 3,040,615 | 0 | +3,040,615 | ⚠️ N/A% |
| | Storage Diff | 28,114 | 0 | +28,114 | ⚠️ N/A% |
| | CPU Cycles | 1,539,489 | 0 | +1,539,489 | ⚠️ N/A% |
| **EndExternalIncentive** | Gas Used | 1,342,842 | 0 | +1,342,842 | ⚠️ N/A% |
| | Storage Diff | -1,988 | 0 | -1,988 | ⚡️ N/A% |
| | CPU Cycles | 642,522 | 0 | +642,522 | ⚠️ N/A% |

---
