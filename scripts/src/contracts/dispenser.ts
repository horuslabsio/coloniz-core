import { Account, Provider, uint256, CallData, Contract } from "starknet";
import dotenv from "dotenv";
dotenv.config();

import abi from "../abi/registry.json";

const PRIVATE_KEY = process.env.PRIVATE_KEY!;
const ACCOUNT_ADDRESS = process.env.ACCOUNT_ADDRESS!;
const RPC_URL = process.env.RPC_URL!;

const ACCOUNT_CONTRACT = process.env.ACCOUNT_CONTRACT!;
const IMPLEMENTATION_HASH = process.env.IMPLEMENTATION_HASH!;
const TOKEN_CONTRACT = process.env.TOKEN_CONTRACT!;
const SALT = process.env.SALT!;
const CHAIN_ID = process.env.CHAIN_ID!;

const TOTAL_AMOUNT_TO_SEND = 0; // total amount to be split across token IDs
const TOKEN_DECIMALS = 0; // adjust depending on the token's decimals

const TOKEN_IDS = [0]; // replace with token IDs

async function main() {
  const provider = new Provider({ nodeUrl: RPC_URL });
  const account = new Account(provider, ACCOUNT_ADDRESS, PRIVATE_KEY);

  const contract = new Contract(abi, ACCOUNT_CONTRACT, provider);
  contract.connect(account);

  const amountPerAccount = TOTAL_AMOUNT_TO_SEND / TOKEN_IDS.length;
  const amountInBaseUnits = BigInt(Math.floor(amountPerAccount * 10 ** TOKEN_DECIMALS));

  const txs: any[] = [];

  for (const tokenId of TOKEN_IDS) {
    const address = await contract.call("get_account", [
      IMPLEMENTATION_HASH,
      TOKEN_CONTRACT,
      uint256.bnToUint256(tokenId),
      SALT,
      CHAIN_ID
    ]);

    console.log(`Sending ${amountPerAccount} tokens to account at ${address} with token ID ${tokenId}`);

    const call = {
      contractAddress: "0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8",
      entrypoint: "transfer",
      calldata: CallData.compile([
        address,
        uint256.bnToUint256(amountInBaseUnits)
      ])
    };

    txs.push(call);
  }

  const res = await account.execute(txs);
  console.log("Transaction hash:", res.transaction_hash);
}

main().catch(console.error);