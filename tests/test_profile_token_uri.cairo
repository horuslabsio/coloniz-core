use coloniz::base::token_uris::profile_token_uri::ProfileTokenUri::get_token_uri;
use coloniz::base::constants::types::{
    ProfileVariants, AccessoryVariants, FaceVariants, ClothVariants, BackgroundVariants,
    BodyVariants, ToolVariants
};

#[test]
fn test_profile_token_uri() {
    let profile_variant = ProfileVariants {
        body: BodyVariants::BODY1,
        tool: ToolVariants::TOOL1,
        background: BackgroundVariants::BACKGROUND1,
        cloth: ClothVariants::CLOTH1,
        face: FaceVariants::FACE1,
        accessory: AccessoryVariants::ACCESSORY1
    };

    let base_uri: ByteArray = "https://api.coloniz.com/images/";
    let image_url = format!("{}{}", base_uri, 1);
    let token_uri: ByteArray = get_token_uri(profile_variant, 1, 3, image_url);
    let expected_token_uri: ByteArray =
        "eyJuYW1lIjoiUHJvZmlsZSAjMSIsImltYWdlIjoiaHR0cHM6Ly9hcGkuY29sb25pei5jb20vaW1hZ2VzLzEiLCJhdHRyaWJ1dGVzIjpbeyJ0cmFpdF90eXBlIjoiTUlOVCBUSU1FU1RBTVAiLCJ2YWx1ZSI6IjMifSx7InRyYWl0X3R5cGUiOiJjaGFyYWN0ZXIiLCJ2YWx1ZSI6IllFTExPVyBDT0xPTklTVCJ9LHsidHJhaXRfdHlwZSI6ImJhY2tncm91bmQiLCJ2YWx1ZSI6IlBFQUNIIn0seyJ0cmFpdF90eXBlIjoiY2xvdGhpbmciLCJ2YWx1ZSI6IlNXRUFURVIifSx7InRyYWl0X3R5cGUiOiJmYWNlIiwidmFsdWUiOiJST1VORCBFWUVTIn0seyJ0cmFpdF90eXBlIjoidG9vbCIsInZhbHVlIjoiQkxVRSBGTEFHIn0seyJ0cmFpdF90eXBlIjoiYWNjZXNzb3J5IiwidmFsdWUiOiJCTFVFIE1BU0sifV19";

    assert(token_uri == expected_token_uri, 'invalid token uri');
}
