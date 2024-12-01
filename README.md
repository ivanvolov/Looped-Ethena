# Aavena vault

![image](https://github.com/user-attachments/assets/bd0d0294-300b-45a3-8f79-3e03bc95afca)

🚀 Inspired by [Seraphim’s tweet](https://x.com/MacroMate8/status/1857308639486427210), Aavena Loop vault simplifies and automates a popular leverage strategy.

Which we structure this as a one-click vault that automates the following flow:

1. Lend stETH as collateral on Aave (50% LTV).
2. Borrow USDT stablecoin.
3. Swap USDT into sUSDe.
4. Lend sUSDe on Aave.
5. Loop to maximize yields.

This streamlined process boosts stablecoin liquidity on Aave and offers users a seamless, high-yield strategy.

## 🛠️ Technical Details

### Automated Rebalancing
The Aavena Loop vault automatically rebalances its positions once per week. This process reinvests accrued yield back into ETH, maximizing ETH stacking efficiency and compounding returns over time.

### Implemented Functions

#### 1. Deposit Function
The `deposit` function allows users to contribute stETH as collateral into the vault. Once deposited:
- The stETH is lent on Aave.
- Stablecoins are borrowed against the collateral.
- The borrowed stablecoins are swapped into sUSDe and reinvested in Aave applying flash loan operation for improved gas efficiency.

This process starts the automated looping strategy and optimizes the user's yield.

#### 2. Withdraw Function
The `withdraw` function enables users to exit the strategy by:
- Unwinding their looped positions.
- Reclaiming their original stETH collateral.

Both functions are designed to provide seamless user interaction while maintaining capital efficiency and safety.

## 🌟 User Benefits

- **Automation:** No manual looping or position management required.  
- **Maximized Yields:** Weekly rebalancing reinvests returns for compounding gains.  
- **Gas Efficiency:** Flash loan operations minimize transaction costs.  
- **Seamless Experience:** Simple deposit and withdrawal process.  

## 🔮 Future Plans

1. Complete the weekly rebalance procedure to reinvest yield into ETH.  
2. Integrate Morpho and Euler to increase vault capacity.  
3. Deploy the vault to mainnet.  
4. Build a similar vault for cbBTC to DCA into BTC using Ethena yield.

## How to run locally

### Setting up

```
forge install
```

### Build

```shell
forge build
```

### Format

```shell
forge fmt
```

### Test all project

```
make test_all
```
