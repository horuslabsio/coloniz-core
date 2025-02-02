use starknet::ContractAddress;

// *************************************************************************
//                              INTERFACE of ICommunity NFT
// *************************************************************************
#[starknet::interface]
pub trait ICustomNFT<TState> {
    // *************************************************************************
    //                            EXTERNALS
    // *************************************************************************

    fn mint_nft(ref self: TState, user_address: ContractAddress) -> u256;
    fn burn_nft(ref self: TState, user_address: ContractAddress, token_id: u256);

    // *************************************************************************
    //                            GETTERS
    // *************************************************************************
    fn get_user_token_id(self: @TState, user_address: ContractAddress) -> u256;

    // *************************************************************************
    //                            METADATA
    // *************************************************************************
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
    fn token_uri(self: @TState, token_id: u256) -> ByteArray;
}
