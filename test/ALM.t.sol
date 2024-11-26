// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ALMTestBase} from "@test/core/ALMTestBase.sol";

import {ALM} from "@src/ALM.sol";
import {ALMBaseLib} from "@src/libraries/ALMBaseLib.sol";
import {IALM} from "@src/interfaces/IALM.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ALMTest is ALMTestBase {
    using SafeERC20 for IERC20;

    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    function setUp() public {
        uint256 mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
        vm.rollFork(21_265_596);

        create_accounts_and_tokens();
        init_alm();

        vm.prank(alice.addr);
        WETH.approve(address(alm), type(uint256).max);
    }

    uint256 amountToDep = 100 ether;

    function test_deposit() public {
        // deal(address(USDT), zero.addr, 268457108531);
        // vm.prank(zero.addr);
        // USDT.safeTransfer(address(alm), 268457108531);
        // vm.stopPrank();

        vm.startPrank(alice.addr);
        uint256 wethToSupply = 100 * 1e18;
        deal(address(WETH), address(alice.addr), wethToSupply);
        alm.deposit(wethToSupply);
        vm.stopPrank();
    }
}
