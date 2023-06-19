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

func TestCreateProposal(t *testing.T) {
	daos = []DAO{}
	proposals = [][]Proposal{}
	CreateDAO("https://gnodao1.org", "https://metadata.gnodao1.org", votingPowers, 86400*2, 30, 10, 10)

	assertPanic(t, func() {
		std.TestSetOrigCaller(caller)
		CreateProposal(0, "DAO fund bootstrap proposal", "Proposal to bootstrap DAO fund.", 0, caller, []VotingPower{}, "", "")
	})

	std.TestSetOrigCaller(caller1)
	CreateProposal(0, "DAO fund bootstrap proposal", "Proposal to bootstrap DAO fund.", 0, caller, []VotingPower{}, "", "")
	proposal := proposals[0][0]
	if proposal.daoId != 0 {
		t.Errorf("proposal daoId should be 0")
	}
	if proposal.id != 0 {
		t.Errorf("proposal id should be 0")
	}
	if proposal.title != "DAO fund bootstrap proposal" {
		t.Errorf("proposal title not set properly")
	}
	if proposal.summary != "Proposal to bootstrap DAO fund." {
		t.Errorf("proposal summary not set properly")
	}
	if proposal.spendAmount != 0 {
		t.Errorf("proposal spendAmount not set properly")
	}
	if proposal.spender != caller {
		t.Errorf("proposal spender not set properly")
	}
	if len(proposal.vpUpdates) != 0 {
		t.Errorf("proposal vpUpdates not set properly")
	}
	if proposal.newMetadata != "" {
		t.Errorf("proposal newMetadata not set properly")
	}
	if proposal.newURI != "" {
		t.Errorf("proposal newURI not set properly")
	}
	if proposal.submitTime != uint64(time.Now().Unix()) {
		t.Errorf("proposal submitTime not set properly")
	}
	if proposal.voteEndTime != uint64(time.Now().Unix())+daos[0].votingPeriod {
		t.Errorf("proposal voteEndTime not set properly")
	}
	if proposal.status != VOTING_PERIOD {
		t.Errorf("proposal status not set properly")
	}
	if proposal.votes == nil {
		t.Errorf("proposal votes not set properly")
	}
	if len(proposal.votingPowers) != 4 {
		t.Errorf("proposal votingPowers not set properly")
	}
}

func TestVoteProposal(t *testing.T) {
	daos = []DAO{}
	proposals = [][]Proposal{}
	CreateDAO("https://gnodao1.org", "https://metadata.gnodao1.org", votingPowers, 86400*2, 30, 10, 10)
	std.TestSetOrigCaller(caller1)
	CreateProposal(0, "DAO fund bootstrap proposal", "Proposal to bootstrap DAO fund.", 0, caller, []VotingPower{}, "", "")
	assertPanic(t, func() { // invalid dao id
		std.TestSetOrigCaller(caller1)
		VoteProposal(1, 0, YES)
	})
	assertPanic(t, func() { // invalid proposal id
		std.TestSetOrigCaller(caller1)
		VoteProposal(0, 1, YES)
	})
	assertPanic(t, func() { // not dao member
		std.TestSetOrigCaller(caller)
		VoteProposal(0, 0, YES)
	})

	// vote and check result is set properly
	std.TestSetOrigCaller(caller1)
	VoteProposal(0, 0, YES)
	vote, found := getVote(0, 0, caller1)
	if !found {
		t.Errorf("proposal vote not set")
	}
	if vote.address != caller1 {
		t.Errorf("vote address not set properly")
	}
	if vote.timestamp != uint64(time.Now().Unix()) {
		t.Errorf("vote timestamp not set properly")
	}
	if vote.option != YES {
		t.Errorf("vote option not set properly")
	}
	if proposals[0][0].votingPowers[int(YES)] != 1 {
		t.Errorf("votePowers by vote option not set properly")
	}

	// vote again with different option and check result
	VoteProposal(0, 0, NO)
	vote, found = getVote(0, 0, caller1)
	if vote.option != NO {
		t.Errorf("vote option not set properly")
	}
	if proposals[0][0].votingPowers[int(YES)] != 0 {
		t.Errorf("votePowers for YES not set properly")
	}
	if proposals[0][0].votingPowers[int(NO)] != 1 {
		t.Errorf("votePowers for NO not set properly")
	}

	// test vote end time already reached
	assertPanic(t, func() { // not dao member
		std.TestSetOrigCaller(caller)
		proposals[0][0].voteEndTime = uint64(time.Now().Unix()) - 1
		VoteProposal(0, 0, YES)
	})
}

// TODO: add test for TallyAndExecute
// TODO: add test for DepositDAO
// TODO: add test for GetDAO
// TODO: add test for GetDAOs
// TODO: add test for GetProposal
// TODO: add test for GetProposals
// TODO: add test for Render
