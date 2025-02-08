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
                @"<svg width=\"200\" height=\"200\" viewBox=\"0 0 52.916665 52.916666\" xmlns=\"http://www.w3.org/2000/svg\"><g>
        <rect fill=\"#ffffff\" stroke=\"none\" width=\"53.535854\" height=\"53.535854\" x=\"-0.32429132\" y=\"0.035320982\"/>
        <path fill=\""
            );

        svg.append(@color_code);
        svg.append(@"\" stroke=\"");
        svg.append(@color_code);

        svg
            .append(
                @"\" stroke-width=\"0.955\" d=\"M47.130838,29.822277 C47.755858,26.905701 48.704862,18.097181 35.544018,16.80482 22.383174,15.51246 4.9011807,14.208279 5.4405627,25.369574 c 0.539376,13.057662 4.9107673,16.996787 9.6009393,18.724629 5.926059,2.183138 21.126177,2.585373 26.537442,-2.349746 3.742541,-3.413228 4.716957,-8.026058 5.551894,-11.92218 z\"/>
        <path
        style=\"display:inline;fill:none;fill-opacity:1;stroke:#ffffff;stroke-width:1.155;stroke-linecap:round;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1\"
        d=\"m 21.792302,35.52765 c 0,0 4.664667,2.84114 9.102005,0.08297\"
        id=\"path23\" />
        <path fill=\"#ffffff\" stroke=\"none\" stroke-width=\"0.674409\" d=\"m18.154168,27.231249 a 2.4755683,2.4755683 0 0 1 -2.456594,2.475495 2.4755683,2.4755683 0 0 1 -2.494252,-2.437547 2.4755683,2.4755683 0 0 1 2.418358,-2.512862 2.4755683,2.4755683 0 0 1 2.531324,2.399027\"/>
        <path fill=\"#ffffff\" stroke=\"none\" stroke-width=\"0.674409\" d=\"m38.577608,27.231249 a 2.4755683,2.4755683 0 0 1 -2.456594,2.475495 2.4755683,2.4755683 0 0 1 -2.494252,-2.437547 2.4755683,2.4755683 0 0 1 2.418358,-2.512862 2.4755683,2.4755683 0 0 1 2.531324,2.399027\"/>
        <text font-weight=\"bold\" font-size=\"6.36386\" x=\"1.8566065\" y=\"10.763453\" transform=\"scale(1.0725055,0.93239615)\"><tspan
            id=\"tspan1\"
            style=\"font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:6.36386px;font-family:'Times New Roman';-inkscape-font-specification:'Times New Roman, ';fill:#000000;fill-opacity:1;stroke:none;stroke-width:0.360786\"
            x=\"1.8566065\"
            y=\"10.763453\" fill=\"#000000\">@"
            );

        svg.append(@local_name.try_into().unwrap());

        svg.append(@"</tspan></text></g></svg>");

        svg
    }
}
