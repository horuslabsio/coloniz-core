#[starknet::component]
pub mod PotComponent {
    // *************************************************************************
    //                            IMPORTS
    // *************************************************************************
    use core::hash::HashStateTrait;
    use core::pedersen::PedersenTrait;
    use starknet::{
        ContractAddress, get_caller_address, get_contract_address, get_block_timestamp,
        storage::{
            StoragePointerWriteAccess, StoragePointerReadAccess, Map, StorageMapReadAccess,
            StorageMapWriteAccess
        }
    };

    use coloniz::base::constants::{types::{PotInstance, JoltParams, JoltType}, errors::Errors};
    use coloniz::interfaces::{
        IPot::IPot, ICommunity::ICommunity, IJolt::IJolt,
        IERC20::{IERC20Dispatcher, IERC20DispatcherTrait}
    };
    use coloniz::community::community::CommunityComponent;
    use coloniz::jolt::jolt::JoltComponent;

    use openzeppelin_access::ownable::OwnableComponent;
    use alexandria_merkle_tree::merkle_tree::{
        Hasher, MerkleTree, pedersen::PedersenHasherImpl, MerkleTreeTrait
    };

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    pub struct Storage {
        instances: Map<u256, PotInstance>, // map<instance_id, Pot>
        total_instances: u256, // tracks total instances
        distributed_amount: Map<u256, u256>, // map<instance_id, distributed_amount>
        has_claimed: Map<ContractAddress, bool>, // map<user profile, claim status>
    }

    // *************************************************************************
    //                            EVENTS
    // *************************************************************************
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        PotInstanceCreated: PotInstanceCreated,
        ClaimedFromPot: ClaimedFromPot,
        WithdrawnFromPot: WithdrawnFromPot,
    }

    #[derive(Drop, starknet::Event)]
    pub struct PotInstanceCreated {
        pub pot_instance_id: u256,
        pub community_id: u256,
        pub merkle_root: felt252,
        pub distribution_amount: u256,
        pub erc20_contract_address: ContractAddress,
        pub instance_start_time: u64,
        pub instance_duration: u64
    }

    #[derive(Drop, starknet::Event)]
    pub struct ClaimedFromPot {
        pub pot_instance_id: u256,
        pub community_id: u256,
        pub address: ContractAddress,
        pub amount_claimed: u256,
        pub erc20_contract_address: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct WithdrawnFromPot {
        pub pot_instance_id: u256,
        pub community_id: u256,
        pub address: ContractAddress,
        pub amount_withdrawn: u256,
        pub erc20_contract_address: ContractAddress,
    }

    #[embeddable_as(communityPot)]
    pub impl CommunityPotImpl<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl Jolt: JoltComponent::HasComponent<TContractState>,
        impl Community: CommunityComponent::HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>
    > of IPot<ComponentState<TContractState>> {
        // *************************************************************************
        //                              EXTERNALS
        // *************************************************************************
        /// @notice creates a new pot instance
        /// @param community_id id of community
        /// @param merkle_root root of the tree
        /// @param max_claim max claim a user can make
        /// @param distribution_amount amount to be distributed
        /// @param erc20_contract_address address of token to distribute
        /// @param instance_start_time time at which instance is activated
        /// @param instance_duration duration of the instance
        fn create_instance(
            ref self: ComponentState<TContractState>,
            community_id: u256,
            merkle_root: felt252,
            max_claim: u256,
            distribution_amount: u256,
            erc20_contract_address: ContractAddress,
            instance_start_time: u64,
            instance_duration: u64
        ) -> u256 {
            // check caller is community owner/mod
            let community_comp = get_dep_component!(@self, Community);
            let community_owner = community_comp.get_community(community_id).community_owner;
            let is_community_mod = community_comp
                .is_community_mod(get_caller_address(), community_id);
            assert(
                get_caller_address() == community_owner || is_community_mod, Errors::UNAUTHORIZED
            );

            // check max claim is less than distribution_amount
            assert(max_claim < distribution_amount, Errors::INVALID_MAX_CLAIM);
            // check start time is not in the past
            let now = get_block_timestamp();
            assert(instance_start_time > now, Errors::INVALID_START_TIME);

            self
                ._create_instance(
                    community_id,
                    merkle_root,
                    max_claim,
                    distribution_amount,
                    erc20_contract_address,
                    instance_start_time,
                    instance_duration
                )
        }

        /// @notice called to claim from pot
        /// @param instance_id id of the pot instance to claim from
        /// @param claim_amount amount to be claimed
        /// @param proof merkle proof to be validated
        fn claim(
            ref self: ComponentState<TContractState>,
            instance_id: u256,
            claim_amount: u256,
            proof: Span<felt252>
        ) {
            // check that instance exists and is ongoing
            let instance = self.instances.read(instance_id);
            assert(instance.instance_id != 0, Errors::INSTANCE_DOES_NOT_EXIST);

            let now = get_block_timestamp();
            let caller = get_caller_address();
            let instance_start_time = instance.instance_start_time;
            let instance_end_time = instance_start_time + instance.instance_duration;
            assert(now > instance_start_time && now < instance_end_time, Errors::INSTANCE_INACTIVE);

            // check that the caller is a member of the community
            let community_comp = get_dep_component!(@self, Community);
            let (is_member, _) = community_comp.is_community_member(caller, instance.community_id);
            assert(is_member, Errors::NOT_COMMUNITY_MEMBER);

            // check that the caller has not previously claimed
            assert(!self.has_claimed.read(caller), Errors::USER_ALREADY_CLAIMED);

            // check that the claim amount does not exceed max claim
            assert(claim_amount <= instance.max_claim, Errors::EXCEEDS_MAX_CLAIM);

            // check the distribution amount is not exhausted
            let distributed_amount = self.distributed_amount.read(instance_id);
            let unclaimed_amount = instance.distribution_amount - distributed_amount;
            assert(unclaimed_amount >= claim_amount, Errors::DISTRIBUTION_AMOUNT_EXHAUSTED);

            // check that proof is valid
            let is_valid_proof = self
                ._verify_claim_proof(
                    instance_id, caller, claim_amount, instance.merkle_root, proof
                );
            assert(is_valid_proof, Errors::INVALID_CLAIM_PROOF);

            // call an internal function to process claim
            self
                ._claim(
                    instance_id,
                    instance.community_id,
                    caller,
                    claim_amount,
                    instance.erc20_contract_address
                )
        }

        /// @notice withdraws the remaining funds after claiming is ended
        /// @param instance_id id of the pot instance to withdraw from
        /// @param address address to withdraw funds to
        fn withdraw(
            ref self: ComponentState<TContractState>, instance_id: u256, address: ContractAddress
        ) {
            let instance = self.instances.read(instance_id);

            // check caller is owner
            let community_comp = get_dep_component!(@self, Community);
            let community_owner = community_comp
                .get_community(instance.community_id)
                .community_owner;
            assert(get_caller_address() == community_owner, Errors::UNAUTHORIZED);

            // check the distribution amount was not exhausted
            let distributed_amount = self.distributed_amount.read(instance_id);
            let unclaimed_amount = instance.distribution_amount - distributed_amount;
            assert(unclaimed_amount > 0, Errors::DISTRIBUTION_AMOUNT_EXHAUSTED);

            // check that instance duration is over
            let now = get_block_timestamp();
            let instance_end_time = instance.instance_start_time + instance.instance_duration;
            assert(now > instance_end_time, Errors::INSTANCE_NOT_ENDED);

            self
                ._withdraw(
                    instance_id,
                    instance.community_id,
                    address,
                    instance.distribution_amount,
                    unclaimed_amount,
                    instance.erc20_contract_address
                );
        }

        // *************************************************************************
        //                              GETTERS
        // *************************************************************************
        /// @notice returns the status of an instance
        /// @param instance_id id of the instance to be queried
        fn instance_is_active(self: @ComponentState<TContractState>, instance_id: u256) -> bool {
            let instance = self.instances.read(instance_id);
            let now = get_block_timestamp();
            let instance_start_time = instance.instance_start_time;
            let instance_end_time = instance_start_time + instance.instance_duration;

            if now > instance_start_time && now < instance_end_time {
                return true;
            } else {
                return false;
            }
        }

        //

        fn get_pot_instance_details(self:@ComponentState<TContractState>, instance_id: u256) -> PotInstance{
            let instance_details = self.instances.read(instance_id);
            instance_details
        }

        /// @notice checks if a user is eligible for claiming
        /// @param instance_id id of instance to check against
        /// @param address address to be checked
        /// @param amount claim amount
        /// @param proof merkle proof to be validated
        fn user_is_eligible(
            self: @ComponentState<TContractState>,
            instance_id: u256,
            address: ContractAddress,
            amount: u256,
            proof: Span<felt252>
        ) -> bool {
            let instance = self.instances.read(instance_id);
            self._verify_claim_proof(instance_id, address, amount, instance.merkle_root, proof)
        }

        /// @notice checks if a user has claimed
        /// @param instance_id id of instance to check against
        /// @param address address to be checked
        fn user_has_claimed(
            self: @ComponentState<TContractState>, instance_id: u256, address: ContractAddress
        ) -> bool {
            self.has_claimed.read(address)
        }

        /// @notice get the distributed amount in an instance
        /// @param instance_id id of instance to check against
        fn get_distributed_amount(
            self: @ComponentState<TContractState>, instance_id: u256
        ) -> u256 {
            self.distributed_amount.read(instance_id)
        }

        /// @notice get the total no. of instances created
        fn get_total_instances(self: @ComponentState<TContractState>) -> u256 {
            self.total_instances.read()
        }
    }

    // *************************************************************************
    //                              PRIVATE FUNCTIONS
    // *************************************************************************
    #[generate_trait]
    pub impl Private<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl Jolt: JoltComponent::HasComponent<TContractState>,
        impl Community: CommunityComponent::HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>
    > of PrivateTrait<TContractState> {
        /// @notice internal function to create new instances
        /// @param community_id id of community
        /// @param merkle_root root of the tree
        /// @param max_claim max claim a user can make
        /// @param distribution_amount amount to be distributed
        /// @param erc20_contract_address address of token to distribute
        /// @param instance_start_time time at which instance is activated
        /// @param instance_duration duration of the instance
        fn _create_instance(
            ref self: ComponentState<TContractState>,
            community_id: u256,
            merkle_root: felt252,
            max_claim: u256,
            distribution_amount: u256,
            erc20_contract_address: ContractAddress,
            instance_start_time: u64,
            instance_duration: u64
        ) -> u256 {
            // jolt amount to the contract
            let jolt_params = JoltParams {
                jolt_type: JoltType::Transfer,
                recipient: get_contract_address(),
                memo: "Funding community pot",
                amount: distribution_amount,
                expiration_stamp: 0,
                subscription_details: (0, false, 0),
                erc20_contract_address: erc20_contract_address
            };

            let mut jolt_comp = get_dep_component_mut!(ref self, Jolt);
            jolt_comp.jolt(jolt_params);

            // write instance details to storage and emit event
            let new_instance_id: u256 = self.total_instances.read() + 1;
            let new_pot_instance = PotInstance {
                instance_id: new_instance_id,
                community_id,
                merkle_root,
                distribution_amount,
                max_claim,
                erc20_contract_address,
                instance_start_time,
                instance_duration
            };

            self.instances.write(new_instance_id, new_pot_instance);
            self.total_instances.write(new_instance_id);

            self
                .emit(
                    PotInstanceCreated {
                        pot_instance_id: new_instance_id,
                        community_id,
                        merkle_root,
                        distribution_amount,
                        erc20_contract_address,
                        instance_start_time,
                        instance_duration
                    }
                );

            new_instance_id
        }

        /// @notice verifies a claim proof
        /// @param instance_id id of pot instance
        /// @param caller claiming address
        /// @param amount claim amount
        /// @param merkle_root root to verify proof against
        /// @param proof merkle proof to be verified
        fn _verify_claim_proof(
            self: @ComponentState<TContractState>,
            instance_id: u256,
            caller: ContractAddress,
            amount: u256,
            merkle_root: felt252,
            proof: Span<felt252>
        ) -> bool {
            // create a new merkle tree instance
            let mut merkle_tree: MerkleTree<Hasher> = MerkleTreeTrait::new();

            // recreate the leaf
            let leaf = PedersenTrait::new(0)
                .update(amount.low.into())
                .update(amount.high.into())
                .update(caller.try_into().unwrap())
                .update(3)
                .finalize();

            // verify merkle proof
            merkle_tree.verify(merkle_root, leaf, proof)
        }

        /// @notice internal function to perform the claim action
        /// @param instance_id id of pot instance
        /// @param community_id id of community, pot instance belongs to
        /// @param caller claiming address
        /// @param amount claim amount
        /// @param erc20_contract_address address of token being claimed
        fn _claim(
            ref self: ComponentState<TContractState>,
            instance_id: u256,
            community_id: u256,
            caller: ContractAddress,
            amount: u256,
            erc20_contract_address: ContractAddress
        ) {
            // update storage
            self.has_claimed.write(caller, true);

            // update distributed amount
            let total_distributed_amount = self.distributed_amount.read(instance_id);
            self.distributed_amount.write(instance_id, (total_distributed_amount + amount));

            // send claim amount to caller
            IERC20Dispatcher { contract_address: erc20_contract_address }.transfer(caller, amount);

            self
                .emit(
                    ClaimedFromPot {
                        pot_instance_id: instance_id,
                        community_id: community_id,
                        address: caller,
                        amount_claimed: amount,
                        erc20_contract_address: erc20_contract_address
                    }
                )
        }

        /// @notice internal function to perform the withdraw action
        /// @param instance_id id of pot instance
        /// @param community_id id of community, pot instance belongs to
        /// @param address address to withdraw funds to
        /// @param distribution_amount total amount that was to be initially distributed
        /// @param unclaimed_amount amount to be withdrawn
        /// @param erc20_contract_address address of token being withdrawn
        fn _withdraw(
            ref self: ComponentState<TContractState>,
            instance_id: u256,
            community_id: u256,
            address: ContractAddress,
            distribution_amount: u256,
            unclaimed_amount: u256,
            erc20_contract_address: ContractAddress
        ) {
            // update distributed amount
            self.distributed_amount.write(instance_id, distribution_amount);

            IERC20Dispatcher { contract_address: erc20_contract_address }
                .transfer(address, unclaimed_amount);

            self
                .emit(
                    WithdrawnFromPot {
                        pot_instance_id: instance_id,
                        community_id: community_id,
                        address: address,
                        amount_withdrawn: unclaimed_amount,
                        erc20_contract_address: erc20_contract_address,
                    }
                );
        }
    }
}
