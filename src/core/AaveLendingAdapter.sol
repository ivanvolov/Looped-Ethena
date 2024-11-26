// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPool} from "@aave-core-v3/contracts/interfaces/IPool.sol";
import {IAaveOracle} from "@aave-core-v3/contracts/interfaces/IAaveOracle.sol";
import {IPoolAddressesProvider} from "@aave-core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPoolDataProvider} from "@aave-core-v3/contracts/interfaces/IPoolDataProvider.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AaveLendingAdapter {
    using SafeERC20 for IERC20;

    //aaveV3
    IPoolAddressesProvider constant provider = IPoolAddressesProvider(0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e);

    IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 constant USDe = IERC20(0x4c9EDD5852cd905f086C759E8383e09bff1E68B3);
    IERC20 constant sUSDe = IERC20(0x9D39A5DE30e57443BfF2A8307A4256c8797A3497);

    constructor() {
        WETH.approve(getPool(), type(uint256).max);
        USDT.forceApprove(getPool(), type(uint256).max);
        USDe.approve(getPool(), type(uint256).max);
    }

    function getPool() public view returns (address) {
        return provider.getPool();
    }

    // ** Long market

    function getBorrowedWM() public view returns (uint256) {
        (, , address variableDebtTokenAddress) = getAssetAddresses(address(USDT));
        return IERC20(variableDebtTokenAddress).balanceOf(address(this));
    }

    function getCollateralWM() public view returns (uint256) {
        (address aTokenAddress, , ) = getAssetAddresses(address(WETH));
        return IERC20(aTokenAddress).balanceOf(address(this));
    }

    function borrowWM(uint256 amount) public {
        IPool(getPool()).borrow(address(USDT), amount, 2, 0, address(this)); // Interest rate mode: 2 = variable
        USDT.safeTransfer(msg.sender, amount);
    }

    function addCollateralWM(uint256 amount) public {
        WETH.transferFrom(msg.sender, address(this), amount);
        IPool(getPool()).supply(address(WETH), amount, address(this), 0);
    }

    // function repayLong(uint256 amount) public {
    //     // USDC.transferFrom(msg.sender, address(this), amount);
    //     // IPool(getPool()).repay(address(USDC), amount, 2, address(this));
    // }

    // function removeCollateralLong(uint256 amount) public {
    //     IPool(getPool()).withdraw(address(WETH), amount, msg.sender);
    // }

    // ** USDe USDT side

    // function repayShort(uint256 amount) public {
    //     WETH.transferFrom(msg.sender, address(this), amount);
    //     IPool(getPool()).repay(address(WETH), amount, 2, address(this));
    // }

    // function removeCollateralShort(uint256 amount) public {
    //     // IPool(getPool()).withdraw(address(USDC), amount, msg.sender);
    // }

    function borrowEM(uint256 amount) public {
        IPool(getPool()).borrow(address(USDT), amount, 2, 0, address(this)); // Interest rate mode: 2 = variable
        USDT.safeTransfer(msg.sender, amount);
    }

    function getCollateralEM() public view returns (uint256) {
        (address aTokenAddress, , ) = getAssetAddresses(address(USDe));
        return IERC20(aTokenAddress).balanceOf(address(this));
    }

    function getBorrowedEM() public view returns (uint256) {
        (, , address variableDebtTokenAddress) = getAssetAddresses(address(USDT));
        return IERC20(variableDebtTokenAddress).balanceOf(address(this));
    }

    function addCollateralEM(uint256 amount) public {
        USDe.transferFrom(msg.sender, address(this), amount);
        IPool(getPool()).supply(address(USDe), amount, address(this), 0);
    }

    // ** Helpers

    function getAssetAddresses(address underlying) public view returns (address, address, address) {
        return IPoolDataProvider(provider.getPoolDataProvider()).getReserveTokensAddresses(underlying);
    }

    function getAssetPrice(address underlying) public view returns (uint256) {
        return IAaveOracle(provider.getPriceOracle()).getAssetPrice(underlying) * 1e10;
    }
}