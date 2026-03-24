package research

func (s *E2ETestSuite) TestGnoswapContractsAreDeployed() {
	poolAddr := s.mustEvalAddress(`gno.land/r/gnoswap/access.MustGetAddress("pool")`)
	positionAddr := s.mustEvalAddress(`gno.land/r/gnoswap/access.MustGetAddress("position")`)

	s.Require().NotEqual(poolAddr, positionAddr)
}

func (s *E2ETestSuite) TestPoolAddressIsStable() {
	poolAddr := s.mustEvalAddress(`gno.land/r/gnoswap/access.MustGetAddress("pool")`)
	poolAddrAgain := s.mustEvalAddress(`gno.land/r/gnoswap/access.MustGetAddress("pool")`)
	s.Require().Equal(poolAddr, poolAddrAgain)
}
