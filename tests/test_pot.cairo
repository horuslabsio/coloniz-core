use core::traits::TryInto;
use core::hash::HashStateTrait;
use core::pedersen::PedersenTrait;
use starknet::{ContractAddress};

use snforge_std::{
    declare, DeclareResultTrait, ContractClassTrait, start_cheat_caller_address,
    stop_cheat_caller_address, start_cheat_block_timestamp, stop_cheat_block_timestamp, spy_events,
    EventSpyAssertionsTrait
};

use coloniz::interfaces::IPot::{IPotDispatcher, IPotDispatcherTrait};
use coloniz::interfaces::ICommunity::{ICommunityDispatcher, ICommunityDispatcherTrait};
use coloniz::community::pot::PotComponent::{
    {Event as ActivatedPotEvent, ActivatedPot}, {Event as ClaimedFromPotEvent, ClaimedFromPot},
    {Event as WithdrawnFromPotEvent, WithdrawnFromPot}
};

const ADMIN: felt252 = 5382942;
const ADDRESS1: felt252 = 254290;
const ADDRESS2: felt252 =
    1288063831824364979088474884344488558916361078386561926909784032724307484129;

// *************************************************************************
//                              SETUP
// *************************************************************************
fn __setup__() -> (ContractAddress, ContractAddress) {
    // declare community nft
    let community_nft_class_hash = declare("CommunityNFT").unwrap().contract_class();

    // deploy pot contract
    let pot_contract = declare("CommunityPot").unwrap().contract_class();
    let (pot_contract_address, _) = pot_contract
        .deploy(@array![(*community_nft_class_hash.class_hash).into()])
        .unwrap();

    // deploy mock USDT
    let usdt_contract = declare("USDT").unwrap().contract_class();
    let (usdt_contract_address, _) = usdt_contract
        .deploy(@array![1000000000000000000000, 0, ADDRESS1])
        .unwrap();

    // create test community
    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());
    let dispatcher = ICommunityDispatcher { contract_address: pot_contract_address };
    dispatcher.create_community(123);
    stop_cheat_caller_address(pot_contract_address);

    return (pot_contract_address, usdt_contract_address);
}

// *************************************************************************
//                              TEST - ACTIVATE
// *************************************************************************
#[test]
fn test_activate() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };

    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());

    let merkle_root = '7e286a6a7d3c81580e2d6d3ed37';
    let instance_id = pot_dispatcher
        .activate(123, merkle_root, 30, 100, usdt_contract_address, 6300, 300);

    let total_instances = pot_dispatcher.get_total_instances();
    assert(instance_id == 1, 'invalid instance');
    assert(total_instances == 1, 'wrong no. of total instances');
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_activate_can_only_be_called_by_community_owner_or_mod() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };

    let merkle_root = '7e286a6a7d3c81580e2d6d3ed37';
    pot_dispatcher.activate(123, merkle_root, 30, 100, usdt_contract_address, 6300, 300);
}

#[test]
#[should_panic(expected: ('coloniz: start time in the past',))]
fn test_activate_should_fail_if_start_time_is_in_the_past() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };

    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 7000);

    let merkle_root = '7e286a6a7d3c81580e2d6d3ed37';
    pot_dispatcher.activate(123, merkle_root, 30, 100, usdt_contract_address, 6300, 300);

    stop_cheat_block_timestamp(pot_contract_address);
    stop_cheat_caller_address(pot_contract_address);
}

#[test]
fn test_activate_event_was_emitted() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };

    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());

    let merkle_root = '7e286a6a7d3c81580e2d6d3ed37';
    let mut spy = spy_events();

    let instance_id = pot_dispatcher
        .activate(123, merkle_root, 30, 100, usdt_contract_address, 6300, 300);

    // check for events
    let expected_event = ActivatedPotEvent::ActivatedPot(
        ActivatedPot {
            pot_instance_id: instance_id,
            community_id: 123,
            merkle_root: merkle_root,
            distribution_amount: 100,
            erc20_contract_address: usdt_contract_address,
            instance_start_time: 6300,
            instance_duration: 300
        }
    );

    spy.assert_emitted(@array![(pot_contract_address, expected_event)]);
    stop_cheat_caller_address(pot_contract_address);
}

// *************************************************************************
//                              TEST - CLAIM
// *************************************************************************
#[test]
fn test_claim() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };
    let community_dispatcher = ICommunityDispatcher { contract_address: pot_contract_address };

    let merkle_root: felt252 =
        415944806682468542317893663524164587180226905219159939966475712536121842448;
    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];

    // create instance
    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());
    let instance_id = pot_dispatcher
        .activate(123, merkle_root, 70, 100, usdt_contract_address, 6300, 4000);
    stop_cheat_caller_address(pot_contract_address);

    // claim
    start_cheat_caller_address(pot_contract_address, ADDRESS2.try_into().unwrap());
    community_dispatcher.join_community(123);

    start_cheat_block_timestamp(pot_contract_address, 7000);
    pot_dispatcher.claim(instance_id, 50, merkle_proof.span());
}
