#[starknet::contract]
pub mod ColonizSubCommunity {
    use coloniz::sub_community::sub_community::SubCommunityComponent;
    use coloniz::community::community::CommunityComponent;
    use coloniz::jolt::jolt::JoltComponent;
    use openzeppelin_access::ownable::OwnableComponent;

    component!(path: SubCommunityComponent, storage: sub_community, event: SubCommunityEvent);
    component!(path: CommunityComponent, storage: community, event: CommunityEvent);
    component!(path: JoltComponent, storage: jolt, event: JoltEvent);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl subCommunityImpl = SubCommunityComponent::SubCommunity<ContractState>;
    impl subCommunityPrivateImpl = SubCommunityComponent::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl communityImpl = CommunityComponent::colonizCommunity<ContractState>;
    impl communityPrivateImpl = CommunityComponent::Private<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        sub_community: SubCommunityComponent::Storage,
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
        SubCommunityEvent: SubCommunityComponent::Event,
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
