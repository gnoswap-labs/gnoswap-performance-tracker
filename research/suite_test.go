package research

import (
	"testing"

	"github.com/stretchr/testify/suite"
)

type E2ETestSuite struct {
	suite.Suite
	env       *TestEnv
	gnoSender string
}

const testAccountAddress = "g1z437dpuh5s4p64vtq09dulg6jzxpr2hd4q8r5x"

func TestE2E(t *testing.T) {
	suite.Run(t, new(E2ETestSuite))
}

func (s *E2ETestSuite) SetupSuite() {
	s.env = mustSetupTestEnv(s.T())
	s.gnoSender = testAccountAddress
	s.Require().Regexp(`^g1[0-9a-z]+$`, s.gnoSender)
}

func (s *E2ETestSuite) mustEvalAddress(expr string) string {
	return s.env.mustEvalAddress(s.T(), expr)
}
