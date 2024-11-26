// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";

import {ALMBaseLib} from "@src/libraries/ALMBaseLib.sol";
import {IWETH} from "@forks/IWETH.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IALM} from "@src/interfaces/IALM.sol";
import {AaveLendingAdapter} from "@src/core/AaveLendingAdapter.sol";

abstract contract BaseStrategyHook is AaveLendingAdapter, IALM {
    address public immutable deployer;

    bool public paused = false;
    bool public shutdown = false;

    constructor() AaveLendingAdapter() {
        deployer = msg.sender;
    }

    function setPaused(bool _paused) external onlyDeployer {
        paused = _paused;
    }

    function setShutdown(bool _shutdown) external onlyDeployer {
        shutdown = _shutdown;
    }

    // --- Modifiers ---

    /// @dev Only the hook deployer may call this function
    modifier onlyDeployer() {
        if (msg.sender != deployer) revert NotHookDeployer();
        _;
    }

    /// @dev Only allows execution when the contract is not paused
    modifier notPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    /// @dev Only allows execution when the contract is not shut down
    modifier notShutdown() {
        if (shutdown) revert ContractShutdown();
        _;
    }
}
