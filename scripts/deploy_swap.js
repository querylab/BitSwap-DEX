
const hre = require("hardhat");

async function main() {


  const BITSWAP = await hre.ethers.getContractFactory("BitSwap");
  const bitswap = await BITSWAP.deploy();

  await bitswap.deployed();


  console.log("***********************************************************************************\n");

  console.log(
   `BitSwap contract deployed with address: ${bitswap.address} \n`
   ); 
   console.log("***********************************************************************************\n");



}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
