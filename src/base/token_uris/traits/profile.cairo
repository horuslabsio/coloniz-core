pub mod ProfileSvg {
    use coloniz::base::token_uris::traits::head::head::headSvgStart;
    use coloniz::base::token_uris::traits::back::back::backSvgStart;
    use coloniz::base::token_uris::traits::body::body::bodySvgStart;
    use coloniz::base::token_uris::traits::cloth::cloth::clothSvgStart;
    use coloniz::base::token_uris::traits::background::background::backgroundSvgStart;
    use coloniz::base::token_uris::traits::face::face::faceSvgStart;
    pub fn gen_profile_svg() -> ByteArray {
        let mut profilesvg: ByteArray =
            "<svg width=\"200\" height=\"200\" viewBox=\"0 0 52.917 52.917\" xmlns=\"http://www.w3.org/2000/svg\">";
        profilesvg.append(@backgroundSvgStart());
        // profilesvg.append(@faceSvgStart());
        // profilesvg.append(@glassSvgStart());
        profilesvg.append(@bodySvgStart());
        profilesvg.append(@clothSvgStart());
        profilesvg.append(@headSvgStart());
        profilesvg.append(@backSvgStart());
        profilesvg.append(@faceSvgStart());
        profilesvg.append(@"</svg>");
        profilesvg
    }
}
