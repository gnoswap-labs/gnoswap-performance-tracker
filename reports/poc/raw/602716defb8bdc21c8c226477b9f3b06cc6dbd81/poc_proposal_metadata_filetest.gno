// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Contract-level proposal value PoC. The workload creates, reads, votes on,
// cancels, and executes real governance proposals; it does not populate
// stand-alone record fixtures.
package main

import (
	"testing"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/ufmt/v0"
	_ "gno.land/r/gnoswap/gov/governance/v1"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/pool/v1"
	_ "gno.land/r/gnoswap/protocol_fee/v1"
	_ "gno.land/r/gnoswap/rbac"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/gns"
	"gno.land/r/gnoswap/gov/governance"
	govstaker "gno.land/r/gnoswap/gov/staker"
	"gno.land/r/gnoswap/scenario/metric"
)

var (
	pmdAdminAddr, _           = access.GetAddress(prabc.ROLE_ADMIN.String())
	pmdAdminRealm             = testing.NewUserRealm(pmdAdminAddr)
	pmdGovStakerAddr, _       = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	pmdMaxInt64         int64 = 9223372036854775807
)

const (
	pmdFirstBatchCount    = 32
	pmdFinalProposalCount = 128
)

// pmdDescription returns a deterministic description at the requested bounded
// scale. The payload itself is part of the real proposal transaction, while
// funding, approvals, and configuration are deliberately outside measurements.
func pmdDescription(repetitions int) string {
	chunk := "GnoSwap governance proposal metadata benchmark payload."
	description := ""
	for i := 0; i < repetitions; i++ {
		description += chunk
	}
	return description
}

func main(cur realm) {
	description4KiB := pmdDescription(80)
	description8KiB := pmdDescription(160)
	if len(description4KiB) < 4096 || len(description8KiB) < 4096 {
		panic("proposal metadata descriptions must be at least 4KiB")
	}

	pmdInitializeSetup(cur)

	// A text proposal becomes inactive after the voting period. Each lifecycle
	// stage therefore creates, votes, and advances the height before the next
	// proposal, growing the real proposal and per-user trees without mocks.
	pmdMeasureTextLifecycle(
		cur,
		1,
		pmdFirstBatchCount,
		description4KiB,
		"Proposal metadata lifecycle text (4KiB, 32 proposals)",
	)
	pmdAssertProposalBatch(pmdFirstBatchCount, description4KiB)

	pmdMeasureTextLifecycle(
		cur,
		int64(pmdFirstBatchCount+1),
		pmdFinalProposalCount-pmdFirstBatchCount,
		description4KiB,
		ufmt.Sprintf(
			"Proposal metadata lifecycle text (4KiB, %d proposals, total %d)",
			pmdFinalProposalCount-pmdFirstBatchCount,
			pmdFinalProposalCount,
		),
	)
	pmdAssertProposalBatch(pmdFinalProposalCount, description4KiB)

	// Keep root Proposal cloning, nested metadata getters, and child/list
	// traversals in separate stages so representation changes are attributable.
	pmdMeasureRootReads(cur, pmdFinalProposalCount)
	pmdMeasureNestedMetadataReads(cur, pmdFinalProposalCount)
	pmdMeasureListReads(cur, pmdFinalProposalCount)

	// Repeat one real proposal with a larger metadata payload after the large
	// tree exists to expose description-size scaling independently of count.
	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata create text (8KiB, total 129)", func() {
		governance.ProposeText(cross(cur), "Metadata 8KiB", description8KiB)
	})
	text8KiBID := governance.GetCurrentProposalID()
	if text8KiBID != int64(pmdFinalProposalCount+1) {
		panic("8KiB proposal counter did not follow the large lifecycle")
	}
	pmdAssertProposalState(text8KiBID, governance.Text, "active", "Metadata 8KiB", description8KiB, false, false, 0)

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata root Proposal read (8KiB)", func() {
		proposals := governance.GetProposals()
		wholeRaw := proposals.Get(ufmt.Sprintf("%d", text8KiBID))
		whole, ok := wholeRaw.(*governance.Proposal)
		if !ok || whole == nil || whole.ID() != text8KiBID {
			panic("8KiB root Proposal getter returned an unexpected record")
		}
	})

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata nested metadata reads (8KiB)", func() {
		title, titleErr := governance.GetTitleByProposalId(text8KiBID)
		description, descriptionErr := governance.GetDescriptionByProposalId(text8KiBID)
		if titleErr != nil || descriptionErr != nil || title != "Metadata 8KiB" || description != description8KiB {
			panic("8KiB nested metadata getter mismatch")
		}
	})

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata vote text (8KiB)", func() {
		governance.Vote(cross(cur), text8KiBID, true)
	})
	testing.SkipHeights(2)
	pmdAssertProposalState(text8KiBID, governance.Text, "passed", "Metadata 8KiB", description8KiB, false, false, 1)

	// Add a start delay only for this proposal so Cancel exercises its real
	// upcoming-state path. Reconfigure is setup, not target-interval work.
	testing.SetRealm(pmdAdminRealm)
	governance.Reconfigure(cross(cur), 10, 1, 0, 50, 0, 0, 2592000)

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata create spend (8KiB)", func() {
		governance.ProposeCommunityPoolSpend(
			cross(cur),
			"Metadata spend",
			description8KiB,
			pmdAdminAddr,
			"gno.land/r/gnoswap/gns.GNS",
			100,
		)
	})
	spendID := governance.GetCurrentProposalID()
	pmdAssertProposalState(spendID, governance.CommunityPoolSpend, "upcoming", "Metadata spend", description8KiB, true, true, 0)

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata cancel spend", func() {
		governance.Cancel(cross(cur), spendID)
	})
	pmdAssertProposalState(spendID, governance.CommunityPoolSpend, "canceled", "Metadata spend", description8KiB, true, true, 0)

	// Restore an immediate voting start for an executable parameter proposal.
	testing.SetRealm(pmdAdminRealm)
	governance.Reconfigure(cross(cur), 0, 1, 0, 50, 0, 0, 2592000)

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata create parameter change (4KiB)", func() {
		governance.ProposeParameterChange(
			cross(cur),
			"Metadata parameter",
			description4KiB,
			1,
			"gno.land/r/gnoswap/pool*EXE*SetPoolCreationFee*EXE*0",
		)
	})
	parameterID := governance.GetCurrentProposalID()
	pmdAssertProposalState(parameterID, governance.ParameterChange, "active", "Metadata parameter", description4KiB, false, true, 0)

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata vote parameter change", func() {
		governance.Vote(cross(cur), parameterID, true)
	})
	pmdAssertProposalState(parameterID, governance.ParameterChange, "active", "Metadata parameter", description4KiB, false, true, 1)
	testing.SkipHeights(2)
	pmdAssertProposalState(parameterID, governance.ParameterChange, "executable", "Metadata parameter", description4KiB, false, true, 1)

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata execute parameter change", func() {
		governance.Execute(cross(cur), parameterID)
	})
	pmdAssertProposalState(parameterID, governance.ParameterChange, "executed", "Metadata parameter", description4KiB, false, true, 1)
}

func pmdInitializeSetup(cur realm) {
	testing.SetRealm(pmdAdminRealm)

	// Keep proposal creation and voting deterministic while retaining the real
	// governance path and xGNS delegation snapshot.
	governance.Reconfigure(cross(cur), 0, 1, 0, 50, 0, 0, 2592000)
	gns.Approve(cross(cur), pmdGovStakerAddr, pmdMaxInt64)
	govstaker.Delegate(cross(cur), pmdAdminAddr, int64(1000000000), "")
	testing.SkipHeights(5)
}

func pmdTextTitle(proposalID int64) string {
	return ufmt.Sprintf("Metadata text %d", proposalID)
}

func pmdMeasureTextLifecycle(
	cur realm,
	startProposalID int64,
	proposalCount int,
	description string,
	label string,
) {
	for i := 0; i < proposalCount; i++ {
		expectedID := startProposalID + int64(i)
		title := pmdTextTitle(expectedID)
		var proposalID int64
		testing.SetRealm(pmdAdminRealm)
		metric.PrintMetricsBy(ufmt.Sprintf("%s create %03d", label, expectedID), func() {
			proposalID = governance.ProposeText(cross(cur), title, description)
		})
		if proposalID != expectedID {
			panic("proposal lifecycle counter diverged")
		}
		testing.SetRealm(pmdAdminRealm)
		metric.PrintMetricsBy(ufmt.Sprintf("%s vote %03d", label, expectedID), func() {
			governance.Vote(cross(cur), proposalID, true)
		})
		testing.SkipHeights(2)
	}
}

func pmdMeasureRootReads(cur realm, proposalCount int) {
	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy(
		ufmt.Sprintf("Proposal metadata root Proposal reads (%d proposals)", proposalCount),
		func() {
			proposals := governance.GetProposals()
			if proposals == nil {
				panic("proposal root getter returned nil")
			}
			for i := 1; i <= proposalCount; i++ {
				wholeRaw := proposals.Get(ufmt.Sprintf("%d", i))
				whole, ok := wholeRaw.(*governance.Proposal)
				if !ok || whole == nil || whole.ID() != int64(i) {
					panic("proposal root getter returned an unexpected record")
				}
			}
		},
	)
}

func pmdMeasureNestedMetadataReads(cur realm, proposalCount int) {
	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy(
		ufmt.Sprintf("Proposal metadata nested metadata reads (%d proposals)", proposalCount),
		func() {
			for i := 1; i <= proposalCount; i++ {
				proposalID := int64(i)
				title, titleErr := governance.GetTitleByProposalId(proposalID)
				description, descriptionErr := governance.GetDescriptionByProposalId(proposalID)
				if titleErr != nil || descriptionErr != nil || title == "" || len(description) < 4096 {
					panic("proposal nested metadata getter failed")
				}
			}
		},
	)
}

func pmdMeasureListReads(cur realm, proposalCount int) {
	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy(
		ufmt.Sprintf("Proposal metadata list and voting-info reads (%d proposals)", proposalCount),
		func() {
			proposals := governance.GetProposals()
			userProposals := governance.GetUserProposals()
			if proposals == nil || userProposals == nil {
				panic("proposal list getter returned nil")
			}
			if userProposals.Get(pmdAdminAddr.String()) == nil {
				panic("proposal user-list getter returned no admin entry")
			}
			for i := 0; i < proposalCount; i++ {
				key, value := proposals.GetByIndex(i)
				if key == "" || value == nil {
					panic("proposal list index getter returned an empty entry")
				}
				votingInfos := governance.GetVotingInfos(int64(i + 1))
				if votingInfos == nil || votingInfos.Size() != 1 {
					panic("proposal voting-info list getter returned an unexpected count")
				}
			}
		},
	)
}

func pmdAssertProposalBatch(proposalCount int, description string) {
	testing.SetRealm(pmdAdminRealm)

	proposals := governance.GetProposals()
	if proposals == nil || proposals.Size() != proposalCount {
		panic("proposal aggregate count invariant failed")
	}
	if governance.GetCurrentProposalID() != int64(proposalCount) {
		panic("proposal aggregate counter invariant failed")
	}

	passedCount := 0
	for i := 1; i <= proposalCount; i++ {
		status, err := governance.GetProposalStatusByProposalId(int64(i))
		if err != nil {
			panic("proposal aggregate status getter failed")
		}
		if status == "passed" {
			passedCount++
		}
	}
	if passedCount != proposalCount {
		panic("proposal aggregate status invariant failed")
	}

	first := int64(1)
	middle := int64((proposalCount + 1) / 2)
	last := int64(proposalCount)
	println(
		"STATE proposal-metadata",
		"aggregate",
		"proposalCount", proposalCount,
		"passedCount", passedCount,
		"first", first,
		"middle", middle,
		"last", last,
	)
	pmdAssertProposalState(first, governance.Text, "passed", pmdTextTitle(first), description, false, false, 1)
	pmdAssertProposalState(middle, governance.Text, "passed", pmdTextTitle(middle), description, false, false, 1)
	pmdAssertProposalState(last, governance.Text, "passed", pmdTextTitle(last), description, false, false, 1)
}

func pmdAssertProposalState(
	proposalID int64,
	expectedType governance.ProposalType,
	expectedStatus string,
	expectedTitle string,
	expectedDescription string,
	expectedSpend bool,
	expectedExecution bool,
	expectedVoteInfoCount int,
) {
	testing.SetRealm(pmdAdminRealm)

	if governance.GetCurrentProposalID() < proposalID {
		panic("proposal counter regressed")
	}

	proposer, err := governance.GetProposerByProposalId(proposalID)
	if err != nil || proposer != pmdAdminAddr {
		panic("proposal proposer authority invariant failed")
	}
	proposalType, err := governance.GetProposalTypeByProposalId(proposalID)
	if err != nil || proposalType != expectedType {
		panic("proposal type invariant failed")
	}
	createdAt, err := governance.GetProposalCreatedAt(proposalID)
	if err != nil || createdAt <= 0 {
		panic("proposal creation timestamp invariant failed")
	}
	createdHeight, err := governance.GetProposalCreatedHeight(proposalID)
	if err != nil || createdHeight <= 0 {
		panic("proposal creation height invariant failed")
	}
	configVersion, err := governance.GetConfigVersionByProposalId(proposalID)
	if err != nil || configVersion <= 0 {
		panic("proposal config-version invariant failed")
	}
	quorum, maxVotingWeight, yea, nay, err := governance.GetVoteStatus(proposalID)
	if err != nil || quorum < 0 || maxVotingWeight <= 0 || yea < 0 || nay < 0 {
		panic("proposal vote-accounting invariant failed")
	}
	if gotYea, gotErr := governance.GetYeaByProposalId(proposalID); gotErr != nil || gotYea != yea {
		panic("proposal yes tally getter mismatch")
	}
	if gotNay, gotErr := governance.GetNayByProposalId(proposalID); gotErr != nil || gotNay != nay {
		panic("proposal no tally getter mismatch")
	}

	title, err := governance.GetTitleByProposalId(proposalID)
	if err != nil || title != expectedTitle {
		panic("proposal title invariant failed")
	}
	description, err := governance.GetDescriptionByProposalId(proposalID)
	if err != nil || description != expectedDescription || len(description) < 4096 {
		panic("proposal description invariant failed")
	}
	status, err := governance.GetProposalStatusByProposalId(proposalID)
	if err != nil || status != expectedStatus {
		panic("proposal status invariant failed")
	}

	spend, spendErr := governance.GetProposalCommunityPoolSpendInfo(proposalID)
	actualSpend := spendErr == nil && spend != nil
	if actualSpend != expectedSpend {
		panic("proposal spend presence invariant failed")
	}
	spendTo := ""
	spendToken := ""
	spendAmount := int64(-1)
	if actualSpend {
		if spend.To() != pmdAdminAddr || spend.TokenPath() != "gno.land/r/gnoswap/gns.GNS" || spend.Amount() != 100 {
			panic("proposal spend fields invariant failed")
		}
		spendTo = spend.To().String()
		spendToken = spend.TokenPath()
		spendAmount = spend.Amount()
	} else if spendErr == nil {
		panic("absent proposal spend must return an error")
	}

	execution, executionErr := governance.GetProposalExecutionInfo(proposalID)
	actualExecution := executionErr == nil && execution != nil
	if actualExecution != expectedExecution {
		panic("proposal execution presence invariant failed")
	}
	executionNum := int64(-1)
	executionMessageCount := -1
	if actualExecution {
		if execution.Num() <= 0 || len(execution.Msgs()) != int(execution.Num()) {
			panic("proposal execution fields invariant failed")
		}
		executionNum = execution.Num()
		executionMessageCount = len(execution.Msgs())
	} else if executionErr == nil {
		panic("absent proposal execution must return an error")
	}

	proposals := governance.GetProposals()
	if proposals == nil || proposals.Size() < int(proposalID) {
		panic("proposal read-only tree invariant failed")
	}
	wholeRaw := proposals.Get(ufmt.Sprintf("%d", proposalID))
	whole, ok := wholeRaw.(*governance.Proposal)
	if !ok || whole == nil {
		panic("proposal whole getter returned an unexpected record")
	}
	if whole.ID() != proposalID || whole.Proposer() != pmdAdminAddr || !whole.IsProposer(pmdAdminAddr) {
		panic("proposal whole getter authority invariant failed")
	}
	if whole.Type() != expectedType || whole.Title() != expectedTitle || whole.Description() != expectedDescription {
		panic("proposal whole getter metadata invariant failed")
	}
	metadata := whole.Metadata()
	if metadata == nil || metadata.Title() != expectedTitle || metadata.Description() != expectedDescription {
		panic("proposal metadata pointer/inline invariant failed")
	}
	if whole.Status() == nil || whole.Data() == nil {
		panic("proposal status/data presence invariant failed")
	}
	if (whole.Data().CommunityPoolSpend() != nil) != expectedSpend || (whole.Data().Execution() != nil) != expectedExecution {
		panic("proposal optional data child invariant failed")
	}
	snapshotTime := whole.SnapshotTime()
	if snapshotTime < 0 {
		panic("proposal snapshot cursor invariant failed")
	}

	votingInfos := governance.GetVotingInfos(proposalID)
	if votingInfos == nil || votingInfos.Size() != expectedVoteInfoCount {
		panic("proposal voting-info count invariant failed")
	}
	userProposals := governance.GetUserProposals()
	if userProposals == nil {
		panic("proposal user-proposals getter returned nil")
	}

	println(
		"STATE proposal-metadata",
		proposalID,
		"currentProposalID", governance.GetCurrentProposalID(),
		"type", proposalType.String(),
		"status", status,
		"proposer", proposer.String(),
		"createdAt", createdAt,
		"createdHeight", createdHeight,
		"snapshotTime", snapshotTime,
		"configVersion", configVersion,
		"quorum", quorum,
		"maxVotingWeight", maxVotingWeight,
		"yea", yea,
		"nay", nay,
		"title", title,
		"descriptionLen", len(description),
		"metadataPresent", metadata != nil,
		"spendPresent", actualSpend,
		"spendTo", spendTo,
		"spendToken", spendToken,
		"spendAmount", spendAmount,
		"executionPresent", actualExecution,
		"executionNum", executionNum,
		"executionMessages", executionMessageCount,
		"votingInfos", votingInfos.Size(),
		"userProposalEntries", userProposals.Size(),
	)
}

// Output:
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 1
// - Gas Used: 1984925
// - Storage Diff: 22306
// - CPU Cycles: 1617111
// - Realm gno.land/r/gnoswap/gov/governance: 22306
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 1
// - Gas Used: 1220203
// - Storage Diff: 4452
// - CPU Cycles: 1024178
// - Realm gno.land/r/gnoswap/gov/governance: 4452
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 2
// - Gas Used: 2250103
// - Storage Diff: 12472
// - CPU Cycles: 2015113
// - Realm gno.land/r/gnoswap/gov/governance: 12472
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 2
// - Gas Used: 1205223
// - Storage Diff: 4414
// - CPU Cycles: 1040293
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 3
// - Gas Used: 2254268
// - Storage Diff: 12458
// - CPU Cycles: 2018336
// - Realm gno.land/r/gnoswap/gov/governance: 12458
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 3
// - Gas Used: 1206411
// - Storage Diff: 4414
// - CPU Cycles: 1040293
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 4
// - Gas Used: 2261656
// - Storage Diff: 12458
// - CPU Cycles: 2024782
// - Realm gno.land/r/gnoswap/gov/governance: 12458
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 4
// - Gas Used: 1207599
// - Storage Diff: 4414
// - CPU Cycles: 1040293
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 5
// - Gas Used: 2262598
// - Storage Diff: 12458
// - CPU Cycles: 2024782
// - Realm gno.land/r/gnoswap/gov/governance: 12458
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 5
// - Gas Used: 1224902
// - Storage Diff: 4414
// - CPU Cycles: 1056408
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 6
// - Gas Used: 2266763
// - Storage Diff: 12458
// - CPU Cycles: 2028005
// - Realm gno.land/r/gnoswap/gov/governance: 12458
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 6
// - Gas Used: 1226090
// - Storage Diff: 4414
// - CPU Cycles: 1056408
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 7
// - Gas Used: 2267705
// - Storage Diff: 12458
// - CPU Cycles: 2028005
// - Realm gno.land/r/gnoswap/gov/governance: 12458
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 7
// - Gas Used: 1227278
// - Storage Diff: 4414
// - CPU Cycles: 1056408
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 8
// - Gas Used: 2275093
// - Storage Diff: 12458
// - CPU Cycles: 2034451
// - Realm gno.land/r/gnoswap/gov/governance: 12458
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 8
// - Gas Used: 1228466
// - Storage Diff: 4414
// - CPU Cycles: 1056408
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 9
// - Gas Used: 2276035
// - Storage Diff: 12458
// - CPU Cycles: 2034451
// - Realm gno.land/r/gnoswap/gov/governance: 12458
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 9
// - Gas Used: 1229654
// - Storage Diff: 4414
// - CPU Cycles: 1056408
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 10
// - Gas Used: 2304874
// - Storage Diff: 12461
// - CPU Cycles: 2044719
// - Realm gno.land/r/gnoswap/gov/governance: 12461
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 10
// - Gas Used: 1247394
// - Storage Diff: 4414
// - CPU Cycles: 1072951
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 11
// - Gas Used: 2303082
// - Storage Diff: 12461
// - CPU Cycles: 2041978
// - Realm gno.land/r/gnoswap/gov/governance: 12461
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 11
// - Gas Used: 1233697
// - Storage Diff: 4414
// - CPU Cycles: 1058066
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 12
// - Gas Used: 2307009
// - Storage Diff: 12461
// - CPU Cycles: 2044957
// - Realm gno.land/r/gnoswap/gov/governance: 12461
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 12
// - Gas Used: 1251005
// - Storage Diff: 4414
// - CPU Cycles: 1074186
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 13
// - Gas Used: 2311181
// - Storage Diff: 12461
// - CPU Cycles: 2048181
// - Realm gno.land/r/gnoswap/gov/governance: 12461
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 13
// - Gas Used: 1250963
// - Storage Diff: 4414
// - CPU Cycles: 1072956
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 14
// - Gas Used: 2312375
// - Storage Diff: 12461
// - CPU Cycles: 2048427
// - Realm gno.land/r/gnoswap/gov/governance: 12461
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 14
// - Gas Used: 1253381
// - Storage Diff: 4414
// - CPU Cycles: 1074186
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 15
// - Gas Used: 2313569
// - Storage Diff: 12461
// - CPU Cycles: 2048673
// - Realm gno.land/r/gnoswap/gov/governance: 12461
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 15
// - Gas Used: 1254569
// - Storage Diff: 4414
// - CPU Cycles: 1074186
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 16
// - Gas Used: 2315009
// - Storage Diff: 12461
// - CPU Cycles: 2049165
// - Realm gno.land/r/gnoswap/gov/governance: 12461
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 16
// - Gas Used: 1255757
// - Storage Diff: 4414
// - CPU Cycles: 1074186
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 17
// - Gas Used: 2601669
// - Storage Diff: 25539
// - CPU Cycles: 2269735
// - Realm gno.land/r/gnoswap/gov/governance: 25539
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 17
// - Gas Used: 1337529
// - Storage Diff: 4486
// - CPU Cycles: 1143872
// - Realm gno.land/r/gnoswap/gov/governance: 4486
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 18
// - Gas Used: 2376112
// - Storage Diff: 12485
// - CPU Cycles: 2097485
// - Realm gno.land/r/gnoswap/gov/governance: 12485
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 18
// - Gas Used: 1339947
// - Storage Diff: 4414
// - CPU Cycles: 1145102
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 19
// - Gas Used: 2371350
// - Storage Diff: 12461
// - CPU Cycles: 2091775
// - Realm gno.land/r/gnoswap/gov/governance: 12461
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 19
// - Gas Used: 1326245
// - Storage Diff: 4414
// - CPU Cycles: 1130212
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 20
// - Gas Used: 2373404
// - Storage Diff: 12461
// - CPU Cycles: 2095083
// - Realm gno.land/r/gnoswap/gov/governance: 12461
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 20
// - Gas Used: 1342447
// - Storage Diff: 4457
// - CPU Cycles: 1145097
// - Realm gno.land/r/gnoswap/gov/governance: 4457
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 21
// - Gas Used: 2377527
// - Storage Diff: 12527
// - CPU Cycles: 2098060
// - Realm gno.land/r/gnoswap/gov/governance: 12527
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 21
// - Gas Used: 1344964
// - Storage Diff: 4435
// - CPU Cycles: 1146327
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 22
// - Gas Used: 2372771
// - Storage Diff: 12510
// - CPU Cycles: 2092350
// - Realm gno.land/r/gnoswap/gov/governance: 12510
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 22
// - Gas Used: 1346161
// - Storage Diff: 4435
// - CPU Cycles: 1146327
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 23
// - Gas Used: 2380173
// - Storage Diff: 12510
// - CPU Cycles: 2098798
// - Realm gno.land/r/gnoswap/gov/governance: 12510
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 23
// - Gas Used: 1348588
// - Storage Diff: 4435
// - CPU Cycles: 1147557
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 24
// - Gas Used: 2380391
// - Storage Diff: 12510
// - CPU Cycles: 2098062
// - Realm gno.land/r/gnoswap/gov/governance: 12510
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 24
// - Gas Used: 1349790
// - Storage Diff: 4435
// - CPU Cycles: 1147562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 25
// - Gas Used: 2681861
// - Storage Diff: 19138
// - CPU Cycles: 2348889
// - Realm gno.land/r/gnoswap/gov/governance: 19138
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 25
// - Gas Used: 1340940
// - Storage Diff: 4471
// - CPU Cycles: 1145102
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 26
// - Gas Used: 2369564
// - Storage Diff: 12524
// - CPU Cycles: 2091615
// - Realm gno.land/r/gnoswap/gov/governance: 12524
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 26
// - Gas Used: 1327247
// - Storage Diff: 4435
// - CPU Cycles: 1130212
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 27
// - Gas Used: 2373496
// - Storage Diff: 12512
// - CPU Cycles: 2094593
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 27
// - Gas Used: 1343334
// - Storage Diff: 4435
// - CPU Cycles: 1145102
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 28
// - Gas Used: 2377920
// - Storage Diff: 12512
// - CPU Cycles: 2098063
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 28
// - Gas Used: 1344531
// - Storage Diff: 4435
// - CPU Cycles: 1145102
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 29
// - Gas Used: 2378874
// - Storage Diff: 12512
// - CPU Cycles: 2098063
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 29
// - Gas Used: 1346958
// - Storage Diff: 4435
// - CPU Cycles: 1146332
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 30
// - Gas Used: 2377218
// - Storage Diff: 12512
// - CPU Cycles: 2097655
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 30
// - Gas Used: 1349380
// - Storage Diff: 4435
// - CPU Cycles: 1147557
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 31
// - Gas Used: 2378419
// - Storage Diff: 12512
// - CPU Cycles: 2097902
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 31
// - Gas Used: 1348122
// - Storage Diff: 4435
// - CPU Cycles: 1145102
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 32
// - Gas Used: 2379374
// - Storage Diff: 12512
// - CPU Cycles: 2097903
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 32
// - Gas Used: 1349319
// - Storage Diff: 4435
// - CPU Cycles: 1145102
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// STATE proposal-metadata aggregate proposalCount 32 passedCount 32 first 1 middle 16 last 32
// STATE proposal-metadata 1 currentProposalID 32 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234567915 createdHeight 128 snapshotTime 1234567915 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 1 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 16 currentProposalID 32 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234568065 createdHeight 158 snapshotTime 1234568065 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 16 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 32 currentProposalID 32 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234568225 createdHeight 190 snapshotTime 1234568225 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 32 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 33
// - Gas Used: 2683276
// - Storage Diff: 19118
// - CPU Cycles: 2348729
// - Realm gno.land/r/gnoswap/gov/governance: 19118
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 33
// - Gas Used: 1344037
// - Storage Diff: 4471
// - CPU Cycles: 1146327
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 34
// - Gas Used: 2375147
// - Storage Diff: 12524
// - CPU Cycles: 2098146
// - Realm gno.land/r/gnoswap/gov/governance: 12524
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 34
// - Gas Used: 1360124
// - Storage Diff: 4435
// - CPU Cycles: 1161217
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 35
// - Gas Used: 2385527
// - Storage Diff: 12512
// - CPU Cycles: 2107572
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 35
// - Gas Used: 1362551
// - Storage Diff: 4435
// - CPU Cycles: 1162447
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 36
// - Gas Used: 2380771
// - Storage Diff: 12512
// - CPU Cycles: 2101862
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 36
// - Gas Used: 1363748
// - Storage Diff: 4435
// - CPU Cycles: 1162447
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 37
// - Gas Used: 2381725
// - Storage Diff: 12512
// - CPU Cycles: 2101862
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 37
// - Gas Used: 1350055
// - Storage Diff: 4435
// - CPU Cycles: 1147557
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 38
// - Gas Used: 2385165
// - Storage Diff: 12512
// - CPU Cycles: 2104348
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 38
// - Gas Used: 1367372
// - Storage Diff: 4435
// - CPU Cycles: 1163677
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 39
// - Gas Used: 2389343
// - Storage Diff: 12512
// - CPU Cycles: 2107572
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 39
// - Gas Used: 1366109
// - Storage Diff: 4435
// - CPU Cycles: 1161217
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 40
// - Gas Used: 2387933
// - Storage Diff: 12512
// - CPU Cycles: 2107410
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 40
// - Gas Used: 1368531
// - Storage Diff: 4435
// - CPU Cycles: 1162442
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 41
// - Gas Used: 2694464
// - Storage Diff: 19118
// - CPU Cycles: 2358483
// - Realm gno.land/r/gnoswap/gov/governance: 19118
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 41
// - Gas Used: 1345900
// - Storage Diff: 4471
// - CPU Cycles: 1146327
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 42
// - Gas Used: 2374519
// - Storage Diff: 12524
// - CPU Cycles: 2098478
// - Realm gno.land/r/gnoswap/gov/governance: 12524
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 42
// - Gas Used: 1363217
// - Storage Diff: 4435
// - CPU Cycles: 1162447
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 43
// - Gas Used: 2378697
// - Storage Diff: 12512
// - CPU Cycles: 2101702
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 43
// - Gas Used: 1349524
// - Storage Diff: 4435
// - CPU Cycles: 1147557
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 44
// - Gas Used: 2382137
// - Storage Diff: 12512
// - CPU Cycles: 2104188
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 44
// - Gas Used: 1350721
// - Storage Diff: 4435
// - CPU Cycles: 1147557
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 45
// - Gas Used: 2383091
// - Storage Diff: 12512
// - CPU Cycles: 2104188
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 45
// - Gas Used: 1365578
// - Storage Diff: 4435
// - CPU Cycles: 1161217
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 46
// - Gas Used: 2387269
// - Storage Diff: 12512
// - CPU Cycles: 2107412
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 46
// - Gas Used: 1366775
// - Storage Diff: 4435
// - CPU Cycles: 1161217
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 47
// - Gas Used: 2388223
// - Storage Diff: 12512
// - CPU Cycles: 2107412
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 47
// - Gas Used: 1369202
// - Storage Diff: 4435
// - CPU Cycles: 1162447
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 48
// - Gas Used: 2389423
// - Storage Diff: 12512
// - CPU Cycles: 2107658
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 48
// - Gas Used: 1370399
// - Storage Diff: 4435
// - CPU Cycles: 1162447
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 49
// - Gas Used: 2695863
// - Storage Diff: 19118
// - CPU Cycles: 2358484
// - Realm gno.land/r/gnoswap/gov/governance: 19118
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 49
// - Gas Used: 1347772
// - Storage Diff: 4471
// - CPU Cycles: 1146327
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 50
// - Gas Used: 2378873
// - Storage Diff: 12524
// - CPU Cycles: 2103780
// - Realm gno.land/r/gnoswap/gov/governance: 12524
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 50
// - Gas Used: 1350194
// - Storage Diff: 4435
// - CPU Cycles: 1147552
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 51
// - Gas Used: 2380074
// - Storage Diff: 12512
// - CPU Cycles: 2104027
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 51
// - Gas Used: 1365056
// - Storage Diff: 4435
// - CPU Cycles: 1161217
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 52
// - Gas Used: 2384253
// - Storage Diff: 12512
// - CPU Cycles: 2107252
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 52
// - Gas Used: 1366253
// - Storage Diff: 4435
// - CPU Cycles: 1161217
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 53
// - Gas Used: 2385207
// - Storage Diff: 12512
// - CPU Cycles: 2107252
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 53
// - Gas Used: 1368680
// - Storage Diff: 4435
// - CPU Cycles: 1162447
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 54
// - Gas Used: 2386407
// - Storage Diff: 12512
// - CPU Cycles: 2107498
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 54
// - Gas Used: 1369877
// - Storage Diff: 4435
// - CPU Cycles: 1162447
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 55
// - Gas Used: 2387361
// - Storage Diff: 12512
// - CPU Cycles: 2107498
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 55
// - Gas Used: 1371074
// - Storage Diff: 4435
// - CPU Cycles: 1162447
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 56
// - Gas Used: 2388807
// - Storage Diff: 12512
// - CPU Cycles: 2107990
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 56
// - Gas Used: 1372271
// - Storage Diff: 4435
// - CPU Cycles: 1162447
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 57
// - Gas Used: 2697623
// - Storage Diff: 19118
// - CPU Cycles: 2358816
// - Realm gno.land/r/gnoswap/gov/governance: 19118
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 57
// - Gas Used: 1350874
// - Storage Diff: 4471
// - CPU Cycles: 1147557
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 58
// - Gas Used: 2380375
// - Storage Diff: 12524
// - CPU Cycles: 2104028
// - Realm gno.land/r/gnoswap/gov/governance: 12524
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 58
// - Gas Used: 1352071
// - Storage Diff: 4435
// - CPU Cycles: 1147557
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 59
// - Gas Used: 2381329
// - Storage Diff: 12512
// - CPU Cycles: 2104028
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 59
// - Gas Used: 1366928
// - Storage Diff: 4435
// - CPU Cycles: 1161217
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 60
// - Gas Used: 2377187
// - Storage Diff: 12512
// - CPU Cycles: 2101134
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 60
// - Gas Used: 1369350
// - Storage Diff: 4435
// - CPU Cycles: 1162442
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 61
// - Gas Used: 2378388
// - Storage Diff: 12512
// - CPU Cycles: 2101381
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 61
// - Gas Used: 1370552
// - Storage Diff: 4435
// - CPU Cycles: 1162447
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 62
// - Gas Used: 2385791
// - Storage Diff: 12512
// - CPU Cycles: 2107830
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 62
// - Gas Used: 1371744
// - Storage Diff: 4435
// - CPU Cycles: 1162442
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 63
// - Gas Used: 2386742
// - Storage Diff: 12512
// - CPU Cycles: 2107827
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 63
// - Gas Used: 1374171
// - Storage Diff: 4435
// - CPU Cycles: 1163672
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 64
// - Gas Used: 2387450
// - Storage Diff: 12512
// - CPU Cycles: 2107581
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 64
// - Gas Used: 1375373
// - Storage Diff: 4435
// - CPU Cycles: 1163677
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 65
// - Gas Used: 2698645
// - Storage Diff: 19118
// - CPU Cycles: 2358410
// - Realm gno.land/r/gnoswap/gov/governance: 19118
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 65
// - Gas Used: 1382521
// - Storage Diff: 4471
// - CPU Cycles: 1177332
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 66
// - Gas Used: 2392160
// - Storage Diff: 12524
// - CPU Cycles: 2116761
// - Realm gno.land/r/gnoswap/gov/governance: 12524
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 66
// - Gas Used: 1383718
// - Storage Diff: 4435
// - CPU Cycles: 1177332
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 67
// - Gas Used: 2393114
// - Storage Diff: 12512
// - CPU Cycles: 2116761
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 67
// - Gas Used: 1386145
// - Storage Diff: 4435
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 68
// - Gas Used: 2388358
// - Storage Diff: 12512
// - CPU Cycles: 2111051
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 68
// - Gas Used: 1387342
// - Storage Diff: 4435
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 69
// - Gas Used: 2389312
// - Storage Diff: 12512
// - CPU Cycles: 2111051
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 69
// - Gas Used: 1388539
// - Storage Diff: 4435
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 70
// - Gas Used: 2393858
// - Storage Diff: 12512
// - CPU Cycles: 2116845
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 70
// - Gas Used: 1390961
// - Storage Diff: 4435
// - CPU Cycles: 1179787
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 71
// - Gas Used: 2395059
// - Storage Diff: 12512
// - CPU Cycles: 2117092
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 71
// - Gas Used: 1390933
// - Storage Diff: 4435
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 72
// - Gas Used: 2396260
// - Storage Diff: 12512
// - CPU Cycles: 2117339
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 72
// - Gas Used: 1392130
// - Storage Diff: 4435
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 73
// - Gas Used: 2709828
// - Storage Diff: 19118
// - CPU Cycles: 2368165
// - Realm gno.land/r/gnoswap/gov/governance: 19118
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 73
// - Gas Used: 1385614
// - Storage Diff: 4471
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 74
// - Gas Used: 2385330
// - Storage Diff: 12524
// - CPU Cycles: 2110891
// - Realm gno.land/r/gnoswap/gov/governance: 12524
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 74
// - Gas Used: 1386811
// - Storage Diff: 4435
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 75
// - Gas Used: 2386284
// - Storage Diff: 12512
// - CPU Cycles: 2110891
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 75
// - Gas Used: 1373118
// - Storage Diff: 4435
// - CPU Cycles: 1163672
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 76
// - Gas Used: 2390216
// - Storage Diff: 12512
// - CPU Cycles: 2113869
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 76
// - Gas Used: 1374315
// - Storage Diff: 4435
// - CPU Cycles: 1163672
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 77
// - Gas Used: 2391170
// - Storage Diff: 12512
// - CPU Cycles: 2113869
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 77
// - Gas Used: 1391632
// - Storage Diff: 4435
// - CPU Cycles: 1179792
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 78
// - Gas Used: 2395348
// - Storage Diff: 12512
// - CPU Cycles: 2117093
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 78
// - Gas Used: 1392829
// - Storage Diff: 4435
// - CPU Cycles: 1179792
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 79
// - Gas Used: 2396302
// - Storage Diff: 12512
// - CPU Cycles: 2117093
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 79
// - Gas Used: 1392796
// - Storage Diff: 4435
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 80
// - Gas Used: 2395138
// - Storage Diff: 12512
// - CPU Cycles: 2117177
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 80
// - Gas Used: 1395218
// - Storage Diff: 4435
// - CPU Cycles: 1179787
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 81
// - Gas Used: 2711311
// - Storage Diff: 19118
// - CPU Cycles: 2368250
// - Realm gno.land/r/gnoswap/gov/governance: 19118
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 81
// - Gas Used: 1372596
// - Storage Diff: 4471
// - CPU Cycles: 1163672
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 82
// - Gas Used: 2381244
// - Storage Diff: 12524
// - CPU Cycles: 2107753
// - Realm gno.land/r/gnoswap/gov/governance: 12524
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 82
// - Gas Used: 1373788
// - Storage Diff: 4435
// - CPU Cycles: 1163667
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 83
// - Gas Used: 2382195
// - Storage Diff: 12512
// - CPU Cycles: 2107750
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 83
// - Gas Used: 1389875
// - Storage Diff: 4435
// - CPU Cycles: 1178557
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 84
// - Gas Used: 2392575
// - Storage Diff: 12512
// - CPU Cycles: 2117176
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 84
// - Gas Used: 1391077
// - Storage Diff: 4435
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 85
// - Gas Used: 2393532
// - Storage Diff: 12512
// - CPU Cycles: 2117179
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 85
// - Gas Used: 1392274
// - Storage Diff: 4435
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 86
// - Gas Used: 2394486
// - Storage Diff: 12512
// - CPU Cycles: 2117179
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 86
// - Gas Used: 1393471
// - Storage Diff: 4435
// - CPU Cycles: 1178562
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 87
// - Gas Used: 2395440
// - Storage Diff: 12512
// - CPU Cycles: 2117179
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 87
// - Gas Used: 1395898
// - Storage Diff: 4435
// - CPU Cycles: 1179792
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 88
// - Gas Used: 2396640
// - Storage Diff: 12512
// - CPU Cycles: 2117425
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 88
// - Gas Used: 1397095
// - Storage Diff: 4435
// - CPU Cycles: 1179792
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 89
// - Gas Used: 2712740
// - Storage Diff: 19118
// - CPU Cycles: 2368251
// - Realm gno.land/r/gnoswap/gov/governance: 19118
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 89
// - Gas Used: 1374468
// - Storage Diff: 4471
// - CPU Cycles: 1163672
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 90
// - Gas Used: 2378048
// - Storage Diff: 12524
// - CPU Cycles: 2105505
// - Realm gno.land/r/gnoswap/gov/governance: 12524
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 90
// - Gas Used: 1375660
// - Storage Diff: 4435
// - CPU Cycles: 1163667
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 91
// - Gas Used: 2379001
// - Storage Diff: 12512
// - CPU Cycles: 2105504
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 91
// - Gas Used: 1392977
// - Storage Diff: 4435
// - CPU Cycles: 1179787
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 92
// - Gas Used: 2383179
// - Storage Diff: 12512
// - CPU Cycles: 2108728
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 92
// - Gas Used: 1394179
// - Storage Diff: 4435
// - CPU Cycles: 1179792
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 93
// - Gas Used: 2384136
// - Storage Diff: 12512
// - CPU Cycles: 2108731
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 93
// - Gas Used: 1395376
// - Storage Diff: 4435
// - CPU Cycles: 1179792
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 94
// - Gas Used: 2385090
// - Storage Diff: 12512
// - CPU Cycles: 2108731
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 94
// - Gas Used: 1396573
// - Storage Diff: 4435
// - CPU Cycles: 1179792
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 95
// - Gas Used: 2386044
// - Storage Diff: 12512
// - CPU Cycles: 2108731
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 95
// - Gas Used: 1397770
// - Storage Diff: 4435
// - CPU Cycles: 1179792
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 96
// - Gas Used: 2393446
// - Storage Diff: 12512
// - CPU Cycles: 2115179
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 96
// - Gas Used: 1398962
// - Storage Diff: 4435
// - CPU Cycles: 1179787
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 97
// - Gas Used: 2640103
// - Storage Diff: 18838
// - CPU Cycles: 2295026
// - Realm gno.land/r/gnoswap/gov/governance: 18838
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 97
// - Gas Used: 1351841
// - Storage Diff: 4471
// - CPU Cycles: 1147552
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 98
// - Gas Used: 2356506
// - Storage Diff: 12524
// - CPU Cycles: 2089387
// - Realm gno.land/r/gnoswap/gov/governance: 12524
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 98
// - Gas Used: 1353038
// - Storage Diff: 4435
// - CPU Cycles: 1147552
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 99
// - Gas Used: 2363908
// - Storage Diff: 12512
// - CPU Cycles: 2095835
// - Realm gno.land/r/gnoswap/gov/governance: 12512
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 99
// - Gas Used: 1354235
// - Storage Diff: 4435
// - CPU Cycles: 1147552
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 100
// - Gas Used: 2455808
// - Storage Diff: 12497
// - CPU Cycles: 2167050
// - Realm gno.land/r/gnoswap/gov/governance: 12497
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 100
// - Gas Used: 1504720
// - Storage Diff: 4435
// - CPU Cycles: 1289118
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 101
// - Gas Used: 2481545
// - Storage Diff: 12473
// - CPU Cycles: 2191517
// - Realm gno.land/r/gnoswap/gov/governance: 12473
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 101
// - Gas Used: 1520817
// - Storage Diff: 4435
// - CPU Cycles: 1304018
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 102
// - Gas Used: 2491815
// - Storage Diff: 12473
// - CPU Cycles: 2200947
// - Realm gno.land/r/gnoswap/gov/governance: 12473
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 102
// - Gas Used: 1523244
// - Storage Diff: 4435
// - CPU Cycles: 1305248
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 103
// - Gas Used: 2486943
// - Storage Diff: 12473
// - CPU Cycles: 2195235
// - Realm gno.land/r/gnoswap/gov/governance: 12473
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 103
// - Gas Used: 1524441
// - Storage Diff: 4435
// - CPU Cycles: 1305248
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 104
// - Gas Used: 2487783
// - Storage Diff: 12473
// - CPU Cycles: 2195235
// - Realm gno.land/r/gnoswap/gov/governance: 12473
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 104
// - Gas Used: 1510743
// - Storage Diff: 4435
// - CPU Cycles: 1290353
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 105
// - Gas Used: 2491110
// - Storage Diff: 12473
// - CPU Cycles: 2197722
// - Realm gno.land/r/gnoswap/gov/governance: 12473
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 105
// - Gas Used: 1528065
// - Storage Diff: 4435
// - CPU Cycles: 1306478
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 106
// - Gas Used: 2495175
// - Storage Diff: 12473
// - CPU Cycles: 2200947
// - Realm gno.land/r/gnoswap/gov/governance: 12473
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 106
// - Gas Used: 1526802
// - Storage Diff: 4435
// - CPU Cycles: 1304018
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 107
// - Gas Used: 2496015
// - Storage Diff: 12473
// - CPU Cycles: 2200947
// - Realm gno.land/r/gnoswap/gov/governance: 12473
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 107
// - Gas Used: 1527999
// - Storage Diff: 4435
// - CPU Cycles: 1304018
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 108
// - Gas Used: 2804787
// - Storage Diff: 18935
// - CPU Cycles: 2451853
// - Realm gno.land/r/gnoswap/gov/governance: 18935
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 108
// - Gas Used: 1507413
// - Storage Diff: 4471
// - CPU Cycles: 1290353
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 109
// - Gas Used: 2482254
// - Storage Diff: 12527
// - CPU Cycles: 2192256
// - Realm gno.land/r/gnoswap/gov/governance: 12527
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 109
// - Gas Used: 1523505
// - Storage Diff: 4435
// - CPU Cycles: 1305248
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 110
// - Gas Used: 2484315
// - Storage Diff: 12515
// - CPU Cycles: 2195565
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 110
// - Gas Used: 1511032
// - Storage Diff: 4435
// - CPU Cycles: 1291578
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 111
// - Gas Used: 2488009
// - Storage Diff: 12515
// - CPU Cycles: 2198299
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 111
// - Gas Used: 1512234
// - Storage Diff: 4435
// - CPU Cycles: 1291583
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 112
// - Gas Used: 2488970
// - Storage Diff: 12515
// - CPU Cycles: 2198300
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 112
// - Gas Used: 1527096
// - Storage Diff: 4435
// - CPU Cycles: 1305248
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 113
// - Gas Used: 2493155
// - Storage Diff: 12515
// - CPU Cycles: 2201525
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 113
// - Gas Used: 1528293
// - Storage Diff: 4435
// - CPU Cycles: 1305248
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 114
// - Gas Used: 2494115
// - Storage Diff: 12515
// - CPU Cycles: 2201525
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 114
// - Gas Used: 1530720
// - Storage Diff: 4435
// - CPU Cycles: 1306478
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 115
// - Gas Used: 2495321
// - Storage Diff: 12515
// - CPU Cycles: 2201771
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 115
// - Gas Used: 1531917
// - Storage Diff: 4435
// - CPU Cycles: 1306478
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 116
// - Gas Used: 2828233
// - Storage Diff: 19123
// - CPU Cycles: 2455237
// - Realm gno.land/r/gnoswap/gov/governance: 19123
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 116
// - Gas Used: 1509285
// - Storage Diff: 4471
// - CPU Cycles: 1290353
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 117
// - Gas Used: 2481632
// - Storage Diff: 12527
// - CPU Cycles: 2192588
// - Realm gno.land/r/gnoswap/gov/governance: 12527
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 117
// - Gas Used: 1526607
// - Storage Diff: 4435
// - CPU Cycles: 1306478
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 118
// - Gas Used: 2485817
// - Storage Diff: 12515
// - CPU Cycles: 2195813
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 118
// - Gas Used: 1512909
// - Storage Diff: 4435
// - CPU Cycles: 1291583
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 119
// - Gas Used: 2489264
// - Storage Diff: 12515
// - CPU Cycles: 2198300
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 119
// - Gas Used: 1514106
// - Storage Diff: 4435
// - CPU Cycles: 1291583
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 120
// - Gas Used: 2488346
// - Storage Diff: 12515
// - CPU Cycles: 2198630
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 120
// - Gas Used: 1530193
// - Storage Diff: 4435
// - CPU Cycles: 1306473
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 121
// - Gas Used: 2492286
// - Storage Diff: 12515
// - CPU Cycles: 2201610
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 121
// - Gas Used: 1531390
// - Storage Diff: 4435
// - CPU Cycles: 1306473
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 122
// - Gas Used: 2493244
// - Storage Diff: 12515
// - CPU Cycles: 2201608
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 122
// - Gas Used: 1532587
// - Storage Diff: 4435
// - CPU Cycles: 1306473
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 123
// - Gas Used: 2494696
// - Storage Diff: 12515
// - CPU Cycles: 2202100
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 123
// - Gas Used: 1533789
// - Storage Diff: 4435
// - CPU Cycles: 1306478
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 124
// - Gas Used: 2829993
// - Storage Diff: 19123
// - CPU Cycles: 2455569
// - Realm gno.land/r/gnoswap/gov/governance: 19123
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 124
// - Gas Used: 1513617
// - Storage Diff: 4471
// - CPU Cycles: 1292813
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 125
// - Gas Used: 2486968
// - Storage Diff: 12527
// - CPU Cycles: 2198878
// - Realm gno.land/r/gnoswap/gov/governance: 12527
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 125
// - Gas Used: 1514814
// - Storage Diff: 4435
// - CPU Cycles: 1292813
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 126
// - Gas Used: 2487928
// - Storage Diff: 12515
// - CPU Cycles: 2198878
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 126
// - Gas Used: 1529676
// - Storage Diff: 4435
// - CPU Cycles: 1306478
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 127
// - Gas Used: 2492113
// - Storage Diff: 12515
// - CPU Cycles: 2202103
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 127
// - Gas Used: 1530873
// - Storage Diff: 4435
// - CPU Cycles: 1306478
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 128
// - Gas Used: 2493073
// - Storage Diff: 12515
// - CPU Cycles: 2202103
// - Realm gno.land/r/gnoswap/gov/governance: 12515
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 128
// - Gas Used: 1533300
// - Storage Diff: 4435
// - CPU Cycles: 1307708
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// STATE proposal-metadata aggregate proposalCount 128 passedCount 128 first 1 middle 64 last 128
// STATE proposal-metadata 1 currentProposalID 128 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234567915 createdHeight 128 snapshotTime 1234567915 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 1 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 64 currentProposalID 128 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234568545 createdHeight 254 snapshotTime 1234568545 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 64 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 128 currentProposalID 128 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569185 createdHeight 382 snapshotTime 1234569185 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 128 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// Proposal metadata root Proposal reads (128 proposals)
// - Gas Used: 21415707
// - Storage Diff: 0
// - CPU Cycles: 20315013
// Proposal metadata nested metadata reads (128 proposals)
// - Gas Used: 35234443
// - Storage Diff: 0
// - CPU Cycles: 33227562
// Proposal metadata list and voting-info reads (128 proposals)
// - Gas Used: 22893166
// - Storage Diff: 0
// - CPU Cycles: 21608180
// Proposal metadata create text (8KiB, total 129)
// - Gas Used: 2508034
// - Storage Diff: 16911
// - CPU Cycles: 2202103
// - Realm gno.land/r/gnoswap/gov/governance: 16911
// STATE proposal-metadata 129 currentProposalID 129 type Text status active proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569195 createdHeight 384 snapshotTime 1234569195 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata 8KiB descriptionLen 8800 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 0 userProposalEntries 1
// Proposal metadata root Proposal read (8KiB)
// - Gas Used: 240271
// - Storage Diff: 0
// - CPU Cycles: 226583
// Proposal metadata nested metadata reads (8KiB)
// - Gas Used: 349466
// - Storage Diff: 0
// - CPU Cycles: 330067
// Proposal metadata vote text (8KiB)
// - Gas Used: 1547685
// - Storage Diff: 4435
// - CPU Cycles: 1307708
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// STATE proposal-metadata 129 currentProposalID 129 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569195 createdHeight 384 snapshotTime 1234569195 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata 8KiB descriptionLen 8800 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// Proposal metadata create spend (8KiB)
// - Gas Used: 3036678
// - Storage Diff: 19154
// - CPU Cycles: 2608065
// - Realm gno.land/r/gnoswap/gov/governance: 19154
// STATE proposal-metadata 130 currentProposalID 130 type CommunityPoolSpend status upcoming proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 3 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata spend descriptionLen 8800 metadataPresent true spendPresent true spendTo g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 spendToken gno.land/r/gnoswap/gns.GNS spendAmount 100 executionPresent true executionNum 1 executionMessages 1 votingInfos 0 userProposalEntries 1
// Proposal metadata cancel spend
// - Gas Used: 878750
// - Storage Diff: 70
// - CPU Cycles: 731405
// - Realm gno.land/r/gnoswap/gov/governance: 70
// STATE proposal-metadata 130 currentProposalID 130 type CommunityPoolSpend status canceled proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 3 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata spend descriptionLen 8800 metadataPresent true spendPresent true spendTo g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 spendToken gno.land/r/gnoswap/gns.GNS spendAmount 100 executionPresent true executionNum 1 executionMessages 1 votingInfos 0 userProposalEntries 1
// Proposal metadata create parameter change (4KiB)
// - Gas Used: 3540234
// - Storage Diff: 13742
// - CPU Cycles: 3159336
// - Realm gno.land/r/gnoswap/gov/governance: 13742
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status active proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 0 userProposalEntries 1
// Proposal metadata vote parameter change
// - Gas Used: 1568630
// - Storage Diff: 4435
// - CPU Cycles: 1334489
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status active proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status executable proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 1 userProposalEntries 1
// Proposal metadata execute parameter change
// - Gas Used: 2809336
// - Storage Diff: 64
// - CPU Cycles: 1669184
// - Realm gno.land/r/gnoswap/gov/governance: 64
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status executed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 1 userProposalEntries 1
