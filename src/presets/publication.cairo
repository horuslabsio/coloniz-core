#[starknet::contract]
pub mod ColonizPublication {
    use starknet::ContractAddress;
    use coloniz::publication::publication::PublicationComponent;
    use coloniz::profile::profile::ProfileComponent;
    use coloniz::jolt::jolt::JoltComponent;
    use openzeppelin_access::ownable::OwnableComponent;
    use coloniz::community::community::CommunityComponent;
    use coloniz::sub_community::sub_community::SubCommunityComponent;


    component!(path: PublicationComponent, storage: publication, event: PublicationEvent);
    component!(path: ProfileComponent, storage: profile, event: ProfileEvent);
    component!(path: JoltComponent, storage: jolt, event: JoltEvent);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: SubCommunityComponent, storage: sub_community, event: SubCommunityEvent);
    component!(path: CommunityComponent, storage: community, event: CommunityEvent);


    #[abi(embed_v0)]
    impl publicationImpl = PublicationComponent::colonizPublication<ContractState>;
    impl publicationInternalImpl = PublicationComponent::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl profileImpl = ProfileComponent::colonizProfile<ContractState>;
    impl ProfilePrivateImpl = ProfileComponent::Private<ContractState>;

    #[abi(embed_v0)]
    impl joltImpl = JoltComponent::Jolt<ContractState>;
    impl joltPrivateImpl = JoltComponent::Private<ContractState>;

    #[abi(embed_v0)]
    impl communityImpl = CommunityComponent::colonizCommunity<ContractState>;
    impl communityPrivateImpl = CommunityComponent::Private<ContractState>;

    #[abi(embed_v0)]
    impl subCommunityImpl = SubCommunityComponent::SubCommunity<ContractState>;
    impl subCommunityPrivateImpl = SubCommunityComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        publication: PublicationComponent::Storage,
        #[substorage(v0)]
        profile: ProfileComponent::Storage,
        #[substorage(v0)]
        jolt: JoltComponent::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        community: CommunityComponent::Storage,
        #[substorage(v0)]
        sub_community: SubCommunityComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        PublicationEvent: PublicationComponent::Event,
        #[flat]
        ProfileEvent: ProfileComponent::Event,
        #[flat]
        JoltEvent: JoltComponent::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        CommunityEvent: CommunityComponent::Event,
        #[flat]
        SubCommunityEvent: SubCommunityComponent::Event,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        coloniznft_contract_address: ContractAddress,
        hub_address: ContractAddress,
        follow_nft_classhash: felt252,
        community_nft_classhash: felt252,
        collect_nft_classhash: felt252,
        owner: ContractAddress
    ) {
        self.profile._initializer(coloniznft_contract_address, hub_address, follow_nft_classhash);
        self.publication._initializer(collect_nft_classhash);
        self.community._initializer(community_nft_classhash);
        self.jolt._initializer(owner);
    }
}
