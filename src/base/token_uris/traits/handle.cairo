pub mod handle {
    use coloniz::base::utils::byte_array_extra::FeltTryIntoByteArray;
    use coloniz::base::token_uris::traits::color::colonizColors::get_random_color;

    pub fn get_svg_handle(token_id: u256, local_name: felt252) -> ByteArray {
        let mut svg: ByteArray = Default::default();

        let local_name_to_u256: u256 = local_name.try_into().unwrap();
        let color_code: ByteArray = get_random_color(local_name_to_u256).try_into().unwrap();

        /// construct the SVG as ByteArray
        svg
            .append(
                @"<svg width=\"300\" height=\"300\" viewBox=\"0 0 300 300\" xmlns=\"http://www.w3.org/2000/svg\">
                <rect width=\"300\" height=\"300\" fill=\""
            );

        svg.append(@color_code);

        svg
            .append(
                @"\"/> <rect x=\"40\" y=\"80\" width=\"220\" height=\"120\" rx=\"20\" ry=\"20\" fill=\"white\" stroke=\"black\" stroke-width=\"3\"/>
        <polygon points=\"100,200 130,200 110,220\" fill=\"white\" stroke=\"black\" stroke-width=\"3\"/>
        <rect x=\"105\" y=\"110\" width=\"90\" height=\"60\" rx=\"30\" ry=\"30\" fill=\"
        "
            );

        svg.append(@color_code);

        svg
            .append(
                @"\"/>
                <circle cx=\"125\" cy=\"140\" r=\"8\" fill=\"white\"/>
                <circle cx=\"175\" cy=\"140\" r=\"8\" fill=\"white\"/>
                <text x=\"50%\" y=\"250\" font-family=\"Arial\" font-size=\"22\" fill=\"white\" text-anchor=\"middle\" font-weight=\"bold\">@
                "
            );

        svg.append(@local_name.try_into().unwrap());

        svg.append(@"</text>
                    </svg>");

        svg
    }
}
