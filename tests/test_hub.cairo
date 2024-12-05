// *************************************************************************
//                              HUB TEST
// *************************************************************************
use core::option::OptionTrait;
use core::starknet::SyscallResultTrait;
use core::result::ResultTrait;
use core::traits::{TryInto, Into};
use starknet::{ContractAddress};
use snforge_std::{
    declare, DeclareResultTrait, ContractClassTrait, start_cheat_caller_address,
    stop_cheat_caller_address
};
use coloniz::interfaces::IHub::{IHubDispatcher, IHubDispatcherTrait};
use coloniz::interfaces::IHandle::{IHandleDispatcher, IHandleDispatcherTrait};
use coloniz::interfaces::IHandleRegistry::{
    IHandleRegistryDispatcher, IHandleRegistryDispatcherTrait
};

const ADMIN: felt252 = 13245;
const ADDRESS1: felt252 = 1234;
const ADDRESS2: felt252 = 53453;
const ADDRESS3: felt252 = 24252;
const ADDRESS4: felt252 = 24552;
const TEST_LOCAL_NAME: felt252 = 'user';
const OWNER: felt252 = 2357;

// *************************************************************************
//                              SETUP
// *************************************************************************
fn __setup__() -> (ContractAddress, ContractAddress, ContractAddress, ContractAddress, u256) {
    // deploy NFT
    let nft_class_hash = declare("ColonizNFT").unwrap().contract_class();
    let mut calldata: Array<felt252> = array![ADMIN];
    let (nft_contract_address, _) = nft_class_hash.deploy(@calldata).unwrap_syscall();

    // deploy handle contract
    let handle_class_hash = declare("Handles").unwrap().contract_class();
    let mut calldata: Array<felt252> = array![ADMIN];
    let (handle_contract_address, _) = handle_class_hash.deploy(@calldata).unwrap_syscall();

    // deploy handle registry contract
    let handle_registry_class_hash = declare("HandleRegistry").unwrap().contract_class();
    let mut calldata: Array<felt252> = array![handle_contract_address.into()];
    let (handle_registry_contract_address, _) = handle_registry_class_hash
        .deploy(@calldata)
        .unwrap_syscall();

    // deploy tokenbound registry
    let registry_class_hash = declare("Registry").unwrap().contract_class();

    // declare tokenbound account
    let account_class_hash = declare("AccountV3").unwrap().contract_class();

    // declare follownft
    let follow_nft_classhash = declare("Follow").unwrap().contract_class();

    // declare community_nft
    let community_nft_classhash = declare("CommunityNFT").unwrap().contract_class();

    // declare collectnft
    let collect_nft_classhash = declare("CollectNFT").unwrap().contract_class();

    // deploy hub contract
    let hub_class_hash = declare("ColonizHub").unwrap().contract_class();
    let mut calldata: Array<felt252> = array![
        nft_contract_address.into(),
        handle_contract_address.into(),
        handle_registry_contract_address.into(),
        (*follow_nft_classhash.class_hash).into(),
        (*community_nft_classhash.class_hash).into(),
        (*collect_nft_classhash.class_hash).into(),
        OWNER
    ];
    let (hub_contract_address, _) = hub_class_hash.deploy(@calldata).unwrap_syscall();

    // create profiles
    let dispatcher = IHubDispatcher { contract_address: hub_contract_address };
    start_cheat_caller_address(hub_contract_address, ADDRESS1.try_into().unwrap());
    let user_one_profile_address = dispatcher
        .create_profile(
            nft_contract_address,
            (*registry_class_hash.class_hash).into(),
            (*account_class_hash.class_hash).into(),
            2478
        );
    stop_cheat_caller_address(hub_contract_address);

    start_cheat_caller_address(hub_contract_address, ADDRESS2.try_into().unwrap());
    let user_two_profile_address = dispatcher
        .create_profile(
            nft_contract_address,
            (*registry_class_hash.class_hash).into(),
            (*account_class_hash.class_hash).into(),
            2478
        );

    stop_cheat_caller_address(hub_contract_address);

    start_cheat_caller_address(hub_contract_address, ADDRESS3.try_into().unwrap());
    let user_three_profile_address = dispatcher
        .create_profile(
            nft_contract_address,
            (*registry_class_hash.class_hash).into(),
            (*account_class_hash.class_hash).into(),
            2478
        );
    stop_cheat_caller_address(hub_contract_address);

    // mint and link handle for user_one
    start_cheat_caller_address(handle_contract_address, user_one_profile_address);
    let handleDispatcher = IHandleDispatcher { contract_address: handle_contract_address };
    let handleRegistryDispatcher = IHandleRegistryDispatcher {
        contract_address: handle_registry_contract_address
    };
    let minted_handle_id = handleDispatcher.mint_handle(TEST_LOCAL_NAME);
    stop_cheat_caller_address(handle_contract_address);

    start_cheat_caller_address(handle_registry_contract_address, user_one_profile_address);
    handleRegistryDispatcher.link(minted_handle_id, user_one_profile_address);
    stop_cheat_caller_address(handle_registry_contract_address);

    return (
        hub_contract_address,
        user_one_profile_address,
        user_two_profile_address,
        user_three_profile_address,
        minted_handle_id
    );
}

// *************************************************************************
//                              TEST
// *************************************************************************
#[test]
fn test_hub_following() {
    let (
        hub_contract_address,
        user_one_profile_address,
        user_two_profile_address,
        user_three_profile_address,
        _
    ) =
        __setup__();

    let dispatcher = IHubDispatcher { contract_address: hub_contract_address };

    start_cheat_caller_address(hub_contract_address, user_one_profile_address);
    let profiles_to_follow: Array<ContractAddress> = array![
        user_two_profile_address, user_three_profile_address
    ];
    dispatcher.follow(profiles_to_follow);

    let follow_status_1 = dispatcher
        .is_following(user_two_profile_address, user_one_profile_address);
    let follow_status_2 = dispatcher
        .is_following(user_three_profile_address, user_one_profile_address);

    assert(follow_status_1 == true, 'invalid follow status');
    assert(follow_status_2 == true, 'invalid follow status');
    stop_cheat_caller_address(hub_contract_address);
}

#[test]
#[should_panic(expected: ('coloniz: invalid profile_addr!',))]
fn test_hub_following_fails_if_any_profile_is_invalid() {
    let (hub_contract_address, user_one_profile_address, _, user_three_profile_address, _) =
        __setup__();

    let dispatcher = IHubDispatcher { contract_address: hub_contract_address };

    start_cheat_caller_address(hub_contract_address, user_one_profile_address);
    let profiles_to_follow: Array<ContractAddress> = array![
        ADDRESS4.try_into().unwrap(), user_three_profile_address
    ];
    dispatcher.follow(profiles_to_follow);
    stop_cheat_caller_address(hub_contract_address);
}

#[test]
#[should_panic(expected: ('coloniz: self_follow forbidden',))]
fn test_hub_following_fails_if_profile_is_self_following() {
    let (hub_contract_address, user_one_profile_address, _, _, _) = __setup__();

    let dispatcher = IHubDispatcher { contract_address: hub_contract_address };

    start_cheat_caller_address(hub_contract_address, user_one_profile_address);
    let profiles_to_follow: Array<ContractAddress> = array![user_one_profile_address];
    dispatcher.follow(profiles_to_follow);
    stop_cheat_caller_address(hub_contract_address);
}

#[test]
fn test_hub_unfollowing() {
    let (
        hub_contract_address,
        user_one_profile_address,
        user_two_profile_address,
        user_three_profile_address,
        _
    ) =
        __setup__();

    let dispatcher = IHubDispatcher { contract_address: hub_contract_address };

    // first follow the profiles
    start_cheat_caller_address(hub_contract_address, user_one_profile_address);
    let profiles_to_follow: Array<ContractAddress> = array![
        user_two_profile_address, user_three_profile_address
    ];
    dispatcher.follow(profiles_to_follow);

    // then unfollow them
    let profiles_to_unfollow: Array<ContractAddress> = array![
        user_two_profile_address, user_three_profile_address
    ];
    dispatcher.unfollow(profiles_to_unfollow);
    stop_cheat_caller_address(hub_contract_address);

    // check following status
    let follow_status_1 = dispatcher
        .is_following(user_two_profile_address, user_one_profile_address);
    let follow_status_2 = dispatcher
        .is_following(user_three_profile_address, user_one_profile_address);

    assert(follow_status_1 == false, 'invalid follow status');
    assert(follow_status_2 == false, 'invalid follow status');
}

#[test]
fn test_set_block_status() {
    let (
        hub_contract_address,
        user_one_profile_address,
        user_two_profile_address,
        user_three_profile_address,
        _
    ) =
        __setup__();

    let dispatcher = IHubDispatcher { contract_address: hub_contract_address };

    // follow action
    start_cheat_caller_address(hub_contract_address, user_one_profile_address);
    dispatcher.follow(array![user_two_profile_address, user_three_profile_address]);
    stop_cheat_caller_address(hub_contract_address);

    // block action
    start_cheat_caller_address(hub_contract_address, user_two_profile_address);
    let profiles_to_block: Array<ContractAddress> = array![user_one_profile_address];
    dispatcher.set_block_status(profiles_to_block, true);

    // check block status
    let block_status_1 = dispatcher.is_blocked(user_two_profile_address, user_one_profile_address);
    assert(block_status_1 == true, 'invalid block status');
    stop_cheat_caller_address(hub_contract_address);

    // unblock action
    start_cheat_caller_address(hub_contract_address, user_two_profile_address);
    let profiles_to_unblock: Array<ContractAddress> = array![user_one_profile_address];
    dispatcher.set_block_status(profiles_to_unblock, false);

    // check block status
    let block_status_2 = dispatcher.is_blocked(user_two_profile_address, user_one_profile_address);
    assert(block_status_2 == false, 'invalid block status');
    stop_cheat_caller_address(hub_contract_address);
}

#[test]
fn test_get_handle_id() {
    let (hub_contract_address, user_one_profile_address, _, _, minted_handle_id) = __setup__();
    let dispatcher = IHubDispatcher { contract_address: hub_contract_address };
    let handle_id = dispatcher.get_handle_id(user_one_profile_address);
    assert(handle_id == minted_handle_id, 'invalid handle id');
}

#[test]
fn test_get_handle() {
    let (hub_contract_address, _, _, _, minted_handle_id) = __setup__();

    let dispatcher = IHubDispatcher { contract_address: hub_contract_address };
    let handle = dispatcher.get_handle(minted_handle_id);
    assert(handle == "user.kst", 'invalid handle id');
}
