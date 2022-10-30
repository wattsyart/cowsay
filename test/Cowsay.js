const {  loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const fs = require('fs');

describe("Cowsay", function () {
  async function deployFixture() {
    const [owner, stranger] = await ethers.getSigners();
    const Cowsay = await ethers.getContractFactory("Cowsay");
    const cowsay = await Cowsay.deploy();
    return { cowsay, owner, stranger };
  }

  it("Can draw all message lengths", async function () {
    const { cowsay } = await loadFixture(deployFixture);    

    const shortMessage = "Moo, gentlekin!";
    console.log(await cowsay["cowsay(string)"](shortMessage));
    console.log(await cowsay["cowthink(string)"](shortMessage));
    
    const mediumMessage = "Moo, gentlekin!\nGentlekin, moo!";
    console.log(await cowsay["cowsay(string)"](mediumMessage));
    console.log(await cowsay["cowthink(string)"](mediumMessage));
    
    const longMessage = "Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo Moo";
    console.log(await cowsay["cowsay(string)"](longMessage));  
    console.log(await cowsay["cowthink(string)"](longMessage));
  });

  it("Can draw custom cows", async function () {
    const { cowsay } = await loadFixture(deployFixture);        
    await testCustomCow(cowsay, "squirrel");
    await testCustomCow(cowsay, "three-eyes");
  });
});

async function testCustomCow(cowsay, cowName) {
  const cowFile = fs.readFileSync(`./test/cows/${cowName}.cow`, 'utf8');
  await cowsay.setCow(cowName, cowFile);
  console.log(await cowsay["cowsay(string,string)"](`I am a ${cowName}!`, cowName));
}