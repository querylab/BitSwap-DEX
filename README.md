# BitSwapDEX-ERC20 🏛️📜💰 

BitSwap is a decentralized exchange deployed on Sepolia Testnet, using ReactJS, Solidity and Hardhat. It allows users to exchange tokens and be liquidity providers, without intermediaries. It is transparent, secure and accessible, with demo coins for testing.


## Setting Up
---
## 1. Clone the repository

## 2. Install dependencies

```bash
$ cd BitSwapDEX-ERC20
$ npm install 
```
## 3. Change variables in Files
```bash
# hardhat.config.js
$ SEPOLIA_ALCHEMY_API_KEY
$ SEPOLIA_PRIVATE_KEY
# src/App.js
$ wethcontract_address
$ wbtccontract_address
$ usdccontract_address
$ daicontract_address
$ bitswapcontract_address
```
## 4. Deployment Solidity Contract Addresses
```bash
# Deployment Contract in folder hardhat-contracts
$ npx hardhat clean
$ npx hardhat compile
```

``` bash
$ npx hardhat run scripts/deploy.js --network sepolia

$ npx hardhat run scripts/deploy_swap.js --network sepolia
```
<a href="https://imgur.com/fB1VLuG"><img src="https://i.imgur.com/fB1VLuG.gif" title="source: imgur.com" /></a>
<a href="https://imgur.com/rRMQ6z1"><img src="https://i.imgur.com/rRMQ6z1.gif" title="source: imgur.com" /></a>

``` bash
#After deploying the Tokens and BitSwap Contracts replace this address in src/sApp.js file with the variable:

$ wethcontract_address
$ wbtccontract_address
$ usdccontract_address
$ daicontract_address
$ bitswapcontract_addres

```


``` bash
# Now you need to call all tokens contract in your Metamask wallet to have funds from the created tokens.
```
<a href="https://imgur.com/IbGeu8a"><img src="https://i.imgur.com/IbGeu8a.gif" title="source: imgur.com" /></a>


## 5. Localhost Deployment

``` bash
$ npm start

http://localhost:3000/

```
<a href="https://imgur.com/g898yNJ"><img src="https://i.imgur.com/g898yNJ.gif" title="source: imgur.com" /></a>


## 6. Create Liquidity

<a href="https://imgur.com/o7Bx3BK"><img src="https://i.imgur.com/o7Bx3BK.gif" title="source: imgur.com" /></a>


<a href="https://imgur.com/76XhNdH"><img src="https://i.imgur.com/76XhNdH.gif" title="source: imgur.com" /></a>























