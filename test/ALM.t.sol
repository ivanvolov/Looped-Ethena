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

interface ISUSDe is IERC20 {
    function setCooldownDuration(uint24 duration) external;
}

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

        vm.prank(bob.addr);
        WETH.approve(address(alm), type(uint256).max);

        {
            // ** We need it caus Uniswap pool is not initialized yet.
            vm.prank(0x3B0AAf6e6fCd4a7cEEf8c92C32DFeA9E64dC1862);
            ISUSDe(address(sUSDe)).setCooldownDuration(0);
        }

        {
            // ** We need smb to withdraw from aave pool cause market cap is reached.
            address whale = 0x4F0A01BAdAa24F762CeE620883f16C4460c06Be0;
            vm.startPrank(whale);
            uint256 before = alm.getCollateral(whale, address(sUSDe));

            // ** repay
            address asset1 = 0xdC035D45d973E3EC169d2276DDab16f1e407384F;
            IERC20(asset1).approve(address(alm._getPool()), type(uint256).max);
            uint256 a_t_close = alm.getBorrowed(whale, asset1);
            deal(asset1, whale, a_t_close);
            alm._getPool().repay(asset1, a_t_close, 2, whale);

            // ** withdraw
            alm._getPool().withdraw(address(sUSDe), before / 2, whale);
            vm.stopPrank();
        }
    }

    function test_deposit() public {
        console.log("price:", alm.wethUsdtPrice() / 1e18);
        assertApproxEqAbs(alm.TVL(), 0, 1000, "TVL not equal");
        assertApproxEqAbs(alm.getCollateralWM(), 0, 1000, "Collateral not equal");
        assertApproxEqAbs(alm.getCollateralEM(), 0, 1000, "Collateral not equal");
        assertApproxEqAbs(alm.getBorrowedUSDT(), 0, 1000, "Borrowed not equal");
        assertApproxEqAbs(alm.balanceOf(alice.addr), 0, 1000, "Shares not equal");

        vm.startPrank(alice.addr);
        uint256 wethToSupply = 10 * 1e18;
        deal(address(WETH), address(alice.addr), wethToSupply);
        alm.deposit(wethToSupply);
        vm.stopPrank();

        assertApproxEqAbs(alm.TVL(), 9983559144938829211, 10, "TVL not equal");
        assertApproxEqAbs(alm.getCollateralWM(), 10 ether, 1000, "Collateral not equal");
        assertApproxEqAbs(alm.getCollateralEM(), 77824561794585607021950, 1000, "Collateral not equal");
        assertApproxEqAbs(alm.getBorrowedUSDT(), 87838599185, 1000, "Borrowed not equal");
        assertApproxEqAbs(alm.balanceOf(alice.addr), 9983559144938829211, 10, "Shares not equal");
    }

    function test_two_deposit() public {
        test_deposit();

        vm.startPrank(bob.addr);
        uint256 wethToSupply = 10 * 1e18;
        deal(address(WETH), address(bob.addr), wethToSupply);
        alm.deposit(wethToSupply);
        vm.stopPrank();

        assertApproxEqAbs(alm.TVL(), 19966661783093358137, 10, "TVL not equal");
        assertApproxEqAbs(alm.getCollateralWM(), 20 ether, 1000, "Collateral not equal");
        assertApproxEqAbs(alm.getCollateralEM(), 155646654448606681912570, 1000, "Collateral not equal");
        assertApproxEqAbs(alm.getBorrowedUSDT(), 175676083297, 1000, "Borrowed not equal");
        assertApproxEqAbs(alm.balanceOf(bob.addr), 9983102638154528926, 10, "Shares not equal");
    }

    function test_withdraw() public {
        test_deposit();

        vm.startPrank(alice.addr);
        alm.withdraw(alm.balanceOf(alice.addr));
        vm.stopPrank();

        assertApproxEqAbs(WETH.balanceOf(address(alice.addr)), 7255099292429920748, 1000, "WETH not equal");
        assertApproxEqAbs(alm.TVL(), 0, 1000, "TVL not equal");
        assertApproxEqAbs(alm.getCollateralWM(), 0, 1000, "Collateral not equal");
        assertApproxEqAbs(alm.getCollateralEM(), 0, 1000, "Collateral not equal");
        assertApproxEqAbs(alm.getBorrowedUSDT(), 0, 1000, "Borrowed not equal");
        assertApproxEqAbs(alm.balanceOf(alice.addr), 0, 1000, "Shares not equal");
    }
}
