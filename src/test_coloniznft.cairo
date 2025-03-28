use core::num::traits::zero::Zero;
use core::starknet::SyscallResultTrait;
use core::traits::TryInto;
use starknet::ContractAddress;

use snforge_std::{
    declare, start_cheat_caller_address, stop_cheat_caller_address, ContractClassTrait,
    DeclareResultTrait
};

use openzeppelin::{token::erc721::interface::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait}};

use coloniz::interfaces::IColonizNFT::{IColonizNFTDispatcher, IColonizNFTDispatcherTrait};
use coloniz::base::constants::types::{
    ProfileVariants, AccessoryVariants, FaceVariants, ClothVariants, BackgroundVariants,
    BodyVariants, ToolVariants
};

const ADMIN: felt252 = 'ADMIN';
const USER_ONE: felt252 = 'BOB';

fn __setup__() -> ContractAddress {
    let nft_contract = declare("ColonizNFT").unwrap().contract_class();
    let mut calldata: Array<felt252> = array![ADMIN];
    let (nft_contract_address, _) = nft_contract.deploy(@calldata).unwrap_syscall();
    (nft_contract_address)
}

#[test]
fn test_metadata() {
    let nft_contract_address = __setup__();
    let dispatcher = ERC721ABIDispatcher { contract_address: nft_contract_address };
    start_cheat_caller_address(nft_contract_address, ADMIN.try_into().unwrap());
    let nft_name = dispatcher.name();
    let nft_symbol = dispatcher.symbol();
    assert(nft_name == "coloniz", 'invalid name');
    assert(nft_symbol == "KST", 'invalid symbol');
    stop_cheat_caller_address(nft_contract_address);
}

#[test]
fn test_last_minted_id_on_init_is_zero() {
    let nft_contract_address = __setup__();
    let dispatcher = IColonizNFTDispatcher { contract_address: nft_contract_address };
    start_cheat_caller_address(nft_contract_address, ADMIN.try_into().unwrap());
    let last_minted_id = dispatcher.get_last_minted_id();
    assert(last_minted_id.is_zero(), 'last minted id not zero');
    stop_cheat_caller_address(nft_contract_address);
}

#[test]
fn test_mint_coloniz_nft() {
    let nft_contract_address = __setup__();
    let dispatcher = IColonizNFTDispatcher { contract_address: nft_contract_address };
    let erc721_dispatcher = ERC721ABIDispatcher { contract_address: nft_contract_address };
    start_cheat_caller_address(nft_contract_address, ADMIN.try_into().unwrap());

    let ACCESSORY7 = ProfileVariants {
        body: BodyVariants::BODY1,
        tool: BackVariants::TOOL1,
        background: BackgroundVariants::BACKGROUND1,
        cloth: ClothVariants::CLOTH1,
        face: FaceVariants::FACE1,
        accessory: AccessoryVariants::ACCESSORY1
    };

    dispatcher.mint_coloniznft(USER_ONE.try_into().unwrap(), ACCESSORY7);
    let balance = erc721_dispatcher.balance_of(USER_ONE.try_into().unwrap());
    assert(balance == 1, 'nft not minted');
    stop_cheat_caller_address(nft_contract_address);
}

#[test]
#[should_panic(expected: ('coloniz: user already minted!',))]
fn test_mint_coloniz_nft_twice_for_the_same_user() {
    let nft_contract_address = __setup__();
    let dispatcher = IColonizNFTDispatcher { contract_address: nft_contract_address };
    start_cheat_caller_address(nft_contract_address, ADMIN.try_into().unwrap());

    let ACCESSORY7 = ProfileVariants {
        body: BodyVariants::BODY1,
        back: ToolVariants::TOOL1,
        background: BackgroundVariants::BACKGROUND1,
        cloth: ClothVariants::CLOTH1,
        face: FaceVariants::FACE1,
        accessory: AccessoryVariants::ACCESSORY2
    };

    dispatcher.mint_coloniznft(USER_ONE.try_into().unwrap(), ACCESSORY7);
    dispatcher.mint_coloniznft(USER_ONE.try_into().unwrap(), ACCESSORY7);
    stop_cheat_caller_address(nft_contract_address);
}

#[test]
fn test_get_last_minted_id_after_minting() {
    let nft_contract_address = __setup__();
    let dispatcher = IColonizNFTDispatcher { contract_address: nft_contract_address };
    start_cheat_caller_address(nft_contract_address, ADMIN.try_into().unwrap());

    let ACCESSORY7 = ProfileVariants {
        body: BodyVariants::BODY1,
        tool: BackVariants::TOOL1,
        background: BackgroundVariants::BACKGROUND1,
        cloth: ClothVariants::CLOTH1,
        face: FaceVariants::FACE1,
        accessory: AccessoryVariants::ACCESSORY1
    };

    dispatcher.mint_coloniznft(USER_ONE.try_into().unwrap(), ACCESSORY7);
    let last_minted_id = dispatcher.get_last_minted_id();
    assert(last_minted_id == 1, 'invalid last minted id');
    stop_cheat_caller_address(nft_contract_address);
}

#[test]
fn test_get_user_token_id_after_minting() {
    let nft_contract_address = __setup__();
    let dispatcher = IColonizNFTDispatcher { contract_address: nft_contract_address };
    start_cheat_caller_address(nft_contract_address, ADMIN.try_into().unwrap());

    let ACCESSORY7 = ProfileVariants {
        body: BodyVariants::BODY1,
        tool: BackVariants::TOOL1,
        background: BackgroundVariants::BACKGROUND1,
        cloth: ClothVariants::CLOTH1,
        face: FaceVariants::FACE1,
        accessory: AccessoryVariants::ACCESSORY1
    };
    dispatcher.mint_coloniznft(USER_ONE.try_into().unwrap(), ACCESSORY7);
    let user_token_id = dispatcher.get_user_token_id(USER_ONE.try_into().unwrap());
    assert(user_token_id == 1, 'invalid user token id');
    stop_cheat_caller_address(nft_contract_address);
}
