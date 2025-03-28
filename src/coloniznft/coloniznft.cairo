#[starknet::contract]
pub mod ColonizNFT {
    // *************************************************************************
    //                             IMPORTS
    // *************************************************************************
    use starknet::{
        ContractAddress, ClassHash, get_block_timestamp, get_caller_address,
        storage::{
            StoragePointerWriteAccess, StoragePointerReadAccess, Map, StorageMapReadAccess,
            StorageMapWriteAccess
        }
    };
    use core::num::traits::zero::Zero;
    use coloniz::interfaces::IColonizNFT;
    use coloniz::base::{
        constants::errors::Errors::{ALREADY_MINTED, UNAUTHORIZED},
        constants::types::ProfileVariants,
        token_uris::profile_token_uri::ProfileTokenUri::get_token_uri,
    };
    use openzeppelin_access::ownable::OwnableComponent;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin_introspection::{src5::SRC5Component};
    use openzeppelin_upgrades::UpgradeableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);

    // allow to check what interface is supported
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    impl SRC5InternalImpl = SRC5Component::InternalImpl<ContractState>;

    // make it a NFT
    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnlyImpl = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // add an owner
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;


    // *************************************************************************
    //                              STORAGE
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
        admin: ContractAddress,
        last_minted_id: u256,
        mint_timestamp: Map<u256, u64>,
        user_token_id: Map<ContractAddress, u256>,
        base_uri: ByteArray,
        profile_variants: Map<u256, ProfileVariants>
    }

    // *************************************************************************
    //                              EVENTS
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
    //                              CONSTRUCTOR
    // *************************************************************************
    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress) {
        self.admin.write(admin);
        self.ownable.initializer(admin);
        self.erc721.initializer("Coloniz Profile", "CLZ:PROFILE", "");
    }

    #[abi(embed_v0)]
    impl colonizImpl of IColonizNFT::IColonizNFT<ContractState> {
        // *************************************************************************
        //                            EXTERNAL
        // *************************************************************************
        /// @notice mints the coloniz NFT
        /// @param address address of user trying to mint the coloniz NFT
        fn mint_coloniznft(
            ref self: ContractState, address: ContractAddress, profile_variant: ProfileVariants
        ) {
            let balance = self.erc721.balance_of(address);
            assert(balance.is_zero(), ALREADY_MINTED);

            let mut token_id = self.last_minted_id.read() + 1;
            self.erc721.mint(address, token_id);
            let timestamp: u64 = get_block_timestamp();

            self.user_token_id.write(address, token_id);
            self.last_minted_id.write(token_id);
            self.mint_timestamp.write(token_id, timestamp);
            self.profile_variants.write(token_id, profile_variant);
        }

        /// @notice sets token base uri
        /// @param base_uri base uri to set
        fn set_base_uri(ref self: ContractState, base_uri: ByteArray) {
            let admin = self.admin.read();
            assert(get_caller_address() == admin, UNAUTHORIZED);
            self.base_uri.write(base_uri);
        }

        /// @notice upgrades the nft contract
        /// @param new_class_hash classhash to upgrade to
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            self.ownable.assert_only_owner();

            // Replace the class hash upgrading the contract
            self.upgradeable.upgrade(new_class_hash);
        }

        // *************************************************************************
        //                            GETTERS
        // *************************************************************************
        /// @notice gets the token ID for a user address
        /// @param user address of user to retrieve token ID for
        fn get_user_token_id(self: @ContractState, user: ContractAddress) -> u256 {
            self.user_token_id.read(user)
        }

        fn get_token_mint_timestamp(self: @ContractState, token_id: u256) -> u64 {
            self.mint_timestamp.read(token_id)
        }

        /// @notice gets the last minted NFT
        fn get_last_minted_id(self: @ContractState) -> u256 {
            self.last_minted_id.read()
        }

        fn get_profile_variant(self: @ContractState, token_id: u256) -> ProfileVariants {
            self.profile_variants.read(token_id)
        }

        // *************************************************************************
        //                            METADATA
        // *************************************************************************
        /// @notice returns the collection name
        fn name(self: @ContractState) -> ByteArray {
            return "Coloniz";
        }

        /// @notice returns the collection symbol
        fn symbol(self: @ContractState) -> ByteArray {
            return "CLZ:PROFILE";
        }

        /// @notice returns the token_uri for a particular token_id
        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            let mint_timestamp: u64 = self.get_token_mint_timestamp(token_id);
            let profile_variant = self.profile_variants.read(token_id);
            let image_url = format!("{}{}", self.base_uri.read(), token_id);
            get_token_uri(profile_variant, token_id, mint_timestamp, image_url)
        }
    }
}
