pub mod ProfileTokenUri {
    use coloniz::base::constants::types::ProfileVariants;
    use coloniz::base::utils::byte_array_extra::FeltTryIntoByteArray;
    use coloniz::base::utils::base64_extended::{get_base64_encode};
    use coloniz::base::token_uris::attributes::profile_attributes::profile::gen_profile_attributes;
 
    fn get_attributes(
        profile_variant: ProfileVariants, mint_timestamp: u64
    ) -> ByteArray {
        let timestamp_felt: felt252 = mint_timestamp.into();
        let profile_attributes = gen_profile_attributes(profile_variant);

        let mut attributes: ByteArray = Default::default();
        attributes.append(@"\"attributes\":[");
        attributes.append(@"{\"trait_type\":\"MINT TIMESTAMP\",\"value\":\"");
        attributes.append(@format!("{}", timestamp_felt));
        attributes.append(@"\"},");

        attributes.append(@"{\"trait_type\":\"character\",\"value\":\"");
        attributes.append(@profile_attributes.body);
        attributes.append(@"\"},");

        attributes.append(@"{\"trait_type\":\"background\",\"value\":\"");
        attributes.append(@profile_attributes.background);
        attributes.append(@"\"},");

        attributes.append(@"{\"trait_type\":\"clothing\",\"value\":\"");
        attributes.append(@profile_attributes.cloth);
        attributes.append(@"\"},");

        attributes.append(@"{\"trait_type\":\"face\",\"value\":\"");
        attributes.append(@profile_attributes.face);
        attributes.append(@"\"},");

        attributes.append(@"{\"trait_type\":\"tool\",\"value\":\"");
        attributes.append(@profile_attributes.tool);
        attributes.append(@"\"},");

        attributes.append(@"{\"trait_type\":\"accessory\",\"value\":\"");
        attributes.append(@profile_attributes.accessory);
        attributes.append(@"\"}");

        attributes.append(@"]}");

        attributes
    }

    fn get_json(token_id: u256, image_url: ByteArray) -> ByteArray {
        let profile_json: ByteArray = "{\"name\":\"Profile #";
        let profile_name: ByteArray = format!("{}{}", profile_json, token_id);

        let mut json: ByteArray = Default::default();
        json.append(@profile_name);
        json.append(@"\",\"image\":\"");
        json.append(@image_url);
        json.append(@"\",");
        json
    }

    pub fn get_token_uri(
        profile_variant: ProfileVariants, token_id: u256, mint_timestamp: u64, image_url: ByteArray
    ) -> ByteArray {
        let mut json_byte_array = get_json(token_id, image_url);
        let mut attribute_byte_array = get_attributes(profile_variant, mint_timestamp);

        // tokenuri_to_encode = json + attribute
        let mut tokenuri_to_encode: ByteArray = Default::default();
        tokenuri_to_encode.append(@json_byte_array);
        tokenuri_to_encode.append(@attribute_byte_array);
        let token_uri = get_base64_encode(tokenuri_to_encode);
        token_uri
    }
}
