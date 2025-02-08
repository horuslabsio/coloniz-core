pub mod follow {
    use coloniz::base::utils::byte_array_extra::FeltTryIntoByteArray;
    use coloniz::base::token_uris::traits::color::colonizColors::get_random_color;

    pub fn get_svg_follow(token_id: u256) -> ByteArray {
        let mut svg: ByteArray = Default::default();

        let color_code: ByteArray = get_random_color(token_id).try_into().unwrap();

        /// construct the SVG as ByteArray
        svg
            .append(
                @"<svg width=\"300\" height=\"300\" viewBox=\"0 0 300 300\" xmlns=\"http://www.w3.org/2000/svg\">
                <rect width=\"300\" height=\"300\" fill=\"black\"/>
                <rect x=\"75\" y=\"90\" width=\"150\" height=\"100\" rx=\"40\" ry=\"40\" fill=\""
            );

        svg.append(@color_code);

        svg.append(@"\" stroke=\"black\" stroke-width=\"4\"/>
                <circle cx=\"115\" cy=\"140\" r=\"10\" fill=\"black\"/>
                <circle cx=\"185\" cy=\"140\" r=\"10\" fill=\"black\"/>
                <circle cx=\"70\" cy=\"150\" r=\"20\" fill=\"none\" stroke=\"white\" stroke-width=\"4\"/>
                <circle cx=\"230\" cy=\"150\" r=\"20\" fill=\"none\" stroke=\"white\" stroke-width=\"4\"/>
                <line x1=\"90\" y1=\"150\" x2=\"210\" y2=\"150\" stroke=\"white\" stroke-width=\"4\"/>
                <text x=\"50%\" y=\"270\" font-family=\"Arial\" font-size=\"24\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">
        ");

        let token_id_to_felt = token_id.into();
        svg.append(@format!("{}", token_id_to_felt));

        svg.append(@"</text>
                    </svg>");

        svg
    }
}
