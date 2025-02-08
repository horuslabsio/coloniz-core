pub mod coloniznft;
pub mod interfaces;
pub mod profile;
pub mod base;
pub mod follownft;
pub mod mocks;
pub mod publication;
pub mod namespaces;
pub mod presets;
pub mod hub;
pub mod jolt;
pub mod community;
pub mod channel;


use coloniz::base::token_uris::follow_token_uri::FollowTokenUri::get_token_uri;
use starknet::ContractAddress;

fn main() {
    let token_id = 232110;
    let followed_profile_address: ContractAddress = 525242.try_into().unwrap();
    let timestamp: u64 = 267;

    let token_uri: ByteArray = get_token_uri(token_id, followed_profile_address, timestamp);
    println!("{:?}", token_uri);
}
