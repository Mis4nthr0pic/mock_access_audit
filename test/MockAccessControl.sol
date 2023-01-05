pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Minion} from "src/MockAccessControl.sol";
import {Attacker} from "src/MockAccessControlAttack.sol";

contract MockAccessControl is Test {
    Minion public minion;
    address owner;
    address user;

    function setUp() public {
        minion = new Minion();

        owner = minion.owner();
        user = makeAddr("User");
        vm.deal(user, 100 ether);
        vm.deal(owner, 100 ether);

        emit log_named_address("Owner", owner);
        emit log_named_decimal_uint("Owner balance is", address(owner).balance, 18);
        emit log_named_address("User", user);
        emit log_named_decimal_uint("User balance is", address(user).balance, 18);
    }

    function testVerify() public {
        Attacker attackerContract = new Attacker{value: 10 ether}(address(minion), 0.2 ether, 5);
        assertTrue(minion.verify(address(attackerContract)));
    }

    // testVerifyFail
    function testVerifyFail() public {
        Attacker attackerContract = new Attacker{value: 10 ether}(address(minion), 0.2 ether, 5);
        assertTrue(!minion.verify(user));
    }

    function testHasFunds() public {
        Attacker attackerContract = new Attacker{value: 10 ether}(address(minion), 0.2 ether, 5);
        assertEq(address(minion).balance, 1 ether);
    }

    // Reverting on retrieve even tho we're pranking the user

    function testRetrieve() public {
        uint256 initialBalance = address(minion).balance;
        vm.prank(owner);
        assertEq(address(minion).balance, 0 ether);
        emit log_named_uint("owner Balance", address(owner).balance);
        Attacker attackerContract = new Attacker{value: 10 ether}(address(minion), 0.2 ether, 5);
        emit log_named_uint("minion Balance", address(minion).balance);
        assertEq(address(minion).balance, 1 ether);
        //@TODO: why this is reverting? vm.prank is not working?
        //minion.retrieve();
    }

    function testInsufficientContribution() public {
        vm.expectRevert("Minimum Contribution needed is 0.1 ether");
        Attacker attackerContract = new Attacker{value: 10 ether}(address(minion), 0.09 ether, 1);
    }

    function testExceedingContribution() public {
        vm.expectRevert("How did you get so much money? Max allowed is 0.2 ether");
        Attacker attackerContract = new Attacker{value: 10 ether}(address(minion), 0.21 ether, 1);
    }

    function testPwnNotRightTime() public {
        vm.expectRevert("Not the right time");
        vm.warp(1672916519); // Time is now 121 seconds after the previous timestamp
        Attacker attackerContract = new Attacker{value: 10 ether}(address(minion), 0.2 ether, 5);
    }

    function testPwnNotAllowingContracts() public {
        vm.expectRevert("Well we don't allow Contracts either");
        minion.pwn{value: 0.1 ether}();
    }
}
