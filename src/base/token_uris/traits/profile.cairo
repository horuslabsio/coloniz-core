pub mod head;
pub mod back;
pub mod body;
pub mod cloth;
pub mod background;
pub mod face;

pub mod profile {
    use coloniz::base::token_uris::traits::profile::head::head::headSvgStart;
    use coloniz::base::token_uris::traits::profile::back::back::backSvgStart;
    use coloniz::base::token_uris::traits::profile::body::body::bodySvgStart;
    use coloniz::base::token_uris::traits::profile::cloth::cloth::clothSvgStart;
    use coloniz::base::token_uris::traits::profile::background::background::backgroundSvgStart;
    use coloniz::base::token_uris::traits::profile::face::face::faceSvgStart;
    pub fn gen_profile_svg() -> ByteArray {
        let mut profilesvg: ByteArray =
            "<svg width=\"200\" height=\"200\" viewBox=\"0 0 52.917 52.917\" xmlns=\"http://www.w3.org/2000/svg\">";
        profilesvg.append(@backgroundSvgStart());
        profilesvg.append(@bodySvgStart());
        profilesvg.append(@clothSvgStart());
        profilesvg.append(@headSvgStart());
        profilesvg.append(@backSvgStart());
        profilesvg.append(@faceSvgStart());
        profilesvg.append(@"</svg>");
        profilesvg
    }
}
