package gnodao

import (
	"fmt"
	"gno.land/r/boards"
	"std"
	"strconv"
	"strings"
	"time"
)

type VoteOption uint32

const (
	YES          VoteOption = 0 // Indicates approval of the proposal in its current form.
	NO           VoteOption = 1 // Indicates disapproval of the proposal in its current form.
	NO_WITH_VETO VoteOption = 2 // Indicates stronger opposition to the proposal than simply voting No. Not available for SuperMajority-typed proposals as a simple No of 1/3 out of total votes would result in the same outcome.
	ABSTAIN      VoteOption = 3 // Indicates that the voter is impartial to the outcome of the proposal. Although Abstain votes are counted towards the quorum, they're excluded when calculating the ratio of other voting options above.
)

// GNODAO VOTE
type Vote struct {
	address   std.Address // address of the voter
	timestamp uint64      // block timestamp of the vote
	option    VoteOption  // vote option
}

type DAO struct {
	id               uint64
	uri              string                     // DAO homepage link
	metadata         string                     // DAO metadata reference link
	funds            Coins                      // DAO managing funds
	depositHistory   []Deposit                  // deposit history - reserved for later use
	spendHistory     []Spend                    // spend history - reserved for later use
	permissions      []string                   // permissions managed on DAO - reserved for later use
	permMap          map[string]map[string]bool // permission map - reserved for later use
	votingPowers     map[string]uint64
	totalVotingPower uint64
	votingPeriod     uint64
	voteQuorum       uint64
	threshold        uint64
	vetoThreshold    uint64
}

type ProposalStatus uint32

const (
	NIL           ProposalStatus = 0
	VOTING_PERIOD ProposalStatus = 1
	PASSED        ProposalStatus = 2
	REJECTED      ProposalStatus = 3
	FAILED        ProposalStatus = 4
)

func (s ProposalStatus) String() string {
	switch s {
	case NIL:
		return "Nil"
	case VOTING_PERIOD:
		return "VotingPeriod"
	case PASSED:
		return "Passed"
	case REJECTED:
		return "Rejected"
	case FAILED:
		return "Failed"
	}
	return ""
}

type Proposal struct {
	daoId        uint64                // dao id of the proposal
	id           uint64                // unique id assigned for each proposal
	title        string                // proposal title
	summary      string                // proposal summary
	spendAmount  Coins                 // amount of tokens to spend as part the proposal
	spender      std.Address           // address to receive spending tokens
	vpUpdates    map[string]uint64     // updates on voting power - optional
	newMetadata  string                // new metadata for the DAO - optional
	newURI       string                // new URI for the DAO - optional
	submitTime   uint64                // proposal submission time
	voteEndTime  uint64                // vote end time for the proposal
	status       ProposalStatus        // StatusNil | StatusVotingPeriod | StatusPassed | StatusRejected | StatusFailed
	votes        map[string]Vote       // votes on the proposal
	votingPowers map[VoteOption]uint64 // voting power sum per voting option
}

// GNODAO STATE
var daos []DAO
var proposals [][]Proposal

func isDAOMember(daoId uint64, address std.Address) bool {
	if len(daos) => int(daoId) {
		return false
	}
	return daos[int(daoId)].votingPowers[address.String()] > 0
}

// GNODAO FUNCTIONS
func CreateDAO(
	uri              string,
	metadata         string,
	votingPowers     map[string]uint64,
	totalVotingPower uint64,
	votingPeriod     uint64,
	voteQuorum       uint64,
	threshold        uint64,
	vetoThreshold    uint64,
) {
	daoId := uint64(len(daos))
	daos = append(daos, DAO {
		id: daoId,
		uri: uri,
		metadata: metadata,
		funds: Coins{},
		depositHistory: []Deposit{}  , 
		spendHistory: []Spend {},
		permissions: []string{},
		votingPowers: votingPowers,
		totalVotingPower:totalVotingPower,
		votingPeriod: votingPeriod,
		voteQuorum: voteQuorum,
		threshold: threshold,
		vetoThreshold: vetoThreshold,
	})
	proposals = append(proposals, []Proposal{})
}

func CreateProposal(daoId uint64, title, summary string) {
	caller := std.GetOrigCaller()

	// if sender is not a dao member, revert
	isCallerDaoMember := isDAOMember(daoId, caller)
	if !isCallerDaoMember {
		panic("caller is not a dao member")
	}

	proposals[daoId] = append(proposals[daoId], Proposal{
		daoId:       daoId,
		id:          len(proposals[daoId]),
		title:       title,
		summary:     summary,
		submitTime:  time.Now().Unix(),
		voteEndTime: time.Now().Unix()+daos[daoId].votingPeriod,
		status:      VOTING_PERIOD,
	})
}

func Vote(daoId, proposalId uint64, option VoteOption) {
	caller := std.GetOrigCaller()

	// if sender is not a dao member, revert
	isCallerDaoMember := isDAOMember(daoId, caller)
	if !isCallerDaoMember {
		panic("caller is not a gnodao member")
	}

	// if invalid proposal, panic
	if int(proposalId) >= len(proposals[daoId]) {
		panic("invalid proposal id")
	}

	// if vote end time is reached panic
	if time.Now().Unix() > int64(proposal.voteEndTime) {
		panic("vote end time reached")
	}

	// Original vote cancel
	callerVotingPower := daos[daoId].votingPowers[caller.String()]
	vote, ok := proposals[daoId][proposalId].votes[caller.String()]
	if ok {
		if proposals[daoId][proposalId].votingPowers[vote.option] > callerVotingPower {
			proposals[daoId][proposalId].votingPowers[vote.option] -= callerVotingPower
		} else {
			proposals[daoId][proposalId].votingPowers[vote.option] = 0
		}
	}

	// Create a vote
	proposals[daoId][proposalId].votes[caller.String()] = Vote{
		address: caller,
		timestamp: time.Now().Unix(),
		option: option,
	}

	// Voting power by option update for new vote
	proposals[daoId][proposalId].votingPowers[option] += callerVotingPower
}

func TallyAndExecute(daoId, proposalId uint64) {
	caller := std.GetOrigCaller()

	// if sender is not a dao member, revert
	isCallerDaoMember := isDAOMember(daoId, caller)
	if !isCallerDaoMember {
		panic("caller is not a gnodao member")
	}

	// validation for proposalId
	if int(proposalId) >= len(proposals[daoId]) {
		panic("invalid proposal id")
	}
	dao := daos[daoId]
	proposal := proposals[daoId][proposalId]
	votingPowers := proposal.votingPowers

	if time.Now().Unix() < int64(proposal.voteEndTime) {
		panic("proposal is in voting period")
	}

	// reference logic for tally - https://github.com/cosmos/cosmos-sdk/blob/main/x/gov/keeper/tally.go
	totalVotes := votingPowers[YES] + votingPowers[NO] + votingPowers[NO_WITH_VETO] + votingPowers[ABSTAIN]
	if totalVotes < dao.totalVotingPower * dao.voteQuorum / 100 {
		proposals[daoId][proposalId].status = REJECTED
	}

	// If no one votes (everyone abstains), proposal rejected
	if totalVotes == votingPowers[ABSTAIN] {
		proposals[daoId][proposalId].status = REJECTED
	}

	// If more than 1/3 of voters veto, proposal rejected
	vetoThreshold := dao.vetoThreshold
	if votingPowers[NO_WITH_VETO] > totalVotes * vetoThreshold / 100 {
		proposals[daoId][proposalId].status = REJECTED
	}

	// If more than 1/2 of non-abstaining voters vote Yes, proposal passes
	threshold := dao.threshold
	if votingPowers[YES] > (totalVotes - votingPowers[ABSTAIN]) * threshold / 100 {
		proposals[daoId][proposalId].status = PASSED

		if proposal.newMetadata != "" {
			daos[daoId].metadata = proposal.newMetadata
		}

		if proposal.newMetadata != "" {
			daos[daoId].uri = proposal.newURI
		}

		for account, vp := range proposal.vpUpdates {
			daos[daoId].votingPowers[account] = vp
		}

		// TODO: spend coins when spendAmount is positive & spender is a valid address
		// spendAmount  Coins 
		// spender      std.Address 
		// TODO: set propoasl to FAILED when DAO does not have enough balance
	}

	// If more than 1/2 of non-abstaining voters vote No, proposal rejected
	proposals[daoId][proposalId].status = REJECTED
}

func DepositDAO(daoId uint64, amount Coins) {
	caller := std.GetOrigCaller()

	// if sender is not a dao member, revert
	isCallerDaoMember := isDAOMember(daoId, caller)
	if !isCallerDaoMember {
		panic("caller is not a gnodao member")
	}

	// TODO: send coins from caller to DAO
	// TODO: verify received amount
	daos[daoId].depositHistory = append(daos[daoId].depositHistory, Deposit {
		address: caller,
		amount: amount,
	})
}

func GetDAO(daoId uint64) Proposal {
	if int(daoId) >= len(daos) {
		panic("invalid dao id")
	}
	return daos[daoId]
}

func GetDAOs(startAfter, limit uint64) []Proposal {
	max := uint64(len(daos))
	if startAfter+limit < max {
		max = startAfter + limit
	}
	return daos[startAfter:max]
}

func GetProposal(daoId, proposalId uint64) Proposal {
	if int(daoId) >= len(daos) {
		panic("invalid dao id")
	}
	if int(proposalId) >= len(proposals[daoId]) {
		panic("invalid proposal id")
	}
	return proposals[daoId][proposalId]
}

func GetProposals(daoId, startAfter, limit uint64) []Proposal {
	if int(daoId) >= len(daos) {
		panic("invalid dao id")
	}
	max := uint64(len(proposals[daoId]))
	if startAfter+limit < max {
		max = startAfter + limit
	}
	return proposals[daoId][startAfter:max]
}

func Render(path string) string {
	// TODO: implement
	return ""
}
