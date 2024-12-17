use starknet::{ContractAddress, ClassHash};
use coloniz::base::constants::types::ProfileVariants;
// *************************************************************************
//                              INTERFACE of coloniz NFT
// *************************************************************************
#[starknet::interface]
pub trait IColonizNFT<TState> {
    // *************************************************************************
    //                            EXTERNALS
    // *************************************************************************
    fn mint_coloniznft(
        ref self: TState, address: ContractAddress, profile_variant: ProfileVariants
    );
    fn set_base_uri(ref self: TState, base_uri: ByteArray);
    fn upgrade(ref self: TState, new_class_hash: ClassHash);
    // *************************************************************************
    //                            GETTERS
    // *************************************************************************
    fn get_last_minted_id(self: @TState) -> u256;
    fn get_user_token_id(self: @TState, user: ContractAddress) -> u256;
    fn get_token_mint_timestamp(self: @TState, token_id: u256) -> u64;
    fn get_profile_variant(self: @TState, token_id: u256) -> ProfileVariants;
    // *************************************************************************
    //                            METADATA
    // *************************************************************************
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
    fn token_uri(self: @TState, token_id: u256) -> ByteArray;
}
