// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Real launchpad project lifecycle for the Project value-payload PoC.
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	ufmt "gno.land/p/nt/ufmt/v0"
	_ "gno.land/r/gnoswap/gov/staker"
	_ "gno.land/r/gnoswap/gov/staker/v1"
	_ "gno.land/r/gnoswap/launchpad/v1"

	"gno.land/r/gnoswap/access"
	"gno.land/r/gnoswap/launchpad"
	"gno.land/r/onbloc/obl"

	"gno.land/r/gnoswap/scenario/metric"
)

const (
	blockTimeSeconds int64 = 5
	daySeconds       int64 = 24 * 60 * 60
	maxInt64         int64 = 9223372036854775807

	batchProjectStageOne     = 32
	batchProjectStageTotal    = 128
	batchProjectRewardAmount int64 = 10_000_000
)

var (
	adminAddr, _ = access.GetAddress(prabc.ROLE_ADMIN.String())
	adminRealm   = testing.NewUserRealm(adminAddr)

	launchpadAddr, _ = access.GetAddress(prabc.ROLE_LAUNCHPAD.String())

	projectAddr = testutils.TestAddress("project-recipient")
)

func main(cur realm) {
	initializeProjectSetup(cur)

	initialProjectID := ""
	initialStartTime := time.Now().Unix() + 4*daySeconds
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("Project create initial (conditions and tiers)", func() {
		initialProjectID = launchpad.CreateProject(
			cross(cur),
			"Project value initial",
			"gno.land/r/onbloc/obl.OBL",
			projectAddr,
			int64(1_000_000_000),
			"gno.land/r/onbloc/obl.OBL",
			"1000000",
			int64(10),
			int64(20),
			int64(70),
			initialStartTime,
		)
	})
	assertProjectConfigured(initialProjectID, int64(1_000_000_000), int64(1000000))
	printProjectState(initialProjectID)

	metric.PrintMetricsBy("Project getters initial", func() {
		launchpad.GetProjects().Get(initialProjectID)
		launchpad.GetProjectName(initialProjectID)
		launchpad.GetProjectTokenPath(initialProjectID)
		launchpad.GetProjectDepositAmount(initialProjectID)
		launchpad.GetProjectRecipient(initialProjectID)
		launchpad.GetProjectTiersRatios(initialProjectID)
		launchpad.GetProjectCreatedHeight(initialProjectID)
		launchpad.GetProjectCreatedAt(initialProjectID)
		launchpad.GetProjectCondition(initialProjectID, "gno.land/r/onbloc/obl.OBL")
		for _, duration := range []int64{30, 90, 180} {
			launchpad.GetProjectTier(initialProjectID, duration)
			launchpad.GetProjectTierTotalDistributeAmount(initialProjectID, duration)
		}
	})
	metric.PrintMetricsBy("Project getters repeated", func() {
		launchpad.GetProjects().Get(initialProjectID)
		launchpad.GetProjectName(initialProjectID)
		launchpad.GetProjectTokenPath(initialProjectID)
		launchpad.GetProjectDepositAmount(initialProjectID)
		launchpad.GetProjectRecipient(initialProjectID)
		launchpad.GetProjectTiersRatios(initialProjectID)
		launchpad.GetProjectCreatedHeight(initialProjectID)
		launchpad.GetProjectCreatedAt(initialProjectID)
		launchpad.GetProjectCondition(initialProjectID, "gno.land/r/onbloc/obl.OBL")
		for _, duration := range []int64{30, 90, 180} {
			launchpad.GetProjectTier(initialProjectID, duration)
			launchpad.GetProjectTierTotalDistributeAmount(initialProjectID, duration)
		}
		launchpad.GetProjectName(initialProjectID)
		launchpad.GetProjectTokenPath(initialProjectID)
		launchpad.GetProjectDepositAmount(initialProjectID)
		launchpad.GetProjectRecipient(initialProjectID)
		launchpad.GetProjectTiersRatios(initialProjectID)
		launchpad.GetProjectCreatedHeight(initialProjectID)
		launchpad.GetProjectCreatedAt(initialProjectID)
		launchpad.GetProjectCondition(initialProjectID, "gno.land/r/onbloc/obl.OBL")
		for _, duration := range []int64{30, 90, 180} {
			launchpad.GetProjectTier(initialProjectID, duration)
			launchpad.GetProjectTierTotalDistributeAmount(initialProjectID, duration)
		}
	})

	// A second real project exercises another tree insertion with a different
	// allocation shape while keeping the workload on the Project value itself.
	secondProjectID := ""
	secondStartTime := time.Now().Unix() + 4*daySeconds
	testing.SkipHeights(1)
	testing.SetRealm(adminRealm)
	metric.PrintMetricsBy("Project create repeated insertion", func() {
		secondProjectID = launchpad.CreateProject(
			cross(cur),
			"Project value repeated",
			"gno.land/r/onbloc/obl.OBL",
			projectAddr,
			int64(500_000_000),
			"",
			"",
			int64(25),
			int64(25),
			int64(50),
			secondStartTime,
		)
	})
	assertProjectConfigured(secondProjectID, int64(500_000_000), 0)
	printProjectState(secondProjectID)

	// Keep the larger population bounded at 128: each entry still carries all
	// three tiers, making this a realistic project-tree workload rather than a
	// synthetic thousand-entry stress test.
	batchProjectIDs := make([]string, 0, batchProjectStageTotal)

	testing.SetRealm(adminRealm)
	testing.SkipHeights(1)
	stageOneStartTime := time.Now().Unix() + 4*daySeconds
	metric.PrintMetricsBy("Project create population (32)", func() {
		for i := len(batchProjectIDs); i < batchProjectStageOne; i++ {
			projectID := launchpad.CreateProject(
				cross(cur),
				ufmt.Sprintf("Project value population %d", i+1),
				"gno.land/r/onbloc/obl.OBL",
				projectAddr,
				batchProjectRewardAmount,
				"",
				"",
				int64(10),
				int64(20),
				int64(70),
				stageOneStartTime,
			)
			batchProjectIDs = append(batchProjectIDs, projectID)
			testing.SkipHeights(1)
		}
	})
	assertBatchPopulation("create-32", batchProjectIDs, 2+len(batchProjectIDs))
	assertBatchProjectSamples("create-32", batchProjectIDs)
	printBatchPopulationSamples("create-32", batchProjectIDs)

	metric.PrintMetricsBy("Project getters population (32)", func() {
		readProjectPopulation(batchProjectIDs)
	})

	testing.SetRealm(adminRealm)
	testing.SkipHeights(1)
	stageTwoStartTime := time.Now().Unix() + 4*daySeconds
	metric.PrintMetricsBy("Project create population add 96 (128 total)", func() {
		for i := len(batchProjectIDs); i < batchProjectStageTotal; i++ {
			projectID := launchpad.CreateProject(
				cross(cur),
				ufmt.Sprintf("Project value population %d", i+1),
				"gno.land/r/onbloc/obl.OBL",
				projectAddr,
				batchProjectRewardAmount,
				"",
				"",
				int64(10),
				int64(20),
				int64(70),
				stageTwoStartTime,
			)
			batchProjectIDs = append(batchProjectIDs, projectID)
			testing.SkipHeights(1)
		}
	})
	assertBatchPopulation("create-128", batchProjectIDs, 2+len(batchProjectIDs))
	assertBatchProjectSamples("create-128", batchProjectIDs)
	printBatchPopulationSamples("create-128", batchProjectIDs)

	metric.PrintMetricsBy("Project getters population (128)", func() {
		readProjectPopulation(batchProjectIDs)
	})
}

func initializeProjectSetup(cur realm) {
	testing.SetRealm(adminRealm)
	obl.Approve(cross(cur), launchpadAddr, maxInt64)
}



func assertProjectConfigured(projectID string, expectedDeposit, expectedCondition int64) {
	depositAmount, err := launchpad.GetProjectDepositAmount(projectID)
	if err != nil || depositAmount != expectedDeposit {
		panic("project deposit amount mismatch")
	}

	ratio, err := launchpad.GetProjectTiersRatios(projectID)
	if err != nil || ratio[30]+ratio[90]+ratio[180] != 100 {
		panic("project tier ratios mismatch")
	}
	if expectedCondition > 0 {
		condition, err := launchpad.GetProjectCondition(projectID, "gno.land/r/onbloc/obl.OBL")
		if err != nil || condition.MinimumAmount() != expectedCondition {
			panic("project condition mismatch")
		}
	}

	for _, duration := range []int64{30, 90, 180} {
		total, err := launchpad.GetProjectTierTotalDistributeAmount(projectID, duration)
		if err != nil || total != expectedDeposit*ratio[duration]/100 {
			panic("project tier allocation mismatch")
		}
	}
}

func printProjectState(projectID string) {
	projectValue := launchpad.GetProjects().Get(projectID)
	project, ok := projectValue.(*launchpad.Project)
	if !ok {
		panic("project getter did not return *Project")
	}

	createdHeight, err := launchpad.GetProjectCreatedHeight(projectID)
	if err != nil {
		panic(err)
	}
	createdAt, err := launchpad.GetProjectCreatedAt(projectID)
	if err != nil {
		panic(err)
	}

	condition, err := launchpad.GetProjectCondition(projectID, "gno.land/r/onbloc/obl.OBL")
	conditionToken := ""
	conditionAmount := int64(0)
	if err == nil {
		conditionToken = condition.TokenPath()
		conditionAmount = condition.MinimumAmount()
	}

	ratio, err := launchpad.GetProjectTiersRatios(projectID)
	if err != nil {
		panic(err)
	}
	ufmt.Printf("STATE project id=%s name=%s token=%s deposit=%d recipient=%s createdHeight=%d createdAtSet=%t conditionToken=%s conditionAmount=%d ratios=%d/%d/%d\n", project.ID(), project.Name(), project.TokenPath(), project.DepositAmount(), project.Recipient().String(), createdHeight, createdAt > 0, conditionToken, conditionAmount, ratio[30], ratio[90], ratio[180])

	for _, duration := range []int64{30, 90, 180} {
		printTierState(projectID, duration, createdAt)
	}
}

func printTierState(projectID string, duration, projectCreatedAt int64) {
	tier, err := launchpad.GetProjectTier(projectID, duration)
	if err != nil {
		panic(err)
	}
	perSecond, err := launchpad.GetProjectTierDistributeAmountPerSecondX128(projectID, duration)
	if err != nil {
		panic(err)
	}
	totalDistribute, err := launchpad.GetProjectTierTotalDistributeAmount(projectID, duration)
	if err != nil {
		panic(err)
	}
	ufmt.Printf("STATE tier project=%s duration=%d id=%s perSecond=%s distribute=%d startOffset=%d endOffset=%d\n", projectID, duration, tier.ID(), perSecond.ToString(), totalDistribute, tier.StartTime()-projectCreatedAt, tier.EndTime()-projectCreatedAt)
}


func readProjectPopulation(projectIDs []string) {
	projects := launchpad.GetProjects()
	for _, projectID := range projectIDs {
		projects.Get(projectID)
		launchpad.GetProjectName(projectID)
		launchpad.GetProjectTokenPath(projectID)
		launchpad.GetProjectDepositAmount(projectID)
		launchpad.GetProjectRecipient(projectID)
		launchpad.GetProjectTiersRatios(projectID)
		launchpad.GetProjectCreatedHeight(projectID)
		launchpad.GetProjectCreatedAt(projectID)
		for _, duration := range []int64{30, 90, 180} {
			launchpad.GetProjectTier(projectID, duration)
			launchpad.GetProjectTierTotalDistributeAmount(projectID, duration)
		}
	}
}

func assertBatchPopulation(stage string, projectIDs []string, expectedProjectCount int) {
	projects := launchpad.GetProjects()
	if projects.Size() != expectedProjectCount {
		panic("project population count mismatch")
	}
	if len(projectIDs) == 0 {
		panic("project population is empty")
	}

	projectDepositTotal := int64(0)
	tier30DistributeTotal := int64(0)
	tier90DistributeTotal := int64(0)
	tier180DistributeTotal := int64(0)

	for _, projectID := range projectIDs {
		projectValue := projects.Get(projectID)
		project, ok := projectValue.(*launchpad.Project)
		if !ok || project.ID() != projectID || project.DepositAmount() != batchProjectRewardAmount {
			panic("project population value mismatch")
		}

		projectDepositAmount, err := launchpad.GetProjectDepositAmount(projectID)
		if err != nil {
			panic(err)
		}
		projectDepositTotal += projectDepositAmount

		for _, duration := range []int64{30, 90, 180} {
			tierAmount, err := launchpad.GetProjectTierTotalDistributeAmount(projectID, duration)
			if err != nil {
				panic(err)
			}
			switch duration {
			case 30:
				tier30DistributeTotal += tierAmount
				if tierAmount != batchProjectRewardAmount/10 {
					panic("tier 30 distribution mismatch")
				}
			case 90:
				tier90DistributeTotal += tierAmount
				if tierAmount != batchProjectRewardAmount/5 {
					panic("tier 90 distribution mismatch")
				}
			case 180:
				tier180DistributeTotal += tierAmount
				if tierAmount != batchProjectRewardAmount*7/10 {
					panic("tier 180 distribution mismatch")
				}
			}
		}
	}

	expectedProjectDepositTotal := int64(len(projectIDs)) * batchProjectRewardAmount
	if projectDepositTotal != expectedProjectDepositTotal {
		panic("project deposit total mismatch")
	}
	if tier30DistributeTotal != int64(len(projectIDs))*batchProjectRewardAmount/10 ||
		tier90DistributeTotal != int64(len(projectIDs))*batchProjectRewardAmount/5 ||
		tier180DistributeTotal != int64(len(projectIDs))*batchProjectRewardAmount*7/10 {
		panic("project tier distribution total mismatch")
	}

	expectedRewardManagerCount := expectedProjectCount * 3
	if launchpad.GetProjectTierRewardManagerCount() != expectedRewardManagerCount {
		panic("reward manager count mismatch")
	}

	ufmt.Printf("STATE project-population stage=%s projects=%d batchProjects=%d projectDepositTotal=%d tierDistribute=%d/%d/%d rewardManagers=%d\n", stage, expectedProjectCount, len(projectIDs), projectDepositTotal, tier30DistributeTotal, tier90DistributeTotal, tier180DistributeTotal, launchpad.GetProjectTierRewardManagerCount())
}

func assertBatchProjectSamples(stage string, projectIDs []string) {
	if len(projectIDs) == 0 {
		panic("project sample population is empty")
	}

	sampleIDs := []string{projectIDs[0], projectIDs[len(projectIDs)/2], projectIDs[len(projectIDs)-1]}
	projects := launchpad.GetProjects()
	for _, projectID := range sampleIDs {
		projectValue := projects.Get(projectID)
		project, ok := projectValue.(*launchpad.Project)
		if !ok || project.ID() != projectID || project.DepositAmount() != batchProjectRewardAmount {
			panic("project sample value mismatch")
		}

		for _, duration := range []int64{30, 90, 180} {
			tier, err := launchpad.GetProjectTier(projectID, duration)
			expectedAmount := batchProjectRewardAmount * 7 / 10
			if duration == 30 {
				expectedAmount = batchProjectRewardAmount / 10
			} else if duration == 90 {
				expectedAmount = batchProjectRewardAmount / 5
			}
			if err != nil || tier.ID() != projectID+ufmt.Sprintf(":%d", duration) || tier.TotalDistributeAmount() != expectedAmount {
				panic("project sample tier value mismatch")
			}
		}
	}

	ufmt.Printf("STATE project-samples stage=%s first=%s middle=%s last=%s\n", stage, sampleIDs[0], sampleIDs[1], sampleIDs[2])
}

func printBatchPopulationSamples(stage string, projectIDs []string) {
	if len(projectIDs) == 0 {
		panic("cannot print empty project population")
	}
	first := projectIDs[0]
	middle := projectIDs[len(projectIDs)/2]
	last := projectIDs[len(projectIDs)-1]
	ufmt.Printf("STATE project-population-samples stage=%s first=%s middle=%s last=%s\n", stage, first, middle, last)
	printProjectState(first)
	printProjectState(middle)
	printProjectState(last)
}
