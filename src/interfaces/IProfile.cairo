use starknet::ContractAddress;
use coloniz::base::constants::types::Profile;
use coloniz::base::constants::types::ProfileVariants;
// *************************************************************************
//                              INTERFACE of COLONIZ PROFILE
// *************************************************************************
#[starknet::interface]
pub trait IProfile<TState> {
    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn create_profile(
        ref self: TState,
        registry_contract_address: ContractAddress,
        implementation_hash: felt252,
        salt: felt252,
        profile_variants: ProfileVariants
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
