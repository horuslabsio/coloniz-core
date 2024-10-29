/**
 * 
 * Deployed @
 * 
  // Contract declared with class hash: 0x49722dc899b024c42c6349d85927c7e9045c26b9f7bb9d21df0335901f0e63d
  // Contract deployed at address: [ "0x369fd3deada2d610a330d98befc977451d010c6da9138f114d58688a07ecda1" ]
 */

import {
    Account,
    CallData,
    json,
    RpcProvider,
} from "starknet";
import fs from "fs";
import path from "path";

import {config} from "dotenv";
config();

// Configure the provider and account
const provider = new RpcProvider({ nodeUrl: process.env.RPC_URL });
const account = new Account(
  provider,
  process.env.ACCOUNT_ADDRESS!,
  process.env.ACCOUNT_PRIVATE_KEY!,
  "1"
);

async function deployKarstPublication() {
    try {
      // Read the compiled contract
      const compiledContractCasm = json.parse(
        fs.readFileSync(
          path.resolve(
            __dirname,
            "../../../target/dev/karst_KarstPublication.compiled_contract_class.json"
          ),
        ).toString("ascii")
      );

      const compiledContractSierra = json.parse(
        fs.readFileSync(
          path.resolve(
            __dirname,
            "../../../target/dev/karst_KarstPublication.contract_class.json"
          ),
        ).toString("ascii")
      );

      // Declare the contract
      const declareResponse = await account.declare({
        contract: compiledContractSierra,
        casm: compiledContractCasm,
      });
      
      console.log(declareResponse);
      await provider.waitForTransaction(declareResponse.transaction_hash);
      console.log("Contract declared with class hash:", declareResponse.class_hash);
  
      // Compile the constructor calldata
      const constructorCalldata = CallData.compile({
        karstnft_contract_address: process.env.KARSTNFT_CONTRACT_ADDRESS!,
        hub_address: process.env.HUB_ADDRESS!,
        follow_nft_classhash: process.env.FOLLOW_NFT_CLASSHASH!,
      });
  
      // Deploy the contract
      const deployResponse = await account.deploy({
        classHash: declareResponse.class_hash,
        constructorCalldata,
      });
  
      console.log(deployResponse);
      await provider.waitForTransaction(deployResponse.transaction_hash);
      console.log("Contract deployed at address:", deployResponse.contract_address);
  
      console.log("KarstPublication deployed successfully");
    } catch (error) {
      console.error("Error deploying KarstPublication:", error);
      throw error;
    }
  }
  
  // Main execution
  (async () => {
    try {
      await deployKarstPublication();
    } catch (error) {
      console.error("Deployment failed:", error);
    }
  })();
