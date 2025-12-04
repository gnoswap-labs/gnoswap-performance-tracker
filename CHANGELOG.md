# GnoSwap Performance Tracking

## Optimization History

| Date | Description | Commit | Report | vs Genesis | vs Previous |
|------|-------------|--------|--------|------------|-------------|
| 251127 | Genesis gas measurement | [e5d1e160](https://github.com/gnoswap-labs/gnoswap/commit/e5d1e160) | [Report](reports/commits/e5d1e160.md) | - | - |
| 251127 | Optimize p/uint256 | [9dbd8927](https://github.com/gnoswap-labs/gnoswap/commit/9dbd89273d8dca332e9b033e77ef0ee1f39f70c9) | [Report](reports/commits/9dbd8927.md) | [Diff](reports/compares/diff_9dbd8927_e5d1e160.md) | [Diff](reports/compares/diff_9dbd8927_e5d1e160.md) |
| 251201 | Optimize p/int256 | [31d883d4](https://github.com/gnoswap-labs/gnoswap/commit/31d883d42b428ecf3d5c735d83f28d2ab734a8b7) | [Report](reports/commits/31d883d4.md) | [Diff](reports/compares/diff_31d883d4_e5d1e160.md) | [Diff](reports/compares/diff_31d883d4_9dbd8927.md) |
| 251202 | Optimize r/common | [94d46728](https://github.com/gnoswap-labs/gnoswap/commit/94d467283a562e0ac319440777f5269a447d3a72) | [Report](reports/commits/94d46728.md) | [Diff](reports/compares/diff_94d46728_e5d1e160.md) | [Diff](reports/compares/diff_94d46728_31d883d4.md) |
| 251203 | Optimize r/pool | [f468996c](https://github.com/gnoswap-labs/gnoswap/commit/f468996ce38e1387392278643af0d83e7219c6cc) | [Report](reports/commits/f468996c.md) | [Diff](reports/compares/diff_f468996c_e5d1e160.md) | [Diff](reports/compares/diff_f468996c_94d46728.md) |

## Notes

- **Report**: Shows gas usage and storage costs for all test functions
- **vs Genesis**: Comparison against the initial baseline (e5d1e160)
- **vs Previous**: Comparison against the previous optimization commit
- Genesis commit (e5d1e160) has no comparisons as it's the baseline
