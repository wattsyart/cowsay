const hre = require("hardhat");

async function main() {
  const Cowsay = await hre.ethers.getContractFactory("Cowsay");
  const cowsay = await Cowsay.deploy(unlockTime, { value: lockedAmount });
  await cowsay.deployed();
  console.log(`Cowsay deployed to ${cowsay.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
