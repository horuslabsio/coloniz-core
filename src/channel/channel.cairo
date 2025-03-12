#[starknet::component]
pub mod ChannelComponent {
    // *************************************************************************
    //                            IMPORT
    // *************************************************************************
    use core::clone::Clone;
    use core::starknet::{
        ContractAddress, contract_address_const, get_caller_address, get_block_timestamp
    };
    use starknet::storage::{
        StoragePointerWriteAccess, Map, StorageMapReadAccess, StorageMapWriteAccess
    };
    use openzeppelin_access::ownable::OwnableComponent;

    use coloniz::jolt::jolt::JoltComponent;
    use coloniz::community::community::CommunityComponent;
    use coloniz::interfaces::{IChannel::IChannel, ICommunity::ICommunity,};
    use coloniz::base::{
        constants::errors::Errors::{
            NOT_CHANNEL_OWNER, ALREADY_MEMBER, NOT_CHANNEL_MEMBER, NOT_COMMUNITY_MEMBER,
            BANNED_FROM_CHANNEL, CHANNEL_HAS_NO_MEMBER, UNAUTHORIZED, INVALID_LENGTH,
            COMMUNITY_DOES_NOT_EXIST, NOT_CHANNEL_MODERATOR, CHANNEL_ALREADY_EXISTS, CHANNEL_DOES_NOT_EXIST
        },
        constants::types::{ChannelDetails, ChannelMember}
    };

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    pub struct Storage {
        channels: Map<u256, ChannelDetails>,
        channel_counter: u256,
        channel_initialized: Map<u256, bool>, // tracks if a channel id has been used or not
        channel_members: Map<(u256, ContractAddress), ChannelMember>,
        channel_moderators: Map<(u256, ContractAddress), bool>,
        channel_ban_status: Map<(u256, ContractAddress), bool>,
        is_channel_deleted: Map<u256, bool>
    }

    // *************************************************************************
    //                              EVENTS
    // *************************************************************************
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        ChannelCreated: ChannelCreated,
        JoinedChannel: JoinedChannel,
        LeftChannel: LeftChannel,
        ChannelModAdded: ChannelModAdded,
        ChannelModRemoved: ChannelModRemoved,
        ChannelBanStatusUpdated: ChannelBanStatusUpdated,
        ChannelDeleted: ChannelDeleted
    }

    #[derive(Drop, starknet::Event)]
    pub struct ChannelCreated {
        pub channel_id: u256,
        pub community_id: u256,
        pub channel_owner: ContractAddress,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct JoinedChannel {
        pub channel_id: u256,
        pub transaction_executor: ContractAddress,
        pub profile: ContractAddress,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct LeftChannel {
        pub channel_id: u256,
        pub transaction_executor: ContractAddress,
        pub profile: ContractAddress,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ChannelModAdded {
        pub channel_id: u256,
        pub transaction_executor: ContractAddress,
        pub mod_address: ContractAddress,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ChannelModRemoved {
        pub channel_id: u256,
        pub transaction_executor: ContractAddress,
        pub mod_address: ContractAddress,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ChannelBanStatusUpdated {
        pub channel_id: u256,
        pub transaction_executor: ContractAddress,
        pub profile: ContractAddress,
        pub ban_status: bool,
        pub block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ChannelDeleted {
        pub channel_id: u256,
        pub channel_owner: ContractAddress,
        pub block_timestamp: u64,
    }


    // *************************************************************************
    //                              EXTERNAL FUNCTIONS
    // *************************************************************************
    #[embeddable_as(colonizChannel)]
    impl ChannelImpl<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl Community: CommunityComponent::HasComponent<TContractState>,
        impl Jolt: JoltComponent::HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>
    > of IChannel<ComponentState<TContractState>> {
        /// @notice creates a new channel
        fn create_channel(
            ref self: ComponentState<TContractState>, channel_id: u256, community_id: u256
        ) -> u256 {
            let channel_owner = get_caller_address();

            // check channel id does not already exist
            let channel_initialized = self.channel_initialized.read(channel_id);
            assert(channel_initialized == false, CHANNEL_ALREADY_EXISTS);

            // check that community exists
            let community_instance = get_dep_component!(@self, Community);
            let _community_id = community_instance.get_community(community_id).community_id;
            assert(community_id == _community_id, COMMUNITY_DOES_NOT_EXIST);

            let (membership_status, _) = community_instance
                .is_community_member(channel_owner, community_id);
            assert(membership_status, NOT_COMMUNITY_MEMBER);

            let new_channel = ChannelDetails {
                channel_id: channel_id,
                community_id: community_id,
                channel_owner: channel_owner,
                channel_metadata_uri: "",
                channel_total_members: 0,
                channel_censorship: false,
            };

            // update storage
            self.channels.write(channel_id, new_channel.clone());
            self.channel_initialized.write(channel_id, true);
            self.channel_counter.write(channel_id);

            // include channel owner as first member
            self._join_channel(channel_owner, channel_id);

            // emit event
            self
                .emit(
                    ChannelCreated {
                        channel_id: new_channel.channel_id,
                        community_id: community_id,
                        channel_owner: new_channel.channel_owner,
                        block_timestamp: get_block_timestamp(),
                    }
                );

            channel_id
        }

        /// @notice adds a new user to a channel
        /// @param channel_id id of channel to be joined
        fn join_channel(ref self: ComponentState<TContractState>, channel_id: u256) {
            let profile = get_caller_address();

            // check user is not already a channel member and wasn't previously banned
            let (is_channel_member, _) = self.is_channel_member(profile, channel_id);
            let is_banned = self.get_channel_ban_status(profile, channel_id);
            assert(!is_banned, BANNED_FROM_CHANNEL);
            assert(!is_channel_member, ALREADY_MEMBER);

            // join channel
            self._join_channel(profile, channel_id);
        }

        /// @notice removes a member from a channel
        /// @param channel_id id of channel to be left
        fn leave_channel(ref self: ComponentState<TContractState>, channel_id: u256) {
            let mut channel = self.channels.read(channel_id);
            let profile = get_caller_address();

            // check that profile is a channel member
            let (is_channel_member, _) = self.is_channel_member(profile, channel_id);
            assert(is_channel_member, NOT_CHANNEL_MEMBER);

            // check that channel has members
            let total_members: u256 = channel.channel_total_members;
            assert(total_members > 1, CHANNEL_HAS_NO_MEMBER);

            // update storage
            self
                .channel_members
                .write(
                    (channel_id, profile),
                    ChannelMember {
                        profile: contract_address_const::<0>(), channel_id: 0, total_publications: 0
                    }
                );

            channel.channel_total_members -= 1;
            self.channels.write(channel_id, channel);

            // emit event
            self
                .emit(
                    LeftChannel {
                        channel_id: channel_id,
                        transaction_executor: get_caller_address(),
                        profile: profile,
                        block_timestamp: get_block_timestamp(),
                    }
                )
        }

        /// @notice Set the metadata URI of the channel
        /// @param channel_id The id of the channel
        /// @param metadata_uri The new metadata URI
        /// @dev Only the owner of the channel or a mod can set the metadata URI
        fn set_channel_metadata_uri(
            ref self: ComponentState<TContractState>, channel_id: u256, metadata_uri: ByteArray
        ) {
            let channel_member: ChannelDetails = self.channels.read(channel_id);
            assert(
                channel_member.channel_owner == get_caller_address()
                    || self.is_channel_mod(get_caller_address(), channel_id),
                UNAUTHORIZED
            );
            let mut channel: ChannelDetails = self.channels.read(channel_id);
            channel.channel_metadata_uri = metadata_uri;
            self.channels.write(channel_id, channel);
        }

        /// @notice Add a moderator to the channel
        /// @param channel_id: The id of the channel
        /// @param Array<moderator> The address of the moderator
        /// dev only primary moderator/owner can add the moderators
        fn add_channel_mods(
            ref self: ComponentState<TContractState>,
            channel_id: u256,
            moderators: Array<ContractAddress>
        ) {
            assert(
                self.channels.read(channel_id).channel_owner == get_caller_address(),
                NOT_CHANNEL_OWNER
            );

            self._add_channel_mods(channel_id, moderators);
        }

        /// @notice Remove a moderator from the channel
        /// @param channel_id: The id of the channel
        /// @param moderator: The address of the moderator
        /// dev only primary moderator/owner can remove the moderators
        fn remove_channel_mods(
            ref self: ComponentState<TContractState>,
            channel_id: u256,
            moderators: Array<ContractAddress>
        ) {
            assert(
                self.channels.read(channel_id).channel_owner == get_caller_address(),
                NOT_CHANNEL_OWNER
            );

            self._remove_channel_mods(channel_id, moderators);
        }

        /// @notice Set the censorship status of the channel
        /// @param channel_id The id of the channel
        fn set_channel_censorship_status(
            ref self: ComponentState<TContractState>, channel_id: u256, censorship_status: bool
        ) {
            let mut channel = self.channels.read(channel_id);

            // check caller is owner
            assert(channel.channel_owner == get_caller_address(), NOT_CHANNEL_OWNER);

            // update storage
            channel.channel_censorship = censorship_status;
            self.channels.write(channel_id, channel);
        }

        /// @notice set the ban status of a profile in the channel
        /// @param channel_id The id of the channel
        /// @param profile The address of the profile
        /// @param ban_status The ban status of the profile
        fn set_channel_ban_status(
            ref self: ComponentState<TContractState>,
            channel_id: u256,
            profiles: Array<ContractAddress>,
            ban_statuses: Array<bool>
        ) {
            let mut channel = self.channels.read(channel_id);

            // check caller is owner or mod
            assert(
                channel.channel_owner == get_caller_address()
                    || self.is_channel_mod(get_caller_address(), channel_id),
                UNAUTHORIZED
            );

            self._set_ban_status(channel_id, profiles, ban_statuses);
        }

        /// @notice delete a channel
        /// @param channel_id The id of the channel
        fn delete_channel(
            ref self: ComponentState<TContractState>,
            channel_id: u256
        ) {
            // check channel exists
            let _channel_id = self.get_channel(channel_id).channel_id;
            assert(channel_id == _channel_id, CHANNEL_DOES_NOT_EXIST);

            // check caller is owner
            let mut channel = self.channels.read(channel_id);
            assert(channel.channel_owner == get_caller_address(), UNAUTHORIZED);

            // update channel details
            let updated_channel = ChannelDetails {
                channel_id: 0,
                community_id: 0,
                channel_owner: 0.try_into().unwrap(),
                channel_metadata_uri: "",
                channel_total_members: 0,
                channel_censorship: false,
            };

            // update storage
            self.channels.write(channel_id, updated_channel);
            self.is_channel_deleted.write(channel_id, true);

            // emit event
            self
                .emit(
                    ChannelDeleted {
                        channel_id: channel_id,
                        channel_owner: get_caller_address(),
                        block_timestamp: get_block_timestamp(),
                    }
                );
        }

        /// @notice gets the channel parameters
        /// @param channel_id The id of the channel
        /// @return ChannelDetails The channel parameters
        fn get_channel(self: @ComponentState<TContractState>, channel_id: u256) -> ChannelDetails {
            self.channels.read(channel_id)
        }

        /// @notice gets the metadata URI of the channel
        /// @param channel_id The id of the channel
        /// @return ByteArray The metadata URI
        fn get_channel_metadata_uri(
            self: @ComponentState<TContractState>, channel_id: u256
        ) -> ByteArray {
            self.channels.read(channel_id).channel_metadata_uri
        }

        /// @notice checks if the profile is a member of the channel
        /// @param profile the address of the profile
        /// @param channel_id the id of the channel
        /// @return bool the profile membership status
        fn is_channel_member(
            self: @ComponentState<TContractState>, profile: ContractAddress, channel_id: u256
        ) -> (bool, ChannelMember) {
            let channel_member: ChannelMember = self.channel_members.read((channel_id, profile));
            if (channel_member.channel_id == channel_id) {
                (true, channel_member)
            } else {
                (false, channel_member)
            }
        }

        /// @notice gets the total number of members in a channel
        /// @param channel_id the id of the channel
        /// @return u256 the number of members in a channel
        fn get_total_channel_members(
            self: @ComponentState<TContractState>, channel_id: u256
        ) -> u256 {
            self.channels.read(channel_id).channel_total_members
        }

        ///@notice gets the community id of a channel
        /// @param channel_id the id of the channel
        /// @return u256 the community id
        fn get_channel_community(self: @ComponentState<TContractState>, channel_id: u256) -> u256 {
            self.channels.read(channel_id).community_id
        }
        /// @notice checks if a profile is a moderator
        /// @param profile addresss to be checked
        /// @param channel_id the id of the channel
        /// @return bool the moderator status
        fn is_channel_mod(
            self: @ComponentState<TContractState>, profile: ContractAddress, channel_id: u256
        ) -> bool {
            self.channel_moderators.read((channel_id, profile))
        }

        /// @notice checks if a channel is censored
        /// @param channel_id the id of the channel
        /// @return bool the censorship status
        fn get_channel_censorship_status(
            self: @ComponentState<TContractState>, channel_id: u256
        ) -> bool {
            self.channels.read(channel_id).channel_censorship
        }

        /// @notice checks if a profile is banned
        /// @param profile addresss to be checked
        /// @param channel_id the id of the channel
        /// @return bool the ban status
        fn get_channel_ban_status(
            self: @ComponentState<TContractState>, profile: ContractAddress, channel_id: u256
        ) -> bool {
            self.channel_ban_status.read((channel_id, profile))
        }

        /// @notice checks if a channel is deleted
        /// @param channel_id id of channel to check
        fn is_channel_deleted(
            self: @ComponentState<TContractState>, channel_id: u256
        ) -> bool {
            self.is_channel_deleted.read(channel_id)
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
        /// @notice initalizes channel component
        /// @param channel_nft_classhash classhash of channel NFT
        fn _initializer(ref self: ComponentState<TContractState>) {
            self.channel_counter.write(0);
        }

        /// @notice internal function to join a channel
        /// @param profile address to add to the channel
        /// @param channel_id id of the channel to be joined
        fn _join_channel(
            ref self: ComponentState<TContractState>, profile: ContractAddress, channel_id: u256
        ) {
            let mut channel: ChannelDetails = self.channels.read(channel_id);

            // check that user is a member of the community this channel belongs to
            let community_instance = get_dep_component!(@self, Community);
            let (membership_status, _) = community_instance
                .is_community_member(profile, channel.community_id);
            assert(membership_status, NOT_COMMUNITY_MEMBER);

            let channel_member = ChannelMember {
                profile: profile, channel_id: channel_id, total_publications: 0,
            };

            // update storage
            channel.channel_total_members += 1;
            self.channels.write(channel_id, channel);
            self.channel_members.write((channel_id, profile), channel_member);

            // emit events
            self
                .emit(
                    JoinedChannel {
                        channel_id: channel_id,
                        transaction_executor: get_caller_address(),
                        profile: profile,
                        block_timestamp: get_block_timestamp(),
                    }
                )
        }

        /// @notice internal function for adding channel mod
        /// @param channel_id id of channel
        /// @param moderators array of moderators
        fn _add_channel_mods(
            ref self: ComponentState<TContractState>,
            channel_id: u256,
            moderators: Array<ContractAddress>
        ) {
            let length = moderators.len();
            let mut index: u32 = 0;

            while index < length {
                let moderator = *moderators.at(index);

                // check moderator is a channel member
                let (is_channel_member, _) = self.is_channel_member(moderator, channel_id);
                assert(is_channel_member == true, NOT_CHANNEL_MEMBER);

                self.channel_moderators.write((channel_id, moderator), true);

                // emit event
                self
                    .emit(
                        ChannelModAdded {
                            channel_id: channel_id,
                            transaction_executor: get_caller_address(),
                            mod_address: moderator,
                            block_timestamp: get_block_timestamp(),
                        }
                    );
                index += 1;
            };
        }

        /// @notice internal function for removing channel mod
        /// @param channel_id id of channel
        // @param moderators to remove
        fn _remove_channel_mods(
            ref self: ComponentState<TContractState>,
            channel_id: u256,
            moderators: Array<ContractAddress>
        ) {
            let length = moderators.len();
            let mut index: u32 = 0;

            while index < length {
                let moderator = *moderators.at(index);

                // check that profile is a moderator
                let is_moderator = self.is_channel_mod(moderator, channel_id);
                assert(is_moderator, NOT_CHANNEL_MODERATOR);

                self.channel_moderators.write((channel_id, moderator), false);

                // emit event
                self
                    .emit(
                        ChannelModRemoved {
                            channel_id: channel_id,
                            mod_address: moderator,
                            transaction_executor: get_caller_address(),
                            block_timestamp: get_block_timestamp()
                        }
                    );
                index += 1;
            };
        }

        /// @notice internal function for set ban status for members
        /// @param channel_id id of channel to be banned or unbanned
        /// @param profiles addresses
        /// @param ban_statuses bool values
        fn _set_ban_status(
            ref self: ComponentState<TContractState>,
            channel_id: u256,
            profiles: Array<ContractAddress>,
            ban_statuses: Array<bool>
        ) {
            assert(profiles.len() == ban_statuses.len(), INVALID_LENGTH);
            let length = profiles.len();
            let mut index: u32 = 0;

            while index < length {
                let profile = *profiles[index];
                let ban_status = *ban_statuses[index];
                let (is_channel_member, _) = self.is_channel_member(profile, channel_id);
                assert(is_channel_member == true, NOT_CHANNEL_MEMBER);
                self.channel_ban_status.write((channel_id, profile), ban_status);

                self
                    .emit(
                        ChannelBanStatusUpdated {
                            channel_id: channel_id,
                            transaction_executor: get_caller_address(),
                            profile: profile,
                            ban_status: ban_status,
                            block_timestamp: get_block_timestamp()
                        }
                    );
                index += 1;
            };
        }
    }
}
