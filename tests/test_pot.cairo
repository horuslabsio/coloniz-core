use core::traits::TryInto;
use starknet::{ContractAddress};

use snforge_std::{
    declare, DeclareResultTrait, ContractClassTrait, start_cheat_caller_address,
    stop_cheat_caller_address, start_cheat_block_timestamp, stop_cheat_block_timestamp, spy_events,
    EventSpyAssertionsTrait
};

use coloniz::interfaces::IPot::{IPotDispatcher, IPotDispatcherTrait};
use coloniz::interfaces::ICommunity::{ICommunityDispatcher, ICommunityDispatcherTrait};
use coloniz::interfaces::IERC20::{IERC20Dispatcher, IERC20DispatcherTrait};
use coloniz::community::pot::PotComponent::{
    {Event as PotInstanceCreatedEvent, PotInstanceCreated},
};

const ADMIN: felt252 = 5382942;
const ADDRESS1: felt252 = 254290;
const ADDRESS2: felt252 =
    1288063831824364979088474884344488558916361078386561926909784032724307484129;
const ADDRESS3: felt252 =
    3239341201613305593557885035590925438209784870822716567301868637707294605022;

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

fn create_instance(
    pot_contract_address: ContractAddress,
    usdt_contract_address: ContractAddress,
    community_id: u256,
    merkle_root: felt252,
    max_claim: u256,
    distribution_amount: u256,
    instance_start_time: u64,
    instance_duration: u64
) -> u256 {
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };
    let erc20_dispatcher = IERC20Dispatcher { contract_address: usdt_contract_address };

    // approve contract to spend amount
    start_cheat_caller_address(usdt_contract_address, ADDRESS1.try_into().unwrap());
    erc20_dispatcher.approve(pot_contract_address, distribution_amount);
    stop_cheat_caller_address(usdt_contract_address);

    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());
    pot_dispatcher
        .create_instance(
            community_id,
            merkle_root,
            max_claim,
            distribution_amount,
            usdt_contract_address,
            instance_start_time,
            instance_duration
        )
}

fn _claim(
    pot_contract_address: ContractAddress,
    usdt_contract_address: ContractAddress,
    community_id: u256,
    merkle_root: felt252,
    merkle_proof: Array<felt252>,
    max_claim: u256,
    distribution_amount: u256,
    claim_amount: u256,
    instance_start_time: u64,
    instance_duration: u64
) {
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };
    let community_dispatcher = ICommunityDispatcher { contract_address: pot_contract_address };

    // create instance
    let instance_id = create_instance(
        pot_contract_address,
        usdt_contract_address,
        community_id,
        merkle_root,
        max_claim,
        distribution_amount,
        instance_start_time,
        instance_duration
    );

    // claim
    start_cheat_caller_address(pot_contract_address, ADDRESS2.try_into().unwrap());
    community_dispatcher.join_community(123);

    start_cheat_block_timestamp(pot_contract_address, 7000);
    pot_dispatcher.claim(instance_id, claim_amount, merkle_proof.span());
    stop_cheat_block_timestamp(pot_contract_address);
}

// *************************************************************************
//                              TESTS - CREATE INSTANCE
// *************************************************************************
#[test]
fn test_create_instance() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };
    let erc20_dispatcher = IERC20Dispatcher { contract_address: usdt_contract_address };

    let merkle_root = 2703728896489335098836699947247689135263632301646280222217001614516487978490;
    let initial_pot_balance = erc20_dispatcher.balance_of(pot_contract_address);
    let instance_id = create_instance(
        pot_contract_address, usdt_contract_address, 123, merkle_root, 30, 100, 6300, 300
    );

    let total_instances = pot_dispatcher.get_total_instances();
    let new_pot_balance = erc20_dispatcher.balance_of(pot_contract_address);
    assert(instance_id == 1, 'invalid instance');
    assert(total_instances == 1, 'wrong no. of total instances');
    assert(new_pot_balance == initial_pot_balance + 100, 'wrong pot balance');
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_create_instance_can_only_be_called_by_community_owner_or_mod() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };

    let merkle_root = 2703728896489335098836699947247689135263632301646280222217001614516487978490;
    pot_dispatcher.create_instance(123, merkle_root, 30, 100, usdt_contract_address, 6300, 300);
}

#[test]
#[should_panic(expected: ('coloniz: start time in the past',))]
fn test_create_instance_should_fail_if_start_time_is_in_the_past() {
    let (pot_contract_address, usdt_contract_addresss) = __setup__();
    let merkle_root = 2703728896489335098836699947247689135263632301646280222217001614516487978490;

    start_cheat_block_timestamp(pot_contract_address, 7000);
    create_instance(
        pot_contract_address, usdt_contract_addresss, 123, merkle_root, 30, 100, 6300, 300
    );
    stop_cheat_caller_address(pot_contract_address);
}

#[test]
fn test_create_instance_event_was_emitted() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let merkle_root = 415944806682468542317893663524164587180226905219159939966475712536121842448;

    let mut spy = spy_events();
    let instance_id = create_instance(
        pot_contract_address, usdt_contract_address, 123, merkle_root, 30, 100, 6300, 300
    );

    // check for events
    let expected_event = PotInstanceCreatedEvent::PotInstanceCreated(
        PotInstanceCreated {
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
//                              TESTS - CLAIM
// *************************************************************************
#[test]
fn test_claim() {
    let (pot_contract_address, usdt_contract_address) = __setup__();

    let merkle_root: felt252 =
        415944806682468542317893663524164587180226905219159939966475712536121842448;
    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];

    _claim(
        pot_contract_address,
        usdt_contract_address,
        123,
        merkle_root,
        merkle_proof,
        70,
        100,
        50,
        6300,
        4000
    )
}

#[test]
#[should_panic(expected: ('coloniz: Not Community Member',))]
fn test_claiming_fails_if_claimer_is_not_a_member_of_the_community() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };

    let merkle_root: felt252 =
        415944806682468542317893663524164587180226905219159939966475712536121842448;
    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];

    // create instance
    let instance_id = create_instance(
        pot_contract_address, usdt_contract_address, 123, merkle_root, 70, 100, 6300, 4000
    );

    // claim
    start_cheat_caller_address(pot_contract_address, ADDRESS2.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 7000);
    pot_dispatcher.claim(instance_id, 50, merkle_proof.span());
}

#[test]
#[should_panic(expected: ('coloniz: instance doesnt exist',))]
fn test_claiming_fails_if_instance_does_not_exist() {
    let (pot_contract_address, _) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };
    let community_dispatcher = ICommunityDispatcher { contract_address: pot_contract_address };

    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];

    // claim
    start_cheat_caller_address(pot_contract_address, ADDRESS2.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 7000);
    community_dispatcher.join_community(123);
    pot_dispatcher.claim(244, 50, merkle_proof.span());
    stop_cheat_block_timestamp(pot_contract_address);
}

#[test]
#[should_panic(expected: ('coloniz: instance inactive',))]
fn test_claiming_fails_if_instance_is_inactive() {
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
    let instance_id = create_instance(
        pot_contract_address, usdt_contract_address, 123, merkle_root, 70, 100, 6300, 4000
    );

    // claim
    start_cheat_caller_address(pot_contract_address, ADDRESS2.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 6000);
    community_dispatcher.join_community(123);
    pot_dispatcher.claim(instance_id, 50, merkle_proof.span());
    stop_cheat_block_timestamp(pot_contract_address);
}

#[test]
#[should_panic(expected: ('coloniz: user already claimed',))]
fn test_claiming_fails_if_user_already_claimed() {
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
    let instance_id = create_instance(
        pot_contract_address, usdt_contract_address, 123, merkle_root, 70, 100, 6300, 4000
    );

    // claim
    start_cheat_caller_address(pot_contract_address, ADDRESS2.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 7000);
    community_dispatcher.join_community(123);
    pot_dispatcher.claim(instance_id, 50, merkle_proof.span());
    pot_dispatcher.claim(instance_id, 50, merkle_proof.span());
}

#[test]
#[should_panic(expected: ('coloniz: amount > max claim',))]
fn test_claiming_fails_if_amount_exceeds_max_claim() {
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
    let instance_id = create_instance(
        pot_contract_address, usdt_contract_address, 123, merkle_root, 30, 100, 6300, 4000
    );

    // claim
    start_cheat_caller_address(pot_contract_address, ADDRESS2.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 7000);
    community_dispatcher.join_community(123);
    pot_dispatcher.claim(instance_id, 50, merkle_proof.span());
}

#[test]
#[should_panic(expected: ('coloniz: invalid claim proof',))]
fn test_claiming_fails_if_proof_is_invalid() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };
    let community_dispatcher = ICommunityDispatcher { contract_address: pot_contract_address };

    let merkle_root: felt252 =
        415944806682468542317893663524164587180226905219159939966475712536121842448;
    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906624
    ];

    // create instance
    let instance_id = create_instance(
        pot_contract_address, usdt_contract_address, 123, merkle_root, 70, 100, 6300, 4000
    );

    // claim
    start_cheat_caller_address(pot_contract_address, ADDRESS2.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 7000);
    community_dispatcher.join_community(123);
    pot_dispatcher.claim(instance_id, 50, merkle_proof.span());
}

#[test]
#[should_panic(expected: ('coloniz: distribution exhausted',))]
fn test_claiming_fails_if_distribution_amount_is_exhausted() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };
    let community_dispatcher = ICommunityDispatcher { contract_address: pot_contract_address };

    let merkle_root: felt252 =
        415944806682468542317893663524164587180226905219159939966475712536121842448;
    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];
    let merkle_proof2: Array<felt252> = array![
        620361465614457148634354227156664052956856170609285224726313640939873958233,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];

    // create instance
    let instance_id = create_instance(
        pot_contract_address, usdt_contract_address, 123, merkle_root, 55, 60, 6300, 4000
    );

    // claim
    start_cheat_caller_address(pot_contract_address, ADDRESS2.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 7000);
    community_dispatcher.join_community(123);
    pot_dispatcher.claim(instance_id, 50, merkle_proof.span());
    stop_cheat_caller_address(pot_contract_address);

    start_cheat_caller_address(pot_contract_address, ADDRESS3.try_into().unwrap());
    community_dispatcher.join_community(123);
    pot_dispatcher.claim(instance_id, 25, merkle_proof2.span());
    stop_cheat_caller_address(pot_contract_address);
}

// *************************************************************************
//                              TESTS - WITHDRAW
// *************************************************************************
fn test_withdraw() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };
    let erc20_dispatcher = IERC20Dispatcher { contract_address: usdt_contract_address };

    let merkle_root: felt252 =
        415944806682468542317893663524164587180226905219159939966475712536121842448;
    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];

    _claim(
        pot_contract_address,
        usdt_contract_address,
        123,
        merkle_root,
        merkle_proof,
        70,
        100,
        50,
        6300,
        4000
    );

    // withdraw
    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 12000);
    pot_dispatcher.withdraw(1, ADDRESS3.try_into().unwrap());
    stop_cheat_block_timestamp(pot_contract_address);
    stop_cheat_caller_address(pot_contract_address);

    // check withdraw was successful
    let user_bal = erc20_dispatcher.balance_of(ADDRESS3.try_into().unwrap());
    let distributed_amount = pot_dispatcher.get_distributed_amount(1);
    assert(user_bal == 50, 'withdrawal was unsuccessful');
    assert(distributed_amount == 100, 'withdrawal was unsuccessful');
}

#[test]
#[should_panic(expected: ('coloniz: user unauthorized!',))]
fn test_withdrawal_can_only_be_called_by_owner() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };

    let merkle_root: felt252 =
        415944806682468542317893663524164587180226905219159939966475712536121842448;
    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];

    _claim(
        pot_contract_address,
        usdt_contract_address,
        123,
        merkle_root,
        merkle_proof,
        70,
        100,
        50,
        6300,
        4000
    );

    // withdraw
    start_cheat_block_timestamp(pot_contract_address, 12000);
    pot_dispatcher.withdraw(1, ADDRESS3.try_into().unwrap());
}

#[test]
#[should_panic(expected: ('coloniz: distribution exhausted',))]
fn test_cannot_withdraw_if_distribution_amount_is_exhausted() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };
    let community_dispatcher = ICommunityDispatcher { contract_address: pot_contract_address };

    let merkle_root: felt252 =
        415944806682468542317893663524164587180226905219159939966475712536121842448;
    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];
    let merkle_proof2: Array<felt252> = array![
        620361465614457148634354227156664052956856170609285224726313640939873958233,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];

    // create instance
    let instance_id = create_instance(
        pot_contract_address, usdt_contract_address, 123, merkle_root, 55, 75, 6300, 4000
    );

    // first claim
    start_cheat_caller_address(pot_contract_address, ADDRESS2.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 7000);
    community_dispatcher.join_community(123);
    pot_dispatcher.claim(instance_id, 50, merkle_proof.span());
    stop_cheat_caller_address(pot_contract_address);

    // second claim
    start_cheat_caller_address(pot_contract_address, ADDRESS3.try_into().unwrap());
    community_dispatcher.join_community(123);
    pot_dispatcher.claim(instance_id, 25, merkle_proof2.span());
    stop_cheat_block_timestamp(pot_contract_address);
    stop_cheat_caller_address(pot_contract_address);

    // try to withdraw
    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 12000);
    pot_dispatcher.withdraw(1, ADDRESS3.try_into().unwrap());
}

#[test]
#[should_panic(expected: ('coloniz: distribution exhausted',))]
fn test_withdrawal_cannot_be_called_twice() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };

    let merkle_root: felt252 =
        415944806682468542317893663524164587180226905219159939966475712536121842448;
    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];

    _claim(
        pot_contract_address,
        usdt_contract_address,
        123,
        merkle_root,
        merkle_proof,
        70,
        100,
        50,
        6300,
        4000
    );

    // withdraw
    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 12000);
    pot_dispatcher.withdraw(1, ADDRESS3.try_into().unwrap());

    // try to withdraw again
    pot_dispatcher.withdraw(1, ADDRESS3.try_into().unwrap());
}

#[test]
#[should_panic(expected: ('coloniz: instance has not ended',))]
fn test_withdrawal_cannot_be_called_if_instance_has_not_ended() {
    let (pot_contract_address, usdt_contract_address) = __setup__();
    let pot_dispatcher = IPotDispatcher { contract_address: pot_contract_address };

    let merkle_root: felt252 =
        415944806682468542317893663524164587180226905219159939966475712536121842448;
    let merkle_proof: Array<felt252> = array![
        2703728896489335098836699947247689135263632301646280222217001614516487978490,
        3381855609922770965061329276586589566725045020499778094981472002911820906627
    ];

    _claim(
        pot_contract_address,
        usdt_contract_address,
        123,
        merkle_root,
        merkle_proof,
        70,
        100,
        50,
        6300,
        4000
    );

    // withdraw
    start_cheat_caller_address(pot_contract_address, ADDRESS1.try_into().unwrap());
    start_cheat_block_timestamp(pot_contract_address, 7000);
    pot_dispatcher.withdraw(1, ADDRESS3.try_into().unwrap());
}
