package research

import (
	"testing"

	"github.com/stretchr/testify/suite"
)

type E2ETestSuite struct {
	suite.Suite
	env *TestEnv
}

func TestE2E(t *testing.T) {
	suite.Run(t, new(E2ETestSuite))
}

func (s *E2ETestSuite) SetupSuite() {
	s.env = mustSetupTestEnv(s.T())
}

func (s *E2ETestSuite) mustEvalAddress(expr string) string {
	return s.env.mustEvalAddress(s.T(), expr)
}
