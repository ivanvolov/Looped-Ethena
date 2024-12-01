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

interface ISUSDe is IERC20 {
    function deposit(uint256 assets, address receiver) external;
}

/// @title ALM
/// @author IVikkk
/// @custom:contact vivan.volovik@gmail.com
contract ALM is ERC20, BaseStrategyHook {
    using SafeERC20 for IERC20;

    constructor() BaseStrategyHook() ERC20("ALM", "hhALM") {
        USDT.forceApprove(ALMBaseLib.SWAP_ROUTER, type(uint256).max);
        WETH.forceApprove(ALMBaseLib.SWAP_ROUTER, type(uint256).max);
        USDe.forceApprove(ALMBaseLib.SWAP_ROUTER, type(uint256).max);
        sUSDe.forceApprove(ALMBaseLib.SWAP_ROUTER, type(uint256).max);

        USDT.forceApprove(address(LENDING_POOL), type(uint256).max);
        USDe.forceApprove(address(LENDING_POOL), type(uint256).max);
        sUSDe.forceApprove(address(LENDING_POOL), type(uint256).max);
        WETH.forceApprove(address(LENDING_POOL), type(uint256).max);

        USDe.approve(address(sUSDe), type(uint256).max);
    }

    ILendingPool constant LENDING_POOL = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    uint256 constant leverage = 3 * 1e18;

    function deposit(uint256 wethToSupply) external notPaused notShutdown {
        WETH.transferFrom(msg.sender, address(this), wethToSupply);
        uint256 firstTVL = TVL();

        // ** Add WETH collateral
        addCollateralWM(wethToSupply);

        // ** Borrow USDT
        uint256 usdtToBorrow = _WETHtoUSDT((wethToSupply * 4) / 5); // 75% of wethToSupply
        borrowWM(usdtToBorrow);

        // ** SWAP USDT => USDe
        ALMBaseLib.swapExactInputEP(address(USDT), address(USDe), usdtToBorrow, address(this));
        uint256 USDeAmount = USDe.balanceOf(address(this));

        // ** USDe => sUSDe
        ISUSDe(address(sUSDe)).deposit(USDeAmount, address(this));
        uint256 sUSDeAmount = sUSDe.balanceOf(address(this));
        console.log("sUSDe amount", sUSDeAmount / 1e18);

        // ** FL USDT
        uint256 usdtToFlashLoan = _sUSDeToUSDT((sUSDeAmount * (leverage - 1e18)) / 1e18);
        address[] memory assets = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        uint256[] memory modes = new uint256[](1);
        (assets[0], amounts[0], modes[0]) = (address(USDT), usdtToFlashLoan, 0);
        LENDING_POOL.flashLoan(address(this), assets, amounts, modes, address(this), "", 0);

        uint256 secondTVL = TVL();
        if (firstTVL == 0) {
            _mint(msg.sender, secondTVL);
        } else {
            uint256 sharesToMint = (totalSupply() * (secondTVL - firstTVL)) / firstTVL;
            _mint(msg.sender, sharesToMint);
        }
    }

    function withdraw(uint256 shares) external notShutdown {
        uint256 ratio = (shares * 1e18) / totalSupply();
        uint256 usdtToFlashLoan = (getBorrowedUSDT() * ratio) / 1e18;
        _burn(msg.sender, shares);

        address[] memory assets = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        uint256[] memory modes = new uint256[](1);
        (assets[0], amounts[0], modes[0]) = (address(USDT), usdtToFlashLoan, 0);
        LENDING_POOL.flashLoan(address(this), assets, amounts, modes, address(this), abi.encode(ratio), 0);
    }

    function executeOperation(
        address[] calldata,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address,
        bytes calldata data
    ) external returns (bool) {
        require(msg.sender == address(LENDING_POOL), "M0");

        if (data.length == 0) {
            // ** SWAP USDT => USDe
            ALMBaseLib.swapExactInputEP(address(USDT), address(USDe), amounts[0], address(this));

            // ** USDe => sUSDe
            ISUSDe(address(sUSDe)).deposit(USDe.balanceOf(address(this)), address(this));

            // ** Add sUSDe collateral
            console.log("sUSDe added collateral", sUSDe.balanceOf(address(this)) / 1e18);
            addCollateralEM(sUSDe.balanceOf(address(this)));

            // ** Borrow USDT to repay flashloan
            uint256 usdtToBorrow = amounts[0] + premiums[0];
            console.log("Borrowed", usdtToBorrow / 1e6);
            borrowEM(usdtToBorrow);
            return true;
        } else {
            // ** repay USDT
            repayUSDT(amounts[0]);

            // ** remove collateral WETH
            uint256 ratio = abi.decode(data, (uint256));
            removeCollateralWM((getCollateralWM() * ratio) / 1e18);

            // ** remove collateral sUSDe
            removeCollateralEM((getCollateralEM() * ratio) / 1e18);

            uint256 usdtToRepay = amounts[0] + premiums[0];
            console.log("usdtToRepay", usdtToRepay / 1e6);
            ALMBaseLib.swapExactOutputWP(address(WETH), address(USDT), usdtToRepay / 10);

            // ISUSDe(address(sUSDe)).deposit(USDe.balanceOf(address(this)), address(this));
        }
    }

    // ** Price Helpers

    function _sUSDeToUSDT(uint256 amount) public view returns (uint256) {
        return (amount * sUSDeUsdtPrice()) / 1e30;
    }

    function _WETHtoUSDT(uint256 amount) public view returns (uint256) {
        return (amount * wethUsdtPrice()) / 1e30;
    }

    function _USDTtoWETH(int256 amount) public view returns (int256) {
        return (amount * 1e30) / int256(wethUsdtPrice());
    }

    function sUSDeUsdtPrice() public view returns (uint256) {
        return (getAssetPrice(address(sUSDe)) * 1e18) / getAssetPrice(address(USDT));
    }

    function wethUsdtPrice() public view returns (uint256) {
        return (getAssetPrice(address(WETH)) * 1e18) / getAssetPrice(address(USDT));
    }

    // ---- Math functions

    function TVL() public view returns (uint256) {
        // console.log("1", _sUSDeToUSDT(getCollateralEM()));
        // console.log("2", getBorrowedUSDT());
        return
            uint256(
                int256(getCollateralWM()) +
                    _USDTtoWETH(int256(_sUSDeToUSDT(getCollateralEM())) - int256(getBorrowedUSDT()))
            );
    }
}
