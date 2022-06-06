const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const MCDATA = await hre.ethers.getContractFactory("Chunks_MinecraftPlayerData");
  const mcdata = await MCDATA.deploy("0x9399BB24DBB5C4b782C70c2969F58716Ebbd6a3b");

  await mcdata.deployed();

  console.log("MC Player Data Contract deployed to:", mcdata.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });