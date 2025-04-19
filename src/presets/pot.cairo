#[starknet::contract]
pub mod CommunityPot {
    use coloniz::community::pot::PotComponent;
    use coloniz::community::community::CommunityComponent;
    use coloniz::jolt::jolt::JoltComponent;
    use openzeppelin_access::ownable::OwnableComponent;

    component!(path: PotComponent, storage: pot, event: PotEvent);
    component!(path: CommunityComponent, storage: community, event: CommunityEvent);
    component!(path: JoltComponent, storage: jolt, event: JoltEvent);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl potImpl = PotComponent::communityPot<ContractState>;
    impl potPrivateImpl = PotComponent::Private<ContractState>;

    #[abi(embed_v0)]
    impl communityImpl = CommunityComponent::colonizCommunity<ContractState>;
    impl communityPrivateImpl = CommunityComponent::Private<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        pot: PotComponent::Storage,
        #[substorage(v0)]
        community: CommunityComponent::Storage,
        #[substorage(v0)]
        jolt: JoltComponent::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        PotEvent: PotComponent::Event,
        #[flat]
        CommunityEvent: CommunityComponent::Event,
        #[flat]
        JoltEvent: JoltComponent::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, community_nft_classhash: felt252) {
        self.community._initializer(community_nft_classhash);
    }
}
