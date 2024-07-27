use starknet::ContractAddress;
use karst::base::constants::types::Profile;
// *************************************************************************
//                              INTERFACE of KARST PROFILE
// *************************************************************************
#[starknet::interface]
pub trait IProfile<TState> {
    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn initializer(
        ref self: TState,
        karst_nft_address: ContractAddress,
        hub_address: ContractAddress,
        follow_nft_classhash: felt252
    );
    fn create_profile(
        ref self: TState,
        karstnft_contract_address: ContractAddress,
        registry_hash: felt252,
        implementation_hash: felt252,
        salt: felt252
    ) -> ContractAddress;
    fn set_profile_metadata_uri(
        ref self: TState, profile_address: ContractAddress, metadata_uri: ByteArray
    );
    // *************************************************************************
    //                              GETTERS
    // *************************************************************************
    fn get_profile_metadata(self: @TState, profile_address: ContractAddress) -> ByteArray;
    fn get_profile(self: @TState, profile_address: ContractAddress) -> Profile;
    fn get_user_publication_count(self: @TState, profile_address: ContractAddress) -> u256;
}
