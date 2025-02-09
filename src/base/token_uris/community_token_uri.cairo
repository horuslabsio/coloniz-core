pub mod CommunityTokenUri {
    use coloniz::base::utils::byte_array_extra::FeltTryIntoByteArray;
    use coloniz::base::utils::base64_extended::get_base64_encode;
    use coloniz::base::token_uris::traits::community::community::get_svg_community;

    pub fn get_token_uri(token_id: u256, community_id: u256, timestamp: u64) -> ByteArray {
        let baseuri = 'data:image/svg+xml;base64,';

        let mut svg_byte_array: ByteArray = get_svg_community(token_id, community_id);
        let mut svg_encoded: ByteArray = get_base64_encode(svg_byte_array);

        let mut attribute_byte_array: ByteArray = get_attributes(
            token_id, ref svg_encoded, community_id, timestamp
        );

        let mut token_uri: ByteArray = baseuri.try_into().unwrap();
        token_uri.append(@attribute_byte_array);
        token_uri
    }

    fn get_attributes(
        token_id: u256, ref svg_encoded_byteArray: ByteArray, community_id: u256, timestamp: u64
    ) -> ByteArray {
        let token_id_to_felt: felt252 = token_id.low.into();
        let community_id_to_felt: felt252 = community_id.low.into();
        let timestamp_to_felt: felt252 = timestamp.try_into().unwrap();

        let mut attributespre: ByteArray = Default::default();
        let mut attributespost: ByteArray = Default::default();

        attributespre.append(@"{\"name\":\"Community #");
        attributespre.append(@format!("{}", community_id_to_felt));
        attributespre.append(@"\",\"description\":\" ");
        attributespre.append(@"Coloniz - #");
        attributespre.append(@format!("{}", token_id_to_felt));
        attributespre.append(@" of Community ");
        attributespre.append(@format!("{}", community_id_to_felt));
        attributespre.append(@"\",\"image\":\"data:image");
        attributespre.append(@"/svg+xml;base64,");

        //post base64 follow svg
        attributespost.append(@"\",\"attributes\":[{\"display");
        attributespost.append(@"_type\":\"number\",\"trait_type");
        attributespost.append(@"\":\"ID\",\"value\":\"");
        attributespost.append(@format!("{}", token_id_to_felt));
        attributespost.append(@"\"},{\"trait_type\":\"mint");
        attributespost.append(@"_timestamp\",\"value\":\"");
        attributespost.append(@format!("{}", timestamp_to_felt));
        attributespost.append(@"\"},{\"trait_type\":\"community");
        attributespost.append(@"_id\",\"value\":\"");
        attributespost.append(@format!("{}", community_id_to_felt));
        attributespost.append(@"\"}]}");

        attributespre.append(@svg_encoded_byteArray);
        attributespre.append(@attributespost);

        get_base64_encode(attributespre)
    }
}

