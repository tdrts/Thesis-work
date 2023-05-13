// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const CONTRACT_NAME = process.env.CONTRACT_NAME;
    const CONTRACT_SYMBOL = process.env.CONTRACT_SYMBOL;
    const NFT = await hre.ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(CONTRACT_NAME, CONTRACT_SYMBOL);
    await nft.deployed();
    let msg = CONTRACT_NAME + ' (' + CONTRACT_SYMBOL+ ') deployed to: ';
    console.log(msg, nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
