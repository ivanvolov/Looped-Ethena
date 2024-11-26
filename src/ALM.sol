// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/console.sol";

import {ALMBaseLib} from "@src/libraries/ALMBaseLib.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {BaseStrategyHook} from "@src/core/BaseStrategyHook.sol";

interface ILendingPool {
    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

/// @title ALM
/// @author IVikkk
/// @custom:contact vivan.volovik@gmail.com
contract ALM is ERC20, BaseStrategyHook {
    using SafeERC20 for IERC20;

    constructor() BaseStrategyHook() ERC20("ALM", "hhALM") {
        USDT.forceApprove(ALMBaseLib.SWAP_ROUTER, type(uint256).max);
        USDe.forceApprove(ALMBaseLib.SWAP_ROUTER, type(uint256).max);
        USDT.forceApprove(address(LENDING_POOL), type(uint256).max);
    }

    ILendingPool constant LENDING_POOL = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    uint256 constant leverage = 2 * 1e18;

    function deposit(uint256 wethToSupply) external notPaused notShutdown {
        WETH.transferFrom(msg.sender, address(this), wethToSupply);
        // ** Add WETH collateral
        addCollateralWM(wethToSupply);

        // ** Borrow USDT
        uint256 usdtToBorrow = (((ethUsdtPrice() * wethToSupply) / 1e30) * 4) / 5;
        borrowWM(usdtToBorrow);

        // ** SWAP USDT => USDe
        ALMBaseLib.swapExactInputEP(address(USDT), address(USDe), usdtToBorrow, address(this));
        uint256 sUSDeAmount = USDe.balanceOf(address(this));

        // ** FL USDe
        console.log(sUSDeAmount);
        uint256 usdtToFlashLoan = (sUSDeAmount * (leverage - 1e18)) / sUSDeUsdtPrice() / 1e12;
        console.log(usdtToFlashLoan);
        address[] memory assets = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        uint256[] memory modes = new uint256[](1);
        (assets[0], amounts[0], modes[0]) = (address(USDT), usdtToFlashLoan, 0);
        LENDING_POOL.flashLoan(address(this), assets, amounts, modes, address(this), "", 0);
    }

    function executeOperation(
        address[] calldata,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address,
        bytes calldata
    ) external returns (bool) {
        require(msg.sender == address(LENDING_POOL), "M0");

        console.log("!");
        // ** SWAP USDT => USDe
        ALMBaseLib.swapExactInputEP(address(USDT), address(USDe), amounts[0], address(this));

        // ** Add USDe collateral
        console.log("!");
        addCollateralEM(USDe.balanceOf(address(this)));

        // ** Borrow USDT to repay flashloan
        console.log("!");
        console.log(amounts[0] + premiums[0]);

        uint256 usdtToBorrow = amounts[0] + premiums[0];
        borrowEM(usdtToBorrow);
        console.log("!");
        return true;
    }

    function sUSDeUsdtPrice() public view returns (uint256) {
        return (getAssetPrice(address(USDe)) * 1e18) / getAssetPrice(address(USDT));
    }

    // TVL = WETHcollaterl + (sUSDeUsdtPrice * USDe - debtUSDT) / ethUsdtPrice

    function ethUsdtPrice() public view returns (uint256) {
        return (getAssetPrice(address(WETH)) * 1e18) / getAssetPrice(address(USDT));
    }

    // ---- Math functions

    function TVL() public view returns (uint256) {
        // uint256 price = _calcCurrentPrice();
        // int256 tvl = int256(lendingAdapter.getCollateral()) +
        //     int256(lendingAdapter.getSupplied() / price) -
        //     int256(lendingAdapter.getBorrowed() / price);
        // return uint256(tvl);
    }

    function sharePrice() public view returns (uint256) {
        // if (totalSupply() == 0) return 0;
        // return (TVL() * 1e18) / totalSupply();
    }

    function _calcCurrentPrice() public view returns (uint256) {
        // return ALMMathLib.getPriceFromSqrtPriceX96(sqrtPriceCurrent);
    }
}
