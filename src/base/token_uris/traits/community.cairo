pub mod community {
    use coloniz::base::utils::byte_array_extra::FeltTryIntoByteArray;
    use coloniz::base::token_uris::traits::color::colonizColors::get_random_color;

    pub fn get_svg_community(token_id: u256, community_id: u256) -> ByteArray {
        let mut svg: ByteArray = Default::default();

        let color_code: ByteArray = get_random_color(token_id).try_into().unwrap();

        /// construct the SVG as ByteArray
        svg
            .append(
                @"<svg width=\"300\" height=\"300\" viewBox=\"0 0 300 300\" xmlns=\"http://www.w3.org/2000/svg\">
                <rect width=\"300\" height=\"300\" fill=\"white\"/>
                <circle cx=\"150\" cy=\"150\" r=\"60\" fill=\""
            );

        svg.append(@color_code);

        svg
            .append(
                @"\" stroke=\"black\" stroke-width=\"4\"/>
            <circle cx=\"90\" cy=\"120\" r=\"15\" fill=\"black\" stroke=\"black\" stroke-width=\"3\"/>
            <circle cx=\"210\" cy=\"120\" r=\"15\" fill=\"black\" stroke=\"black\" stroke-width=\"3\"/>
            <circle cx=\"120\" cy=\"200\" r=\"15\" fill=\"black\" stroke=\"black\" stroke-width=\"3\"/>
            <circle cx=\"180\" cy=\"200\" r=\"15\" fill=\"black\" stroke=\"black\" stroke-width=\"3\"/>
            <line x1=\"150\" y1=\"150\" x2=\"90\" y2=\"120\" stroke=\"black\" stroke-width=\"3\"/>
            <line x1=\"150\" y1=\"150\" x2=\"210\" y2=\"120\" stroke=\"black\" stroke-width=\"3\"/>
            <line x1=\"150\" y1=\"150\" x2=\"120\" y2=\"200\" stroke=\"black\" stroke-width=\"3\"/>
            <line x1=\"150\" y1=\"150\" x2=\"180\" y2=\"200\" stroke=\"black\" stroke-width=\"3\"/>
            <text x=\"50%\" y=\"270\" font-family=\"Arial\" font-size=\"22\" fill=\"black\" text-anchor=\"middle\" font-weight=\"bold\">COMMUNITY #
        "
            );

        let community_id_to_felt = community_id.into();
        svg.append(@format!("{}", community_id_to_felt));

        svg.append(@"</text>
                    </svg>");

        svg
    }
}
