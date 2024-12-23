pub mod profile {
    use coloniz::base::constants::types::{
        ProfileVariants, AccessoryVariants, FaceVariants, ClothVariants, BackgroundVariants,
        BodyVariants, ToolVariants
    };

    #[derive(Drop)]
    pub struct ProfileAttributes {
        pub tool: ByteArray,
        pub body: ByteArray,
        pub background: ByteArray,
        pub cloth: ByteArray,
        pub face: ByteArray,
        pub accessory: ByteArray
    }

    fn get_back_attribute(tool: ToolVariants) -> ByteArray {
        match tool {
            ToolVariants::TOOL1 => "BLUE FLAG",
            ToolVariants::TOOL2 => "BLUE GOLFSTICK",
            ToolVariants::TOOL3 => "FISHING ROD",
            ToolVariants::TOOL4 => "RED FLAG",
            ToolVariants::TOOL5 => "STYLIZED BATON",
            ToolVariants::TOOL6 => "WHITE GOLFSTICK",
            ToolVariants::EMPTY => ""
        }
    }

    fn get_body_attribute(body: BodyVariants) -> ByteArray {
        match body {
            BodyVariants::BODY1 => "YELLOW COLONIST",
            BodyVariants::BODY2 => "WHITE COLONIST",
            BodyVariants::BODY3 => "SMOKEWHITE COLONIST",
            BodyVariants::BODY4 => "BLUE COLONIST",
            BodyVariants::BODY5 => "OFFWHITE COLONIST",
            BodyVariants::BODY6 => "BEIGE COLONIST",
            BodyVariants::BODY7 => "GREY COLONIST"
        }
    }

    fn get_background_attribute(background: BackgroundVariants) -> ByteArray {
        match background {
            BackgroundVariants::BACKGROUND1 => "PEACH",
            BackgroundVariants::BACKGROUND2 => "BROWN",
            BackgroundVariants::BACKGROUND3 => "GOLD",
            BackgroundVariants::BACKGROUND4 => "BLUE",
            BackgroundVariants::BACKGROUND5 => "GREEN",
            BackgroundVariants::EMPTY => ""
        }
    }

    fn get_cloth_attribute(cloth: ClothVariants) -> ByteArray {
        match cloth {
            ClothVariants::CLOTH1 => "SWEATER",
            ClothVariants::CLOTH2 => "BLUE WEAR",
            ClothVariants::CLOTH3 => "RED WEAR",
            ClothVariants::CLOTH4 => "ORANGE WEAR",
            ClothVariants::CLOTH5 => "PINK WEAR",
            ClothVariants::EMPTY => ""
        }
    }

    fn get_face_attribute(face: FaceVariants) -> ByteArray {
        match face {
            FaceVariants::FACE1 => "ROUND EYES",
            FaceVariants::FACE2 => "FROWN",
            FaceVariants::FACE3 => "SMILE",
            FaceVariants::FACE4 => "IN LOVE",
            FaceVariants::FACE5 => "EXCITED",
            FaceVariants::FACE6 => "PROUD",
            FaceVariants::FACE7 => "WELCOMING",
            FaceVariants::FACE8 => "HAPPY"
        }
    }

    fn get_accessory_attribute(accessory: AccessoryVariants) -> ByteArray {
        match accessory {
            AccessoryVariants::ACCESSORY1 => "BLUE MASK",
            AccessoryVariants::ACCESSORY2 => "CAP",
            AccessoryVariants::ACCESSORY3 => "ORANGE MASK",
            AccessoryVariants::ACCESSORY4 => "PINK VISOR",
            AccessoryVariants::ACCESSORY5 => "BLACK VISOR",
            AccessoryVariants::ACCESSORY6 => "RED MASK",
            AccessoryVariants::ACCESSORY7 => "VR HEADSET",
            AccessoryVariants::EMPTY => ""
        }
    }

    pub fn gen_profile_attributes(profile_variant: ProfileVariants) -> ProfileAttributes {
        ProfileAttributes {
            tool: get_back_attribute(profile_variant.tool),
            body: get_body_attribute(profile_variant.body),
            background: get_background_attribute(profile_variant.background),
            cloth: get_cloth_attribute(profile_variant.cloth),
            face: get_face_attribute(profile_variant.face),
            accessory: get_accessory_attribute(profile_variant.accessory)
        }
    }
}
