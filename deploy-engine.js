const hre = require("hardhat");

async function main() {
  const TOKEN_ADDRESS = "0x..."; // e.g., USDC Address
  
  const Engine = await hre.ethers.getContractFactory("SubscriptionEngine");
  const engine = await Engine.deploy(TOKEN_ADDRESS);
  await engine.waitForDeployment();

  console.log("Subscription Engine deployed to:", await engine.getAddress());

  // Create a monthly plan (30 days = 2592000 seconds) for 50 USDC
  const amount = hre.ethers.parseUnits("50", 6);
  const frequency = 2592000;
  
  await engine.createPlan(amount, frequency);
  console.log("Monthly plan created.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
