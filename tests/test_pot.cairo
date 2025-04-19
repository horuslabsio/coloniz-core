use core::traits::TryInto;
use core::hash::HashStateTrait;
use core::pedersen::PedersenTrait;
use starknet::{ContractAddress, contract_address_const};

use snforge_std::{
    declare, DeclareResultTrait, ContractClassTrait, start_cheat_caller_address,
    stop_cheat_caller_address, start_cheat_nonce, stop_cheat_nonce, start_cheat_block_timestamp,
    stop_cheat_block_timestamp, spy_events, EventSpyAssertionsTrait
};

use coloniz::interfaces::IPot::{IPotDispatcher, IPotDispatcherTrait};
use coloniz::interfaces::ICommunity::{ICommunityDispatcher, ICommunityDispatcherTrait};
use coloniz::community::pot::CommunityPot::{
    {Event as ActivatedPotEvent, ActivatedPot},
    {Event as ClaimedFromPotEvent, ClaimedFromPot},
    {Event as WithdrawnFromPotEvent, WithdrawnFromPot}
};

const ADMIN: felt252 = 5382942;
const ADDRESS1: felt252 = 254290;
const ADDRESS2: felt252 = 525616;
const FEE_ADDRESS: felt252 = 250322;

// *************************************************************************
//                              SETUP
// *************************************************************************
fn __setup__() -> (ContractAddress, u256) {
    // deploy pot contract
    let pot_contract = declare("CommunityPot").unwrap().contract_class();
    let (pot_contract_address, _) = pot_contract.deploy(@array![]).unwrap();

    // declare community nft
    let community_nft_class_hash = declare("CommunityNFT").unwrap().contract_class();

    // deploy community preset contract
    let community_contract = declare("ColonizCommunity").unwrap().contract_class();
    let mut community_constructor_calldata: Array<felt252> = array![
        (*community_nft_class_hash.class_hash).into(), ADMIN
    ];
    let (community_contract_address, _) = community_contract
        .deploy(@community_constructor_calldata)
        .unwrap();

    // create test community
    start_cheat_caller_address(community_contract_address, ADDRESS1.try_into().unwrap());
    let community_dispatcher = ICommunityDispatcher {
        contract_address: community_contract_address
    };
    let community_id = community_dispatcher.create_community(123);
    stop_cheat_caller_address(community_contract_address);

    return (pot_contract_address, community_id);
}

// *************************************************************************
//                              TEST
// *************************************************************************
#[test]
fn test_activate() {
    let (pot_contract_address, community_id) = __setup__();
    let pot_dispatcher = IPotDispatcher{ contract_address: pot_contract_address };

    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());
    let instance_id = pot_dispatcher.activate(
        123,
        'tyigikhgikhkghiii',
        30,
        100,
        123.try_into().unwrap(),
        6300,
        300
    );
    assert(instance_id == 1, 'invalid instance');
}