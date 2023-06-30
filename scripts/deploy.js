
const hre = require("hardhat");




async function main() {


  const WETH = await hre.ethers.getContractFactory("WETH");
  const weth = await WETH.deploy();

  await weth.deployed();

  const WBTC = await hre.ethers.getContractFactory("WBTC");
  const wbtc = await WBTC.deploy();

  await wbtc.deployed();

  const USDC = await hre.ethers.getContractFactory("USDC");
  const usdc = await USDC.deploy();

  await usdc.deployed();

  const DAI = await hre.ethers.getContractFactory("DAI");
  const dai = await DAI.deploy();

  await dai.deployed();

  


 

 
   console.log("***********************************************************************************\n");
   console.log(
    `WETH contract deployed with address: ${weth.address} \n`
    ); 
    console.log("***********************************************************************************\n");
 
   console.log(
     `WBTC contract deployed with address: ${wbtc.address} \n`
    ); 
    console.log("***********************************************************************************\n");
 
    console.log(
     `USDC contract deployed with address: ${usdc.address} \n`
    ); 
    console.log("***********************************************************************************\n");
 
    console.log(
     `DAI contract deployed with address: ${dai.address} \n`
    ); 
    console.log("***********************************************************************************\n");
 





}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
