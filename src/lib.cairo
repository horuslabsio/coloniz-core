pub mod coloniznft;
pub mod interfaces;
pub mod profile;
pub mod base;
pub mod follownft;
pub mod mocks;
pub mod publication;
pub mod namespaces;
pub mod presets;
pub mod hub;
pub mod jolt;
pub mod community;
pub mod channel;

use coloniz::base::token_uris::profile_token_uri::ProfileTokenUri::get_token_uri;
use coloniz::base::constants::types::{ ProfileVariants, AccessoryVariants, FaceVariants, ClothVariants, BackgroundVariants, BodyVariants, ToolVariants };

fn main() {
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
    println!("{:?}", token_uri);
}