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
    }

    uint256 amountToDep = 100 ether;

    function test_deposit() public {
        // assertEq(hook.TVL(), 0);
        // deal(address(WETH), address(alice.addr), amountToDep);
        // vm.prank(alice.addr);
        // (, uint256 shares) = hook.deposit(alice.addr, amountToDep);
        // assertApproxEqAbs(shares, amountToDep, 1e10);
        // assertEqBalanceStateZero(alice.addr);
        // assertEqBalanceStateZero(address(hook));
        // assertEqMorphoA(borrowUSDCmId, 0, 0, amountToDep);
        // assertEqMorphoA(depositUSDCmId, 0, 0, 0);
        // assertEq(hook.sqrtPriceCurrent(), 1182773400228691521900860642689024);
        // assertEq(hook._calcCurrentPrice(), 4486999999999999769339);
        // assertApproxEqAbs(hook.TVL(), amountToDep, 1e10);
    }

    function test_aave_lending_adapter_long() public {
        // ** Approve
        vm.startPrank(alice.addr);
        WETH.approve(address(alm), type(uint256).max);
        USDT.forceApprove(address(alm), type(uint256).max);
        USDe.approve(address(alm), type(uint256).max);

        USDT.forceApprove(ALMBaseLib.SWAP_ROUTER, type(uint256).max);
        USDe.forceApprove(ALMBaseLib.SWAP_ROUTER, type(uint256).max);

        // ** Add WETH collateral
        uint256 wethToSupply = 100 * 1e18;
        deal(address(WETH), address(alice.addr), wethToSupply);
        alm.addCollateralWM(wethToSupply);
        assertApproxEqAbs(alm.getCollateralWM(), wethToSupply, 1e1);
        assertApproxEqAbs(alm.getBorrowedWM(), 0, 1e1);
        assertEqBalanceStateZero(alice.addr);

        // ** Borrow USDT
        uint256 usdtToBorrow = ((wethToSupply * 3400) / 1e12) / 2;
        alm.borrowWM(usdtToBorrow);
        assertApproxEqAbs(alm.getCollateralWM(), wethToSupply, 1e1);
        assertApproxEqAbs(alm.getBorrowedWM(), usdtToBorrow, 1e1);
        assertEqBalanceState(alice.addr, 0, usdtToBorrow);

        // ** Swap USDT => USDe
        ALMBaseLib.swapExactInputEP(address(USDT), address(USDe), USDT.balanceOf(address(alice.addr)), alice.addr);
        assertEqBalanceState(alice.addr, 0, 0, 169774087752505746850814);

        // ** Add USDe collateral
        uint256 balanceBefore = USDe.balanceOf(address(alice.addr));
        alm.addCollateralEM(balanceBefore);
        assertApproxEqAbs(alm.getCollateralEM(), balanceBefore, 1e1);
        assertApproxEqAbs(alm.getBorrowedEM(), usdtToBorrow, 1e1);
        assertEqBalanceStateZero(alice.addr);

        // ** Borrow USDT
        uint256 usdtToBorrow2 = balanceBefore / 1e12 / 2;
        alm.borrowEM(usdtToBorrow2);
        assertApproxEqAbs(alm.getCollateralEM(), balanceBefore, 1e1);
        assertApproxEqAbs(alm.getBorrowedEM(), usdtToBorrow + usdtToBorrow2, 1e1);
        assertEqBalanceState(alice.addr, 0, usdtToBorrow2);

        vm.stopPrank();
    }
}
