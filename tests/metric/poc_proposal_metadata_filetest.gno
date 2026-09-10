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
	pmdAdminAddr, _    = access.GetAddress(prabc.ROLE_ADMIN.String())
	pmdAdminRealm      = testing.NewUserRealm(pmdAdminAddr)
	pmdGovStakerAddr, _ = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	pmdMaxInt64 int64  = 9223372036854775807
)

const (
	pmdFirstBatchCount  = 32
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
	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy(label, func() {
		for i := 0; i < proposalCount; i++ {
			expectedID := startProposalID + int64(i)

			testing.SetRealm(pmdAdminRealm)
			proposalID := governance.ProposeText(cross(cur), pmdTextTitle(expectedID), description)
			if proposalID != expectedID {
				panic("proposal lifecycle counter diverged")
			}

			testing.SetRealm(pmdAdminRealm)
			governance.Vote(cross(cur), proposalID, true)
			testing.SkipHeights(2)
		}
	})
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
