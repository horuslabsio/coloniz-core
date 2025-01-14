import { TBAChainID, TBAVersion, TokenboundClient, WalletClient } from "starknet-tokenbound-sdk";

const walletClient: WalletClient = {
    address: "0x07EadF65B6D96A7DEbB36380fF936F6701a053Be8f2824D6293f188fA542C502",
    privateKey: "",
  };
  const options = {
    walletClient: walletClient,
    chain_id: TBAChainID.sepolia,
    version: TBAVersion.V2,
    jsonRPC: "https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_7/LSOcLfeCY8c4ovUNnDNX4YJhkMpsVD5F",
  };
  const tokenbound = new TokenboundClient(options);
export default  tokenbound


// erc20 contract: 0x006e1698dcd0665757dd213a59aff489624bab8c970ce0482c23937a78879b04
// erc721: 0x04b91a940002d2d8d42272bc4de1dc5d7b34a8566c4fe655aa6ae8b8e0313b37