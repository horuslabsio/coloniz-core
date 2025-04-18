#[starknet::contract]
pub mod CommunityPot {
    // *************************************************************************
    //                            IMPORTS
    // *************************************************************************
    use starknet::{
        ContractAddress, get_caller_address, get_contract_address, get_block_timestamp, get_tx_info,
        storage::{
            StoragePointerWriteAccess, StoragePointerReadAccess, Map, StorageMapReadAccess,
            StorageMapWriteAccess
        }
    };

    use coloniz::base::constants::{ types::{ PotInstance }, errors::Errors };
    use coloniz::interfaces::{ IPot::IPot, IERC20::{IERC20Dispatcher, IERC20DispatcherTrait} };
    use coloniz::community::community::CommunityComponent;
    use coloniz::jolt::jolt::JoltComponent;

    use openzeppelin_access::ownable::OwnableComponent;
    use openzeppelin_upgrades::UpgradeableComponent;

    component!(path: CommunityComponent, storage: community, event: CommunityEvent);
    component!(path: JoltComponent, storage: jolt, event: JoltEvent);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: UpgradeableComponent, storage: upgradeable, event: UpgradeableEvent);

    impl communityImpl = CommunityComponent::colonizCommunity<ContractState>;
    impl joltImpl = JoltComponent::Jolt<ContractState>;
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;

    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;
    impl UpgradeableInternalImpl = UpgradeableComponent::InternalImpl<ContractState>;

    #[storage]
    pub struct Storage {
        instances: Map<u256, PotInstance>,
        total_instances: u256,
        #[substorage(v0)]
        community: CommunityComponent::Storage,
        #[substorage(v0)]
        jolt: JoltComponent::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        upgradeable: UpgradeableComponent::Storage,
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
        #[flat]
        CommunityEvent: CommunityComponent::Event,
        #[flat]
        JoltEvent: JoltComponent::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        UpgradeableEvent: UpgradeableComponent::Event
    }

    #[derive(Drop, starknet::Event)]
    pub struct ActivatedPot {
        pub pot_instance_id: u256,
        pub community_id: u256,
        pub root: u256,
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
        pub amount_claimed: u256
    }

    #[derive(Drop, starknet::Event)]
    pub struct WithdrawnFromPot {
        pub pot_instance_id: u256,
        pub community_id: u256,
        pub address: ContractAddress,
        pub amount_withdrawn: u256
    }

    #[abi(embed_v0)]
    impl CommunityPotImpl of IPot<ContractState> {
        // *************************************************************************
        //                              EXTERNALS
        // *************************************************************************
        fn activate(
            ref self: ContractState,
            community_id: u256,
            root: u256,
            max_claim: u256,
            distribution_amount: u256,
            erc20_contract_address: ContractAddress,
            instance_start_time: u64,
            instance_duration: u64
        ) -> u256 {
            // check caller is community owner/mod
            let community_owner = self.community.get_community(community_id).community_owner;
            let is_community_mod = self.community.is_community_mod(get_caller_address(), community_id);
            assert(get_caller_address() == community_owner || is_community_mod, Errors::UNAUTHORIZED);

            // check max claim is less than distribution_amount
            assert(max_claim < distribution_amount, Errors::INVALID_MAX_CLAIM);
            // check start time is not in the past
            let now = get_block_timestamp();
            assert(instance_start_time > now, Errors::INVALID_START_TIME);
            // check duration is greater than 1 hr
            assert(instance_duration > 3600, Errors::INVALID_DURATION);

            // write instance details to storage
            let new_instance_id: u256 = self.total_instances.read() + 1;
            let new_pot_instance =  PotInstance {
                instance_id: new_instance_id,
                community_id,
                root,
                distribution_amount,
                max_claim,
                erc20_contract_address,
                instance_duration
            };
            self.instances.write(new_instance_id, new_pot_instance);

            self.emit( ActivatedPot {
                pot_instance_id: new_instance_id,
                community_id,
                root,
                distribution_amount,
                erc20_contract_address,
                instance_start_time,
                instance_duration
            });

            new_instance_id
        }

        fn claim(ref self: ContractState, instance_id: u256) {

        }

        fn withdraw(ref self: ContractState, instance_id: u256, address: ContractAddress) {
            
        }

        // *************************************************************************
        //                              GETTERS
        // *************************************************************************
        fn instance_is_active(self: @ContractState, instance_id: u256) -> bool {
            false
        }

        fn user_is_eligible(self: @ContractState, instance_id: u256, address: ContractAddress) -> (bool, u256) {
            (false, 0)
        }
    }
}