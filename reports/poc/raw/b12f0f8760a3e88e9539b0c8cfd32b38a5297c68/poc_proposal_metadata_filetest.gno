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
// - Gas Used: 1946483
// - Storage Diff: 22716
// - CPU Cycles: 1581693
// - Realm gno.land/r/gnoswap/gov/governance: 22716
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 1
// - Gas Used: 1020807
// - Storage Diff: 4488
// - CPU Cycles: 860911
// - Realm gno.land/r/gnoswap/gov/governance: 4488
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 2
// - Gas Used: 2171858
// - Storage Diff: 12882
// - CPU Cycles: 1944439
// - Realm gno.land/r/gnoswap/gov/governance: 12882
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 2
// - Gas Used: 1002604
// - Storage Diff: 4450
// - CPU Cycles: 873803
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 3
// - Gas Used: 2176023
// - Storage Diff: 12868
// - CPU Cycles: 1947662
// - Realm gno.land/r/gnoswap/gov/governance: 12868
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 3
// - Gas Used: 1003792
// - Storage Diff: 4450
// - CPU Cycles: 873803
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 4
// - Gas Used: 2183411
// - Storage Diff: 12868
// - CPU Cycles: 1954108
// - Realm gno.land/r/gnoswap/gov/governance: 12868
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 4
// - Gas Used: 1004980
// - Storage Diff: 4450
// - CPU Cycles: 873803
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 5
// - Gas Used: 2184353
// - Storage Diff: 12868
// - CPU Cycles: 1954108
// - Realm gno.land/r/gnoswap/gov/governance: 12868
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 5
// - Gas Used: 1019060
// - Storage Diff: 4450
// - CPU Cycles: 886695
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 6
// - Gas Used: 2188518
// - Storage Diff: 12868
// - CPU Cycles: 1957331
// - Realm gno.land/r/gnoswap/gov/governance: 12868
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 6
// - Gas Used: 1020248
// - Storage Diff: 4450
// - CPU Cycles: 886695
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 7
// - Gas Used: 2189460
// - Storage Diff: 12868
// - CPU Cycles: 1957331
// - Realm gno.land/r/gnoswap/gov/governance: 12868
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 7
// - Gas Used: 1021436
// - Storage Diff: 4450
// - CPU Cycles: 886695
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 8
// - Gas Used: 2196848
// - Storage Diff: 12868
// - CPU Cycles: 1963777
// - Realm gno.land/r/gnoswap/gov/governance: 12868
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 8
// - Gas Used: 1022624
// - Storage Diff: 4450
// - CPU Cycles: 886695
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 9
// - Gas Used: 2197790
// - Storage Diff: 12868
// - CPU Cycles: 1963777
// - Realm gno.land/r/gnoswap/gov/governance: 12868
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 9
// - Gas Used: 1023812
// - Storage Diff: 4450
// - CPU Cycles: 886695
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 10
// - Gas Used: 2227733
// - Storage Diff: 12871
// - CPU Cycles: 1974045
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 10
// - Gas Used: 1038335
// - Storage Diff: 4450
// - CPU Cycles: 900025
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 11
// - Gas Used: 2225941
// - Storage Diff: 12871
// - CPU Cycles: 1971304
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 11
// - Gas Used: 1027615
// - Storage Diff: 4450
// - CPU Cycles: 888117
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 12
// - Gas Used: 2229868
// - Storage Diff: 12871
// - CPU Cycles: 1974283
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 12
// - Gas Used: 1041699
// - Storage Diff: 4450
// - CPU Cycles: 901013
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 13
// - Gas Used: 2234040
// - Storage Diff: 12871
// - CPU Cycles: 1977507
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 13
// - Gas Used: 1041903
// - Storage Diff: 4450
// - CPU Cycles: 900029
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 14
// - Gas Used: 2235234
// - Storage Diff: 12871
// - CPU Cycles: 1977753
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 14
// - Gas Used: 1044075
// - Storage Diff: 4450
// - CPU Cycles: 901013
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 15
// - Gas Used: 2236428
// - Storage Diff: 12871
// - CPU Cycles: 1977999
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 15
// - Gas Used: 1045263
// - Storage Diff: 4450
// - CPU Cycles: 901013
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 16
// - Gas Used: 2237868
// - Storage Diff: 12871
// - CPU Cycles: 1978491
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 16
// - Gas Used: 1046451
// - Storage Diff: 4450
// - CPU Cycles: 901013
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 17
// - Gas Used: 2525632
// - Storage Diff: 25949
// - CPU Cycles: 2199061
// - Realm gno.land/r/gnoswap/gov/governance: 25949
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 17
// - Gas Used: 1110761
// - Storage Diff: 4522
// - CPU Cycles: 954288
// - Realm gno.land/r/gnoswap/gov/governance: 4522
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 18
// - Gas Used: 2298971
// - Storage Diff: 12895
// - CPU Cycles: 2026811
// - Realm gno.land/r/gnoswap/gov/governance: 12895
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 18
// - Gas Used: 1112933
// - Storage Diff: 4450
// - CPU Cycles: 955272
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 19
// - Gas Used: 2294209
// - Storage Diff: 12871
// - CPU Cycles: 2021101
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 19
// - Gas Used: 1102209
// - Storage Diff: 4450
// - CPU Cycles: 943360
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 20
// - Gas Used: 2296125
// - Storage Diff: 12871
// - CPU Cycles: 2024409
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 20
// - Gas Used: 1115305
// - Storage Diff: 4450
// - CPU Cycles: 955268
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 21
// - Gas Used: 2300050
// - Storage Diff: 12871
// - CPU Cycles: 2027386
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 21
// - Gas Used: 1117477
// - Storage Diff: 4450
// - CPU Cycles: 956252
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 22
// - Gas Used: 2295288
// - Storage Diff: 12871
// - CPU Cycles: 2021676
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 22
// - Gas Used: 1118665
// - Storage Diff: 4450
// - CPU Cycles: 956252
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 23
// - Gas Used: 2302684
// - Storage Diff: 12871
// - CPU Cycles: 2028124
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 23
// - Gas Used: 1120837
// - Storage Diff: 4450
// - CPU Cycles: 957236
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 24
// - Gas Used: 2302896
// - Storage Diff: 12871
// - CPU Cycles: 2027388
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 24
// - Gas Used: 1122029
// - Storage Diff: 4450
// - CPU Cycles: 957240
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 25
// - Gas Used: 2605455
// - Storage Diff: 19467
// - CPU Cycles: 2278215
// - Realm gno.land/r/gnoswap/gov/governance: 19467
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 25
// - Gas Used: 1113599
// - Storage Diff: 4486
// - CPU Cycles: 955272
// - Realm gno.land/r/gnoswap/gov/governance: 4486
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 26
// - Gas Used: 2292003
// - Storage Diff: 12883
// - CPU Cycles: 2020941
// - Realm gno.land/r/gnoswap/gov/governance: 12883
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 26
// - Gas Used: 1102875
// - Storage Diff: 4450
// - CPU Cycles: 943360
// - Realm gno.land/r/gnoswap/gov/governance: 4450
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 27
// - Gas Used: 2295929
// - Storage Diff: 12871
// - CPU Cycles: 2023919
// - Realm gno.land/r/gnoswap/gov/governance: 12871
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 27
// - Gas Used: 1116008
// - Storage Diff: 4461
// - CPU Cycles: 955272
// - Realm gno.land/r/gnoswap/gov/governance: 4461
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 28
// - Gas Used: 2300554
// - Storage Diff: 12940
// - CPU Cycles: 2027389
// - Realm gno.land/r/gnoswap/gov/governance: 12940
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 28
// - Gas Used: 1117340
// - Storage Diff: 4471
// - CPU Cycles: 955272
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 29
// - Gas Used: 2301508
// - Storage Diff: 12923
// - CPU Cycles: 2027389
// - Realm gno.land/r/gnoswap/gov/governance: 12923
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 29
// - Gas Used: 1119521
// - Storage Diff: 4471
// - CPU Cycles: 956256
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 30
// - Gas Used: 2299714
// - Storage Diff: 12923
// - CPU Cycles: 2026981
// - Realm gno.land/r/gnoswap/gov/governance: 12923
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 30
// - Gas Used: 1121698
// - Storage Diff: 4471
// - CPU Cycles: 957236
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 31
// - Gas Used: 2300915
// - Storage Diff: 12923
// - CPU Cycles: 2027228
// - Realm gno.land/r/gnoswap/gov/governance: 12923
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 31
// - Gas Used: 1120931
// - Storage Diff: 4471
// - CPU Cycles: 955272
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 32 proposals) create 32
// - Gas Used: 2301870
// - Storage Diff: 12923
// - CPU Cycles: 2027229
// - Realm gno.land/r/gnoswap/gov/governance: 12923
// Proposal metadata lifecycle text (4KiB, 32 proposals) vote 32
// - Gas Used: 1122128
// - Storage Diff: 4471
// - CPU Cycles: 955272
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// STATE proposal-metadata aggregate proposalCount 32 passedCount 32 first 1 middle 16 last 32
// STATE proposal-metadata 1 currentProposalID 32 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234567915 createdHeight 128 snapshotTime 1234567915 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 1 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 16 currentProposalID 32 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234568065 createdHeight 158 snapshotTime 1234568065 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 16 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 32 currentProposalID 32 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234568225 createdHeight 190 snapshotTime 1234568225 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 32 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 33
// - Gas Used: 2607086
// - Storage Diff: 19539
// - CPU Cycles: 2278055
// - Realm gno.land/r/gnoswap/gov/governance: 19539
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 33
// - Gas Used: 1116718
// - Storage Diff: 4507
// - CPU Cycles: 956252
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 34
// - Gas Used: 2297733
// - Storage Diff: 12937
// - CPU Cycles: 2027472
// - Realm gno.land/r/gnoswap/gov/governance: 12937
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 34
// - Gas Used: 1129827
// - Storage Diff: 4471
// - CPU Cycles: 968164
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 35
// - Gas Used: 2308113
// - Storage Diff: 12925
// - CPU Cycles: 2036898
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 35
// - Gas Used: 1132008
// - Storage Diff: 4471
// - CPU Cycles: 969148
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 36
// - Gas Used: 2303357
// - Storage Diff: 12925
// - CPU Cycles: 2031188
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 36
// - Gas Used: 1133205
// - Storage Diff: 4471
// - CPU Cycles: 969148
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 37
// - Gas Used: 2304311
// - Storage Diff: 12925
// - CPU Cycles: 2031188
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 37
// - Gas Used: 1122490
// - Storage Diff: 4471
// - CPU Cycles: 957236
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 38
// - Gas Used: 2307751
// - Storage Diff: 12925
// - CPU Cycles: 2033674
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 38
// - Gas Used: 1136583
// - Storage Diff: 4471
// - CPU Cycles: 970132
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 39
// - Gas Used: 2311929
// - Storage Diff: 12925
// - CPU Cycles: 2036898
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 39
// - Gas Used: 1135812
// - Storage Diff: 4471
// - CPU Cycles: 968164
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 40
// - Gas Used: 2310381
// - Storage Diff: 12925
// - CPU Cycles: 2036736
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 40
// - Gas Used: 1137989
// - Storage Diff: 4471
// - CPU Cycles: 969144
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 41
// - Gas Used: 2618418
// - Storage Diff: 19531
// - CPU Cycles: 2287809
// - Realm gno.land/r/gnoswap/gov/governance: 19531
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 41
// - Gas Used: 1118581
// - Storage Diff: 4507
// - CPU Cycles: 956252
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 42
// - Gas Used: 2296967
// - Storage Diff: 12937
// - CPU Cycles: 2027804
// - Realm gno.land/r/gnoswap/gov/governance: 12937
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 42
// - Gas Used: 1132674
// - Storage Diff: 4471
// - CPU Cycles: 969148
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 43
// - Gas Used: 2301145
// - Storage Diff: 12925
// - CPU Cycles: 2031028
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 43
// - Gas Used: 1121959
// - Storage Diff: 4471
// - CPU Cycles: 957236
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 44
// - Gas Used: 2304585
// - Storage Diff: 12925
// - CPU Cycles: 2033514
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 44
// - Gas Used: 1123156
// - Storage Diff: 4471
// - CPU Cycles: 957236
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 45
// - Gas Used: 2305539
// - Storage Diff: 12925
// - CPU Cycles: 2033514
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 45
// - Gas Used: 1135281
// - Storage Diff: 4471
// - CPU Cycles: 968164
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 46
// - Gas Used: 2309717
// - Storage Diff: 12925
// - CPU Cycles: 2036738
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 46
// - Gas Used: 1136478
// - Storage Diff: 4471
// - CPU Cycles: 968164
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 47
// - Gas Used: 2310671
// - Storage Diff: 12925
// - CPU Cycles: 2036738
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 47
// - Gas Used: 1138659
// - Storage Diff: 4471
// - CPU Cycles: 969148
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 48
// - Gas Used: 2311871
// - Storage Diff: 12925
// - CPU Cycles: 2036984
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 48
// - Gas Used: 1139856
// - Storage Diff: 4471
// - CPU Cycles: 969148
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 49
// - Gas Used: 2619829
// - Storage Diff: 19531
// - CPU Cycles: 2287810
// - Realm gno.land/r/gnoswap/gov/governance: 19531
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 49
// - Gas Used: 1120453
// - Storage Diff: 4507
// - CPU Cycles: 956252
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 50
// - Gas Used: 2301183
// - Storage Diff: 12937
// - CPU Cycles: 2033106
// - Realm gno.land/r/gnoswap/gov/governance: 12937
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 50
// - Gas Used: 1122630
// - Storage Diff: 4471
// - CPU Cycles: 957232
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 51
// - Gas Used: 2302384
// - Storage Diff: 12925
// - CPU Cycles: 2033353
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 51
// - Gas Used: 1134759
// - Storage Diff: 4471
// - CPU Cycles: 968164
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 52
// - Gas Used: 2306563
// - Storage Diff: 12925
// - CPU Cycles: 2036578
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 52
// - Gas Used: 1135956
// - Storage Diff: 4471
// - CPU Cycles: 968164
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 53
// - Gas Used: 2307517
// - Storage Diff: 12925
// - CPU Cycles: 2036578
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 53
// - Gas Used: 1138137
// - Storage Diff: 4471
// - CPU Cycles: 969148
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 54
// - Gas Used: 2308717
// - Storage Diff: 12925
// - CPU Cycles: 2036824
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 54
// - Gas Used: 1139334
// - Storage Diff: 4471
// - CPU Cycles: 969148
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 55
// - Gas Used: 2309671
// - Storage Diff: 12925
// - CPU Cycles: 2036824
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 55
// - Gas Used: 1140531
// - Storage Diff: 4471
// - CPU Cycles: 969148
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 56
// - Gas Used: 2311117
// - Storage Diff: 12925
// - CPU Cycles: 2037316
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 56
// - Gas Used: 1141728
// - Storage Diff: 4471
// - CPU Cycles: 969148
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 57
// - Gas Used: 2621589
// - Storage Diff: 19531
// - CPU Cycles: 2288142
// - Realm gno.land/r/gnoswap/gov/governance: 19531
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 57
// - Gas Used: 1123309
// - Storage Diff: 4507
// - CPU Cycles: 957236
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 58
// - Gas Used: 2302685
// - Storage Diff: 12937
// - CPU Cycles: 2033354
// - Realm gno.land/r/gnoswap/gov/governance: 12937
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 58
// - Gas Used: 1124506
// - Storage Diff: 4471
// - CPU Cycles: 957236
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 59
// - Gas Used: 2303639
// - Storage Diff: 12925
// - CPU Cycles: 2033354
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 59
// - Gas Used: 1136631
// - Storage Diff: 4471
// - CPU Cycles: 968164
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 60
// - Gas Used: 2299359
// - Storage Diff: 12925
// - CPU Cycles: 2030460
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 60
// - Gas Used: 1138808
// - Storage Diff: 4471
// - CPU Cycles: 969144
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 61
// - Gas Used: 2300560
// - Storage Diff: 12925
// - CPU Cycles: 2030707
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 61
// - Gas Used: 1140009
// - Storage Diff: 4471
// - CPU Cycles: 969148
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 62
// - Gas Used: 2307963
// - Storage Diff: 12925
// - CPU Cycles: 2037156
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 62
// - Gas Used: 1141202
// - Storage Diff: 4471
// - CPU Cycles: 969144
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 63
// - Gas Used: 2308914
// - Storage Diff: 12925
// - CPU Cycles: 2037153
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 63
// - Gas Used: 1143383
// - Storage Diff: 4471
// - CPU Cycles: 970128
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 64
// - Gas Used: 2309622
// - Storage Diff: 12925
// - CPU Cycles: 2036907
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 64
// - Gas Used: 1144584
// - Storage Diff: 4471
// - CPU Cycles: 970132
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 65
// - Gas Used: 2622611
// - Storage Diff: 19531
// - CPU Cycles: 2287736
// - Realm gno.land/r/gnoswap/gov/governance: 19531
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 65
// - Gas Used: 1149001
// - Storage Diff: 4507
// - CPU Cycles: 981056
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 66
// - Gas Used: 2314332
// - Storage Diff: 12937
// - CPU Cycles: 2046087
// - Realm gno.land/r/gnoswap/gov/governance: 12937
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 66
// - Gas Used: 1150198
// - Storage Diff: 4471
// - CPU Cycles: 981056
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 67
// - Gas Used: 2315286
// - Storage Diff: 12925
// - CPU Cycles: 2046087
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 67
// - Gas Used: 1152379
// - Storage Diff: 4471
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 68
// - Gas Used: 2310530
// - Storage Diff: 12925
// - CPU Cycles: 2040377
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 68
// - Gas Used: 1153576
// - Storage Diff: 4471
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 69
// - Gas Used: 2311484
// - Storage Diff: 12925
// - CPU Cycles: 2040377
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 69
// - Gas Used: 1154773
// - Storage Diff: 4471
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 70
// - Gas Used: 2315892
// - Storage Diff: 12925
// - CPU Cycles: 2046171
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 70
// - Gas Used: 1156950
// - Storage Diff: 4471
// - CPU Cycles: 983020
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 71
// - Gas Used: 2317093
// - Storage Diff: 12925
// - CPU Cycles: 2046418
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 71
// - Gas Used: 1157167
// - Storage Diff: 4471
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 72
// - Gas Used: 2318294
// - Storage Diff: 12925
// - CPU Cycles: 2046665
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 72
// - Gas Used: 1158364
// - Storage Diff: 4471
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 73
// - Gas Used: 2633794
// - Storage Diff: 19531
// - CPU Cycles: 2297491
// - Realm gno.land/r/gnoswap/gov/governance: 19531
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 73
// - Gas Used: 1151848
// - Storage Diff: 4507
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 74
// - Gas Used: 2307364
// - Storage Diff: 12937
// - CPU Cycles: 2040217
// - Realm gno.land/r/gnoswap/gov/governance: 12937
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 74
// - Gas Used: 1153045
// - Storage Diff: 4471
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 75
// - Gas Used: 2308318
// - Storage Diff: 12925
// - CPU Cycles: 2040217
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 75
// - Gas Used: 1142330
// - Storage Diff: 4471
// - CPU Cycles: 970128
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 76
// - Gas Used: 2312250
// - Storage Diff: 12925
// - CPU Cycles: 2043195
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 76
// - Gas Used: 1143527
// - Storage Diff: 4471
// - CPU Cycles: 970128
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 77
// - Gas Used: 2313204
// - Storage Diff: 12925
// - CPU Cycles: 2043195
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 77
// - Gas Used: 1157620
// - Storage Diff: 4471
// - CPU Cycles: 983024
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 78
// - Gas Used: 2317382
// - Storage Diff: 12925
// - CPU Cycles: 2046419
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 78
// - Gas Used: 1158817
// - Storage Diff: 4471
// - CPU Cycles: 983024
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 79
// - Gas Used: 2318336
// - Storage Diff: 12925
// - CPU Cycles: 2046419
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 79
// - Gas Used: 1159030
// - Storage Diff: 4471
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 80
// - Gas Used: 2317034
// - Storage Diff: 12925
// - CPU Cycles: 2046503
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 80
// - Gas Used: 1161207
// - Storage Diff: 4471
// - CPU Cycles: 983020
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 81
// - Gas Used: 2635277
// - Storage Diff: 19531
// - CPU Cycles: 2297576
// - Realm gno.land/r/gnoswap/gov/governance: 19531
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 81
// - Gas Used: 1141808
// - Storage Diff: 4507
// - CPU Cycles: 970128
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 82
// - Gas Used: 2303140
// - Storage Diff: 12937
// - CPU Cycles: 2037079
// - Realm gno.land/r/gnoswap/gov/governance: 12937
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 82
// - Gas Used: 1143001
// - Storage Diff: 4471
// - CPU Cycles: 970124
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 83
// - Gas Used: 2304091
// - Storage Diff: 12925
// - CPU Cycles: 2037076
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 83
// - Gas Used: 1156110
// - Storage Diff: 4471
// - CPU Cycles: 982036
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 84
// - Gas Used: 2314471
// - Storage Diff: 12925
// - CPU Cycles: 2046502
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 84
// - Gas Used: 1157311
// - Storage Diff: 4471
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 85
// - Gas Used: 2315428
// - Storage Diff: 12925
// - CPU Cycles: 2046505
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 85
// - Gas Used: 1158508
// - Storage Diff: 4471
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 86
// - Gas Used: 2316382
// - Storage Diff: 12925
// - CPU Cycles: 2046505
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 86
// - Gas Used: 1159705
// - Storage Diff: 4471
// - CPU Cycles: 982040
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 87
// - Gas Used: 2317336
// - Storage Diff: 12925
// - CPU Cycles: 2046505
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 87
// - Gas Used: 1161886
// - Storage Diff: 4471
// - CPU Cycles: 983024
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 88
// - Gas Used: 2318536
// - Storage Diff: 12925
// - CPU Cycles: 2046751
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 88
// - Gas Used: 1163083
// - Storage Diff: 4471
// - CPU Cycles: 983024
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 89
// - Gas Used: 2636706
// - Storage Diff: 19531
// - CPU Cycles: 2297577
// - Realm gno.land/r/gnoswap/gov/governance: 19531
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 89
// - Gas Used: 1143680
// - Storage Diff: 4507
// - CPU Cycles: 970128
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 90
// - Gas Used: 2299806
// - Storage Diff: 12937
// - CPU Cycles: 2034831
// - Realm gno.land/r/gnoswap/gov/governance: 12937
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 90
// - Gas Used: 1144873
// - Storage Diff: 4471
// - CPU Cycles: 970124
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 91
// - Gas Used: 2300759
// - Storage Diff: 12925
// - CPU Cycles: 2034830
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 91
// - Gas Used: 1158966
// - Storage Diff: 4471
// - CPU Cycles: 983020
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 92
// - Gas Used: 2304937
// - Storage Diff: 12925
// - CPU Cycles: 2038054
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 92
// - Gas Used: 1160167
// - Storage Diff: 4471
// - CPU Cycles: 983024
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 93
// - Gas Used: 2305894
// - Storage Diff: 12925
// - CPU Cycles: 2038057
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 93
// - Gas Used: 1161364
// - Storage Diff: 4471
// - CPU Cycles: 983024
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 94
// - Gas Used: 2306848
// - Storage Diff: 12925
// - CPU Cycles: 2038057
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 94
// - Gas Used: 1162561
// - Storage Diff: 4471
// - CPU Cycles: 983024
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 95
// - Gas Used: 2307802
// - Storage Diff: 12925
// - CPU Cycles: 2038057
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 95
// - Gas Used: 1163758
// - Storage Diff: 4471
// - CPU Cycles: 983024
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 96
// - Gas Used: 2315204
// - Storage Diff: 12925
// - CPU Cycles: 2044505
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 96
// - Gas Used: 1164951
// - Storage Diff: 4471
// - CPU Cycles: 983020
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 97
// - Gas Used: 2564069
// - Storage Diff: 19251
// - CPU Cycles: 2224352
// - Realm gno.land/r/gnoswap/gov/governance: 19251
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 97
// - Gas Used: 1124277
// - Storage Diff: 4507
// - CPU Cycles: 957232
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 98
// - Gas Used: 2278264
// - Storage Diff: 12937
// - CPU Cycles: 2018713
// - Realm gno.land/r/gnoswap/gov/governance: 12937
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 98
// - Gas Used: 1125474
// - Storage Diff: 4471
// - CPU Cycles: 957232
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 99
// - Gas Used: 2285666
// - Storage Diff: 12925
// - CPU Cycles: 2025161
// - Realm gno.land/r/gnoswap/gov/governance: 12925
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 99
// - Gas Used: 1126671
// - Storage Diff: 4471
// - CPU Cycles: 957232
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 100
// - Gas Used: 2378394
// - Storage Diff: 12910
// - CPU Cycles: 2096376
// - Realm gno.land/r/gnoswap/gov/governance: 12910
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 100
// - Gas Used: 1252258
// - Storage Diff: 4471
// - CPU Cycles: 1074333
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 101
// - Gas Used: 2404131
// - Storage Diff: 12886
// - CPU Cycles: 2120843
// - Realm gno.land/r/gnoswap/gov/governance: 12886
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 101
// - Gas Used: 1265375
// - Storage Diff: 4471
// - CPU Cycles: 1086253
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 102
// - Gas Used: 2414401
// - Storage Diff: 12886
// - CPU Cycles: 2130273
// - Realm gno.land/r/gnoswap/gov/governance: 12886
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 102
// - Gas Used: 1267556
// - Storage Diff: 4471
// - CPU Cycles: 1087237
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 103
// - Gas Used: 2409529
// - Storage Diff: 12886
// - CPU Cycles: 2124561
// - Realm gno.land/r/gnoswap/gov/governance: 12886
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 103
// - Gas Used: 1268753
// - Storage Diff: 4471
// - CPU Cycles: 1087237
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 104
// - Gas Used: 2410369
// - Storage Diff: 12886
// - CPU Cycles: 2124561
// - Realm gno.land/r/gnoswap/gov/governance: 12886
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 104
// - Gas Used: 1258034
// - Storage Diff: 4471
// - CPU Cycles: 1075321
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 105
// - Gas Used: 2413696
// - Storage Diff: 12886
// - CPU Cycles: 2127048
// - Realm gno.land/r/gnoswap/gov/governance: 12886
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 105
// - Gas Used: 1272131
// - Storage Diff: 4471
// - CPU Cycles: 1088221
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 106
// - Gas Used: 2417761
// - Storage Diff: 12886
// - CPU Cycles: 2130273
// - Realm gno.land/r/gnoswap/gov/governance: 12886
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 106
// - Gas Used: 1271360
// - Storage Diff: 4471
// - CPU Cycles: 1086253
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 107
// - Gas Used: 2418601
// - Storage Diff: 12886
// - CPU Cycles: 2130273
// - Realm gno.land/r/gnoswap/gov/governance: 12886
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 107
// - Gas Used: 1272557
// - Storage Diff: 4471
// - CPU Cycles: 1086253
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 108
// - Gas Used: 2727637
// - Storage Diff: 19348
// - CPU Cycles: 2381179
// - Realm gno.land/r/gnoswap/gov/governance: 19348
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 108
// - Gas Used: 1254704
// - Storage Diff: 4507
// - CPU Cycles: 1075321
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 109
// - Gas Used: 2404840
// - Storage Diff: 12940
// - CPU Cycles: 2121582
// - Realm gno.land/r/gnoswap/gov/governance: 12940
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 109
// - Gas Used: 1267817
// - Storage Diff: 4471
// - CPU Cycles: 1087237
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 110
// - Gas Used: 2406763
// - Storage Diff: 12928
// - CPU Cycles: 2124891
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 110
// - Gas Used: 1258078
// - Storage Diff: 4471
// - CPU Cycles: 1076301
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 111
// - Gas Used: 2410457
// - Storage Diff: 12928
// - CPU Cycles: 2127625
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 111
// - Gas Used: 1259279
// - Storage Diff: 4471
// - CPU Cycles: 1076305
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 112
// - Gas Used: 2411418
// - Storage Diff: 12928
// - CPU Cycles: 2127626
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 112
// - Gas Used: 1271408
// - Storage Diff: 4471
// - CPU Cycles: 1087237
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 113
// - Gas Used: 2415603
// - Storage Diff: 12928
// - CPU Cycles: 2130851
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 113
// - Gas Used: 1272605
// - Storage Diff: 4471
// - CPU Cycles: 1087237
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 114
// - Gas Used: 2416563
// - Storage Diff: 12928
// - CPU Cycles: 2130851
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 114
// - Gas Used: 1274786
// - Storage Diff: 4471
// - CPU Cycles: 1088221
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 115
// - Gas Used: 2417769
// - Storage Diff: 12928
// - CPU Cycles: 2131097
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 115
// - Gas Used: 1275983
// - Storage Diff: 4471
// - CPU Cycles: 1088221
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 116
// - Gas Used: 2752187
// - Storage Diff: 19536
// - CPU Cycles: 2384563
// - Realm gno.land/r/gnoswap/gov/governance: 19536
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 116
// - Gas Used: 1256576
// - Storage Diff: 4507
// - CPU Cycles: 1075321
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 117
// - Gas Used: 2404080
// - Storage Diff: 12940
// - CPU Cycles: 2121914
// - Realm gno.land/r/gnoswap/gov/governance: 12940
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 117
// - Gas Used: 1270673
// - Storage Diff: 4471
// - CPU Cycles: 1088221
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 118
// - Gas Used: 2408265
// - Storage Diff: 12928
// - CPU Cycles: 2125139
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 118
// - Gas Used: 1259954
// - Storage Diff: 4471
// - CPU Cycles: 1076305
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 119
// - Gas Used: 2411712
// - Storage Diff: 12928
// - CPU Cycles: 2127626
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 119
// - Gas Used: 1261151
// - Storage Diff: 4471
// - CPU Cycles: 1076305
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 120
// - Gas Used: 2410656
// - Storage Diff: 12928
// - CPU Cycles: 2127956
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 120
// - Gas Used: 1274260
// - Storage Diff: 4471
// - CPU Cycles: 1088217
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 121
// - Gas Used: 2414596
// - Storage Diff: 12928
// - CPU Cycles: 2130936
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 121
// - Gas Used: 1275457
// - Storage Diff: 4471
// - CPU Cycles: 1088217
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 122
// - Gas Used: 2415554
// - Storage Diff: 12928
// - CPU Cycles: 2130934
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 122
// - Gas Used: 1276654
// - Storage Diff: 4471
// - CPU Cycles: 1088217
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 123
// - Gas Used: 2417006
// - Storage Diff: 12928
// - CPU Cycles: 2131426
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 123
// - Gas Used: 1277855
// - Storage Diff: 4471
// - CPU Cycles: 1088221
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 124
// - Gas Used: 2753947
// - Storage Diff: 19536
// - CPU Cycles: 2384895
// - Realm gno.land/r/gnoswap/gov/governance: 19536
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 124
// - Gas Used: 1260416
// - Storage Diff: 4507
// - CPU Cycles: 1077289
// - Realm gno.land/r/gnoswap/gov/governance: 4507
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 125
// - Gas Used: 2409278
// - Storage Diff: 12940
// - CPU Cycles: 2128204
// - Realm gno.land/r/gnoswap/gov/governance: 12940
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 125
// - Gas Used: 1261613
// - Storage Diff: 4471
// - CPU Cycles: 1077289
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 126
// - Gas Used: 2410238
// - Storage Diff: 12928
// - CPU Cycles: 2128204
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 126
// - Gas Used: 1273742
// - Storage Diff: 4471
// - CPU Cycles: 1088221
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 127
// - Gas Used: 2414423
// - Storage Diff: 12928
// - CPU Cycles: 2131429
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 127
// - Gas Used: 1274939
// - Storage Diff: 4471
// - CPU Cycles: 1088221
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) create 128
// - Gas Used: 2415383
// - Storage Diff: 12928
// - CPU Cycles: 2131429
// - Realm gno.land/r/gnoswap/gov/governance: 12928
// Proposal metadata lifecycle text (4KiB, 96 proposals, total 128) vote 128
// - Gas Used: 1277120
// - Storage Diff: 4471
// - CPU Cycles: 1089205
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// STATE proposal-metadata aggregate proposalCount 128 passedCount 128 first 1 middle 64 last 128
// STATE proposal-metadata 1 currentProposalID 128 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234567915 createdHeight 128 snapshotTime 1234567915 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 1 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 64 currentProposalID 128 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234568545 createdHeight 254 snapshotTime 1234568545 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 64 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 128 currentProposalID 128 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569185 createdHeight 382 snapshotTime 1234569185 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata text 128 descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// Proposal metadata root Proposal reads (128 proposals)
// - Gas Used: 21303579
// - Storage Diff: 0
// - CPU Cycles: 20312197
// Proposal metadata nested metadata reads (128 proposals)
// - Gas Used: 25044875
// - Storage Diff: 0
// - CPU Cycles: 24202026
// Proposal metadata list and voting-info reads (128 proposals)
// - Gas Used: 22759662
// - Storage Diff: 0
// - CPU Cycles: 21605364
// Proposal metadata create text (8KiB, total 129)
// - Gas Used: 2430344
// - Storage Diff: 17324
// - CPU Cycles: 2131429
// - Realm gno.land/r/gnoswap/gov/governance: 17324
// STATE proposal-metadata 129 currentProposalID 129 type Text status active proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569195 createdHeight 384 snapshotTime 1234569195 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata 8KiB descriptionLen 8800 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 0 userProposalEntries 1
// Proposal metadata root Proposal read (8KiB)
// - Gas Used: 239395
// - Storage Diff: 0
// - CPU Cycles: 226561
// Proposal metadata nested metadata reads (8KiB)
// - Gas Used: 269860
// - Storage Diff: 0
// - CPU Cycles: 259555
// Proposal metadata vote text (8KiB)
// - Gas Used: 1278317
// - Storage Diff: 4471
// - CPU Cycles: 1089205
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// STATE proposal-metadata 129 currentProposalID 129 type Text status passed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569195 createdHeight 384 snapshotTime 1234569195 configVersion 2 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata 8KiB descriptionLen 8800 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent false executionNum -1 executionMessages -1 votingInfos 1 userProposalEntries 1
// Proposal metadata create spend (8KiB)
// - Gas Used: 2945187
// - Storage Diff: 19565
// - CPU Cycles: 2524333
// - Realm gno.land/r/gnoswap/gov/governance: 19193
// - Realm gno.land/r/gnoswap/gov/governance/v1: 372
// STATE proposal-metadata 130 currentProposalID 130 type CommunityPoolSpend status upcoming proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 3 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata spend descriptionLen 8800 metadataPresent true spendPresent true spendTo g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 spendToken gno.land/r/gnoswap/gns.GNS spendAmount 100 executionPresent true executionNum 1 executionMessages 1 votingInfos 0 userProposalEntries 1
// Proposal metadata cancel spend
// - Gas Used: 670804
// - Storage Diff: 106
// - CPU Cycles: 437880
// - Realm gno.land/r/gnoswap/gov/governance: 106
// STATE proposal-metadata 130 currentProposalID 130 type CommunityPoolSpend status canceled proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 3 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata spend descriptionLen 8800 metadataPresent true spendPresent true spendTo g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 spendToken gno.land/r/gnoswap/gns.GNS spendAmount 100 executionPresent true executionNum 1 executionMessages 1 votingInfos 0 userProposalEntries 1
// Proposal metadata create parameter change (4KiB)
// - Gas Used: 3436895
// - Storage Diff: 14153
// - CPU Cycles: 3064298
// - Realm gno.land/r/gnoswap/gov/governance: 13859
// - Realm gno.land/r/gnoswap/gov/governance/v1: 294
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status active proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 0 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 0 userProposalEntries 1
// Proposal metadata vote parameter change
// - Gas Used: 1285008
// - Storage Diff: 4471
// - CPU Cycles: 1093129
// - Realm gno.land/r/gnoswap/gov/governance: 4471
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status active proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 1 userProposalEntries 1
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status executable proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 1 userProposalEntries 1
// Proposal metadata execute parameter change
// - Gas Used: 2676788
// - Storage Diff: 76
// - CPU Cycles: 1427737
// - Realm gno.land/r/gnoswap/gov/governance: 76
// STATE proposal-metadata 131 currentProposalID 131 type ParameterChange status executed proposer g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 createdAt 1234569205 createdHeight 386 snapshotTime 1234569205 configVersion 4 quorum 500000000 maxVotingWeight 1000000000 yea 1000000000 nay 0 title Metadata parameter descriptionLen 4400 metadataPresent true spendPresent false spendTo  spendToken  spendAmount -1 executionPresent true executionNum 1 executionMessages 1 votingInfos 1 userProposalEntries 1
