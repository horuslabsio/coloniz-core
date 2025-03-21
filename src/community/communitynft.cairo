#[starknet::contract]
pub mod CommunityNFT {
    // *************************************************************************
    //                             IMPORTS
    // *************************************************************************
    use starknet::{ContractAddress, get_block_timestamp};
    use core::num::traits::zero::Zero;
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin_access::ownable::OwnableComponent;
    use openzeppelin_upgrades::UpgradeableComponent;

    use coloniz::interfaces::ICustomNFT::ICustomNFT;
    use coloniz::base::{
        constants::errors::Errors::{ALREADY_MINTED, NOT_TOKEN_OWNER, TOKEN_DOES_NOT_EXIST},
        utils::base64_extended::convert_into_byteArray,
        token_uris::community_token_uri::CommunityTokenUri::get_token_uri,
    };
    use starknet::storage::{
        Map, StoragePointerWriteAccess, StoragePointerReadAccess, StorageMapReadAccess,
        StorageMapWriteAccess
    };

    // *************************************************************************
    //                             COMPONENTS
    // *************************************************************************
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);

    // ERC721 Mixin
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // add an owner
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    // *************************************************************************
    //                             STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
        last_minted_id: u256,
        mint_timestamp: Map<u256, u64>,
        user_token_id: Map<ContractAddress, u256>,
        community_id: u256
    }

    // *************************************************************************
    //                             EVENTS
    // *************************************************************************
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event
    }

    // *************************************************************************
    //                             CONSTRUCTOR
    // *************************************************************************
    #[constructor]
    fn constructor(ref self: ContractState, community_id: u256, admin: ContractAddress) {
        self.ownable.initializer(admin);
        self.community_id.write(community_id);
    }

    #[abi(embed_v0)]
    impl CommunityNft of ICustomNFT<ContractState> {
        // *************************************************************************
        //                            EXTERNAL
        // *************************************************************************

        /// @notice mints a community NFT
        /// @param address address of user trying to mint the community NFT token
        fn mint_nft(ref self: ContractState, user_address: ContractAddress) -> u256 {
            let balance = self.erc721.balance_of(user_address);
            assert(balance.is_zero(), ALREADY_MINTED);

            let mut token_id = self.last_minted_id.read() + 1;
            self.erc721.mint(user_address, token_id);
            let timestamp: u64 = get_block_timestamp();
            self.user_token_id.write(user_address, token_id);

            self.last_minted_id.write(token_id);
            self.mint_timestamp.write(token_id, timestamp);
            token_id
        }

        /// @notice burns a community NFT
        /// @param address address of user trying to burn the community NFT token
        fn burn_nft(ref self: ContractState, user_address: ContractAddress, token_id: u256) {
            let user_token_id = self.user_token_id.read(user_address);
            assert(user_token_id == token_id, NOT_TOKEN_OWNER);

            // check the token exists
            assert(self.erc721.exists(token_id), TOKEN_DOES_NOT_EXIST);
            self.erc721.burn(token_id);
            self.user_token_id.write(user_address, 0);
        }

        // *************************************************************************
        //                            GETTERS
        // *************************************************************************
        /// @notice gets the token ID for a user address
        /// @param user address of user to retrieve token ID for
        fn get_user_token_id(self: @ContractState, user_address: ContractAddress) -> u256 {
            self.user_token_id.read(user_address)
        }

        // *************************************************************************
        //                            METADATA
        // *************************************************************************
        /// @notice returns the community name
        fn name(self: @ContractState) -> ByteArray {
            let mut collection_name = ArrayTrait::<felt252>::new();
            let community_id_felt252: felt252 = self.community_id.read().try_into().unwrap();
            collection_name.append('Coloniz Community | #');
            collection_name.append(community_id_felt252);
            let collection_name_byte = convert_into_byteArray(ref collection_name);
            collection_name_byte
        }

        /// @notice returns the collection symbol
        fn symbol(self: @ContractState) -> ByteArray {
            return "CLZ:COMMUNITY";
        }

        /// @notice returns the token_uri for a particular token_id
        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            let token_mint_timestamp = self.mint_timestamp.read(token_id);
            let community_id = self.community_id.read();
            get_token_uri(token_id, community_id, token_mint_timestamp)
        }
    }
}
