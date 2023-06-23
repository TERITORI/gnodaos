# GnoDAO

Our aim is to introduce DAO functionality to Gnolang through this project.

## Test execution

To run the tests run

```
gnodev test r/gnodao --verbose --root-dir ../gno
```

## User flow

Here are the steps to deploy a contract with a quorum:

1. Firstly, you can deploy a contract.
2. This contract has a quorum, which is essentially an array of addresses and an agreement ratio that can be updated. You can add new members, remove members, or change the quorum ratio.
3. One member of the quorum can propose a transaction.
4. Each member of the quorum is required to make a transaction to vote yes for the proposed transaction ID.
5. If the number of yes votes exceeds the quorum, one member can execute the transaction.
6. If the number of yes votes is less than the quorum, one member can close the proposal. However, this step can be inconvenient. Instead, we can set an expiration period for each proposal when we submit one. If block.timestamp is greater than expiration, no one can vote or execute it.


## Research

- [Gnolang multisig research](https://hackmd.io/lF6_guCYQemIYXHV0oCynA)

## Resources

- [Gnoland Cheatsheet](https://github.com/slashbinslashnoname/gnoland_cheatsheet)
- [Gno Projects list](https://notes.pwnh4.com/s/pPIPCgXFw)
- [Realm types example](https://gnoland.space/r/users/types.gno)
- [Realm users example](https://gnoland.space/r/users/users.gno)
- [Realm Board example](https://github.com/gnolang/gno/tree/master/examples/gno.land/r/boards)
