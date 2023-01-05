pragma solidity 0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {Minion} from "src/MockAccessControl.sol";
import {Attacker} from "src/MockAccessControlAttack.sol";

contract TestMockAccessAttack is Test {
    Minion minionContract;
    Attacker attackerContract;

    function setUp() public {
        minionContract = new Minion();
        attackerContract = new Attacker{value: 10 ether}(address(minionContract), 0.2 ether, 5);
    }

    function testAttack() public {
        assertEq(minionContract.verify(address(attackerContract)), true);
    }
}
