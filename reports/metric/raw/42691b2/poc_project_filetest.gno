// PKGPATH: gno.land/r/gnoswap/scenario/metric/main

// Real launchpad project lifecycle for the Project value-payload PoC.
package main

import (
	"testing"
	"time"

	prabc "gno.land/p/gnoswap/rbac"
	"gno.land/p/nt/testutils/v0"
	ufmt "gno.land/p/nt/ufmt/v0"
	_ "gno.land/r/gnoswap/common/v1"
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

	batchProjectStageOne           = 32
	batchProjectStageTotal         = 128
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
	project := readProjectValue(launchpad.GetProjects().Get(projectID))

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
		project := readProjectValue(projects.Get(projectID))
		if project.ID() != projectID || project.DepositAmount() != batchProjectRewardAmount {
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
		project := readProjectValue(projects.Get(projectID))
		if project.ID() != projectID || project.DepositAmount() != batchProjectRewardAmount {
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

// Normalize only validation reads; measured getter calls remain unchanged.
func readProjectValue(value interface{}) launchpad.Project {
	switch project := value.(type) {
	case launchpad.Project:
		return project
	case *launchpad.Project:
		return *project
	default:
		panic("project getter returned an unexpected payload type")
	}
}

// Output:
// Project create initial (conditions and tiers)
// - Gas Used: 8856280
// - Storage Diff: 37161
// - CPU Cycles: 6672738
// STATE project id=gno.land/r/onbloc/obl.OBL:123 name=Project value initial token=gno.land/r/onbloc/obl.OBL deposit=1000000000 recipient=g1wpex76n9vd6z6un9vd5hq6t9de697h6lghtgpc createdHeight=123 createdAtSet=true conditionToken=gno.land/r/onbloc/obl.OBL conditionAmount=1000000 ratios=10/20/70
// STATE tier project=gno.land/r/onbloc/obl.OBL:123 duration=30 id=gno.land/r/onbloc/obl.OBL:123:30 perSecond=13128177736147317263247477138571304454320 distribute=100000000 startOffset=345600 endOffset=2937600
// STATE tier project=gno.land/r/onbloc/obl.OBL:123 duration=90 id=gno.land/r/onbloc/obl.OBL:123:90 perSecond=8752118490764878175498318092380869636213 distribute=200000000 startOffset=345600 endOffset=8121600
// STATE tier project=gno.land/r/onbloc/obl.OBL:123 duration=180 id=gno.land/r/onbloc/obl.OBL:123:180 perSecond=15316207358838536807122056661666521863374 distribute=700000000 startOffset=345600 endOffset=15897600
// Project getters initial
// - Gas Used: 1042674
// - Storage Diff: 0
// - CPU Cycles: 974812
// Project getters repeated
// - Gas Used: 1929708
// - Storage Diff: 0
// - CPU Cycles: 1815654
// Project create repeated insertion
// - Gas Used: 5910385
// - Storage Diff: 24690
// - CPU Cycles: 5513865
// STATE project id=gno.land/r/onbloc/obl.OBL:124 name=Project value repeated token=gno.land/r/onbloc/obl.OBL deposit=500000000 recipient=g1wpex76n9vd6z6un9vd5hq6t9de697h6lghtgpc createdHeight=124 createdAtSet=true conditionToken= conditionAmount=0 ratios=25/25/50
// STATE tier project=gno.land/r/onbloc/obl.OBL:124 duration=30 id=gno.land/r/onbloc/obl.OBL:124:30 perSecond=16410222170184146579059346423214130567901 distribute=125000000 startOffset=345595 endOffset=2937595
// STATE tier project=gno.land/r/onbloc/obl.OBL:124 duration=90 id=gno.land/r/onbloc/obl.OBL:124:90 perSecond=5470074056728048859686448807738043522633 distribute=125000000 startOffset=345595 endOffset=8121595
// STATE tier project=gno.land/r/onbloc/obl.OBL:124 duration=180 id=gno.land/r/onbloc/obl.OBL:124:180 perSecond=5470074056728048859686448807738043522633 distribute=250000000 startOffset=345595 endOffset=15897595
// Project create population (32)
// - Gas Used: 208923802
// - Storage Diff: 827545
// - CPU Cycles: 193686942
// STATE project-population stage=create-32 projects=34 batchProjects=32 projectDepositTotal=320000000 tierDistribute=32000000/64000000/224000000 rewardManagers=102
// STATE project-samples stage=create-32 first=gno.land/r/onbloc/obl.OBL:125 middle=gno.land/r/onbloc/obl.OBL:141 last=gno.land/r/onbloc/obl.OBL:156
// STATE project-population-samples stage=create-32 first=gno.land/r/onbloc/obl.OBL:125 middle=gno.land/r/onbloc/obl.OBL:141 last=gno.land/r/onbloc/obl.OBL:156
// STATE project id=gno.land/r/onbloc/obl.OBL:125 name=Project value population 1 token=gno.land/r/onbloc/obl.OBL deposit=10000000 recipient=g1wpex76n9vd6z6un9vd5hq6t9de697h6lghtgpc createdHeight=125 createdAtSet=true conditionToken= conditionAmount=0 ratios=10/20/70
// STATE tier project=gno.land/r/onbloc/obl.OBL:125 duration=30 id=gno.land/r/onbloc/obl.OBL:125:30 perSecond=131281777361473172632474771385713044543 distribute=1000000 startOffset=345600 endOffset=2937600
// STATE tier project=gno.land/r/onbloc/obl.OBL:125 duration=90 id=gno.land/r/onbloc/obl.OBL:125:90 perSecond=87521184907648781754983180923808696362 distribute=2000000 startOffset=345600 endOffset=8121600
// STATE tier project=gno.land/r/onbloc/obl.OBL:125 duration=180 id=gno.land/r/onbloc/obl.OBL:125:180 perSecond=153162073588385368071220566616665218633 distribute=7000000 startOffset=345600 endOffset=15897600
// STATE project id=gno.land/r/onbloc/obl.OBL:141 name=Project value population 17 token=gno.land/r/onbloc/obl.OBL deposit=10000000 recipient=g1wpex76n9vd6z6un9vd5hq6t9de697h6lghtgpc createdHeight=141 createdAtSet=true conditionToken= conditionAmount=0 ratios=10/20/70
// STATE tier project=gno.land/r/onbloc/obl.OBL:141 duration=30 id=gno.land/r/onbloc/obl.OBL:141:30 perSecond=131281777361473172632474771385713044543 distribute=1000000 startOffset=345520 endOffset=2937520
// STATE tier project=gno.land/r/onbloc/obl.OBL:141 duration=90 id=gno.land/r/onbloc/obl.OBL:141:90 perSecond=87521184907648781754983180923808696362 distribute=2000000 startOffset=345520 endOffset=8121520
// STATE tier project=gno.land/r/onbloc/obl.OBL:141 duration=180 id=gno.land/r/onbloc/obl.OBL:141:180 perSecond=153162073588385368071220566616665218633 distribute=7000000 startOffset=345520 endOffset=15897520
// STATE project id=gno.land/r/onbloc/obl.OBL:156 name=Project value population 32 token=gno.land/r/onbloc/obl.OBL deposit=10000000 recipient=g1wpex76n9vd6z6un9vd5hq6t9de697h6lghtgpc createdHeight=156 createdAtSet=true conditionToken= conditionAmount=0 ratios=10/20/70
// STATE tier project=gno.land/r/onbloc/obl.OBL:156 duration=30 id=gno.land/r/onbloc/obl.OBL:156:30 perSecond=131281777361473172632474771385713044543 distribute=1000000 startOffset=345445 endOffset=2937445
// STATE tier project=gno.land/r/onbloc/obl.OBL:156 duration=90 id=gno.land/r/onbloc/obl.OBL:156:90 perSecond=87521184907648781754983180923808696362 distribute=2000000 startOffset=345445 endOffset=8121445
// STATE tier project=gno.land/r/onbloc/obl.OBL:156 duration=180 id=gno.land/r/onbloc/obl.OBL:156:180 perSecond=153162073588385368071220566616665218633 distribute=7000000 startOffset=345445 endOffset=15897445
// Project getters population (32)
// - Gas Used: 40564988
// - Storage Diff: 0
// - CPU Cycles: 38613307
// Project create population add 96 (128 total)
// - Gas Used: 640179450
// - Storage Diff: 2490381
// - CPU Cycles: 590034148
// STATE project-population stage=create-128 projects=130 batchProjects=128 projectDepositTotal=1280000000 tierDistribute=128000000/256000000/896000000 rewardManagers=390
// STATE project-samples stage=create-128 first=gno.land/r/onbloc/obl.OBL:125 middle=gno.land/r/onbloc/obl.OBL:190 last=gno.land/r/onbloc/obl.OBL:253
// STATE project-population-samples stage=create-128 first=gno.land/r/onbloc/obl.OBL:125 middle=gno.land/r/onbloc/obl.OBL:190 last=gno.land/r/onbloc/obl.OBL:253
// STATE project id=gno.land/r/onbloc/obl.OBL:125 name=Project value population 1 token=gno.land/r/onbloc/obl.OBL deposit=10000000 recipient=g1wpex76n9vd6z6un9vd5hq6t9de697h6lghtgpc createdHeight=125 createdAtSet=true conditionToken= conditionAmount=0 ratios=10/20/70
// STATE tier project=gno.land/r/onbloc/obl.OBL:125 duration=30 id=gno.land/r/onbloc/obl.OBL:125:30 perSecond=131281777361473172632474771385713044543 distribute=1000000 startOffset=345600 endOffset=2937600
// STATE tier project=gno.land/r/onbloc/obl.OBL:125 duration=90 id=gno.land/r/onbloc/obl.OBL:125:90 perSecond=87521184907648781754983180923808696362 distribute=2000000 startOffset=345600 endOffset=8121600
// STATE tier project=gno.land/r/onbloc/obl.OBL:125 duration=180 id=gno.land/r/onbloc/obl.OBL:125:180 perSecond=153162073588385368071220566616665218633 distribute=7000000 startOffset=345600 endOffset=15897600
// STATE project id=gno.land/r/onbloc/obl.OBL:190 name=Project value population 65 token=gno.land/r/onbloc/obl.OBL deposit=10000000 recipient=g1wpex76n9vd6z6un9vd5hq6t9de697h6lghtgpc createdHeight=190 createdAtSet=true conditionToken= conditionAmount=0 ratios=10/20/70
// STATE tier project=gno.land/r/onbloc/obl.OBL:190 duration=30 id=gno.land/r/onbloc/obl.OBL:190:30 perSecond=131281777361473172632474771385713044543 distribute=1000000 startOffset=345440 endOffset=2937440
// STATE tier project=gno.land/r/onbloc/obl.OBL:190 duration=90 id=gno.land/r/onbloc/obl.OBL:190:90 perSecond=87521184907648781754983180923808696362 distribute=2000000 startOffset=345440 endOffset=8121440
// STATE tier project=gno.land/r/onbloc/obl.OBL:190 duration=180 id=gno.land/r/onbloc/obl.OBL:190:180 perSecond=153162073588385368071220566616665218633 distribute=7000000 startOffset=345440 endOffset=15897440
// STATE project id=gno.land/r/onbloc/obl.OBL:253 name=Project value population 128 token=gno.land/r/onbloc/obl.OBL deposit=10000000 recipient=g1wpex76n9vd6z6un9vd5hq6t9de697h6lghtgpc createdHeight=253 createdAtSet=true conditionToken= conditionAmount=0 ratios=10/20/70
// STATE tier project=gno.land/r/onbloc/obl.OBL:253 duration=30 id=gno.land/r/onbloc/obl.OBL:253:30 perSecond=131281777361473172632474771385713044543 distribute=1000000 startOffset=345125 endOffset=2937125
// STATE tier project=gno.land/r/onbloc/obl.OBL:253 duration=90 id=gno.land/r/onbloc/obl.OBL:253:90 perSecond=87521184907648781754983180923808696362 distribute=2000000 startOffset=345125 endOffset=8121125
// STATE tier project=gno.land/r/onbloc/obl.OBL:253 duration=180 id=gno.land/r/onbloc/obl.OBL:253:180 perSecond=153162073588385368071220566616665218633 distribute=7000000 startOffset=345125 endOffset=15897125
// Project getters population (128)
// - Gas Used: 170551222
// - Storage Diff: 0
// - CPU Cycles: 162762747
