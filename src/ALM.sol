// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/console.sol";

import {ALMBaseLib} from "@src/libraries/ALMBaseLib.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BaseStrategyHook} from "@src/core/BaseStrategyHook.sol";

/// @title ALM
/// @author IVikkk
/// @custom:contact vivan.volovik@gmail.com
contract ALM is ERC20, BaseStrategyHook {
    constructor() BaseStrategyHook() ERC20("ALM", "hhALM") {}

    function deposit(address to, uint256 amount) external notPaused notShutdown returns (uint256, uint256) {
        // if (amount == 0) revert ZeroLiquidity();
        // refreshReserves();
        // (uint128 deltaL, uint256 amountIn, uint256 shares) = _calcDepositParams(amount);
        // WETH.transferFrom(msg.sender, address(this), amountIn);
        // lendingAdapter.addCollateral(WETH.balanceOf(address(this)));
        // liquidity = liquidity + deltaL;
        // _mint(to, shares);
        // emit Deposit(msg.sender, amountIn, shares);
        // return (amountIn, shares);
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
