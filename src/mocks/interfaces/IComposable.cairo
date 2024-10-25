use starknet::ContractAddress;
use coloniz::base::constants::types::{
    Profile, PublicationType, Publication, RepostParams, PostParams, CommentParams
};
// *************************************************************************
//                              INTERFACE of coloniz PROFILE
// *************************************************************************
#[starknet::interface]
pub trait IComposable<TState> {
    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn create_profile(
        ref self: TState,
        coloniznft_contract_address: ContractAddress,
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

    // // *************************************************************************
    //                             PUBLICATION
    // *************************************************************************

    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn initialize(ref self: TState, hub_address: ContractAddress);
    fn post(ref self: TState, post_params: PostParams) -> u256;
    fn comment(ref self: TState, comment_params: CommentParams) -> u256;
    fn repost(ref self: TState, repost_params: RepostParams) -> u256;
    fn upvote(ref self: TState, profile_address: ContractAddress, pub_id: u256,);
    fn downvote(ref self: TState, profile_address: ContractAddress, pub_id: u256,);
    fn tip(
        ref self: TState,
        profile_address: ContractAddress,
        pub_id: u256,
        amount: u256,
        erc20_contract_address: ContractAddress,
    );
    fn collect(
        ref self: TState,
        profile_address: ContractAddress,
        pub_id: u256,
        channel_id: u256,
        community_id: u256,
        collect_nft_impl_class_hash: felt252,
    ) -> u256;

    // *************************************************************************
    //                              GETTERS
    // *************************************************************************
    fn get_publication(
        self: @TState, profile_address: ContractAddress, pub_id_assigned: u256
    ) -> Publication;
    fn get_publication_type(
        self: @TState, profile_address: ContractAddress, pub_id_assigned: u256
    ) -> PublicationType;
    fn get_publication_content_uri(
        self: @TState, profile_address: ContractAddress, pub_id: u256
    ) -> ByteArray;
    fn has_user_voted(self: @TState, profile_address: ContractAddress, pub_id: u256) -> bool;
    fn get_upvote_count(self: @TState, profile_address: ContractAddress, pub_id: u256) -> u256;
    fn get_downvote_count(self: @TState, profile_address: ContractAddress, pub_id: u256) -> u256;
    fn get_tipped_amount(self: @TState, profile_address: ContractAddress, pub_id: u256) -> u256;
}
