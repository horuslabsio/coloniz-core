// *************************************************************************
//                              FOLLOW NFT TEST
// *************************************************************************
use core::option::OptionTrait;
use core::result::ResultTrait;
use core::traits::TryInto;
use starknet::{ContractAddress, get_block_timestamp};

use snforge_std::{
    declare, start_cheat_caller_address, stop_cheat_caller_address, spy_events,
    EventSpyAssertionsTrait, ContractClassTrait, DeclareResultTrait, start_cheat_block_timestamp,
    stop_cheat_block_timestamp
};

use coloniz::interfaces::IFollowNFT::{IFollowNFTDispatcher, IFollowNFTDispatcherTrait};
use coloniz::follownft::follownft::Follow::{Event as FollowEvent, Followed};
use coloniz::follownft::follownft::Follow::{Event as UnfollowEvent, Unfollowed};
use coloniz::follownft::follownft::Follow::{Event as FollowerBlockedEvent, FollowerBlocked};
use coloniz::follownft::follownft::Follow::{Event as FollowerUnblockedEvent, FollowerUnblocked};
use coloniz::base::constants::types::FollowData;
use coloniz::interfaces::IERC721::{IERC721Dispatcher, IERC721DispatcherTrait};

const HUB_ADDRESS: felt252 = 24205;
const ADMIN: felt252 = 13245;
const FOLLOWED_ADDRESS: felt252 = 1234;
const FOLLOWER1: felt252 = 53453;
const FOLLOWER2: felt252 = 24252;
const FOLLOWER3: felt252 = 24552;
const FOLLOWER4: felt252 = 24262;

fn __setup__() -> ContractAddress {
    let follow_nft_contract = declare("Follow").unwrap().contract_class();
    let mut follow_nft_constructor_calldata = array![HUB_ADDRESS, FOLLOWED_ADDRESS, ADMIN];
    let (follow_nft_contract_address, _) = follow_nft_contract
        .deploy(@follow_nft_constructor_calldata)
        .unwrap();
    return (follow_nft_contract_address);
}

// *************************************************************************
//                              TEST
// *************************************************************************
#[test]
fn test_follower_count_on_init_is_zero() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    let follower_count = dispatcher.get_follower_count();
    assert(follower_count == 0, 'invalid_follower_count');
}

#[test]
#[should_panic(expected: ('coloniz: caller is not Hub!',))]
fn test_cannot_call_follow_if_not_hub() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, FOLLOWER2.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
#[should_panic(expected: ('coloniz: caller is not Hub!',))]
fn test_cannot_call_unfollow_if_not_hub() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, FOLLOWER2.try_into().unwrap());
    dispatcher.unfollow(FOLLOWER1.try_into().unwrap());
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
#[should_panic(expected: ('coloniz: already following!',))]
fn test_cannot_follow_if_already_following() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    // follow
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    // try to follow again
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_follow() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    let follow_id = dispatcher.get_follow_id(FOLLOWER1.try_into().unwrap());
    let follower_profile_address = dispatcher.get_follower_profile_address(follow_id);
    assert(follow_id == 1, 'invalid follow ID');
    assert(
        follower_profile_address == FOLLOWER1.try_into().unwrap(), 'invalid follower
    profile'
    );
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_follower_count() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    dispatcher.follow(FOLLOWER2.try_into().unwrap());
    dispatcher.follow(FOLLOWER3.try_into().unwrap());
    dispatcher.follow(FOLLOWER4.try_into().unwrap());
    let follower_count = dispatcher.get_follower_count();
    assert(follower_count == 4, 'invalid follower count');
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_is_following() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    let is_following_should_be_true = dispatcher.is_following(FOLLOWER1.try_into().unwrap());
    let is_following_should_be_false = dispatcher.is_following(FOLLOWER2.try_into().unwrap());
    assert(is_following_should_be_true == true, 'invalid result');
    assert(is_following_should_be_false == false, 'invalid result');
}

#[test]
fn test_follow_data() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    start_cheat_block_timestamp(follow_nft_contract_address, 100);
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    let follow_id = dispatcher.get_follow_id(FOLLOWER1.try_into().unwrap());
    let follow_data = dispatcher.get_follow_data(follow_id);
    let data = FollowData {
        followed_profile_address: FOLLOWED_ADDRESS.try_into().unwrap(),
        follower_profile_address: FOLLOWER1.try_into().unwrap(),
        follow_timestamp: 100,
        block_status: false
    };
    assert(
        follow_data.followed_profile_address == data.followed_profile_address,
        'invalid followed profile'
    );
    assert(
        follow_data.follower_profile_address == data.follower_profile_address,
        'invalid follower profile'
    );
    assert(follow_data.follow_timestamp == data.follow_timestamp, 'invalid follow timestamp');
    assert(follow_data.block_status == data.block_status, 'invalid block status');
    stop_cheat_caller_address(follow_nft_contract_address);
    stop_cheat_block_timestamp(follow_nft_contract_address);
}

#[test]
fn test_unfollow() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    dispatcher.follow(FOLLOWER2.try_into().unwrap());
    dispatcher.unfollow(FOLLOWER1.try_into().unwrap());
    let follow_id = dispatcher.get_follow_id(FOLLOWER1.try_into().unwrap());
    let follower_count = dispatcher.get_follower_count();
    assert(follow_id == 0, 'unfollow operation failed');
    assert(follower_count == 1, 'invalid follower count');
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
#[should_panic(expected: ('coloniz: user not following!',))]
fn test_cannot_unfollow_if_not_following() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.unfollow(FOLLOWER1.try_into().unwrap());
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_process_block() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    dispatcher.process_block(FOLLOWER1.try_into().unwrap());
    let follow_id = dispatcher.get_follow_id(FOLLOWER1.try_into().unwrap());
    let follow_data = dispatcher.get_follow_data(follow_id);
    assert(follow_data.block_status == true, 'block operation failed');
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_process_unblock() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    dispatcher.process_unblock(FOLLOWER1.try_into().unwrap());
    let follow_id = dispatcher.get_follow_id(FOLLOWER1.try_into().unwrap());
    let follow_data = dispatcher.get_follow_data(follow_id);
    assert(follow_data.block_status == false, 'unblock operation failed');
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_metadata() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    let nft_name = dispatcher.name();
    let nft_symbol = dispatcher.symbol();
    assert(nft_name == "coloniz:FOLLOWER", 'invalid name');
    assert(nft_symbol == "KFL", 'invalid symbol');
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_is_blocked() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    dispatcher.process_block(FOLLOWER1.try_into().unwrap());
    assert(
        dispatcher.is_blocked(FOLLOWER1.try_into().unwrap()) == true,
        'incorrect value for is_blocked'
    );
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_follow_mints_nft() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    let _erc721Dispatcher = IERC721Dispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    let follow_id = dispatcher.get_follow_id(FOLLOWER1.try_into().unwrap());
    let follower_profile_address = dispatcher.get_follower_profile_address(follow_id);
    assert(
        _erc721Dispatcher.owner_of(follow_id) == follower_profile_address,
        'Follow did not mint
        NFT'
    );
}

#[test]
#[should_panic(expected: ('ERC721: invalid token ID',))]
fn test_unfollow_burns_nft() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    let _erc721Dispatcher = IERC721Dispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    let follow_id = dispatcher.get_follow_id(FOLLOWER1.try_into().unwrap());
    let follower_profile_address = dispatcher.get_follower_profile_address(follow_id);
    assert(
        _erc721Dispatcher.owner_of(follow_id) == follower_profile_address,
        'Follow did not mint
        NFT'
    );
    dispatcher.unfollow(FOLLOWER1.try_into().unwrap());
    _erc721Dispatcher.owner_of(follow_id);
}

#[test]
fn test_followed_event() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());

    let mut spy = spy_events();
    dispatcher.follow(FOLLOWER1.try_into().unwrap());

    let follow_id = dispatcher.get_follow_id(FOLLOWER1.try_into().unwrap());
    let follower_profile_address = dispatcher.get_follower_profile_address(follow_id);
    let expected_event = FollowEvent::Followed(
        Followed {
            followed_address: FOLLOWED_ADDRESS.try_into().unwrap(),
            follower_address: follower_profile_address,
            follow_id: follow_id,
            timestamp: get_block_timestamp()
        }
    );

    spy.assert_emitted(@array![(follow_nft_contract_address, expected_event)]);

    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_unfollowed_event() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    let mut spy = spy_events();
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    dispatcher.follow(FOLLOWER2.try_into().unwrap());
    dispatcher.unfollow(FOLLOWER1.try_into().unwrap());

    let expected_event = UnfollowEvent::Unfollowed(
        Unfollowed {
            unfollowed_address: FOLLOWED_ADDRESS.try_into().unwrap(),
            unfollower_address: FOLLOWER1.try_into().unwrap(),
            follow_id: 1,
            timestamp: get_block_timestamp()
        }
    );
    spy.assert_emitted(@array![(follow_nft_contract_address, expected_event)]);
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_block_event() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    let mut spy = spy_events();
    dispatcher.process_block(FOLLOWER1.try_into().unwrap());
    let follow_id = dispatcher.get_follow_id(FOLLOWER1.try_into().unwrap());

    let expected_event = FollowerBlockedEvent::FollowerBlocked(
        FollowerBlocked {
            followed_address: FOLLOWED_ADDRESS.try_into().unwrap(),
            blocked_follower: FOLLOWER1.try_into().unwrap(),
            follow_id: follow_id,
            timestamp: get_block_timestamp()
        }
    );
    spy.assert_emitted(@array![(follow_nft_contract_address, expected_event)]);
    stop_cheat_caller_address(follow_nft_contract_address);
}

#[test]
fn test_unblock_event() {
    let follow_nft_contract_address = __setup__();
    let dispatcher = IFollowNFTDispatcher { contract_address: follow_nft_contract_address };
    start_cheat_caller_address(follow_nft_contract_address, HUB_ADDRESS.try_into().unwrap());
    dispatcher.follow(FOLLOWER1.try_into().unwrap());
    let mut spy = spy_events();
    dispatcher.process_unblock(FOLLOWER1.try_into().unwrap());
    let follow_id = dispatcher.get_follow_id(FOLLOWER1.try_into().unwrap());

    let expected_event = FollowerUnblockedEvent::FollowerUnblocked(
        FollowerUnblocked {
            followed_address: FOLLOWED_ADDRESS.try_into().unwrap(),
            unblocked_follower: FOLLOWER1.try_into().unwrap(),
            follow_id: follow_id,
            timestamp: get_block_timestamp()
        }
    );
    spy.assert_emitted(@array![(follow_nft_contract_address, expected_event)]);
    stop_cheat_caller_address(follow_nft_contract_address);
}
