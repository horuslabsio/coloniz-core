pub mod HandleTokenUri {
    use coloniz::base::utils::byte_array_extra::FeltTryIntoByteArray;
    use coloniz::base::utils::base64_extended::get_base64_encode;
    use coloniz::base::token_uris::traits::handle::handle::get_svg_handle;

    pub fn get_token_uri(token_id: u256, local_name: felt252, namespace: felt252) -> ByteArray {
        let baseuri = 'data:image/svg+xml;base64,';

        let mut svg_byte_array: ByteArray = get_svg_handle(token_id, local_name);
        let mut svg_encoded: ByteArray = get_base64_encode(svg_byte_array);

        let mut attribute_byte_array: ByteArray = get_attributes(
            token_id, ref svg_encoded, local_name, namespace
        );

        let mut token_uri: ByteArray = baseuri.try_into().unwrap();
        token_uri.append(@attribute_byte_array);
        token_uri
    }

    fn get_attributes(
        token_id: u256,
        ref svg_encoded_byteArray: ByteArray,
        local_name: felt252,
        namespace: felt252
    ) -> ByteArray {
        let token_id_to_felt: felt252 = token_id.low.into();

        let mut attributespre: ByteArray = Default::default();
        let mut attributespost: ByteArray = Default::default();

        attributespre.append(@"{\"name\":\"@");
        attributespre.append(@local_name.try_into().unwrap());
        attributespre.append(@"\",\"description\":\" ");
        attributespre.append(@"Coloniz - Handle @");
        attributespre.append(@local_name.try_into().unwrap());
        attributespre.append(@"\",\"image\":\"data:image");
        attributespre.append(@"/svg+xml;base64,");

        attributespost.append(@"\",\"attributes\":[{\"display");
        attributespost.append(@"_type\":\"number\",\"trait_type");
        attributespost.append(@"\":\"ID\",\"value\":\"");
        attributespost.append(@format!("{}", token_id_to_felt));
        attributespost.append(@"\"},{\"trait_type\":\"NAMES");
        attributespost.append(@"PACE\",\"value\":\"");
        attributespost.append(@namespace.try_into().unwrap());
        attributespost.append(@"\"}]}");

        attributespre.append(@svg_encoded_byteArray);
        attributespre.append(@attributespost);

        get_base64_encode(attributespre)
    }
}

