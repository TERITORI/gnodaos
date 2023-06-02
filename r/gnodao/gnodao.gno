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
	daoId       uint64          // dao id of the proposal
	id          uint64          // unique id assigned for each proposal
	title       string          // proposal title
	summary     string          // proposal summary
	submitTime  uint64          // proposal submission time
	voteEndTime uint64          // vote end time for the proposal
	status      ProposalStatus  // StatusNil | StatusVotingPeriod | StatusPassed | StatusRejected | StatusFailed
	votes       map[string]Vote // votes on the proposal
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

	// if sender is not in the current quorum, revert
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

	// if sender is not in the current quorum, revert
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

	// Create a port
	proposals[daoId][proposalId].votes[caller.String()] = Vote{
		address: caller,
		timestamp: time.Now().Unix(),
		option: option,
	}
}

func Execute(proposalId uint64) {
	caller := std.GetOrigCaller()

	if int(proposalId) >= len(proposals) {
		panic("invalid proposal id")
	}
	proposal := proposals[proposalId]

	// if tx is not TO_EXECUTE, revert
	if proposal.Status != TO_EXECUTE {
		panic("not an executable proposal")
	}

	// if sender is not in the current quorum, revert
	isCallerDaoMember := isDAOMember(proposal.daoId, caller)
	if !isCallerDaoMember {
		panic("caller is not a gnodao member")
	}

	// if expiration time is reached, set proposal as CANCELLED
	if time.Now().Unix() > int64(proposal.Expiration) {
		proposals[proposalId].Status = CANCELLED
		return
	}

	// Execute an approved tx
	boards.CreateBoard("new board")

	// set proposal to EXECUTED
	proposals[proposalId].Status = EXECUTED
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

func Render(path string) string {
	if path == "" {
		membersText := ``
		for _, member := range quorum.members {
			membersText += fmt.Sprintf("- %s\n", member.String())
		}

		pendingProposals := ``
		executedProposals := ``
		cancelledProposals := ``

		for index, proposal := range proposals {
			switch proposal.Status {
			case PENDING:
				pendingProposals += fmt.Sprintf("- [%s](https://gnodao.com/proposal/%d)\n", proposal.Title, index+1)
			case EXECUTED:
				executedProposals += fmt.Sprintf("- [%s](https://gnodao.com/proposal/%d)\n", proposal.Title, index+1)
			case CANCELLED:
				cancelledProposals += fmt.Sprintf("- [%s](https://gnodao.com/proposal/%d)\n", proposal.Title, index+1)
			}
		}

		return fmt.Sprintf(`
# Gnodao setup

Members:
%s

Minimum approval needed: %d

# Proposals

Pending:
%s

Executed:
%s

Cancelled:
%s`, membersText, quorum.minApproval, pendingProposals, executedProposals, cancelledProposals)
	}

	subPath := strings.Split(path, "/")
	switch subPath[0] {
	case "proposal":
		if len(subPath) == 1 {
			panic("no proposal id provided on path")
		}
		proposalId, err := strconv.Atoi(subPath[1])
		if err != nil {
			panic(err)
		}
		if len(proposals) <= int(proposalId) {
			panic("invalid proposal id")
		}
		proposal := proposals[daoId][proposalId]

		statusText := proposal.Status.String()
		approversText := ``
		for _, approval := range proposal.Approvals {
			approversText += fmt.Sprintf("- %s\n", approval.address.String())
		}
		return fmt.Sprintf(`Status: %s
Need at least %d approvals

Proposal description:
%s

Approved by:
%s`, statusText, quorum.minApproval, proposal.Description, approversText)
	}

	return ""
}
