#[starknet::component]
pub mod PotComponent {
    // *************************************************************************
    //                            IMPORTS
    // *************************************************************************
    use core::hash::HashStateTrait;
    use core::pedersen::PedersenTrait;
    use starknet::{
        ContractAddress, get_caller_address, get_block_timestamp,
        storage::{
            StoragePointerWriteAccess, StoragePointerReadAccess, Map, StorageMapReadAccess,
            StorageMapWriteAccess
        }
    };

    use coloniz::base::constants::{types::{PotInstance, JoltParams, JoltType}, errors::Errors};
    use coloniz::interfaces::{
        IPot::IPot, 
        ICommunity::ICommunity,
        IJolt::IJolt
    };
    use coloniz::community::community::CommunityComponent;
    use coloniz::jolt::jolt::JoltComponent;

    use openzeppelin_access::ownable::OwnableComponent;
    use alexandria_merkle_tree::merkle_tree::{ Hasher, MerkleTree, pedersen::PedersenHasherImpl, MerkleTreeTrait };

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
        ActivatedPot: ActivatedPot,
        ClaimedFromPot: ClaimedFromPot,
        WithdrawnFromPot: WithdrawnFromPot,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ActivatedPot {
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
     >of IPot<ComponentState<TContractState>> {
        // *************************************************************************
        //                              EXTERNALS
        // *************************************************************************
        fn activate(
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

            // write instance details to storage
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
                    ActivatedPot {
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

        fn claim(ref self: ComponentState<TContractState>, instance_id: u256, amount: u256, proof: Span<felt252>) {
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
            assert(self.has_claimed.read(caller), Errors::USER_ALREADY_CLAIMED);

            // check the distribution amount is not exhausted
            let distributed_amount = self.distributed_amount.read(instance_id);
            let unclaimed_amount = instance.distribution_amount - distributed_amount;
            assert(unclaimed_amount > 0, Errors::DISTRIBUTION_AMOUNT_EXHAUSTED);

            // check that proof is valid
            let is_valid_proof = self._verify_claim_proof(
                instance_id, 
                caller, 
                amount, 
                instance.merkle_root,
                proof
            );
            assert(is_valid_proof, Errors::INVALID_CLAIM_PROOF);

            // call an internal function to process claim
            self
                ._claim(
                    instance_id,
                    instance.community_id,
                    caller,
                    amount,
                    instance.erc20_contract_address
                )
        }

        fn withdraw(ref self: ComponentState<TContractState>, instance_id: u256, address: ContractAddress) {
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
                    unclaimed_amount,
                    instance.erc20_contract_address
                );
        }

        // *************************************************************************
        //                              GETTERS
        // *************************************************************************
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

        fn user_is_eligible(
            self: @ComponentState<TContractState>,
            instance_id: u256,
            address: ContractAddress,
            amount: u256,
            proof: Span<felt252>
        ) -> bool {
            let instance = self.instances.read(instance_id);
            self._verify_claim_proof(
                instance_id, 
                address, 
                amount, 
                instance.merkle_root, 
                proof
            )
        }

        fn user_has_claimed(
            self: @ComponentState<TContractState>, instance_id: u256, address: ContractAddress
        ) -> bool {
            self.has_claimed.read(address)
        }

        fn get_distributed_amount(self: @ComponentState<TContractState>, instance_id: u256) -> u256 {
            self.distributed_amount.read(instance_id)
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
                .update(caller.into())
                .update(amount.low.into())
                .update(amount.high.into())
                .update(3)
                .finalize();

            // verify merkle proof
            merkle_tree.verify(merkle_root, leaf, proof)
        }

        fn _claim(
            ref self: ComponentState<TContractState>,
            instance_id: u256,
            community_id: u256,
            caller: ContractAddress,
            amount: u256,
            erc20_contract_address: ContractAddress
        ) {
            // jolt the funds to the caller
            let jolt_params = JoltParams {
                jolt_type: JoltType::Transfer,
                recipient: caller,
                memo: "claimed funds from pot",
                amount: amount,
                expiration_stamp: 0,
                subscription_details: (0, false, 0),
                erc20_contract_address: erc20_contract_address
            };

            let mut jolt_comp = get_dep_component_mut!(ref self, Jolt);
            jolt_comp.jolt(jolt_params);

            // update storage
            self.has_claimed.write(caller, true);

            // emit claimed event
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

        fn _withdraw(
            ref self: ComponentState<TContractState>,
            instance_id: u256,
            community_id: u256,
            address: ContractAddress,
            amount: u256,
            erc20_contract_address: ContractAddress
        ) {
            // jolt the funds back to the owner
            let jolt_params = JoltParams {
                jolt_type: JoltType::Transfer,
                recipient: address,
                memo: "Withdrew unclaimed funds from pot",
                amount: amount,
                expiration_stamp: 0,
                subscription_details: (0, false, 0),
                erc20_contract_address: erc20_contract_address
            };

            let mut jolt_comp = get_dep_component_mut!(ref self, Jolt);
            jolt_comp.jolt(jolt_params);

            // emit event
            self
                .emit(
                    WithdrawnFromPot {
                        pot_instance_id: instance_id,
                        community_id: community_id,
                        address: address,
                        amount_withdrawn: amount,
                        erc20_contract_address: erc20_contract_address,
                    }
                );
        }
    }
}
