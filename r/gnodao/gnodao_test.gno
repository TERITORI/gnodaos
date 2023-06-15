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
		"Gno DAO1",
		"https://metadata.gnodao1.org",
		[]VotingPower{
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
		},
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
	if IsDAOMember(0, caller1) != true {
		t.Errorf("Should be true")
	}
}

// TODO: add test for CreateDAO
// TODO: add test for CreateProposal
// TODO: add test for Vote
// TODO: add test for TallyAndExecute
// TODO: add test for DepositDAO
// TODO: add test for GetDAO
// TODO: add test for GetDAOs
// TODO: add test for GetProposal
// TODO: add test for GetProposals
// TODO: add test for Render
