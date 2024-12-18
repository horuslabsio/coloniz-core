use starknet::{ContractAddress, ClassHash};
use coloniz::base::constants::types::{
    Profile, PostParams, RepostParams, CommentParams, PublicationType, Publication
};
use coloniz::base::constants::types::ProfileVariants;

// *************************************************************************
//                              INTERFACE of HUB CONTRACT
// *************************************************************************
#[starknet::interface]
pub trait IHub<TState> {
    // *************************************************************************
    //                              PROFILE
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

    fn get_profile_metadata(self: @TState, profile_address: ContractAddress) -> ByteArray;

    fn get_profile(self: @TState, profile_address: ContractAddress) -> Profile;

    fn get_user_publication_count(self: @TState, profile_address: ContractAddress) -> u256;

    // *************************************************************************
    //                            PUBLICATION
    // *************************************************************************
    fn post(ref self: TState, post_params: PostParams) -> u256;

    fn comment(ref self: TState, comment_params: CommentParams) -> u256;

    fn repost(ref self: TState, repost_params: RepostParams) -> u256;

    fn get_publication(
        self: @TState, profile_address: ContractAddress, pub_id_assigned: u256
    ) -> Publication;

    fn get_publication_type(
        self: @TState, profile_address: ContractAddress, pub_id_assigned: u256
    ) -> PublicationType;

    fn get_publication_content_uri(
        self: @TState, profile_address: ContractAddress, pub_id: u256
    ) -> ByteArray;

    // *************************************************************************
    //                            FOLLOW INTERACTIONS
    // *************************************************************************
    fn follow(
        ref self: TState, address_of_profiles_to_follow: Array<ContractAddress>
    ) -> Array<u256>;
    fn unfollow(ref self: TState, address_of_profiles_to_unfollow: Array<ContractAddress>);
    fn set_block_status(
        ref self: TState, address_of_profiles_to_block: Array<ContractAddress>, block_status: bool
    );
    fn is_following(
        self: @TState, followed_profile_address: ContractAddress, follower_address: ContractAddress
    ) -> bool;
    fn is_blocked(
        self: @TState, followed_profile_address: ContractAddress, follower_address: ContractAddress
    ) -> bool;

    // *************************************************************************
    //                            HANDLES
    // *************************************************************************
    fn get_handle_id(self: @TState, profile_address: ContractAddress) -> u256;
    fn get_handle(self: @TState, handle_id: u256) -> ByteArray;

    // *************************************************************************
    //                            UPGRADEABILITY
    // *************************************************************************
    fn upgrade(ref self: TState, new_class_hash: ClassHash);
}
