// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// String to Bytes32: https://www.devoven.com/encoding/string-to-bytes32

// Tintin solidity boot camp
// 0x54696e74696e20736f6c696469747920626f6f742063616d7000000000000000
// Make web3 great again!
// 0x4d616b65207765623320677265617420616761696e2100000000000000000000

// Unix时间戳: https://tool.chinaz.com/tools/unixtime.aspx
// 10月11日0点的Unix时间戳1728576000
// 开始时间 10月11日8点: 1728604800
// 结束时间 10月13日0点: 1728748800

import "forge-std/Test.sol";
import "../src/Ballot.sol";

contract BallotTest is Test {
    Ballot ballot;

    address chairperson;
    address voter1;
    address voter2;

    bytes32 proposal1 = 0x54696e74696e20736f6c696469747920626f6f742063616d7000000000000000;
    bytes32 proposal2 = 0x4d616b65207765623320677265617420616761696e2100000000000000000000;

    uint256 startTime = 1728604800;
    uint256 endTime = 1728748800;

    function setUp() public {
        chairperson = makeAddr("chairperson");
        voter1 = makeAddr("voter1");
        voter2 = makeAddr("voter2");

        bytes32[] memory proposalNames = new bytes32[](2);
        proposalNames[0] = proposal1;
        proposalNames[1] = proposal2;

        vm.startPrank(chairperson);
        ballot = new Ballot(proposalNames, startTime, endTime);
        ballot.giveRightToVote(voter1);
        ballot.giveRightToVote(voter2);
        vm.stopPrank();
    }

    function testSetVoterWeight() public {
        vm.warp(startTime + 1);

        vm.prank(chairperson);
        ballot.setVoterWeight(voter1, 5);

        assertEq(ballot.getVoter(voter1).weight, 5);

        vm.prank(voter1);
        ballot.vote(0);

        assertEq(ballot.getProposal(0).voteCount, 5);
    }

    function testSetVoterWeightAfterVotingEnded() public {
        vm.warp(endTime + 1);

        vm.prank(chairperson);
        vm.expectRevert("Voting has ended.");
        ballot.setVoterWeight(voter1, 5);
    }

    function testSetVoterWeightDuringCooldown() public {
        vm.warp(startTime + 1);

        vm.prank(chairperson);
        ballot.setVoterWeight(voter1, 5);

        vm.prank(chairperson);
        vm.expectRevert("Weight update cooldown not yet expired.");
        ballot.setVoterWeight(voter1, 10);
    }

    function testSetVoterWeightToZero() public {
        vm.warp(startTime + 1);

        vm.prank(chairperson);
        vm.expectRevert("Weight must be greater than 0");
        ballot.setVoterWeight(voter1, 0);
    }

    function testSetVoterWeightByNonChairperson() public {
        vm.warp(startTime + 1);

        vm.prank(voter2);
        vm.expectRevert("You are not chairperson.");
        ballot.setVoterWeight(voter1, 5);
    }
}
