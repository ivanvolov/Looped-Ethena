// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ALMTestBase} from "@test/core/ALMTestBase.sol";

import {ALM} from "@src/ALM.sol";
import {ALMBaseLib} from "@src/libraries/ALMBaseLib.sol";
import {IALM} from "@src/interfaces/IALM.sol";

contract ALMTest is ALMTestBase {
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    function setUp() public {
        uint256 mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
        vm.rollFork(21_265_596);

        create_accounts_and_tokens();
        init_alm();
        approve_accounts();
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
        // ** Enable Alice to call the adapter
        // vm.prank(deployer.addr);
        // lendingAdapter.addAuthorizedCaller(address(alice.addr));
        // // ** Approve to Morpho
        // vm.startPrank(alice.addr);
        // WETH.approve(address(lendingAdapter), type(uint256).max);
        // USDC.approve(address(lendingAdapter), type(uint256).max);
        // // ** Add collateral
        // uint256 wethToSupply = 4000 * 1e18;
        // deal(address(WETH), address(alice.addr), wethToSupply);
        // lendingAdapter.addCollateralLong(wethToSupply);
        // assertApproxEqAbs(lendingAdapter.getCollateralLong(), wethToSupply, 1e1);
        // assertApproxEqAbs(lendingAdapter.getBorrowedLong(), 0, 1e1);
        // assertEqBalanceStateZero(alice.addr);
        // // ** Borrow
        // uint256 usdcToBorrow = ((wethToSupply * 4500) / 1e12) / 2;
        // lendingAdapter.borrowLong(usdcToBorrow);
        // assertApproxEqAbs(lendingAdapter.getCollateralLong(), wethToSupply, 1e1);
        // assertApproxEqAbs(lendingAdapter.getBorrowedLong(), usdcToBorrow, 1e1);
        // assertEqBalanceState(alice.addr, 0, usdcToBorrow);
        // // ** Repay
        // lendingAdapter.repayLong(usdcToBorrow);
        // assertApproxEqAbs(lendingAdapter.getCollateralLong(), wethToSupply, 1e1);
        // assertApproxEqAbs(lendingAdapter.getBorrowedLong(), 0, 1e1);
        // assertEqBalanceStateZero(alice.addr);
        // // ** Remove collateral
        // lendingAdapter.removeCollateralLong(wethToSupply);
        // assertApproxEqAbs(lendingAdapter.getCollateralLong(), 0, 1e1);
        // assertApproxEqAbs(lendingAdapter.getBorrowedLong(), 0, 1e1);
        // assertEqBalanceState(alice.addr, wethToSupply, 0);
        // vm.stopPrank();
    }
}
