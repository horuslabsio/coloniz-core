#[starknet::component]
pub mod SubCommunityComponent {
    // *************************************************************************
    //                            IMPORT
    // *************************************************************************
    use core::clone::Clone;
    use core::starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use openzeppelin_access::ownable::OwnableComponent;

    use coloniz::jolt::jolt::JoltComponent;
    use coloniz::community::community::CommunityComponent;
    use coloniz::interfaces::{ISubCommunity::ISubCommunity, ICommunity::ICommunity};
    use coloniz::base::{
        constants::errors::Errors::{
            UNAUTHORIZED, COMMUNITY_DOES_NOT_EXIST, CHANNEL_ALREADY_EXISTS, CHANNEL_DOES_NOT_EXIST,
            SUB_COMMUNITY_ALREADY_EXISTS, SUB_COMMUNITY_DOES_NOT_EXIST
        },
        constants::types::{SubCommunityDetails, ChannelDetails}
    };

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    pub struct Storage {
        sub_communities: Map<u256, SubCommunityDetails>,
        channels: Map<u256, ChannelDetails>,
        sub_community_initialized: Map<u256, bool>, // tracks if a sub community id has been used
        channel_initialized: Map<u256, bool>, // tracks if a channel id has been used
        sub_community_moderators: Map<(u256, ContractAddress), bool>,
        is_sub_community_deleted: Map<u256, bool>,
        is_channel_deleted: Map<u256, bool>
    }

    // *************************************************************************
    //                              EVENTS
    // *************************************************************************
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        SubCommunityCreated: SubCommunityCreated,
        ChannelCreated: ChannelCreated,
        SubCommunityModAdded: SubCommunityModAdded,
        SubCommunityModRemoved: SubCommunityModRemoved,
        SubCommunityDeleted: SubCommunityDeleted,
        ChannelDeleted: ChannelDeleted
    }

    #[derive(Drop, starknet::Event)]
    pub struct SubCommunityCreated {
        pub sub_community_id: u256,
        pub community_id: u256,
        pub transaction_executor: ContractAddress,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ChannelCreated {
        pub channel_id: u256,
        pub community_id: u256,
        pub sub_community_id: u256,
        pub transaction_executor: ContractAddress,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct SubCommunityModAdded {
        pub sub_community_id: u256,
        pub mod_address: ContractAddress,
        pub transaction_executor: ContractAddress,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct SubCommunityModRemoved {
        pub sub_community_id: u256,
        pub mod_address: ContractAddress,
        pub transaction_executor: ContractAddress,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct SubCommunityDeleted {
        pub sub_community_id: u256,
        pub transaction_executor: ContractAddress,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ChannelDeleted {
        pub channel_id: u256,
        pub transaction_executor: ContractAddress,
        pub block_timestamp: u64,
    }


    // *************************************************************************
    //                              EXTERNAL FUNCTIONS
    // *************************************************************************
    #[embeddable_as(SubCommunity)]
    impl ChannelImpl<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl Community: CommunityComponent::HasComponent<TContractState>,
        impl Jolt: JoltComponent::HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>
    > of ISubCommunity<ComponentState<TContractState>> {
        /// @notice creates a new sub community
        /// @param sub_community_id id of new sub_community
        /// @param community_id id of parent community
        fn create_sub_community(
            ref self: ComponentState<TContractState>, sub_community_id: u256, community_id: u256
        ) -> u256 {
            // check sub_community id does not already exist
            let is_initialized = self.sub_community_initialized.read(sub_community_id);
            assert(is_initialized == false, SUB_COMMUNITY_ALREADY_EXISTS);

            // check that community exists
            let community_instance = get_dep_component!(@self, Community);
            let _community_id = community_instance.get_community(community_id).community_id;
            assert(community_id == _community_id, COMMUNITY_DOES_NOT_EXIST);

            let new_sub_community = SubCommunityDetails {
                sub_community_id: sub_community_id,
                community_id: community_id,
                sub_community_metadata_uri: ""
            };

            // update storage
            self.sub_communities.write(sub_community_id, new_sub_community.clone());
            self.channel_initialized.write(sub_community_id, true);

            // create default channel
            self.create_channel(sub_community_id, sub_community_id);

            // emit event
            self
                .emit(
                    SubCommunityCreated {
                        sub_community_id: sub_community_id,
                        community_id: community_id,
                        transaction_executor: get_caller_address(),
                        block_timestamp: get_block_timestamp(),
                    }
                );

            sub_community_id
        }

        /// @notice creates a new channel
        /// @param channel_id id of new channel
        /// @param sub_community_id id of parent sub_community
        fn create_channel(
            ref self: ComponentState<TContractState>, channel_id: u256, sub_community_id: u256
        ) -> u256 {
            // check channel id does not already exist
            let is_initialized = self.channel_initialized.read(channel_id);
            assert(is_initialized == false, CHANNEL_ALREADY_EXISTS);

            // check that sub-community exists
            let sub_community_id = self.sub_communities.read(sub_community_id).sub_community_id;
            assert(sub_community_id != 0, SUB_COMMUNITY_DOES_NOT_EXIST);

            // get parent community id
            let parent_community_id = self.sub_communities.read(sub_community_id).community_id;

            let new_channel = ChannelDetails {
                channel_id: channel_id,
                community_id: parent_community_id,
                sub_community_id: sub_community_id,
                channel_metadata_uri: ""
            };

            // update storage
            self.channels.write(channel_id, new_channel.clone());
            self.channel_initialized.write(channel_id, true);

            // emit event
            self
                .emit(
                    ChannelCreated {
                        channel_id: channel_id,
                        community_id: parent_community_id,
                        sub_community_id: sub_community_id,
                        transaction_executor: get_caller_address(),
                        block_timestamp: get_block_timestamp(),
                    }
                );

            channel_id
        }

        /// @notice Set the metadata URI of the sub community
        /// @param sub_community_id The id of the sub community
        /// @param metadata_uri The new metadata URI
        /// @dev Only the owner of the community or a sub community mod can set the metadata URI
        fn set_sub_community_metadata_uri(
            ref self: ComponentState<TContractState>,
            sub_community_id: u256,
            metadata_uri: ByteArray
        ) {
            // validate caller
            self._validate_authorization(get_caller_address(), sub_community_id);

            let mut updated_sub_community: SubCommunityDetails = self
                .sub_communities
                .read(sub_community_id);
            updated_sub_community.sub_community_metadata_uri = metadata_uri;
            self.sub_communities.write(sub_community_id, updated_sub_community);
        }

        /// @notice Set the metadata URI of the channel
        /// @param channel_id The id of the channel
        /// @param metadata_uri The new metadata URI
        /// @dev Only the owner of the community or a sub community mod can set the metadata URI
        fn set_channel_metadata_uri(
            ref self: ComponentState<TContractState>, channel_id: u256, metadata_uri: ByteArray
        ) {
            let sub_community_id = self.get_channel(channel_id).sub_community_id;

            // validate caller
            self._validate_authorization(get_caller_address(), sub_community_id);

            let mut updated_channel: ChannelDetails = self.channels.read(channel_id);
            updated_channel.channel_metadata_uri = metadata_uri;
            self.channels.write(channel_id, updated_channel);
        }

        /// @notice Add a moderator to the sub community
        /// @param sub_community_id The id of the sub_community
        /// @param Array<moderator> The address of the moderator
        /// dev only primary moderator/owner can add the moderators
        fn add_sub_community_mods(
            ref self: ComponentState<TContractState>,
            sub_community_id: u256,
            moderators: Array<ContractAddress>
        ) {
            // validate caller
            self._validate_authorization(get_caller_address(), sub_community_id);

            self._add_sub_community_mods(sub_community_id, moderators);
        }

        /// @notice Remove a moderator from the sub community
        /// @param sub_community_id The id of the sub_community
        /// @param moderator: The address of the moderator
        /// dev only primary moderator/owner can remove the moderators
        fn remove_sub_community_mods(
            ref self: ComponentState<TContractState>,
            sub_community_id: u256,
            moderators: Array<ContractAddress>
        ) {
            // validate caller
            self._validate_authorization(get_caller_address(), sub_community_id);

            self._remove_sub_community_mods(sub_community_id, moderators);
        }


        /// @notice delete a channel
        /// @param channel_id The id of the channel
        fn delete_channel(ref self: ComponentState<TContractState>, channel_id: u256) {
            // check channel exists
            let _channel_id = self.get_channel(channel_id).channel_id;
            assert(channel_id == _channel_id, CHANNEL_DOES_NOT_EXIST);

            // validate caller
            let sub_community_id = self.get_channel(channel_id).sub_community_id;
            self._validate_authorization(get_caller_address(), sub_community_id);

            // update channel details
            let updated_channel = ChannelDetails {
                channel_id: 0, community_id: 0, sub_community_id: 0, channel_metadata_uri: ""
            };

            // update storage
            self.channels.write(channel_id, updated_channel);
            self.is_channel_deleted.write(channel_id, true);

            // emit event
            self
                .emit(
                    ChannelDeleted {
                        channel_id: channel_id,
                        transaction_executor: get_caller_address(),
                        block_timestamp: get_block_timestamp(),
                    }
                );
        }

        /// @notice delete a sub community
        /// @param sub_community_id The id of the sub community
        fn delete_sub_community(ref self: ComponentState<TContractState>, sub_community_id: u256) {
            // check sub community exists
            let sub_community_id = self.sub_communities.read(sub_community_id).sub_community_id;
            assert(sub_community_id != 0, SUB_COMMUNITY_DOES_NOT_EXIST);

            // validate caller
            self._validate_authorization(get_caller_address(), sub_community_id);

            // update channel details
            let updated_sub_community = SubCommunityDetails {
                sub_community_id: 0, community_id: 0, sub_community_metadata_uri: ""
            };

            // update storage
            self.sub_communities.write(sub_community_id, updated_sub_community);
            self.is_sub_community_deleted.write(sub_community_id, true);

            // emit event
            self
                .emit(
                    SubCommunityDeleted {
                        sub_community_id: sub_community_id,
                        transaction_executor: get_caller_address(),
                        block_timestamp: get_block_timestamp(),
                    }
                );
        }

        // *************************************************************************
        //                            GETTERS
        // *************************************************************************

        /// @notice gets the sub community parameters
        /// @param sub_community_id The id of the sub community
        /// @return SubCommunityDetails The sub community parameters
        fn get_sub_community(
            self: @ComponentState<TContractState>, sub_community_id: u256
        ) -> SubCommunityDetails {
            self.sub_communities.read(sub_community_id)
        }

        /// @notice gets the channel parameters
        /// @param channel_id The id of the channel
        /// @return ChannelDetails The channel parameters
        fn get_channel(self: @ComponentState<TContractState>, channel_id: u256) -> ChannelDetails {
            self.channels.read(channel_id)
        }

        /// @notice gets the metadata URI of the sub community
        /// @param sub_community_id The id of the sub community
        /// @return ByteArray The metadata URI
        fn get_sub_community_metadata_uri(
            self: @ComponentState<TContractState>, sub_community_id: u256
        ) -> ByteArray {
            self.sub_communities.read(sub_community_id).sub_community_metadata_uri
        }

        /// @notice gets the metadata URI of the channel
        /// @param channel_id The id of the channel
        /// @return ByteArray The metadata URI
        fn get_channel_metadata_uri(
            self: @ComponentState<TContractState>, channel_id: u256
        ) -> ByteArray {
            self.channels.read(channel_id).channel_metadata_uri
        }

        ///@notice gets the parent community id of a sub community
        /// @param sub_community_id the id of the sub community
        /// @return u256 the community id
        fn get_parent_community_id(
            self: @ComponentState<TContractState>, sub_community_id: u256
        ) -> u256 {
            self.sub_communities.read(sub_community_id).community_id
        }
        /// @notice checks if a profile is a moderator
        /// @param profile addresss to be checked
        /// @param sub_community_id the id of the sub community
        /// @return bool the moderator status
        fn is_sub_community_mod(
            self: @ComponentState<TContractState>, profile: ContractAddress, sub_community_id: u256
        ) -> bool {
            self.sub_community_moderators.read((sub_community_id, profile))
        }

        /// @notice checks if a channel is deleted
        /// @param channel_id id of channel to check
        fn is_channel_deleted(self: @ComponentState<TContractState>, channel_id: u256) -> bool {
            self.is_channel_deleted.read(channel_id)
        }

        /// @notice checks if a sub community is deleted
        /// @param sub_community_id id of sub community to check
        fn is_sub_community_deleted(
            self: @ComponentState<TContractState>, sub_community_id: u256
        ) -> bool {
            self.is_sub_community_deleted.read(sub_community_id)
        }
    }

    // *************************************************************************
    //                            PRIVATE FUNCTIONS
    // *************************************************************************
    #[generate_trait]
    pub impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl Community: CommunityComponent::HasComponent<TContractState>,
        impl Jolt: JoltComponent::HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        /// @notice validates authorization for sub communities
        /// @param sub_community_id id of sub community to validate authorization
        fn _validate_authorization(
            self: @ComponentState<TContractState>, caller: ContractAddress, sub_community_id: u256
        ) {
            let community_id = self.get_sub_community(sub_community_id).community_id;

            let community_instance = get_dep_component!(self, Community);
            let parent_community_owner = community_instance
                .get_community(community_id)
                .community_owner;

            // check caller is parent owner or sub_community mod
            assert(
                parent_community_owner == get_caller_address()
                    || self.is_sub_community_mod(get_caller_address(), sub_community_id),
                UNAUTHORIZED
            );
        }

        /// @notice internal function for adding sub community mod
        /// @param sub_community_id id of sub community
        /// @param moderators array of moderators
        fn _add_sub_community_mods(
            ref self: ComponentState<TContractState>,
            sub_community_id: u256,
            moderators: Array<ContractAddress>
        ) {
            let length = moderators.len();
            let mut index: u32 = 0;

            while index < length {
                let moderator = *moderators.at(index);
                self.sub_community_moderators.write((sub_community_id, moderator), true);

                // emit event
                self
                    .emit(
                        SubCommunityModAdded {
                            sub_community_id: sub_community_id,
                            mod_address: moderator,
                            transaction_executor: get_caller_address(),
                            block_timestamp: get_block_timestamp(),
                        }
                    );
                index += 1;
            };
        }

        /// @notice internal function for removing channel mod
        /// @param channel_id id of channel
        // @param moderators to remove
        fn _remove_sub_community_mods(
            ref self: ComponentState<TContractState>,
            sub_community_id: u256,
            moderators: Array<ContractAddress>
        ) {
            let length = moderators.len();
            let mut index: u32 = 0;

            while index < length {
                let moderator = *moderators.at(index);
                self.sub_community_moderators.write((sub_community_id, moderator), false);

                // emit event
                self
                    .emit(
                        SubCommunityModRemoved {
                            sub_community_id: sub_community_id,
                            mod_address: moderator,
                            transaction_executor: get_caller_address(),
                            block_timestamp: get_block_timestamp()
                        }
                    );
                index += 1;
            };
        }
    }
}
