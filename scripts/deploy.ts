import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners(); // Get the deployer's address
  const adminAddress = deployer.address; // Use deployer as the admin

  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy FixedCapToken
  const token = await ethers.deployContract("DTVTToken", [adminAddress]);
  await token.waitForDeployment();
  console.log("FixedCapToken Contract Deployed at:", token.target);

  // USDC Token Address (Replace with actual USDC token address or deploy a mock token for testing)
  const usdcAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"; // Replace with actual USDC address

  // Define the token sale rate (e.g., 100 tokens per ETH)
  const tokenSaleRate = 100;

  // Deploy FixedCapTokenSale with required arguments
  const sale = await ethers.deployContract("FixedCapTokenSale", [
    token.target, // FixedCapToken address
    usdcAddress, // USDC token address
    tokenSaleRate, // Rate
  ]);

  await sale.waitForDeployment();
  console.log("FixedCapTokenSale Contract Deployed at:", sale.target);
}

// Run the deployment script
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
