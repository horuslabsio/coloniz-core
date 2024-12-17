// *************************************************************************
//                              REGISTRY
// *************************************************************************
#[starknet::contract]
pub mod Registry {
    // *************************************************************************
    //                              IMPORTS
    // *************************************************************************
    use core::hash::HashStateTrait;
    use core::pedersen::PedersenTrait;
    use starknet::{
        ContractAddress, get_contract_address, syscalls::deploy_syscall, class_hash::ClassHash,
        SyscallResultTrait
    };
    use token_bound_accounts::interfaces::IRegistry::IRegistry;

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    pub struct Storage {}

    // *************************************************************************
    //                              EVENTS
    // *************************************************************************
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        AccountCreated: AccountCreated
    }

    /// @notice Emitted when a new tokenbound account is deployed/created
    /// @param account_address the deployed contract address of the tokenbound acccount
    /// @param token_contract the contract address of the NFT
    /// @param token_id the ID of the NFT
    #[derive(Drop, starknet::Event)]
    pub struct AccountCreated {
        pub account_address: ContractAddress,
        pub token_contract: ContractAddress,
        pub token_id: u256,
    }


    // *************************************************************************
    //                              EXTERNAL FUNCTIONS
    // *************************************************************************
    #[abi(embed_v0)]
    impl IRegistryImpl of IRegistry<ContractState> {
        /// @notice deploys a new tokenbound account for an NFT
        /// @param implementation_hash the class hash of the reference account
        /// @param token_contract the contract address of the NFT
        /// @param token_id the ID of the NFT
        /// @param salt random salt for deployment
        fn create_account(
            ref self: ContractState,
            implementation_hash: felt252,
            token_contract: ContractAddress,
            token_id: u256,
            salt: felt252,
            chain_id: felt252
        ) -> ContractAddress {
            let mut constructor_calldata: Array<felt252> = array![
                token_contract.into(),
                token_id.low.into(),
                token_id.high.into(),
                get_contract_address().into(),
                implementation_hash,
                salt
            ];

            let class_hash: ClassHash = implementation_hash.try_into().unwrap();
            let result = deploy_syscall(class_hash, salt, constructor_calldata.span(), false);
            let (account_address, _) = result.unwrap_syscall();

            self.emit(AccountCreated { account_address, token_contract, token_id, });
            account_address
        }

        /// @notice calculates the account address for an existing tokenbound account
        /// @param implementation_hash the class hash of the reference account
        /// @param token_contract the contract address of the NFT
        /// @param token_id the ID of the NFT
        /// @param salt random salt for deployment
        fn get_account(
            self: @ContractState,
            implementation_hash: felt252,
            token_contract: ContractAddress,
            token_id: u256,
            salt: felt252,
            chain_id: felt252
        ) -> ContractAddress {
            let constructor_calldata_hash = PedersenTrait::new(0)
                .update(token_contract.into())
                .update(token_id.low.into())
                .update(token_id.high.into())
                .update(get_contract_address().into())
                .update(implementation_hash)
                .update(salt)
                .update(6)
                .finalize();

            let prefix: felt252 = 'STARKNET_CONTRACT_ADDRESS';
            let account_address = PedersenTrait::new(0)
                .update(prefix)
                .update(get_contract_address().into())
                .update(salt)
                .update(implementation_hash)
                .update(constructor_calldata_hash)
                .update(5)
                .finalize();

            account_address.try_into().unwrap()
        }
    }
}
