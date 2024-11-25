// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ALMBaseLib} from "@src/libraries/ALMBaseLib.sol";
import {ALM} from "@src/ALM.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {TestAccount, TestAccountLib} from "@test/libraries/TestAccountLib.t.sol";

abstract contract ALMTestBase is Test {
    using TestAccountLib for TestAccount;

    ALM alm;

    IERC20 USDC;
    IERC20 WETH;

    TestAccount deployer;
    TestAccount alice;
    TestAccount zero;

    function init_alm() internal {
        vm.startPrank(deployer.addr);
        alm = new ALM();
        vm.stopPrank();
    }

    function create_accounts_and_tokens() public {
        WETH = IERC20(ALMBaseLib.WETH);
        vm.label(address(WETH), "WETH");
        USDC = IERC20(ALMBaseLib.USDC);
        vm.label(address(USDC), "USDC");

        deployer = TestAccountLib.createTestAccount("deployer");
        alice = TestAccountLib.createTestAccount("alice");
        zero = TestAccountLib.createTestAccount("zero");
    }

    function approve_accounts() public {
        vm.startPrank(alice.addr);
        USDC.approve(address(alm), type(uint256).max);
        WETH.approve(address(alm), type(uint256).max);
        vm.stopPrank();
    }

    // -- Custom assertions -- //

    function assertEqBalanceStateZero(address owner) public view {
        assertEqBalanceState(owner, 0, 0, 0);
    }

    function assertEqBalanceState(address owner, uint256 _balanceWETH, uint256 _balanceUSDC) public view {
        assertEqBalanceState(owner, _balanceWETH, _balanceUSDC, 0);
    }

    function assertEqBalanceState(
        address owner,
        uint256 _balanceWETH,
        uint256 _balanceUSDC,
        uint256 _balanceETH
    ) public view {
        assertApproxEqAbs(WETH.balanceOf(owner), _balanceWETH, 1000, "Balance WETH not equal");
        assertApproxEqAbs(USDC.balanceOf(owner), _balanceUSDC, 10, "Balance USDC not equal");
        assertApproxEqAbs(owner.balance, _balanceETH, 10, "Balance ETH not equal");
    }
}
