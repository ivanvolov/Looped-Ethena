// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ALMBaseLib} from "@src/libraries/ALMBaseLib.sol";
import {ALM} from "@src/ALM.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {TestAccount, TestAccountLib} from "@test/libraries/TestAccountLib.t.sol";

abstract contract ALMTestBase is Test {
    using SafeERC20 for IERC20;

    using TestAccountLib for TestAccount;

    ALM alm;

    IERC20 USDe;
    IERC20 sUSDe;
    IERC20 USDT;
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
        USDT = IERC20(ALMBaseLib.USDT);
        vm.label(address(USDT), "USDT");
        USDe = IERC20(ALMBaseLib.USDe);
        vm.label(address(USDe), "USDe");
        sUSDe = IERC20(ALMBaseLib.sUSDe);
        vm.label(address(sUSDe), "sUSDe");

        deployer = TestAccountLib.createTestAccount("deployer");
        alice = TestAccountLib.createTestAccount("alice");
        zero = TestAccountLib.createTestAccount("zero");
    }

    // -- Custom assertions -- //

    function assertEqBalanceStateZero(address owner) public view {
        assertEqBalanceState(owner, 0, 0, 0);
    }

    function assertEqBalanceState(address owner, uint256 _balanceWETH, uint256 _balanceUSDT) public view {
        assertEqBalanceState(owner, _balanceWETH, _balanceUSDT, 0);
    }

    function assertEqBalanceState(
        address owner,
        uint256 _balanceWETH,
        uint256 _balanceUSDT,
        uint256 _balanceUSDe
    ) public view {
        assertApproxEqAbs(WETH.balanceOf(owner), _balanceWETH, 1000, "Balance WETH not equal");
        assertApproxEqAbs(USDT.balanceOf(owner), _balanceUSDT, 10, "Balance USDT not equal");
        assertApproxEqAbs(USDe.balanceOf(owner), _balanceUSDe, 1000, "Balance USDe not equal");
    }
}
