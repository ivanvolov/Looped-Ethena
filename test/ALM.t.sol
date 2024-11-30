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
        vm.rollFork(21300295);

        create_accounts_and_tokens();
        init_alm();

        vm.prank(alice.addr);
        WETH.approve(address(alm), type(uint256).max);

        {
            // ** We need smb to withdraw from aave pool cause market cap is reached.
            address whale = 0x4F0A01BAdAa24F762CeE620883f16C4460c06Be0;
            vm.startPrank(whale);
            uint256 before = alm.getCollateralEM(whale, address(sUSDe));

            // ** repay
            address asset1 = 0xdC035D45d973E3EC169d2276DDab16f1e407384F;
            IERC20(asset1).approve(address(alm._getPool()), type(uint256).max);
            uint256 a_t_close = alm.getBorrowedEM(whale, asset1);
            deal(asset1, whale, a_t_close);
            alm._getPool().repay(asset1, a_t_close, 2, whale);

            // ** withdraw
            alm._getPool().withdraw(address(sUSDe), before / 2, whale);
            vm.stopPrank();
        }
    }

    function test_deposit() public {
        vm.startPrank(alice.addr);
        uint256 wethToSupply = 10 * 1e18;
        deal(address(WETH), address(alice.addr), wethToSupply);
        alm.deposit(wethToSupply);
        vm.stopPrank();
    }
}
