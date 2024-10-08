```bash
$ forge test --gas-report
[⠢] Compiling...
[⠆] Compiling 1 files with Solc 0.8.25
[⠰] Solc 0.8.25 finished in 4.03s
Compiler run successful!

Ran 5 tests for test/BallotTest.t.sol:BallotTest
[PASS] testSetVoterWeight() (gas: 160024)
[PASS] testSetVoterWeightAfterVotingEnded() (gas: 41661)
[PASS] testSetVoterWeightByNonChairperson() (gas: 39469)
[PASS] testSetVoterWeightDuringCooldown() (gas: 100234)
[PASS] testSetVoterWeightToZero() (gas: 43981)
Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 5.82ms (13.69ms CPU time)
| src/Ballot.sol:Ballot contract |                 |       |        |       |         |
|--------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                | Deployment Size |       |        |       |         |
| 927403                         | 4066            |       |        |       |         |
| Function Name                  | min             | avg   | median | max   | # calls |
| getProposal                    | 2924            | 2924  | 2924   | 2924  | 1       |
| getVoter                       | 5384            | 5384  | 5384   | 5384  | 1       |
| giveRightToVote                | 50625           | 50625 | 50625  | 50625 | 10      |
| setVoterWeight                 | 24208           | 36348 | 28652  | 55118 | 6       |
| vote                           | 78408           | 78408 | 78408  | 78408 | 1       |


Ran 1 test suite in 17.02ms (5.82ms CPU time): 5 tests passed, 0 failed, 0 skipped (5 total tests)

```

**Task04**
基于当前提供的 Ballot 合约,进行修改和扩展，添加时间限制功能并确保其功能正确性。

一、投票时间
功能描述: 为投票过程添加时间限制。设置一个开始时间和结束时间来控制投票的时间窗口。用户只能在投票周期内进行投票。
要求:
在合约中添加两个新的状态变量 startTime 和 endTime，用于表示投票的开始时间和结束时间。
在构造函数中初始化这些时间变量。
修改 vote 函数，确保用户只能在时间窗口内投票。如果不在时间窗口内投票，应该抛出错误。

二、设置权重
功能描述: 允许投票权重的设置。投票权重可以由合约所有者设置，默认每个选民的权重为 1。
要求:
添加一个函数 setVoterWeight(address voter, uint weight)，允许合约所有者为某个选民设置特定的投票权重，并添加时间限制。
确保只有合约所有者（chairperson）可以调用此函数。

String to Bytes32: https://www.devoven.com/encoding/string-to-bytes32

Tintin solidity boot camp
0x54696e74696e20736f6c696469747920626f6f742063616d7000000000000000

Make web3 great again!
0x4d616b65207765623320677265617420616761696e2100000000000000000000

Unix 时间戳: https://tool.chinaz.com/tools/unixtime.aspx
10 月 11 日 0 点: 1728576000
开始时间 10 月 11 日 8 点: 1728604800
结束时间 10 月 13 日 0 点: 1728748800

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```
