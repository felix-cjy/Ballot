// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Ballot {
    // 投票者
    struct Voter {
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
        // 改动,增加权重修改时间
        uint256 lastWeightUpdate;
    }

    struct Proposal {
        bytes32 name;
        uint256 voteCount;
    }

    // 改动,增加开始和结束时间
    uint256 public startTime;
    uint256 public endTime;

    // 改动,权重修改得冷却时间,3天
    uint256 public constant WEIGHT_UPDATE_COOLDOWN = 3 days;

    address public chairperson;
    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    // 改动,增加事件通知
    event NewProposal(address indexed proposer, bytes32 indexed proposalName);
    event VoteCast(address indexed voter, uint256 indexed proposalId);
    event Delegate(address indexed delegator, address indexed delegate);
    event WeightUpdate(address indexed voter, uint256 newWeight);

    constructor(bytes32[] memory proposalNames, uint256 _startTime, uint256 _endTime) {
        require(block.timestamp < _startTime, "Vote has already started");
        require(_startTime < _endTime, "Wrong setting");
        startTime = _startTime;
        endTime = _endTime;

        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }

    function giveRightToVote(address voter) external {
        require(msg.sender == chairperson, "Only chairperson can give right to vote");
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0);

        voters[voter].weight = 1;
        // 改动,初始时间为0,不影响第一次修改权重
        voters[voter].lastWeightUpdate = 0;
    }

    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];

        require(sender.weight != 0, "You have no right to vote");
        require(!sender.voted, "You already voted.");

        require(to != msg.sender, "Self-delegation is disallowed.");
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation");
        }

        Voter storage delegate_ = voters[to];

        require(delegate_.weight >= 1);

        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
        emit Delegate(msg.sender, to);
    }

    function vote(uint256 proposal) external {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Not the time");

        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "You have no right to vote");
        require(!sender.voted, "You already voted.");

        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
        emit VoteCast(msg.sender, proposal);
    }

    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() external view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }

    // 改动, 增加设置投票权重
    function setVoterWeight(address voter, uint256 weight) external {
        require(msg.sender == chairperson, "You are not chairperson.");
        require(block.timestamp <= endTime, "Voting has ended.");
        require(
            block.timestamp - voters[voter].lastWeightUpdate >= WEIGHT_UPDATE_COOLDOWN,
            "Weight update cooldown not yet expired."
        );
        require(weight > 0, "Weight must be greater than 0");

        voters[voter].weight = weight;
        voters[voter].lastWeightUpdate = block.timestamp;

        emit WeightUpdate(voter, weight);
    }

    function getVoter(address voter) public view returns (Voter memory) {
        return voters[voter];
    }

    function getProposal(uint256 index) public view returns (Proposal memory) {
        return proposals[index];
    }
}
