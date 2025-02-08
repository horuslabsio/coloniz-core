pub mod FollowTokenUri {
    use starknet::ContractAddress;
    use coloniz::base::utils::byte_array_extra::FeltTryIntoByteArray;
    use coloniz::base::utils::base64_extended::get_base64_encode;
    use coloniz::base::token_uris::traits::follow::follow::get_svg_follow;

    pub fn get_token_uri(
        follow_token_id: u256, followed_profile_address: ContractAddress, follow_timestamp: u64
    ) -> ByteArray {
        let baseuri = 'data:image/svg+xml;base64,';

        let mut svg_byte_array: ByteArray = get_svg_follow(follow_token_id);
        let mut svg_encoded: ByteArray = get_base64_encode(svg_byte_array);

        let mut attribute_byte_array: ByteArray = get_attributes(
            follow_token_id, ref svg_encoded, followed_profile_address, follow_timestamp
        );

        let mut token_uri: ByteArray = baseuri.try_into().unwrap();
        token_uri.append(@attribute_byte_array);
        token_uri
    }

    fn get_attributes(
        token_id: u256,
        ref svg_encoded_byteArray: ByteArray,
        followed_profile_address: ContractAddress,
        follow_timestamp: u64
    ) -> ByteArray {
        let token_id_felt: felt252 = token_id.try_into().unwrap();
        let followed_profile_address_felt: felt252 = followed_profile_address.try_into().unwrap();
        let follow_timestamp_felt: felt252 = follow_timestamp.try_into().unwrap();

        let mut attributespre: ByteArray = Default::default();
        let mut attributespost: ByteArray = Default::default();

        attributespre.append(@"{\"name\":\"Follower #");
        attributespre.append(@format!("{}", token_id_felt));
        attributespre.append(@"\",\"description\":\" ");
        attributespre.append(@"Coloniz - Follower #");
        attributespre.append(@format!("{}", token_id_felt));
        attributespre.append(@" of Profile ");
        attributespre.append(@format!("{}", followed_profile_address_felt));
        attributespre.append(@"\",\"image\":\"data:image");
        attributespre.append(@"/svg+xml;base64,");

        //post base64 follow svg
        attributespost.append(@"\",\"attributes\":[{\"display");
        attributespost.append(@"_type\":\"number\",\"trait_type");
        attributespost.append(@"\":\"ID\",\"value\":\"");
        attributespost.append(@format!("{}", token_id_felt));
        attributespost.append(@"\"},{\"trait_type\":\"mint");
        attributespost.append(@"_timestamp\",\"value\":\"");
        attributespost.append(@format!("{}", follow_timestamp_felt));
        attributespost.append(@"\"},{\"trait_type\":\"followed");
        attributespost.append(@"_profile\",\"value\":\"");
        attributespost.append(@format!("{}", followed_profile_address_felt));
        attributespost.append(@"\"}]}");

        attributespre.append(@svg_encoded_byteArray);
        attributespre.append(@attributespost);

        get_base64_encode(attributespre)
    }
}
