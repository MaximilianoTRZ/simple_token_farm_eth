import { ethers } from "hardhat";

async function main() {
  const DappToken = await ethers.getContractFactory("DappToken");
  const dappToken = await DappToken.deploy();
  await dappToken.deployed();

  console.log("DappToken deployed to:", dappToken.address);

  const LPToken = await ethers.getContractFactory("LPToken");
  const lptoken = await LPToken.deploy();
  await lptoken.deployed();

  console.log("LPToken deployed to:", lptoken.address);

  const TokenFarm = await ethers.getContractFactory("TokenFarm");
  const tokenFarm = await TokenFarm.deploy(dappToken.address, lptoken.address);
  await tokenFarm.deployed();

  console.log("TokenFarm deployed to:", tokenFarm.address);

  // Give tokenFarm access to dappToken mint function
  await dappToken.toggleController(tokenFarm.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
