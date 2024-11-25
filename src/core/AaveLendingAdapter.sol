// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IPool} from "@aave-core-v3/contracts/interfaces/IPool.sol";
import {IAaveOracle} from "@aave-core-v3/contracts/interfaces/IAaveOracle.sol";
import {IPoolAddressesProvider} from "@aave-core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPoolDataProvider} from "@aave-core-v3/contracts/interfaces/IPoolDataProvider.sol";

contract AaveLendingAdapter is Ownable {
    //aaveV3
    IPoolAddressesProvider constant provider = IPoolAddressesProvider(0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e);

    IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    mapping(address => bool) public authorizedCallers;

    constructor() Ownable(msg.sender) {
        WETH.approve(getPool(), type(uint256).max);
        USDC.approve(getPool(), type(uint256).max);
    }

    function getPool() public view returns (address) {
        return provider.getPool();
    }

    function addAuthorizedCaller(address _caller) external onlyOwner {
        authorizedCallers[_caller] = true;
    }

    // ** Long market

    function getBorrowedLong() external view returns (uint256) {
        (, , address variableDebtTokenAddress) = getAssetAddresses(address(USDC));
        return IERC20(variableDebtTokenAddress).balanceOf(address(this));
    }

    function borrowLong(uint256 amountUSDC) external onlyAuthorizedCaller {
        IPool(getPool()).borrow(address(USDC), amountUSDC, 2, 0, address(this)); // Interest rate mode: 2 = variable
        USDC.transfer(msg.sender, amountUSDC);
    }

    function repayLong(uint256 amountUSDC) external onlyAuthorizedCaller {
        USDC.transferFrom(msg.sender, address(this), amountUSDC);
        IPool(getPool()).repay(address(USDC), amountUSDC, 2, address(this));
    }

    function getCollateralLong() external view returns (uint256) {
        (address aTokenAddress, , ) = getAssetAddresses(address(WETH));
        return IERC20(aTokenAddress).balanceOf(address(this));
    }

    function removeCollateralLong(uint256 amountWETH) external onlyAuthorizedCaller {
        IPool(getPool()).withdraw(address(WETH), amountWETH, msg.sender);
    }

    function addCollateralLong(uint256 amountWETH) external onlyAuthorizedCaller {
        WETH.transferFrom(msg.sender, address(this), amountWETH);
        IPool(getPool()).supply(address(WETH), amountWETH, address(this), 0);
    }

    // ** Short market

    function getBorrowedShort() external view returns (uint256) {
        (, , address variableDebtTokenAddress) = getAssetAddresses(address(WETH));
        return IERC20(variableDebtTokenAddress).balanceOf(address(this));
    }

    function borrowShort(uint256 amountWETH) external onlyAuthorizedCaller {
        IPool(getPool()).borrow(address(WETH), amountWETH, 2, 0, address(this)); // Interest rate mode: 2 = variable
        WETH.transfer(msg.sender, amountWETH);
    }

    function repayShort(uint256 amountWETH) external onlyAuthorizedCaller {
        WETH.transferFrom(msg.sender, address(this), amountWETH);
        IPool(getPool()).repay(address(WETH), amountWETH, 2, address(this));
    }

    function getCollateralShort() external view returns (uint256) {
        (address aTokenAddress, , ) = getAssetAddresses(address(USDC));
        return IERC20(aTokenAddress).balanceOf(address(this));
    }

    function removeCollateralShort(uint256 amountUSDC) external onlyAuthorizedCaller {
        IPool(getPool()).withdraw(address(USDC), amountUSDC, msg.sender);
    }

    function addCollateralShort(uint256 amountUSDC) external onlyAuthorizedCaller {
        USDC.transferFrom(msg.sender, address(this), amountUSDC);
        IPool(getPool()).supply(address(USDC), amountUSDC, address(this), 0);
    }

    // ** Helpers

    function getAssetAddresses(address underlying) public view returns (address, address, address) {
        return IPoolDataProvider(provider.getPoolDataProvider()).getReserveTokensAddresses(underlying);
    }

    function getAssetPrice(address underlying) external view returns (uint256) {
        return IAaveOracle(provider.getPriceOracle()).getAssetPrice(underlying) * 1e10;
    }

    function syncLong() external {}

    function syncShort() external {}

    modifier onlyAuthorizedCaller() {
        require(authorizedCallers[msg.sender] == true, "Caller is not authorized V4 pool");
        _;
    }
}
