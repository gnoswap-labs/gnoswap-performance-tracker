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
// - Gas Used: 1987604
// - Storage Diff: 21926
// - CPU Cycles: 1619960
// - Realm gno.land/r/gnoswap/gov/governance: 21926
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 1
// - Gas Used: 1217685
// - Storage Diff: 4452
// - CPU Cycles: 1022106
// - Realm gno.land/r/gnoswap/gov/governance: 4452
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 2
// - Gas Used: 2254568
// - Storage Diff: 12092
// - CPU Cycles: 2019092
// - Realm gno.land/r/gnoswap/gov/governance: 12092
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 2
// - Gas Used: 1202705
// - Storage Diff: 4414
// - CPU Cycles: 1038221
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 3
// - Gas Used: 2258733
// - Storage Diff: 12078
// - CPU Cycles: 2022315
// - Realm gno.land/r/gnoswap/gov/governance: 12078
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 3
// - Gas Used: 1203893
// - Storage Diff: 4414
// - CPU Cycles: 1038221
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 4
// - Gas Used: 2266121
// - Storage Diff: 12078
// - CPU Cycles: 2028761
// - Realm gno.land/r/gnoswap/gov/governance: 12078
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 4
// - Gas Used: 1205081
// - Storage Diff: 4414
// - CPU Cycles: 1038221
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 5
// - Gas Used: 2267063
// - Storage Diff: 12078
// - CPU Cycles: 2028761
// - Realm gno.land/r/gnoswap/gov/governance: 12078
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 5
// - Gas Used: 1222384
// - Storage Diff: 4414
// - CPU Cycles: 1054336
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 6
// - Gas Used: 2271228
// - Storage Diff: 12078
// - CPU Cycles: 2031984
// - Realm gno.land/r/gnoswap/gov/governance: 12078
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 6
// - Gas Used: 1223572
// - Storage Diff: 4414
// - CPU Cycles: 1054336
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 7
// - Gas Used: 2272170
// - Storage Diff: 12078
// - CPU Cycles: 2031984
// - Realm gno.land/r/gnoswap/gov/governance: 12078
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 7
// - Gas Used: 1224760
// - Storage Diff: 4414
// - CPU Cycles: 1054336
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 8
// - Gas Used: 2279558
// - Storage Diff: 12078
// - CPU Cycles: 2038430
// - Realm gno.land/r/gnoswap/gov/governance: 12078
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 8
// - Gas Used: 1225948
// - Storage Diff: 4414
// - CPU Cycles: 1054336
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 9
// - Gas Used: 2280500
// - Storage Diff: 12078
// - CPU Cycles: 2038430
// - Realm gno.land/r/gnoswap/gov/governance: 12078
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 9
// - Gas Used: 1227136
// - Storage Diff: 4414
// - CPU Cycles: 1054336
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 10
// - Gas Used: 2309339
// - Storage Diff: 12081
// - CPU Cycles: 2048698
// - Realm gno.land/r/gnoswap/gov/governance: 12081
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 10
// - Gas Used: 1244876
// - Storage Diff: 4414
// - CPU Cycles: 1070879
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 11
// - Gas Used: 2307547
// - Storage Diff: 12081
// - CPU Cycles: 2045957
// - Realm gno.land/r/gnoswap/gov/governance: 12081
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 11
// - Gas Used: 1231179
// - Storage Diff: 4414
// - CPU Cycles: 1055994
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 12
// - Gas Used: 2311474
// - Storage Diff: 12081
// - CPU Cycles: 2048936
// - Realm gno.land/r/gnoswap/gov/governance: 12081
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 12
// - Gas Used: 1248487
// - Storage Diff: 4414
// - CPU Cycles: 1072114
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 13
// - Gas Used: 2315646
// - Storage Diff: 12081
// - CPU Cycles: 2052160
// - Realm gno.land/r/gnoswap/gov/governance: 12081
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 13
// - Gas Used: 1248445
// - Storage Diff: 4414
// - CPU Cycles: 1070884
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 14
// - Gas Used: 2316840
// - Storage Diff: 12081
// - CPU Cycles: 2052406
// - Realm gno.land/r/gnoswap/gov/governance: 12081
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 14
// - Gas Used: 1250863
// - Storage Diff: 4414
// - CPU Cycles: 1072114
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 15
// - Gas Used: 2318034
// - Storage Diff: 12081
// - CPU Cycles: 2052652
// - Realm gno.land/r/gnoswap/gov/governance: 12081
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 15
// - Gas Used: 1252051
// - Storage Diff: 4414
// - CPU Cycles: 1072114
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 16
// - Gas Used: 2319474
// - Storage Diff: 12081
// - CPU Cycles: 2053144
// - Realm gno.land/r/gnoswap/gov/governance: 12081
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 16
// - Gas Used: 1253239
// - Storage Diff: 4414
// - CPU Cycles: 1072114
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 17
// - Gas Used: 2606134
// - Storage Diff: 25159
// - CPU Cycles: 2273714
// - Realm gno.land/r/gnoswap/gov/governance: 25159
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 17
// - Gas Used: 1335011
// - Storage Diff: 4486
// - CPU Cycles: 1141800
// - Realm gno.land/r/gnoswap/gov/governance: 4486
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 18
// - Gas Used: 2380577
// - Storage Diff: 12105
// - CPU Cycles: 2101464
// - Realm gno.land/r/gnoswap/gov/governance: 12105
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 18
// - Gas Used: 1337429
// - Storage Diff: 4414
// - CPU Cycles: 1143030
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 19
// - Gas Used: 2375815
// - Storage Diff: 12081
// - CPU Cycles: 2095754
// - Realm gno.land/r/gnoswap/gov/governance: 12081
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 19
// - Gas Used: 1323727
// - Storage Diff: 4414
// - CPU Cycles: 1128140
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 20
// - Gas Used: 2377869
// - Storage Diff: 12081
// - CPU Cycles: 2099062
// - Realm gno.land/r/gnoswap/gov/governance: 12081
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 20
// - Gas Used: 1339800
// - Storage Diff: 4414
// - CPU Cycles: 1143025
// - Realm gno.land/r/gnoswap/gov/governance: 4414
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 21
// - Gas Used: 2381794
// - Storage Diff: 12081
// - CPU Cycles: 2102039
// - Realm gno.land/r/gnoswap/gov/governance: 12081
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 21
// - Gas Used: 1342356
// - Storage Diff: 4460
// - CPU Cycles: 1144255
// - Realm gno.land/r/gnoswap/gov/governance: 4460
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 22
// - Gas Used: 2377221
// - Storage Diff: 12144
// - CPU Cycles: 2096329
// - Realm gno.land/r/gnoswap/gov/governance: 12144
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 22
// - Gas Used: 1343625
// - Storage Diff: 4435
// - CPU Cycles: 1144255
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 23
// - Gas Used: 2384623
// - Storage Diff: 12127
// - CPU Cycles: 2102777
// - Realm gno.land/r/gnoswap/gov/governance: 12127
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 23
// - Gas Used: 1346052
// - Storage Diff: 4435
// - CPU Cycles: 1145485
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 24
// - Gas Used: 2384841
// - Storage Diff: 12127
// - CPU Cycles: 2102041
// - Realm gno.land/r/gnoswap/gov/governance: 12127
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 24
// - Gas Used: 1347254
// - Storage Diff: 4435
// - CPU Cycles: 1145490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 25
// - Gas Used: 2686299
// - Storage Diff: 18755
// - CPU Cycles: 2352868
// - Realm gno.land/r/gnoswap/gov/governance: 18755
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 25
// - Gas Used: 1338413
// - Storage Diff: 4471
// - CPU Cycles: 1143030
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 26
// - Gas Used: 2374020
// - Storage Diff: 12141
// - CPU Cycles: 2095594
// - Realm gno.land/r/gnoswap/gov/governance: 12141
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 26
// - Gas Used: 1324720
// - Storage Diff: 4435
// - CPU Cycles: 1128140
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 27
// - Gas Used: 2377952
// - Storage Diff: 12129
// - CPU Cycles: 2098572
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 27
// - Gas Used: 1340807
// - Storage Diff: 4435
// - CPU Cycles: 1143030
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 28
// - Gas Used: 2382376
// - Storage Diff: 12129
// - CPU Cycles: 2102042
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 28
// - Gas Used: 1342004
// - Storage Diff: 4435
// - CPU Cycles: 1143030
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 29
// - Gas Used: 2383330
// - Storage Diff: 12129
// - CPU Cycles: 2102042
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 29
// - Gas Used: 1344431
// - Storage Diff: 4435
// - CPU Cycles: 1144260
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 30
// - Gas Used: 2381674
// - Storage Diff: 12129
// - CPU Cycles: 2101634
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 30
// - Gas Used: 1346853
// - Storage Diff: 4435
// - CPU Cycles: 1145485
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 31
// - Gas Used: 2382875
// - Storage Diff: 12129
// - CPU Cycles: 2101881
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 31
// - Gas Used: 1345595
// - Storage Diff: 4435
// - CPU Cycles: 1143030
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 32
// - Gas Used: 2383830
// - Storage Diff: 12129
// - CPU Cycles: 2101882
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 32
// - Gas Used: 1346792
// - Storage Diff: 4435
// - CPU Cycles: 1143030
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// STATE proposal-metadata aggregate proposalCount 32 passedCount 32 first 1 middle 16 last 32
// STATE proposal-metadata 1 currentProposalID 32 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234567915 createdHeight 128 snapshotTime 1234567915 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 1 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 16 currentProposalID 32 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234568065 createdHeight 158 snapshotTime 1234568065 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 16 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 32 currentProposalID 32 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234568225 createdHeight 190 snapshotTime 1234568225 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 32 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 33
// - Gas Used: 2687732
// - Storage Diff: 18735
// - CPU Cycles: 2352708
// - Realm gno.land/r/gnoswap/gov/governance: 18735
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 33
// - Gas Used: 1341510
// - Storage Diff: 4471
// - CPU Cycles: 1144255
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 34
// - Gas Used: 2379603
// - Storage Diff: 12141
// - CPU Cycles: 2102125
// - Realm gno.land/r/gnoswap/gov/governance: 12141
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 34
// - Gas Used: 1357597
// - Storage Diff: 4435
// - CPU Cycles: 1159145
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 35
// - Gas Used: 2389983
// - Storage Diff: 12129
// - CPU Cycles: 2111551
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 35
// - Gas Used: 1360024
// - Storage Diff: 4435
// - CPU Cycles: 1160375
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 36
// - Gas Used: 2385227
// - Storage Diff: 12129
// - CPU Cycles: 2105841
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 36
// - Gas Used: 1361221
// - Storage Diff: 4435
// - CPU Cycles: 1160375
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 37
// - Gas Used: 2386181
// - Storage Diff: 12129
// - CPU Cycles: 2105841
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 37
// - Gas Used: 1347528
// - Storage Diff: 4435
// - CPU Cycles: 1145485
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 38
// - Gas Used: 2389621
// - Storage Diff: 12129
// - CPU Cycles: 2108327
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 38
// - Gas Used: 1364845
// - Storage Diff: 4435
// - CPU Cycles: 1161605
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 39
// - Gas Used: 2393799
// - Storage Diff: 12129
// - CPU Cycles: 2111551
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 39
// - Gas Used: 1363582
// - Storage Diff: 4435
// - CPU Cycles: 1159145
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 40
// - Gas Used: 2392389
// - Storage Diff: 12129
// - CPU Cycles: 2111389
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 40
// - Gas Used: 1366004
// - Storage Diff: 4435
// - CPU Cycles: 1160370
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 41
// - Gas Used: 2698920
// - Storage Diff: 18735
// - CPU Cycles: 2362462
// - Realm gno.land/r/gnoswap/gov/governance: 18735
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 41
// - Gas Used: 1343373
// - Storage Diff: 4471
// - CPU Cycles: 1144255
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 42
// - Gas Used: 2378975
// - Storage Diff: 12141
// - CPU Cycles: 2102457
// - Realm gno.land/r/gnoswap/gov/governance: 12141
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 42
// - Gas Used: 1360690
// - Storage Diff: 4435
// - CPU Cycles: 1160375
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 43
// - Gas Used: 2383153
// - Storage Diff: 12129
// - CPU Cycles: 2105681
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 43
// - Gas Used: 1346997
// - Storage Diff: 4435
// - CPU Cycles: 1145485
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 44
// - Gas Used: 2386593
// - Storage Diff: 12129
// - CPU Cycles: 2108167
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 44
// - Gas Used: 1348194
// - Storage Diff: 4435
// - CPU Cycles: 1145485
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 45
// - Gas Used: 2387547
// - Storage Diff: 12129
// - CPU Cycles: 2108167
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 45
// - Gas Used: 1363051
// - Storage Diff: 4435
// - CPU Cycles: 1159145
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 46
// - Gas Used: 2391725
// - Storage Diff: 12129
// - CPU Cycles: 2111391
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 46
// - Gas Used: 1364248
// - Storage Diff: 4435
// - CPU Cycles: 1159145
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 47
// - Gas Used: 2392679
// - Storage Diff: 12129
// - CPU Cycles: 2111391
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 47
// - Gas Used: 1366675
// - Storage Diff: 4435
// - CPU Cycles: 1160375
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 48
// - Gas Used: 2393879
// - Storage Diff: 12129
// - CPU Cycles: 2111637
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 48
// - Gas Used: 1367872
// - Storage Diff: 4435
// - CPU Cycles: 1160375
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 49
// - Gas Used: 2700319
// - Storage Diff: 18735
// - CPU Cycles: 2362463
// - Realm gno.land/r/gnoswap/gov/governance: 18735
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 49
// - Gas Used: 1345245
// - Storage Diff: 4471
// - CPU Cycles: 1144255
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 50
// - Gas Used: 2383329
// - Storage Diff: 12141
// - CPU Cycles: 2107759
// - Realm gno.land/r/gnoswap/gov/governance: 12141
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 50
// - Gas Used: 1347667
// - Storage Diff: 4435
// - CPU Cycles: 1145480
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 51
// - Gas Used: 2384530
// - Storage Diff: 12129
// - CPU Cycles: 2108006
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 51
// - Gas Used: 1362529
// - Storage Diff: 4435
// - CPU Cycles: 1159145
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 52
// - Gas Used: 2388709
// - Storage Diff: 12129
// - CPU Cycles: 2111231
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 52
// - Gas Used: 1363726
// - Storage Diff: 4435
// - CPU Cycles: 1159145
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 53
// - Gas Used: 2389663
// - Storage Diff: 12129
// - CPU Cycles: 2111231
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 53
// - Gas Used: 1366153
// - Storage Diff: 4435
// - CPU Cycles: 1160375
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 54
// - Gas Used: 2390863
// - Storage Diff: 12129
// - CPU Cycles: 2111477
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 54
// - Gas Used: 1367350
// - Storage Diff: 4435
// - CPU Cycles: 1160375
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 55
// - Gas Used: 2391817
// - Storage Diff: 12129
// - CPU Cycles: 2111477
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 55
// - Gas Used: 1368547
// - Storage Diff: 4435
// - CPU Cycles: 1160375
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 56
// - Gas Used: 2393263
// - Storage Diff: 12129
// - CPU Cycles: 2111969
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 56
// - Gas Used: 1369744
// - Storage Diff: 4435
// - CPU Cycles: 1160375
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 57
// - Gas Used: 2702079
// - Storage Diff: 18735
// - CPU Cycles: 2362795
// - Realm gno.land/r/gnoswap/gov/governance: 18735
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 57
// - Gas Used: 1348347
// - Storage Diff: 4471
// - CPU Cycles: 1145485
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 58
// - Gas Used: 2384831
// - Storage Diff: 12141
// - CPU Cycles: 2108007
// - Realm gno.land/r/gnoswap/gov/governance: 12141
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 58
// - Gas Used: 1349544
// - Storage Diff: 4435
// - CPU Cycles: 1145485
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 59
// - Gas Used: 2385785
// - Storage Diff: 12129
// - CPU Cycles: 2108007
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 59
// - Gas Used: 1364401
// - Storage Diff: 4435
// - CPU Cycles: 1159145
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 60
// - Gas Used: 2381643
// - Storage Diff: 12129
// - CPU Cycles: 2105113
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 60
// - Gas Used: 1366823
// - Storage Diff: 4435
// - CPU Cycles: 1160370
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 61
// - Gas Used: 2382844
// - Storage Diff: 12129
// - CPU Cycles: 2105360
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 61
// - Gas Used: 1368025
// - Storage Diff: 4435
// - CPU Cycles: 1160375
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 62
// - Gas Used: 2390247
// - Storage Diff: 12129
// - CPU Cycles: 2111809
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 62
// - Gas Used: 1369217
// - Storage Diff: 4435
// - CPU Cycles: 1160370
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 63
// - Gas Used: 2391198
// - Storage Diff: 12129
// - CPU Cycles: 2111806
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 63
// - Gas Used: 1371644
// - Storage Diff: 4435
// - CPU Cycles: 1161600
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 64
// - Gas Used: 2391906
// - Storage Diff: 12129
// - CPU Cycles: 2111560
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 64
// - Gas Used: 1372846
// - Storage Diff: 4435
// - CPU Cycles: 1161605
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 65
// - Gas Used: 2703101
// - Storage Diff: 18735
// - CPU Cycles: 2362389
// - Realm gno.land/r/gnoswap/gov/governance: 18735
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 65
// - Gas Used: 1379994
// - Storage Diff: 4471
// - CPU Cycles: 1175260
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 66
// - Gas Used: 2396616
// - Storage Diff: 12141
// - CPU Cycles: 2120740
// - Realm gno.land/r/gnoswap/gov/governance: 12141
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 66
// - Gas Used: 1381191
// - Storage Diff: 4435
// - CPU Cycles: 1175260
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 67
// - Gas Used: 2397570
// - Storage Diff: 12129
// - CPU Cycles: 2120740
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 67
// - Gas Used: 1383618
// - Storage Diff: 4435
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 68
// - Gas Used: 2392814
// - Storage Diff: 12129
// - CPU Cycles: 2115030
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 68
// - Gas Used: 1384815
// - Storage Diff: 4435
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 69
// - Gas Used: 2393768
// - Storage Diff: 12129
// - CPU Cycles: 2115030
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 69
// - Gas Used: 1386012
// - Storage Diff: 4435
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 70
// - Gas Used: 2398314
// - Storage Diff: 12129
// - CPU Cycles: 2120824
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 70
// - Gas Used: 1388434
// - Storage Diff: 4435
// - CPU Cycles: 1177715
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 71
// - Gas Used: 2399515
// - Storage Diff: 12129
// - CPU Cycles: 2121071
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 71
// - Gas Used: 1388406
// - Storage Diff: 4435
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 72
// - Gas Used: 2400716
// - Storage Diff: 12129
// - CPU Cycles: 2121318
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 72
// - Gas Used: 1389603
// - Storage Diff: 4435
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 73
// - Gas Used: 2714284
// - Storage Diff: 18735
// - CPU Cycles: 2372144
// - Realm gno.land/r/gnoswap/gov/governance: 18735
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 73
// - Gas Used: 1383087
// - Storage Diff: 4471
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 74
// - Gas Used: 2389786
// - Storage Diff: 12141
// - CPU Cycles: 2114870
// - Realm gno.land/r/gnoswap/gov/governance: 12141
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 74
// - Gas Used: 1384284
// - Storage Diff: 4435
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 75
// - Gas Used: 2390740
// - Storage Diff: 12129
// - CPU Cycles: 2114870
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 75
// - Gas Used: 1370591
// - Storage Diff: 4435
// - CPU Cycles: 1161600
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 76
// - Gas Used: 2394672
// - Storage Diff: 12129
// - CPU Cycles: 2117848
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 76
// - Gas Used: 1371788
// - Storage Diff: 4435
// - CPU Cycles: 1161600
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 77
// - Gas Used: 2395626
// - Storage Diff: 12129
// - CPU Cycles: 2117848
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 77
// - Gas Used: 1389105
// - Storage Diff: 4435
// - CPU Cycles: 1177720
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 78
// - Gas Used: 2399804
// - Storage Diff: 12129
// - CPU Cycles: 2121072
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 78
// - Gas Used: 1390302
// - Storage Diff: 4435
// - CPU Cycles: 1177720
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 79
// - Gas Used: 2400758
// - Storage Diff: 12129
// - CPU Cycles: 2121072
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 79
// - Gas Used: 1390269
// - Storage Diff: 4435
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 80
// - Gas Used: 2399594
// - Storage Diff: 12129
// - CPU Cycles: 2121156
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 80
// - Gas Used: 1392691
// - Storage Diff: 4435
// - CPU Cycles: 1177715
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 81
// - Gas Used: 2715767
// - Storage Diff: 18735
// - CPU Cycles: 2372229
// - Realm gno.land/r/gnoswap/gov/governance: 18735
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 81
// - Gas Used: 1370069
// - Storage Diff: 4471
// - CPU Cycles: 1161600
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 82
// - Gas Used: 2385700
// - Storage Diff: 12141
// - CPU Cycles: 2111732
// - Realm gno.land/r/gnoswap/gov/governance: 12141
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 82
// - Gas Used: 1371261
// - Storage Diff: 4435
// - CPU Cycles: 1161595
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 83
// - Gas Used: 2386651
// - Storage Diff: 12129
// - CPU Cycles: 2111729
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 83
// - Gas Used: 1387348
// - Storage Diff: 4435
// - CPU Cycles: 1176485
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 84
// - Gas Used: 2397031
// - Storage Diff: 12129
// - CPU Cycles: 2121155
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 84
// - Gas Used: 1388550
// - Storage Diff: 4435
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 85
// - Gas Used: 2397988
// - Storage Diff: 12129
// - CPU Cycles: 2121158
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 85
// - Gas Used: 1389747
// - Storage Diff: 4435
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 86
// - Gas Used: 2398942
// - Storage Diff: 12129
// - CPU Cycles: 2121158
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 86
// - Gas Used: 1390944
// - Storage Diff: 4435
// - CPU Cycles: 1176490
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 87
// - Gas Used: 2399896
// - Storage Diff: 12129
// - CPU Cycles: 2121158
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 87
// - Gas Used: 1393371
// - Storage Diff: 4435
// - CPU Cycles: 1177720
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 88
// - Gas Used: 2401096
// - Storage Diff: 12129
// - CPU Cycles: 2121404
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 88
// - Gas Used: 1394568
// - Storage Diff: 4435
// - CPU Cycles: 1177720
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 89
// - Gas Used: 2717196
// - Storage Diff: 18735
// - CPU Cycles: 2372230
// - Realm gno.land/r/gnoswap/gov/governance: 18735
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 89
// - Gas Used: 1371941
// - Storage Diff: 4471
// - CPU Cycles: 1161600
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 90
// - Gas Used: 2382504
// - Storage Diff: 12141
// - CPU Cycles: 2109484
// - Realm gno.land/r/gnoswap/gov/governance: 12141
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 90
// - Gas Used: 1373133
// - Storage Diff: 4435
// - CPU Cycles: 1161595
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 91
// - Gas Used: 2383457
// - Storage Diff: 12129
// - CPU Cycles: 2109483
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 91
// - Gas Used: 1390450
// - Storage Diff: 4435
// - CPU Cycles: 1177715
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 92
// - Gas Used: 2387635
// - Storage Diff: 12129
// - CPU Cycles: 2112707
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 92
// - Gas Used: 1391652
// - Storage Diff: 4435
// - CPU Cycles: 1177720
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 93
// - Gas Used: 2388592
// - Storage Diff: 12129
// - CPU Cycles: 2112710
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 93
// - Gas Used: 1392849
// - Storage Diff: 4435
// - CPU Cycles: 1177720
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 94
// - Gas Used: 2389546
// - Storage Diff: 12129
// - CPU Cycles: 2112710
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 94
// - Gas Used: 1394046
// - Storage Diff: 4435
// - CPU Cycles: 1177720
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 95
// - Gas Used: 2390500
// - Storage Diff: 12129
// - CPU Cycles: 2112710
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 95
// - Gas Used: 1395243
// - Storage Diff: 4435
// - CPU Cycles: 1177720
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 96
// - Gas Used: 2397902
// - Storage Diff: 12129
// - CPU Cycles: 2119158
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 96
// - Gas Used: 1396435
// - Storage Diff: 4435
// - CPU Cycles: 1177715
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 97
// - Gas Used: 2644559
// - Storage Diff: 18455
// - CPU Cycles: 2299005
// - Realm gno.land/r/gnoswap/gov/governance: 18455
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 97
// - Gas Used: 1349314
// - Storage Diff: 4471
// - CPU Cycles: 1145480
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 98
// - Gas Used: 2360962
// - Storage Diff: 12141
// - CPU Cycles: 2093366
// - Realm gno.land/r/gnoswap/gov/governance: 12141
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 98
// - Gas Used: 1350511
// - Storage Diff: 4435
// - CPU Cycles: 1145480
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 99
// - Gas Used: 2368364
// - Storage Diff: 12129
// - CPU Cycles: 2099814
// - Realm gno.land/r/gnoswap/gov/governance: 12129
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 99
// - Gas Used: 1351708
// - Storage Diff: 4435
// - CPU Cycles: 1145480
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 100
// - Gas Used: 2460264
// - Storage Diff: 12114
// - CPU Cycles: 2171029
// - Realm gno.land/r/gnoswap/gov/governance: 12114
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 100
// - Gas Used: 1502193
// - Storage Diff: 4435
// - CPU Cycles: 1287046
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 101
// - Gas Used: 2486001
// - Storage Diff: 12090
// - CPU Cycles: 2195496
// - Realm gno.land/r/gnoswap/gov/governance: 12090
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 101
// - Gas Used: 1518290
// - Storage Diff: 4435
// - CPU Cycles: 1301946
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 102
// - Gas Used: 2496271
// - Storage Diff: 12090
// - CPU Cycles: 2204926
// - Realm gno.land/r/gnoswap/gov/governance: 12090
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 102
// - Gas Used: 1520717
// - Storage Diff: 4435
// - CPU Cycles: 1303176
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 103
// - Gas Used: 2491399
// - Storage Diff: 12090
// - CPU Cycles: 2199214
// - Realm gno.land/r/gnoswap/gov/governance: 12090
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 103
// - Gas Used: 1521914
// - Storage Diff: 4435
// - CPU Cycles: 1303176
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 104
// - Gas Used: 2492239
// - Storage Diff: 12090
// - CPU Cycles: 2199214
// - Realm gno.land/r/gnoswap/gov/governance: 12090
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 104
// - Gas Used: 1508216
// - Storage Diff: 4435
// - CPU Cycles: 1288281
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 105
// - Gas Used: 2495566
// - Storage Diff: 12090
// - CPU Cycles: 2201701
// - Realm gno.land/r/gnoswap/gov/governance: 12090
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 105
// - Gas Used: 1525538
// - Storage Diff: 4435
// - CPU Cycles: 1304406
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 106
// - Gas Used: 2499631
// - Storage Diff: 12090
// - CPU Cycles: 2204926
// - Realm gno.land/r/gnoswap/gov/governance: 12090
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 106
// - Gas Used: 1524275
// - Storage Diff: 4435
// - CPU Cycles: 1301946
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 107
// - Gas Used: 2500471
// - Storage Diff: 12090
// - CPU Cycles: 2204926
// - Realm gno.land/r/gnoswap/gov/governance: 12090
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 107
// - Gas Used: 1525472
// - Storage Diff: 4435
// - CPU Cycles: 1301946
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 108
// - Gas Used: 2809243
// - Storage Diff: 18552
// - CPU Cycles: 2455832
// - Realm gno.land/r/gnoswap/gov/governance: 18552
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 108
// - Gas Used: 1504886
// - Storage Diff: 4471
// - CPU Cycles: 1288281
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 109
// - Gas Used: 2486710
// - Storage Diff: 12144
// - CPU Cycles: 2196235
// - Realm gno.land/r/gnoswap/gov/governance: 12144
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 109
// - Gas Used: 1520978
// - Storage Diff: 4435
// - CPU Cycles: 1303176
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 110
// - Gas Used: 2488771
// - Storage Diff: 12132
// - CPU Cycles: 2199544
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 110
// - Gas Used: 1508505
// - Storage Diff: 4435
// - CPU Cycles: 1289506
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 111
// - Gas Used: 2492465
// - Storage Diff: 12132
// - CPU Cycles: 2202278
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 111
// - Gas Used: 1509707
// - Storage Diff: 4435
// - CPU Cycles: 1289511
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 112
// - Gas Used: 2493426
// - Storage Diff: 12132
// - CPU Cycles: 2202279
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 112
// - Gas Used: 1524569
// - Storage Diff: 4435
// - CPU Cycles: 1303176
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 113
// - Gas Used: 2497611
// - Storage Diff: 12132
// - CPU Cycles: 2205504
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 113
// - Gas Used: 1525766
// - Storage Diff: 4435
// - CPU Cycles: 1303176
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 114
// - Gas Used: 2498571
// - Storage Diff: 12132
// - CPU Cycles: 2205504
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 114
// - Gas Used: 1528193
// - Storage Diff: 4435
// - CPU Cycles: 1304406
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 115
// - Gas Used: 2499777
// - Storage Diff: 12132
// - CPU Cycles: 2205750
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 115
// - Gas Used: 1529390
// - Storage Diff: 4435
// - CPU Cycles: 1304406
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 116
// - Gas Used: 2832689
// - Storage Diff: 18740
// - CPU Cycles: 2459216
// - Realm gno.land/r/gnoswap/gov/governance: 18740
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 116
// - Gas Used: 1506758
// - Storage Diff: 4471
// - CPU Cycles: 1288281
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 117
// - Gas Used: 2486088
// - Storage Diff: 12144
// - CPU Cycles: 2196567
// - Realm gno.land/r/gnoswap/gov/governance: 12144
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 117
// - Gas Used: 1524080
// - Storage Diff: 4435
// - CPU Cycles: 1304406
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 118
// - Gas Used: 2490273
// - Storage Diff: 12132
// - CPU Cycles: 2199792
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 118
// - Gas Used: 1510382
// - Storage Diff: 4435
// - CPU Cycles: 1289511
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 119
// - Gas Used: 2493720
// - Storage Diff: 12132
// - CPU Cycles: 2202279
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 119
// - Gas Used: 1511579
// - Storage Diff: 4435
// - CPU Cycles: 1289511
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 120
// - Gas Used: 2492802
// - Storage Diff: 12132
// - CPU Cycles: 2202609
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 120
// - Gas Used: 1527666
// - Storage Diff: 4435
// - CPU Cycles: 1304401
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 121
// - Gas Used: 2496742
// - Storage Diff: 12132
// - CPU Cycles: 2205589
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 121
// - Gas Used: 1528863
// - Storage Diff: 4435
// - CPU Cycles: 1304401
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 122
// - Gas Used: 2497700
// - Storage Diff: 12132
// - CPU Cycles: 2205587
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 122
// - Gas Used: 1530060
// - Storage Diff: 4435
// - CPU Cycles: 1304401
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 123
// - Gas Used: 2499152
// - Storage Diff: 12132
// - CPU Cycles: 2206079
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 123
// - Gas Used: 1531262
// - Storage Diff: 4435
// - CPU Cycles: 1304406
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 124
// - Gas Used: 2834449
// - Storage Diff: 18740
// - CPU Cycles: 2459548
// - Realm gno.land/r/gnoswap/gov/governance: 18740
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 124
// - Gas Used: 1511090
// - Storage Diff: 4471
// - CPU Cycles: 1290741
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 125
// - Gas Used: 2491424
// - Storage Diff: 12144
// - CPU Cycles: 2202857
// - Realm gno.land/r/gnoswap/gov/governance: 12144
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 125
// - Gas Used: 1512287
// - Storage Diff: 4435
// - CPU Cycles: 1290741
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 126
// - Gas Used: 2492384
// - Storage Diff: 12132
// - CPU Cycles: 2202857
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 126
// - Gas Used: 1527149
// - Storage Diff: 4435
// - CPU Cycles: 1304406
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 127
// - Gas Used: 2496569
// - Storage Diff: 12132
// - CPU Cycles: 2206082
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 127
// - Gas Used: 1528346
// - Storage Diff: 4435
// - CPU Cycles: 1304406
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 128
// - Gas Used: 2497529
// - Storage Diff: 12132
// - CPU Cycles: 2206082
// - Realm gno.land/r/gnoswap/gov/governance: 12132
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 128
// - Gas Used: 1530773
// - Storage Diff: 4435
// - CPU Cycles: 1305636
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// STATE proposal-metadata aggregate proposalCount 128 passedCount 128 first 1 middle 64 last 128
// STATE proposal-metadata 1 currentProposalID 128 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234567915 createdHeight 128 snapshotTime 1234567915 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 1 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 64 currentProposalID 128 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234568545 createdHeight 254 snapshotTime 1234568545 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 64 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 128 currentProposalID 128 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569185 createdHeight 382 snapshotTime 1234569185 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 128 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// Proposal metadata root Proposal reads (128 proposals)
// - Gas Used: 21033755
// - Storage Diff: 0
// - CPU Cycles: 19905157
// Proposal metadata nested metadata reads (128 proposals)
// - Gas Used: 34664075
// - Storage Diff: 0
// - CPU Cycles: 32615210
// Proposal metadata list and voting-info reads (128 proposals)
// - Gas Used: 22526574
// - Storage Diff: 0
// - CPU Cycles: 21198324
// Proposal metadata create text (8KiB, total 129)
// - Gas Used: 2512490
// - Storage Diff: 16528
// - CPU Cycles: 2206082
// - Realm gno.land/r/gnoswap/gov/governance: 16528
// STATE proposal-metadata 129 currentProposalID 129 type Text status active proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569195 createdHeight 384 snapshotTime 1234569195 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata 8KiB descriptionLen 8800 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 0 userProposalEntries 1
// Proposal metadata root Proposal read (8KiB)
// - Gas Used: 237287
// - Storage Diff: 0
// - CPU Cycles: 223381
// Proposal metadata nested metadata reads (8KiB)
// - Gas Used: 345010
// - Storage Diff: 0
// - CPU Cycles: 325283
// Proposal metadata vote text (8KiB)
// - Gas Used: 1545158
// - Storage Diff: 4435
// - CPU Cycles: 1305636
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// STATE proposal-metadata 129 currentProposalID 129 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569195 createdHeight 384 snapshotTime 1234569195 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata 8KiB descriptionLen 8800 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// Proposal metadata create spend (8KiB)
// - Gas Used: 3041134
// - Storage Diff: 18771
// - CPU Cycles: 2612044
// - Realm gno.land/r/gnoswap/gov/governance: 18771
// STATE proposal-metadata 130 currentProposalID 130 type CommunityPoolSpend status upcoming proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 3 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata spend descriptionLen 8800 metadataPresent true spendPresent true spendTo g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 spendToken gno.land/r/gnoswap/gns.GNS spendAmount 100 executionPresent true executionNum 1 executionMessages 1 votingInfos 0 userProposalEntries 1
// Proposal metadata cancel spend
// - Gas Used: 872999
// - Storage Diff: 70
// - CPU Cycles: 726131
// - Realm gno.land/r/gnoswap/gov/governance: 70
// STATE proposal-metadata 130 currentProposalID 130 type CommunityPoolSpend status canceled proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 3 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata spend descriptionLen 8800 metadataPresent true spendPresent true spendTo g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 spendToken gno.land/r/gnoswap/gns.GNS spendAmount 100 executionPresent true executionNum 1 executionMessages 1 votingInfos 0 userProposalEntries 1
// Proposal metadata create parameter change (4KiB)
// - Gas Used: 3544690
// - Storage Diff: 13359
// - CPU Cycles: 3163315
// - Realm gno.land/r/gnoswap/gov/governance: 13359
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status active proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 0 userProposalEntries 1
// Proposal metadata vote parameter change
// - Gas Used: 1566103
// - Storage Diff: 4435
// - CPU Cycles: 1332417
// - Realm gno.land/r/gnoswap/gov/governance: 4435
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status active proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status executable proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 1 userProposalEntries 1
// Proposal metadata execute parameter change
// - Gas Used: 2806809
// - Storage Diff: 64
// - CPU Cycles: 1667112
// - Realm gno.land/r/gnoswap/gov/governance: 64
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status executed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 1 userProposalEntries 1
