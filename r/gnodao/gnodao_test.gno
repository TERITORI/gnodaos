package gnodao

import (
	"std"
	"testing"
	"time"
)

var caller std.Address = "g1rel7980x4y257yh30umy3jx223efwakvnabcde"
var caller1 std.Address = "g1rel7980x4y257yh30umy3jx223efwakvnaaaaa"
var caller2 std.Address = "g1rel7980x4y257yh30umy3jx223efwakvnbbbbb"
var daoMembers = []std.Address{
	"g1rel7980x4y257yh30umy3jx223efwakvnaaaaa",
	"g1rel7980x4y257yh30umy3jx223efwakvnbbbbb",
	"g1rel7980x4y257yh30umy3jx223efwakvnccccc",
}
var votingPowers = []VotingPower{
	{
		address: daoMembers[0].String(),
		power:   1,
	},
	{
		address: daoMembers[1].String(),
		power:   2,
	},
	{
		address: daoMembers[2].String(),
		power:   3,
	},
}

func assertPanic(t *testing.T, f func()) {
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("The code did not panic")
		}
	}()
	f()
}

func TestIsDAOMember(t *testing.T) {
	daos = []DAO{}
	CreateDAO(
		"https://gnodao1.org",
		"https://metadata.gnodao1.org",
		votingPowers,
		86400*2,
		30,
		10,
		10,
	)

	// TODO: what package is ideal to use for checks?
	if IsDAOMember(0, caller) != false {
		t.Errorf("Should not be false")
	}
	if IsDAOMember(0, caller1) != true {
		t.Errorf("Should be true")
	}
	if IsDAOMember(0, caller2) != true {
		t.Errorf("Should be true")
	}
}

func TestCreateDAO(t *testing.T) {
	daos = []DAO{}
	proposals = [][]Proposal{}
	CreateDAO(
		"https://gnodao1.org",
		"https://metadata.gnodao1.org",
		votingPowers,
		86400*2,
		30,
		10,
		10,
	)
	if len(daos) != 1 {
		t.Errorf("Number of daos be 1")
	}
	if len(proposals) != 1 {
		t.Errorf("Number of daos be 1")
	}
	dao := daos[0]
	if dao.id != 0 {
		t.Errorf("first DAO id should be 0")
	}
	if dao.uri != "https://gnodao1.org" {
		t.Errorf("dao uri not set properly")
	}
	if dao.metadata != "https://metadata.gnodao1.org" {
		t.Errorf("dao metadata not set properly")
	}
	if dao.funds != 0 {
		t.Errorf("dao funds not set properly")
	}
	if len(dao.depositHistory) != 0 {
		t.Errorf("dao deposit history not set properly")
	}
	if len(dao.spendHistory) != 0 {
		t.Errorf("dao spend history not set properly")
	}
	if len(dao.permissions) != 0 {
		t.Errorf("dao permissions not set properly")
	}
	if dao.permMap == nil {
		t.Errorf("dao permission map not set properly")
	}
	if getDAOVotingPower(0, caller.String()) != 0 {
		t.Errorf("voting power not set properly")
	}
	if getDAOVotingPower(0, caller1.String()) != 1 {
		t.Errorf("voting power not set properly")
	}
	if getDAOVotingPower(0, caller2.String()) != 2 {
		t.Errorf("voting power not set properly")
	}
	if dao.totalVotingPower != 6 {
		t.Errorf("totalVotingPower not set properly")
	}
	if dao.votingPeriod != 86400*2 {
		t.Errorf("votingPeriod not set properly")
	}
	if dao.voteQuorum != 30 {
		t.Errorf("voteQuorum not set properly")
	}
	if dao.threshold != 10 {
		t.Errorf("threshold not set properly")
	}
	if dao.vetoThreshold != 10 {
		t.Errorf("vetoThreshold not set properly")
	}
}

// TODO: add test for CreateProposal
// TODO: add test for Vote
// TODO: add test for TallyAndExecute
// TODO: add test for DepositDAO
// TODO: add test for GetDAO
// TODO: add test for GetDAOs
// TODO: add test for GetProposal
// TODO: add test for GetProposals
// TODO: add test for Render
