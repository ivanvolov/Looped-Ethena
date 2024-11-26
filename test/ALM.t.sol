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
        // vm.prank(zero.addr);
        // console.log(zero.addr);
        // USDT.forceApprove(address(alm), type(uint256).max);
        // vm.stopPrank();
        deal(address(USDT), address(zero.addr), 268457108531);

        vm.startPrank(alice.addr);

        uint256 wethToSupply = 100 * 1e18;
        deal(address(WETH), address(alice.addr), wethToSupply);
        alm.deposit2(wethToSupply);
        // assertApproxEqAbs(alm.getCollateralWM(), wethToSupply, 1e1);
        // assertApproxEqAbs(alm.getBorrowedWM(), 0, 1e1);

        vm.stopPrank();
    }

    function test_aave_lending_adapter_long() public {
        // // ** Approve
        // vm.startPrank(alice.addr);
        // WETH.approve(address(alm), type(uint256).max);
        // USDT.forceApprove(address(alm), type(uint256).max);
        // USDe.approve(address(alm), type(uint256).max);
        // USDT.forceApprove(ALMBaseLib.SWAP_ROUTER, type(uint256).max);
        // USDe.forceApprove(ALMBaseLib.SWAP_ROUTER, type(uint256).max);
        // // ** Add WETH collateral
        // uint256 wethToSupply = 100 * 1e18;
        // deal(address(WETH), address(alice.addr), wethToSupply);
        // alm.addCollateralWM(wethToSupply);
        // assertApproxEqAbs(alm.getCollateralWM(), wethToSupply, 1e1);
        // assertApproxEqAbs(alm.getBorrowedWM(), 0, 1e1);
        // assertEqBalanceStateZero(alice.addr);
        // // ** Borrow USDT
        // uint256 usdtToBorrow = ((wethToSupply * 3400) / 1e12) / 2;
        // alm.borrowWM(usdtToBorrow);
        // assertApproxEqAbs(alm.getCollateralWM(), wethToSupply, 1e1);
        // assertApproxEqAbs(alm.getBorrowedWM(), usdtToBorrow, 1e1);
        // assertEqBalanceState(alice.addr, 0, usdtToBorrow);
        // // ** Swap USDT => USDe
        // ALMBaseLib.swapExactInputEP(address(USDT), address(USDe), USDT.balanceOf(address(alice.addr)), alice.addr);
        // assertEqBalanceState(alice.addr, 0, 0, 169774087752505746850814);
        // // ** Add USDe collateral
        // uint256 balanceBefore = USDe.balanceOf(address(alice.addr));
        // alm.addCollateralEM(balanceBefore);
        // assertApproxEqAbs(alm.getCollateralEM(), balanceBefore, 1e1);
        // assertApproxEqAbs(alm.getBorrowedEM(), usdtToBorrow, 1e1);
        // assertEqBalanceStateZero(alice.addr);
        // // ** Borrow USDT
        // uint256 usdtToBorrow2 = balanceBefore / 1e12 / 2;
        // alm.borrowEM(usdtToBorrow2);
        // assertApproxEqAbs(alm.getCollateralEM(), balanceBefore, 1e1);
        // assertApproxEqAbs(alm.getBorrowedEM(), usdtToBorrow + usdtToBorrow2, 1e1);
        // assertEqBalanceState(alice.addr, 0, usdtToBorrow2);
        // vm.stopPrank();
    }
}
