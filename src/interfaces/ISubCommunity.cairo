use starknet::ContractAddress;
use coloniz::base::constants::types::{ChannelDetails, SubCommunityDetails};

#[starknet::interface]
pub trait ISubCommunity<TState> {
    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn create_sub_community(ref self: TState, sub_community_id: u256, community_id: u256) -> u256;
    fn create_channel(ref self: TState, channel_id: u256, sub_community_id: u256) -> u256;
    fn set_sub_community_metadata_uri(ref self: TState, sub_community_id: u256, metadata_uri: ByteArray);
    fn set_channel_metadata_uri(ref self: TState, channel_id: u256, metadata_uri: ByteArray);
    fn add_sub_community_mods(ref self: TState, sub_community_id: u256, moderators: Array<ContractAddress>);
    fn remove_sub_community_mods(ref self: TState, sub_community_id: u256, moderators: Array<ContractAddress>);
    fn delete_sub_community(ref self: TState, sub_community_id: u256);
    fn delete_channel(ref self: TState, channel_id: u256);

    // *************************************************************************
    //                              GETTERS
    // *************************************************************************
    fn get_sub_community(self: @TState, sub_community_id: u256) -> SubCommunityDetails;
    fn get_channel(self: @TState, channel_id: u256) -> ChannelDetails;
    fn get_parent_community_id(self: @TState, sub_community_id: u256) -> u256;
    fn get_sub_community_metadata_uri(self: @TState, sub_community_id: u256) -> ByteArray;
    fn get_channel_metadata_uri(self: @TState, channel_id: u256) -> ByteArray;
    fn is_sub_community_mod(self: @TState, profile: ContractAddress, sub_community_id: u256) -> bool;
    fn is_sub_community_deleted(self: @TState, sub_community_id: u256) -> bool;
    fn is_channel_deleted(self: @TState, channel_id: u256) -> bool;
}
