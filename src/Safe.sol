// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

contract Safe {
    receive() external payable {}

    function withdrawn() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}
