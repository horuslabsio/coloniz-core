// let make the face of the profile svg

pub mod background {
    use coloniz::base::utils::byte_array_extra::FeltTryIntoByteArray;

    #[derive(Drop)]
    enum BackgroundVariants {
        BACKGROUND1, // 1
        BACKGROUND2, // 2
        BACKGROUND3, // 3
        BACKGROUND4, // 4
        BACKGROUND5, // 5 
    }

    pub fn backgroundSvgStart() -> ByteArray {
        getBackgroundVariant(BackgroundVariants::BACKGROUND2)
    }

    pub fn getBackgroundVariant(backgroundVariant: BackgroundVariants) -> ByteArray {
        let mut decidedbackground: ByteArray = Default::default();
        match backgroundVariant {
            BackgroundVariants::BACKGROUND1 => {
                decidedbackground =
                    "<rect style=\"display:inline;fill:#de8174;fill-opacity:1;stroke-width:.02627\" width=\"53.114\" height=\"53.52\" x=\".007\" y=\"-.277\" ry=\"0\"/>"
            },
            BackgroundVariants::BACKGROUND2 => {
                decidedbackground =
                    "<rect style=\"display:inline;fill:#db8956;fill-opacity:1;stroke-width:.02627\" width=\"53.114\" height=\"53.52\" x=\".007\" y=\"-.277\" ry=\"0\"/>"
            },
            BackgroundVariants::BACKGROUND3 => {
                decidedbackground =
                    "<rect style=\"display:inline;fill:#eeb100;fill-opacity:1;stroke-width:.02627\" width=\"53.114\" height=\"53.52\" x=\".007\" y=\"-.277\" ry=\"0\"/>"
            },
            BackgroundVariants::BACKGROUND4 => {
                decidedbackground =
                    "<rect style=\"display:inline;fill:#005d80;fill-opacity:1;stroke-width:.02627\" width=\"53.114\" height=\"53.52\" x=\".007\" y=\"-.277\" ry=\"0\"/>"
            },
            BackgroundVariants::BACKGROUND5 => {
                decidedbackground =
                    "<rect style=\"display:inline;fill:teal;fill-opacity:1;stroke-width:.02627\" width=\"53.114\" height=\"53.52\" x=\".007\" y=\"-.277\" ry=\"0\"/>"
            },
        }
        decidedbackground
    }
}
