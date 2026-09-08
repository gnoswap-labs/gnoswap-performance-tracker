# B+ tree fanout 확대 적용 실험

## 결론

**fanout 64→4를 전체 이력 트리에 일괄 적용하는 것은 권장하지 않는다.** 초기 할당은 줄지만, 이력이 커지면 더 잦은 분할과 깊어진 탐색 때문에 가스와 저장량이 증가한다. `outsideAccumulation`의 기존 결정을 풀 단위 장기 이력에 그대로 일반화할 수 없다.

- 우선 검토: `rewardCache`, `byStartTime`처럼 항목이 적게 유지되는 풀별 트리. 운영 cardinality는 아직 검증하지 않았다. `unclaimablePeriods`도 초기 절감 후보였지만 50~100개 구간의 실제 incentive 종료 gas가 약 4% 늘어 조건부 후보로 낮춘다. A 묶음도 그대로 적용하는 것은 권장하지 않는다.
- 보류: `stakedLiquidity`, `globalRewardRatioAccumulation`, `historicalTick`까지 포함한 일괄 축소. `CollectReward` gas가 metric의 20~100개 position 성장에서 1.35~2.23%, stress의 1,000개 position에서 5.21%, 왕복 swap 50회 후에는 3.14% 증가했다.
- 이 보고서는 실험 브랜치의 결과이며 배포/마이그레이션 권고가 아니다. 기존 온체인 트리의 fanout은 바뀌지 않는다.

## 비교 기준

원리: [contract PR #1438](https://github.com/gnoswap-labs/gnoswap/pull/1438), [tracker PR #44](https://github.com/gnoswap-labs/gnoswap-performance-tracker/pull/44).

| 구분 | 컨트랙트 리비전 | 변경 |
|---|---|---|
| 기준 | `b12f0f8760a3e88e9539b0c8cfd32b38a5297c68` | 최신 main, #1438 반영. 아래 6개는 64, outsideAccumulation은 이미 4 |
| A | `1925062d5ed7c8d47c49b931cbdb122b1ac6e06f` | rewardCache / unclaimablePeriods / byStartTime: 64→4 |
| B | `cc8b7f110ee69c4d683f71da0cfdc4fbb52b19d1` | A + stakedLiquidity / globalRewardRatioAccumulation / historicalTick: 64→4 |

- 컨트랙트 파일: `contract/r/gnoswap/staker/pool.gno`, 숫자 변경만 각각 3줄. 공개 API/자료형/조회·갱신 로직은 그대로다.
- 브랜치: A `perf/tree-fanout-sparse`, B `perf/tree-fanout-candidates`.
- Tracker base: `cd348c2a78ed766c3adb69d7e5c4030fdec9b89b`, 실험 브랜치 `test/tree-fanout-candidates`.
- Gno: `bac78a97b20e12ba471bdd73a41af31bd94bdc12` (`gas-2ed70a20`), 모든 비교에 같은 리비전 사용.
- 각 리비전은 tracker가 만든 별도 컨트랙트/runtime worktree에서 실행. 기존 canonical checkout과 기존 보고서는 변경하지 않았다.
- `Gas Used`는 실행량이다. 동일한 제출 `GasFee`/`GasWanted`에서 이 값이 줄어도 실제 납부 GNOT이 자동 감소하는 것은 아니다.

## 후보 목록

경로는 컨트랙트 `contract/r/gnoswap/` 기준. 실제 운영 cardinality/호출 빈도는 측정하지 않았으며 해당 평가는 코드 쓰기 패턴에 근거한 추정이다.

| 우선순위 | 대상 / 위치 | 기준 fanout | 판단 |
|---|---|---:|---|
| 1 | `staker/pool.gno:214` rewardCache | 64 | 보상률이 바뀔 때만 기록. 작은 풀별 트리라면 유리하지만 tier/배분 변경 이력 증가 시 역효과. A/B 실측 |
| 1 | `staker/pool.gno:402` unclaimablePeriods | 64 | 무유동성 구간 인덱스. 구간 생성·종료·삭제를 함께 보아야 함. A/B 실측 |
| 1 | `staker/pool.gno:404` byStartTime | 64 | 풀별 외부 인센티브 시작시각 버킷, 같은 시각은 같은 버킷. 항목이 적을 때 우선 후보. A/B 실측 |
| 2 | `staker/pool.gno:207,217-218` stakedLiquidity / globalRewardRatioAccumulation / historicalTick | 64 | stake/unstake/tick-cross 이력. 값 변경 가드가 있어도 장기 성장 가능. B 실측, 일괄 축소 보류 |
| 3 | `pool/pool.gno:252,254` 풀별 ticks / positions | 32 / 16 | 풀별 초기 할당 후보. populated tick/position 수가 커질 때 lookup/insert/remove와 swap 경로를 별도 측정해야 함. 미변경 |
| 3 | `launchpad/reward_manager.gno` RewardManager.rewards | 16 | 매니저별 트리. 신규 프로젝트 초기 비용과 활성 deposit 증가/withdraw를 함께 비교할 후보. 미변경 |
| 낮음 | `gov/staker/tree.gno:25-28` totalDelegationHistory | 64 | 전역 위임 이력, 최신값·기간 조회 및 snapshot cleanup 사용. 성장/정리 분포 없이 축소 권장 불가. 미변경 |
| 낮음 | gov/staker 사용자 이력·보상상태, governance proposal/vote, position 전역 인덱스, referral, protocol_fee token 트리 | 주로 16 | 전역 사용자/제안 수 증가 또는 token 수 분포 영향. 이번 결과를 일반화하지 않음. 미변경 |

B+ tree 구현에서 빈 생성자는 fanout 필드만 저장하고 첫 `Set`에 leaf의 key/value 배열을 할당한다. 따라서 단순 생성 호출 횟수보다 실제 첫 삽입과 유지되는 항목 수가 중요하다. append 분할은 fanout 4에서 항목 #5, #8, #11, #14 등에 발생한다.

## 실제 동작 metric 비교

세 리비전에 동일한 fixture를 적용하여 각각 **211개 metric 행**을 얻었다. 이는 전체 fixture의 성공 개수가 아니다. 아래 값은 해당 측정 구간이 완료되어 실제 출력된 행이다.

| 측정 구간 | 기준 gas | A gas | B gas | B 대 기준 |
|---|---:|---:|---:|---:|
| SetPoolTier (tier 1) | 4,031,260 | 3,988,626 | 3,952,838 | -1.945% |
| StakeToken | 10,617,929 | 10,617,929 | 10,579,863 | -0.359% |
| Swap, halving / 1 staked tick-cross | 32,166,135 | 32,139,123 | 32,088,345 | -0.242% |
| Swap, halving / 50 staked tick-crosses | 445,312,170 | 445,285,158 | 445,234,380 | -0.017% |
| CollectReward, internal reward | 13,986,040 | 13,986,040 | 13,986,040 | 변화 없음 |
| CollectReward, 20 staked positions 성장 | 15,310,774 | 15,310,774 | 15,518,112 | +1.354% |
| CollectReward, 60 staked positions 성장 | 15,775,643 | 15,775,643 | 16,127,079 | +2.228% |
| CollectReward, 100 staked positions 성장 | 15,892,651 | 15,892,651 | 16,228,705 | +2.115% |
| EndExternalIncentive, 미청구 구간 10개 | 2,281,738 | 2,311,196 | 2,311,196 | +1.291% |
| EndExternalIncentive, 미청구 구간 50개 | 2,294,168 | 2,386,736 | 2,386,736 | +4.035% |
| EndExternalIncentive, 미청구 구간 100개 | 2,332,035 | 2,425,562 | 2,425,562 | +4.011% |

SetPoolTier 저장 증가량: 기준 **47,025 B**, A **35,741 B** (-11,284 B), B **24,457 B** (-22,568 B). CPU cycles는 이 구간에서 셋 모두 1,842,521이다.

이번 halving swap에서 B의 절감은 staked tick-cross 1/10/50개 모두 **77,790 gas**로 같았다. #1438의 tick별 트리와 달리 이번 대상은 풀별 공유 트리이므로, 교차 tick 수만큼 절감이 비례해서 커진다고 기대해서는 안 된다.

`StakeToken`의 저장 증가량은 A에서 +5,642 B 더 크게 보이지만 gas는 같다. 저장 delta는 현재 구간의 할당과 해제를 합한 순변화이며 전체 상태 크기가 아니다. 예를 들어 더 작은 트리를 해제하면 회수량도 작아진다. 이 한 행을 전체 저장 효율 악화/개선으로 해석해서는 안 된다.

## 개별 트리 성장 실험

`tests/metric/staker_pool_tree_fanout_filetest.gno`는 실제 `staker.NewPool` / `NewIncentives`로 생성한 트리를 사용한다. 풀/인센티브를 전역에 보관하고 typed value, entry count, 역순/최신 조회, 삭제 결과를 검증한다. raw B+ tree 대체물이 아니다.

- 풀 이력 4종: 총 129개 항목. 생성자에서 이미 넣은 seed는 1개로 계산한다.
- 인센티브 인덱스 2종: 총 65개 항목.
- #5/#14 및 #64/#65/#128/#129의 개별 쓰기와 중간 batch를 측정한다. 이들은 관찰 지점이며 모든 지점이 모든 fanout의 분할 지점인 것은 아니다.
- 아래 합계는 명명된 `Set` 측정 구간만 합한 값이다. 생성자·assertion·read/remove는 제외. 실제 단일 트랜잭션 gas 또는 트리 최종 크기가 아니다.

| 트리 | 항목 수 | 64 쓰기 gas 합계 | 4 쓰기 gas 합계 (B) | 증가율 | 64 / 4 쓰기 storage delta 합계(B) |
|---|---:|---:|---:|---:|---:|
| stakedLiquidity | 129 | 23,199,434 | 35,347,364 | +52.36% | 184,359 / 332,387 |
| rewardCache | 129 | 21,740,203 | 33,889,009 | +55.88% | 72,985 / 221,891 |
| globalRewardRatioAccumulation | 129 | 23,271,309 | 35,423,091 | +52.22% | 76,217 / 225,113 |
| historicalTick | 129 | 21,878,633 | 33,988,296 | +55.35% | 81,325 / 224,165 |
| unclaimablePeriods | 65 | 10,015,516 | 15,072,395 | +50.49% | 40,389 / 103,739 |
| byStartTime | 65 | 14,140,857 | 20,750,515 | +46.74% | 75,384 / 133,032 |

초기 `NewPool` 측정 구간은 431,242→359,666 gas (-16.60%), 45,984→23,416 B. 반면 `historicalTick` #14 쓰기는 152,725→386,649 gas (+153.17%)이고, 129개 항목의 최신값 조회는 126,496→187,794 gas (+48.46%)다. 이는 **트리 연산 단위** 증가율이며 전체 swap 증가율로 표현하면 안 된다.

독립 실행에서도 신규 fixture가 마지막 삭제 검증까지 완료했고 `Error` directive가 없음을 확인한 뒤 golden 갱신 없이 재실행해 통과했다. 독립 실행과 전체 suite 사이 일부 gas/storage 값에 작은 차이가 있어 수치 비교는 동일 suite의 보고서끼리만 사용했다.

## 장기 이력 stress 비교

세 리비전 모두 선택한 14개 fixture가 끝까지 실행되었고, 각 파일에 `Error` directive가 없으며 정확히 14개 metric 행이 생성됨을 driver가 확인했다. 아래 storage delta는 세 리비전에서 각각 같았다.

| 측정 구간 | 기준 gas | A gas | B gas | B 대 기준 |
|---|---:|---:|---:|---:|
| CollectReward, 100 positions | 21,444,366 | 21,444,366 | 21,970,075 | +2.452% |
| CollectReward, 500 positions | 21,587,575 | 21,587,575 | 22,453,197 | +4.010% |
| CollectReward, 1,000 positions | 21,608,344 | 21,608,344 | 22,733,759 | +5.208% |
| CollectReward, 왕복 swap 20회 후 | 22,402,173 | 22,402,173 | 23,102,016 | +3.124% |
| CollectReward, 왕복 swap 50회 후 | 22,822,019 | 22,822,019 | 23,538,014 | +3.137% |
| 500 positions / tick-loop 500 / tier 변경 5회 / claim 5개 | 143,676,707 | 144,169,222 | 144,169,222 | +0.343% |

`tick=500`은 기존 fixture의 loop-count 표기이지 검증된 실제 교차 tick 개수를 뜻하지 않는다. 마지막 행은 A/B 모두 증가하므로 드문 보상률 변경 이력도 커지면 비용이 증가함을 보여준다. 선택한 14개 stress metric에서 gas 개선은 없었다.

- [기준 stress](stress/commits/b12f0f8.md)
- [A stress](stress/commits/1925062.md)
- [B stress](stress/commits/cc8b7f1.md)
- [A 대 기준 stress](stress/compares/diff_1925062_b12f0f8.md)
- [B 대 기준 stress](stress/compares/diff_cc8b7f1_b12f0f8.md)
- [B 대 A stress](stress/compares/diff_cc8b7f1_1925062.md)

## 재현 및 산출물

```sh
make compare-metric-force cc8b7f1 1925062 b12f0f8
python3 scripts/run_tree_fanout_stress.py . cc8b7f1 1925062 b12f0f8
```

- [기준 metric](metric/commits/b12f0f8.md)
- [A metric](metric/commits/1925062.md)
- [B metric](metric/commits/cc8b7f1.md)
- [A 대 기준](metric/compares/diff_1925062_b12f0f8.md)
- [B 대 기준](metric/compares/diff_cc8b7f1_b12f0f8.md)
- [B 대 A](metric/compares/diff_cc8b7f1_1925062.md)

Stress driver는 tracker의 기존 worktree 준비·Gno build·metric parser·comparison script를 사용하되, 현재 contract에서 측정 가능한 보상/staked-tick 이력 fixture 14개를 선택한다. 생성된 각 fixture의 `Error` directive 부재와 metric 출력, 최종 14개 행을 확인한다. 전체 stress suite의 성공을 의미하지 않는다. 비활성 `.gnoa` fixture는 실행하지 않는다.

컨트랙트 B 검증: `make test WORKDIR=fanout-validation PKG=gno.land/r/gnoswap/staker`, `make test WORKDIR=fanout-validation PKG=gno.land/r/gnoswap/staker/v1` 모두 통과. 같은 metric-enabled Gno를 독립 worktree에서 빌드하여 PATH/GNOROOT를 맞췄다.

## 측정 harness 주의사항

기존 tracker의 일부 fixture는 최신 contract API와 맞지 않았다. 실험 브랜치에서 `pool.Swap`의 삭제된 caller 인자, `SafeGRC20Transfer(0, cur, ...)`, `GetSlot0Tick` 오류 반환 처리를 맞췄고, emission 시작 전 기존 `scenarioutils.EnsureCanonicalDefaultPool`을 재사용했다. 이 보완은 모든 비교 리비전에 동일하게 적용했다. 이전 tracker 보고서와의 차이를 컨트랙트 성능 변화로 비교하면 안 된다.

미청구 구간 10/50/100개의 종료 fixture는 자정 정렬된 다음 날이 현재 시각으로부터 24시간 미만일 수 있어, 이틀 뒤 자정으로 시작시각을 설정했다. 구간 수·90일 incentive 기간은 유지하며 세 리비전에 동일하게 적용했다. 세 fixture 모두 실제 종료 metric과 panic 없음도 독립 실행에서 확인했다.

Gno `-update-golden-tests`는 실행 panic을 `Error` directive로 기록하고 PASS 처리할 수 있다. 따라서 make 종료/fixture PASS만으로 전체 워크로드 성공을 주장하지 않는다. 실제 생성된 metric 행과 별도 동작 테스트를 증거로 사용한다. 초기화 단계에서 중단되어 metric이 없는 fixture는 성능 개선/무변화 판단에 포함하지 않는다.

전체 stress 실행에서는 router fixture의 `invalid non-origin call`, 다수 외부 인센티브 fixture의 `[GNOSWAP-STAKER-009] invalid incentive start time`도 확인했다. 이를 성공으로 간주하지 않고 최종 stress 비교에서 제외했다. 이 제외 범위까지 성능 개선/회귀 없음으로 일반화하지 않는다.
