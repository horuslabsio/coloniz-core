// *************************************************************************
//                              SUB_COMMUNITY TEST
// *************************************************************************
use core::option::OptionTrait;
use core::result::ResultTrait;
use core::traits::{TryInto, Into};
use starknet::ContractAddress;

use snforge_std::{
    declare, start_cheat_caller_address, start_cheat_block_timestamp, stop_cheat_caller_address, spy_events,
    EventSpyAssertionsTrait, ContractClassTrait, DeclareResultTrait
};

use coloniz::interfaces::ICommunity::{ICommunityDispatcher, ICommunityDispatcherTrait};
use coloniz::interfaces::ISubCommunity::{ISubCommunityDispatcher, ISubCommunityDispatcherTrait};
use coloniz::sub_community::sub_community::SubCommunityComponent::{
    { Event as SubCommunityCreatedEvent, SubCommunityCreated },
    { Event as ChannelCreatedEvent, ChannelCreated }
};

const HUB_ADDRESS: felt252 = 'HUB';
const ADMIN: felt252 = 'ADMIN';
const USER_ONE: felt252 = 'BOB';
const USER_TWO: felt252 = 'ALICE';
const USER_THREE: felt252 = 'ROB';
const USER_FOUR: felt252 = 'DAN';
const USER_FIVE: felt252 = 'RANDY';
const USER_SIX: felt252 = 'JOE';
const NFT_ONE: felt252 = 'JOE_NFT';

// *************************************************************************
//                              SETUP
// *************************************************************************
fn __setup__() -> ContractAddress {
    // deploy community nft
    let community_nft_class_hash = declare("CommunityNFT").unwrap().contract_class().class_hash;

    let sub_community_contract = declare("ColonizSubCommunity").unwrap().contract_class();
    let mut constructor_calldata = array![(*(community_nft_class_hash)).into()];
    let (contract_address, _) = sub_community_contract.deploy(@constructor_calldata).unwrap();

    return contract_address;
}

// *************************************************************************
//                              TESTS
// *************************************************************************
#[test]
fn test_sub_community_creation() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);

    stop_cheat_caller_address(contract_address);

    assert(sub_community_id == 234, 'invalid sub community ID');

    // check default channel was created
    let channel_id = sub_community_dispatcher.get_channel(234).channel_id;
    assert(channel_id == 234, 'invalid default channel ID');
}

#[test]
#[should_panic(expected: ('coloniz: sub-com already exists',))]
fn test_creating_sub_community_with_existing_id_fails() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    sub_community_dispatcher.create_sub_community(234, community_id);
    sub_community_dispatcher.create_sub_community(234, community_id);
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_sub_community_creation_should_fail_if_not_by_authorized_caller() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());
    let community_id = community_dispatcher.create_community(123);
    stop_cheat_caller_address(contract_address);

    sub_community_dispatcher.create_sub_community(234, community_id);
}

#[test]
fn test_sub_community_creation_emits_an_event() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());
    start_cheat_block_timestamp(contract_address, 7000);

    let community_id = community_dispatcher.create_community(123);

    let mut spy = spy_events();
    sub_community_dispatcher.create_sub_community(234, community_id);

    // check for events
    let expected_event = SubCommunityCreatedEvent::SubCommunityCreated(
        SubCommunityCreated {
            sub_community_id: 234,
            community_id: 123,
            transaction_executor: USER_ONE.try_into().unwrap(),
            block_timestamp: 7000
        }
    );

    spy.assert_emitted(@array![(contract_address, expected_event)]);
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_channel_creation() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);
    let channel_id = sub_community_dispatcher.create_channel(593, sub_community_id);

    stop_cheat_caller_address(contract_address);

    let _sub_community_id = sub_community_dispatcher.get_channel(593).sub_community_id;
    assert(channel_id == 593, 'invalid channel ID');
    assert(_sub_community_id == sub_community_id, 'invalid sub community ID');
}

#[test]
#[should_panic(expected: ('coloniz: channel already exists',))]
fn test_channel_creation_with_existing_id_fails() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);
    sub_community_dispatcher.create_channel(593, sub_community_id);
    sub_community_dispatcher.create_channel(593, sub_community_id);

    stop_cheat_caller_address(contract_address);
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_channel_creation_should_fail_if_not_by_authorized_caller() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());
    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);
    stop_cheat_caller_address(contract_address);
    
    sub_community_dispatcher.create_channel(593, sub_community_id);
}

#[test]
fn test_channel_creation_emits_an_event() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());
    start_cheat_block_timestamp(contract_address, 7000);

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);

    let mut spy = spy_events();
    sub_community_dispatcher.create_channel(593, sub_community_id);

    // check for events
    let expected_event = ChannelCreatedEvent::ChannelCreated(
        ChannelCreated {
            channel_id: 593,
            community_id: 123,
            sub_community_id: 234,
            transaction_executor: USER_ONE.try_into().unwrap(),
            block_timestamp: 7000
        }
    );

    spy.assert_emitted(@array![(contract_address, expected_event)]);
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_set_sub_community_metadata_uri() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);
    sub_community_dispatcher
        .set_sub_community_metadata_uri(sub_community_id, "ipfs://metalru324afn2kl13n");

    stop_cheat_caller_address(contract_address);

    let metadata_uri = sub_community_dispatcher.get_sub_community_metadata_uri(sub_community_id);
    assert(metadata_uri == "ipfs://metalru324afn2kl13n", 'invalid sub community ID');
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_set_sub_community_metadata_uri_fails_if_not_by_authorized_caller() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);
    stop_cheat_caller_address(contract_address);

    sub_community_dispatcher
        .set_sub_community_metadata_uri(sub_community_id, "ipfs://metalru324afn2kl13n");
}

#[test]
fn test_set_channel_metadata_uri() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);
    sub_community_dispatcher.set_channel_metadata_uri(234, "ipfs://default3ru324afn2kl13n");

    stop_cheat_caller_address(contract_address);

    let metadata_uri = sub_community_dispatcher.get_channel_metadata_uri(sub_community_id);
    assert(metadata_uri == "ipfs://default3ru324afn2kl13n", 'invalid sub community ID');
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_set_channel_metadata_uri_if_not_by_authorized_caller() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());
    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);
    stop_cheat_caller_address(contract_address);

    sub_community_dispatcher.set_channel_metadata_uri(234, "ipfs://default3ru324afn2kl13n");
}

#[test]
fn test_add_sub_community_mods() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);

    stop_cheat_caller_address(contract_address);

    // moderators should join community
    start_cheat_caller_address(contract_address, USER_SIX.try_into().unwrap());
    community_dispatcher.join_community(community_id);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER_FIVE.try_into().unwrap());
    community_dispatcher.join_community(community_id);
    stop_cheat_caller_address(contract_address);

    // add moderators
    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());
    sub_community_dispatcher
        .add_sub_community_mods(
            sub_community_id, array![USER_FIVE.try_into().unwrap(), USER_SIX.try_into().unwrap()]
        );
    stop_cheat_caller_address(contract_address);

    let user_five_is_mod = sub_community_dispatcher
        .is_sub_community_mod(USER_FIVE.try_into().unwrap(), sub_community_id);
    let user_six_is_mod = sub_community_dispatcher
        .is_sub_community_mod(USER_SIX.try_into().unwrap(), sub_community_id);

    assert(user_five_is_mod == true, 'invalid mod status');
    assert(user_six_is_mod == true, 'invalid mod status');
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_add_sub_community_mods_should_fail_if_not_by_an_authorized_caller() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);

    stop_cheat_caller_address(contract_address);

    // moderators should join community
    start_cheat_caller_address(contract_address, USER_SIX.try_into().unwrap());
    community_dispatcher.join_community(community_id);

    // add moderators
    sub_community_dispatcher
        .add_sub_community_mods(
            sub_community_id, array![USER_SIX.try_into().unwrap()]
        );
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_remove_sub_community_mods() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);

    stop_cheat_caller_address(contract_address);

    // moderators should join community
    start_cheat_caller_address(contract_address, USER_SIX.try_into().unwrap());
    community_dispatcher.join_community(community_id);
    stop_cheat_caller_address(contract_address);

    start_cheat_caller_address(contract_address, USER_FIVE.try_into().unwrap());
    community_dispatcher.join_community(community_id);
    stop_cheat_caller_address(contract_address);

    // add moderators
    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());
    sub_community_dispatcher
        .add_sub_community_mods(
            sub_community_id, array![USER_FIVE.try_into().unwrap(), USER_SIX.try_into().unwrap()]
        );
    stop_cheat_caller_address(contract_address);

    // remove moderators
    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());
    sub_community_dispatcher
        .remove_sub_community_mods(
            sub_community_id, array![USER_FIVE.try_into().unwrap(), USER_SIX.try_into().unwrap()]
        );
    stop_cheat_caller_address(contract_address);

    let user_five_is_mod = sub_community_dispatcher
        .is_sub_community_mod(USER_FIVE.try_into().unwrap(), sub_community_id);
    let user_six_is_mod = sub_community_dispatcher
        .is_sub_community_mod(USER_SIX.try_into().unwrap(), sub_community_id);

    assert(user_five_is_mod == false, 'invalid mod status');
    assert(user_six_is_mod == false, 'invalid mod status');
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_remove_sub_community_mods_fails_if_not_by_authorized_caller() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);

    stop_cheat_caller_address(contract_address);

    // moderators should join community
    start_cheat_caller_address(contract_address, USER_SIX.try_into().unwrap());
    community_dispatcher.join_community(community_id);
    stop_cheat_caller_address(contract_address);

    // add moderators
    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());
    sub_community_dispatcher
        .add_sub_community_mods(
            sub_community_id, array![USER_SIX.try_into().unwrap()]
        );
    stop_cheat_caller_address(contract_address);

    // remove moderators
    start_cheat_caller_address(contract_address, USER_FIVE.try_into().unwrap());
    sub_community_dispatcher
        .remove_sub_community_mods(
            sub_community_id, array![USER_SIX.try_into().unwrap()]
        );
    stop_cheat_caller_address(contract_address);
}

#[test]
fn test_channel_deletion() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);
    let channel_id = sub_community_dispatcher.create_channel(593, sub_community_id);

    sub_community_dispatcher.delete_channel(channel_id);
    stop_cheat_caller_address(contract_address);

    let _channel_id = sub_community_dispatcher.get_channel(channel_id).channel_id;
    assert(_channel_id == 0, 'channel was not deleted');
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_channel_deletion_should_fail_if_not_by_an_authorized_caller() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);
    let channel_id = sub_community_dispatcher.create_channel(593, sub_community_id);
    stop_cheat_caller_address(contract_address);

    sub_community_dispatcher.delete_channel(channel_id);
}

#[test]
fn test_sub_community_deletion() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);

    sub_community_dispatcher.delete_sub_community(sub_community_id);
    stop_cheat_caller_address(contract_address);

    let _sub_community_id = sub_community_dispatcher
        .get_sub_community(sub_community_id)
        .sub_community_id;
    assert(_sub_community_id == 0, 'sub community was not deleted');
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_sub_community_deletion_should_fail_if_not_by_an_authorized_caller() {
    let contract_address = __setup__();
    let community_dispatcher = ICommunityDispatcher { contract_address: contract_address };
    let sub_community_dispatcher = ISubCommunityDispatcher { contract_address: contract_address };

    start_cheat_caller_address(contract_address, USER_ONE.try_into().unwrap());

    let community_id = community_dispatcher.create_community(123);
    let sub_community_id = sub_community_dispatcher.create_sub_community(234, community_id);
    stop_cheat_caller_address(contract_address);

    sub_community_dispatcher.delete_sub_community(sub_community_id);
}