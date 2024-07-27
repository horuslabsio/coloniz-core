// *************************************************************************
//                            OZ ERC721
// *************************************************************************
use openzeppelin::{
    token::erc721::{ERC721Component::{ERC721Metadata, ERC721Mixin, HasComponent}},
    introspection::src5::SRC5Component,
};


#[starknet::interface]
trait IERC721Metadata<TState> {
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
}

#[starknet::embeddable]
impl IERC721MetadataImpl<
    TContractState,
    +HasComponent<TContractState>,
    +SRC5Component::HasComponent<TContractState>,
    +Drop<TContractState>
> of IERC721Metadata<TContractState> {
    fn name(self: @TContractState) -> ByteArray {
        let component = HasComponent::get_component(self);
        ERC721Metadata::name(component)
    }

    fn symbol(self: @TContractState) -> ByteArray {
        let component = HasComponent::get_component(self);
        ERC721Metadata::symbol(component)
    }
}


#[starknet::contract]
mod Handles {
    // *************************************************************************
    //                            IMPORT
    // *************************************************************************
    use core::num::traits::zero::Zero;
    use core::traits::TryInto;
    use core::poseidon::PoseidonTrait;
    use core::hash::{HashStateTrait, HashStateExTrait};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use openzeppelin::{
        account, access::ownable::OwnableComponent,
        token::erc721::{
            ERC721Component, erc721::ERC721Component::InternalTrait as ERC721InternalTrait
        },
        introspection::{src5::SRC5Component}
    };
    use karst::base::{
        constants::errors::Errors,
        utils::byte_array_extra::FeltTryIntoByteArray, // token_uris::handle_token_uri::HandleTokenUri,
    };
    use karst::interfaces::{
        IKarstNFT::{IKarstNFTDispatcher, IKarstNFTDispatcherTrait}, IHandle::IHandle
    };

    use karst::base::token_uris::token_uris::TokenURIComponent;
    component!(path: TokenURIComponent, storage: token_uri, event: TokenUriEvent);


    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);

    // allow to check what interface is supported
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;
    impl SRC5InternalImpl = SRC5Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnlyImpl = ERC721Component::ERC721CamelOnlyImpl<ContractState>;

    // add an owner
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl TokenURIImpl = TokenURIComponent::KarstTokenURI<ContractState>;

    // *************************************************************************
    //                            STORAGE
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
        token_uri: TokenURIComponent::Storage,
        admin: ContractAddress,
        total_supply: u256,
        local_names: LegacyMap::<u256, felt252>,
    }

    // *************************************************************************
    //                            CONSTANTS
    // *************************************************************************
    const MAX_LOCAL_NAME_LENGTH: u256 = 26;
    const NAMESPACE: felt252 = 'kst';
    const ASCII_A: u8 = 97;
    const ASCII_Z: u8 = 122;
    const ASCII_0: u8 = 48;
    const ASCII_9: u8 = 57;
    const ASCII_UNDERSCORE: u8 = 95;

    // *************************************************************************
    //                            EVENTS
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
        HandleMinted: HandleMinted,
        HandleBurnt: HandleBurnt,
    }

    #[derive(Drop, starknet::Event)]
    pub struct HandleMinted {
        local_name: felt252,
        token_id: u256,
        to: ContractAddress,
        block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct HandleBurnt {
        local_name: felt252,
        token_id: u256,
        owner: ContractAddress,
        block_timestamp: u64,
    }

    // *************************************************************************
    //                            CONSTRUCTOR
    // *************************************************************************
    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress) {
        self.admin.write(admin);
        self.erc721.initializer("Karst Handles", "KARST", "");
    }

    //                            EXTERNAL FUNCTIONS
    // *************************************************************************
    #[abi(embed_v0)]
    impl HandlesImpl of IHandle<ContractState> {
        /// @notice mints a handle to a profile address
        /// @param address profile address to mint handle to
        /// @param local_name username to be minted
        fn mint_handle(
            ref self: ContractState, address: ContractAddress, local_name: felt252,
        ) -> u256 {
            self._validate_local_name(local_name);
            let token_id = self._mint_handle(address, local_name);
            token_id
        }

        /// @notice burns a handle previously minted
        /// @param token_id ID of handle to be burnt
        fn burn_handle(ref self: ContractState, token_id: u256) {
            assert(get_caller_address() == self.erc721.owner_of(token_id), Errors::INVALID_OWNER);
            let current_supply = self.total_supply.read();
            let local_name = self.local_names.read(token_id);
            self.erc721._burn(token_id);
            self.total_supply.write(current_supply - 1);
            self.local_names.write(token_id, 0);
            self
                .emit(
                    HandleBurnt {
                        local_name: local_name,
                        owner: get_caller_address(),
                        token_id: token_id,
                        block_timestamp: get_block_timestamp()
                    }
                );
        }

        // *************************************************************************
        //                            GETTERS
        // *************************************************************************
        /// @notice returns Karst namespace
        fn get_namespace(self: @ContractState) -> felt252 {
            return NAMESPACE;
        }

        /// @notice returns the local name for a user
        /// @param token_id ID of handle who's local name should be returned
        fn get_local_name(self: @ContractState, token_id: u256) -> felt252 {
            self.local_names.read(token_id)
        }

        /// @notice returns the full handle of a user
        /// @param token_id ID of handle to retrieve
        fn get_handle(self: @ContractState, token_id: u256) -> ByteArray {
            let local_name = self.get_local_name(token_id);
            assert(local_name.is_non_zero(), Errors::HANDLE_DOES_NOT_EXIST);
            let local_name_in_byte_array: ByteArray = local_name.try_into().unwrap();
            let namespace_in_byte_array: ByteArray = NAMESPACE.try_into().unwrap();
            let handle = local_name_in_byte_array + "." + namespace_in_byte_array;
            handle
        }

        /// @notice checks if a handle exists
        /// @param token_id ID of handle to be queried
        fn exists(self: @ContractState, token_id: u256) -> bool {
            self.erc721._exists(token_id)
        }

        /// @notice returns no. of handles minted
        fn total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }

        /// @notice returns the token ID for a given local name
        /// @param local_name local name to be queried
        fn get_token_id(self: @ContractState, local_name: felt252) -> u256 {
            let hash: u256 = PoseidonTrait::new()
                .update_with(local_name)
                .finalize()
                .try_into()
                .unwrap();
            hash
        }

        // *************************************************************************
        //                            METADATA
        // *************************************************************************
        /// @notice returns the collection name
        fn name(self: @ContractState) -> ByteArray {
            return "Karst Handles";
        }

        /// @notice returns the collection symbol
        fn symbol(self: @ContractState) -> ByteArray {
            return "KARST";
        }

        /// @notice returns the token URI of a particular handle
        /// @param token_id ID of handle to be queried
        /// @param local_name local name of handle to be queried

        fn get_handle_token_uri(
            self: @ContractState, token_id: u256, local_name: felt252
        ) -> ByteArray {
            // call token uri component
            self.token_uri.profile_get_token_uri(token_id, mint_timestamp, profile);

        }
    }

    // *************************************************************************
    //                            PRIVATE FUNCTIONS
    // *************************************************************************
    #[generate_trait]
    impl Private of PrivateTrait {
        /// @notice internal function that mints a handle to a profile
        /// @param address profile address to mint handle to
        /// @param local_name username to be minted
        fn _mint_handle(
            ref self: ContractState, address: ContractAddress, local_name: felt252,
        ) -> u256 {
            let token_id = self.get_token_id(local_name);
            let mut current_total_supply = self.total_supply.read();
            current_total_supply += 1;
            self.total_supply.write(current_total_supply);

            self.erc721._mint(address, token_id);
            self.local_names.write(token_id, local_name);

            self
                .emit(
                    HandleMinted {
                        local_name: local_name,
                        to: address,
                        token_id: token_id,
                        block_timestamp: get_block_timestamp()
                    }
                );
            token_id
        }

        /// @notice validates that a local name contains only [a-z,0-9,_] and does not begin with an underscore.
        /// @param local_name username to be minted
        fn _validate_local_name(self: @ContractState, local_name: felt252) {
            let mut value: u256 = local_name.into();
            let mut last_char = 0_u8;

            loop {
                if value == 0 {
                    break;
                }
                last_char = (value & 0xFF).try_into().unwrap();
                assert(
                    (self._is_alpha_numeric(last_char) || last_char == ASCII_UNDERSCORE),
                    Errors::INVALID_LOCAL_NAME
                );

                value = value / 0x100;
            };

            // Note that for performance reason, the local_name is parsed in reverse order,
            // so the first character is the last processed one.
            assert(last_char != ASCII_UNDERSCORE.into(), Errors::INVALID_LOCAL_NAME);
        }

        // @notice checks that a character is alpha numeric
        // @param char character to be validated
        fn _is_alpha_numeric(self: @ContractState, char: u8) -> bool {
            (char >= ASCII_A && char <= ASCII_Z) || (char >= ASCII_0 && char <= ASCII_9)
        }
    }
}
