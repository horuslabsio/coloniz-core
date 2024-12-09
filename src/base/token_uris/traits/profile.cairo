pub mod head;
pub mod back;
pub mod body;
pub mod cloth;
pub mod background;
pub mod face;

pub mod profile {
    use coloniz::base::constants::types::ProfileVariants;
    use coloniz::base::token_uris::traits::profile::head::head::accessoryVariant;
    use coloniz::base::token_uris::traits::profile::back::back::backVariant;
    use coloniz::base::token_uris::traits::profile::body::body::bodyVariant;
    use coloniz::base::token_uris::traits::profile::cloth::cloth::clothVariant;
    use coloniz::base::token_uris::traits::profile::background::background::backgroundVariant;
    use coloniz::base::token_uris::traits::profile::face::face::faceVariant;

    pub fn gen_profile_svg(profile_variant: ProfileVariants) -> ByteArray {
        let mut profilesvg: ByteArray =
            "<svg width=\"200\" height=\"200\" viewBox=\"0 0 52.917 52.917\" xmlns=\"http://www.w3.org/2000/svg\">";

        profilesvg.append(@backgroundVariant(profile_variant.background));
        profilesvg.append(@bodyVariant(profile_variant.body));
        profilesvg.append(@clothVariant(profile_variant.cloth));
        profilesvg.append(@accessoryVariant(profile_variant.accessory));
        profilesvg.append(@backVariant(profile_variant.tool));
        profilesvg.append(@faceVariant(profile_variant.face));
        profilesvg.append(@"</svg>");
        profilesvg
    }
}
