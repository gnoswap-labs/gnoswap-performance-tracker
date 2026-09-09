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
	pmdAdminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	pmdAdminRealm   = testing.NewUserRealm(pmdAdminAddr)
	pmdGovStakerAddr, _ = access.GetAddress(prabc.ROLE_GOV_STAKER.String())
	pmdMaxInt64 int64 = 9223372036854775807
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

	// Root + metadata creation/read workload at the 4KiB scale.
	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata create text (4KiB)", func() {
		governance.ProposeText(cross(cur), "Metadata 4KiB", description4KiB)
	})
	text4KiBID := governance.GetCurrentProposalID()
	pmdAssertProposalState(text4KiBID, governance.Text, "active", "Metadata 4KiB", description4KiB, false, false, 0)

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata hot scalar reads (4KiB)", func() {
		for i := 0; i < 8; i++ {
			governance.GetTitleByProposalId(text4KiBID)
			governance.GetDescriptionByProposalId(text4KiBID)
			governance.GetProposalStatusByProposalId(text4KiBID)
			governance.GetProposalTypeByProposalId(text4KiBID)
			governance.GetYeaByProposalId(text4KiBID)
			governance.GetNayByProposalId(text4KiBID)
		}
	})

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata whole getters (4KiB)", func() {
		proposals := governance.GetProposals()
		if proposals == nil || proposals.Size() != 1 {
			panic("proposal whole getter did not expose the created proposal")
		}
		if governance.GetVotingInfos(text4KiBID) == nil {
			panic("proposal voting-info whole getter returned nil")
		}
		if governance.GetUserProposals() == nil {
			panic("user-proposals whole getter returned nil")
		}
	})

	// Vote through the public proxy, then let the text proposal become
	// inactive so the next real proposal creation exercises cleanup/writeback.
	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata vote text (4KiB)", func() {
		governance.Vote(cross(cur), text4KiBID, true)
	})
	pmdAssertProposalState(text4KiBID, governance.Text, "active", "Metadata 4KiB", description4KiB, false, false, 1)
	testing.SkipHeights(2)
	pmdAssertProposalState(text4KiBID, governance.Text, "passed", "Metadata 4KiB", description4KiB, false, false, 1)

	// Repeat a real text proposal at 8KiB to expose description-size scaling.
	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata create text (8KiB)", func() {
		governance.ProposeText(cross(cur), "Metadata 8KiB", description8KiB)
	})
	text8KiBID := governance.GetCurrentProposalID()
	pmdAssertProposalState(text8KiBID, governance.Text, "active", "Metadata 8KiB", description8KiB, false, false, 0)

	testing.SetRealm(pmdAdminRealm)
	metric.PrintMetricsBy("Proposal metadata whole getters (8KiB)", func() {
		proposals := governance.GetProposals()
		if proposals == nil || proposals.Size() != 2 {
			panic("proposal whole getter lost an earlier proposal")
		}
		if governance.GetVotingInfos(text8KiBID) == nil {
			panic("8KiB proposal voting-info getter returned nil")
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
