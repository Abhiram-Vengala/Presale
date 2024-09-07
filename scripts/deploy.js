// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const CFT = await hre.ethers.deployContract("CFTToken");

  await CFT.waitForDeployment();

  const presale = await hre.ethers.deployContract("Presale",[CFT.target,"0x7169D38820dfd117C3FA1f22a697dBA58d90BA06"]);

  await presale.waitForDeployment();

  console.log(
    `cft address : ${CFT.target}
     presale address : ${presale.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
