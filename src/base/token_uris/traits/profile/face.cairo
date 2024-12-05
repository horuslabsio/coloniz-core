pub mod face {
    use coloniz::base::utils::byte_array_extra::FeltTryIntoByteArray;
    use coloniz::base::constants::types::FaceVariants;

    pub fn faceVariant(variant: FaceVariants) -> ByteArray {
        getFaceVariant(variant)
    }

    pub fn getFaceVariant(faceVariant: FaceVariants) -> ByteArray {
        let mut decidedFace: ByteArray = Default::default();
        match faceVariant {
            FaceVariants::FACE1 => {
                decidedFace =
                    "<g style=\"display:inline;fill:#f9f9f9\" transform=\"matrix(.10019 0 0 .1008 .16 -.277)\"><rect style=\"fill:#f9f9f9;fill-opacity:1;stroke-width:.264583\" width=\"22.288\" height=\"19.2\" x=\"202.878\" y=\"208.652\" ry=\"9.6\"/><rect style=\"fill:#f9f9f9;fill-opacity:1;stroke-width:.264583\" width=\"22.288\" height=\"19.2\" x=\"309.241\" y=\"212.885\" ry=\"9.6\"/></g>"
            },
            FaceVariants::FACE2 => {
                decidedFace =
                    "<g style=\"display:inline;fill:#f9f9f9\" transform=\"matrix(.10019 0 0 .1008 .16 -.276)\"><rect style=\"fill:#f9f9f9;fill-opacity:1;stroke-width:.264583\" width=\"31.521\" height=\"3.418\" x=\"198.238\" y=\"217.606\" ry=\"1.709\"/><rect style=\"fill:#f9f9f9;fill-opacity:1;stroke-width:.264583\" width=\"31.521\" height=\"3.418\" x=\"303.013\" y=\"220.252\" ry=\"1.709\"/><path style=\"fill:none;fill-opacity:1;stroke:#fff;stroke-width:3;stroke-dasharray:none;stroke-opacity:1\" d=\"M242.224 269.072s22.964-20.783 52.503 1.774\"/></g>"
            },
            FaceVariants::FACE3 => {
                decidedFace =
                    "<g style=\"display:inline;fill:none\" transform=\"matrix(.10019 0 0 .1008 .159 -.277)\"><ellipse style=\"fill:none;fill-opacity:1;stroke:#b8e5eb;stroke-width:3;stroke-dasharray:none;stroke-opacity:1\" cx=\"214.472\" cy=\"219.857\" rx=\"11.963\" ry=\"10.823\"/><ellipse style=\"fill:none;fill-opacity:1;stroke:#b8e5eb;stroke-width:3;stroke-dasharray:none;stroke-opacity:1\" cx=\"318.718\" cy=\"222.503\" rx=\"11.963\" ry=\"10.823\"/><path style=\"fill:none;fill-opacity:1;stroke:#b8e5eb;stroke-width:3;stroke-dasharray:none;stroke-opacity:1\" d=\"M251 252.694s16.423 17.266 32.28 0\"/></g>"
            },
            FaceVariants::FACE4 => {
                decidedFace =
                    "<g style=\"display:inline;fill:#0f0\" transform=\"matrix(.10019 0 0 .1008 .159 -.276)\"><rect style=\"fill:#0b0;fill-opacity:1;stroke:#0f0;stroke-width:3;stroke-dasharray:none;stroke-opacity:1\" width=\"21.267\" height=\"2.279\" x=\"204.246\" y=\"218.285\" ry=\"1.139\"/><path style=\"fill:#0f0;fill-opacity:1;stroke:none;stroke-width:2.15202;stroke-dasharray:none;stroke-opacity:1\" d=\"M317.01 222.957s-5.38-11.03-9.957-3.68c-4.802 7.711 9.957 14.868 9.957 14.868s15.173-8.235 9.58-15.898c-4.151-5.686-9.58 4.71-9.58 4.71\"/></g>"
            },
            FaceVariants::FACE5 => {
                decidedFace =
                    "<g style=\"display:inline;fill:#f9f9f9\" transform=\"matrix(.10019 0 0 .1008 .159 -.276)\"><rect style=\"fill:#f9f9f9;fill-opacity:1;stroke:#fff;stroke-width:2.77929;stroke-dasharray:none;stroke-opacity:1\" width=\"3.639\" height=\"17.69\" x=\"213.318\" y=\"211.04\" ry=\".816\"/><rect style=\"fill:#f9f9f9;fill-opacity:1;stroke:#fff;stroke-width:2.77929;stroke-dasharray:none;stroke-opacity:1\" width=\"3.639\" height=\"17.69\" x=\"317.564\" y=\"214.215\" ry=\".816\"/><path style=\"fill:none;fill-opacity:1;stroke:#fff;stroke-width:3;stroke-dasharray:none;stroke-opacity:1\" d=\"M246.468 253.671s17.792 18.793 35.319.38\"/></g>"
            },
            FaceVariants::FACE6 => {
                decidedFace =
                    "<g style=\"display:inline;fill:#f9f9f9\" transform=\"matrix(.10019 0 0 .1008 .159 -.277)\"><rect style=\"display:inline;fill:#ff0;fill-opacity:1;stroke:none;stroke-width:3;stroke-dasharray:none;stroke-opacity:1\" width=\"11.278\" height=\"21.483\" x=\"209.434\" y=\"208.383\" ry=\"5.639\"/><rect style=\"display:inline;fill:#ff0;fill-opacity:1;stroke:none;stroke-width:3;stroke-dasharray:none;stroke-opacity:1\" width=\"11.278\" height=\"21.483\" x=\"313.68\" y=\"212.617\" ry=\"5.639\"/></g>"
            },
            FaceVariants::FACE7 => {
                decidedFace =
                    "<g style=\"display:inline;fill:#f9f9f9\"><text xml:space=\"preserve\" style=\"font-style:italic;font-weight:600;font-size:26.7955px;font-family:&quot;Bookman Old Style&quot;;-inkscape-font-specification:&quot;Bookman Old Style Semi-Bold Italic&quot;;text-align:start;writing-mode:lr-tb;direction:ltr;text-anchor:start;fill:#0ff;fill-opacity:1;stroke:none;stroke-width:1.58241;stroke-dasharray:none;stroke-opacity:1\" x=\"219.558\" y=\"201.857\" transform=\"matrix(.0886 0 0 .11398 .16 -.276)\"><tspan style=\"fill:#0ff;stroke-width:1.58241\" x=\"219.558\" y=\"201.857\">HE</tspan></text><text xml:space=\"preserve\" style=\"font-style:italic;font-weight:600;font-size:24.6578px;font-family:&quot;Bookman Old Style&quot;;-inkscape-font-specification:&quot;Bookman Old Style Semi-Bold Italic&quot;;text-align:start;writing-mode:lr-tb;direction:ltr;text-anchor:start;fill:#0ff;fill-opacity:1;stroke:none;stroke-width:1.45617;stroke-dasharray:none;stroke-opacity:1\" x=\"364.759\" y=\"190.059\" transform=\"matrix(.08153 0 0 .12386 .16 -.276)\"><tspan style=\"fill:#0ff;stroke-width:1.45617\" x=\"364.759\" y=\"190.059\">LLO</tspan></text></g>"
            },
            FaceVariants::FACE8 => {
                decidedFace =
                    "<g style=\"display:inline;fill:#f9f9f9\"><path style=\"fill:none;fill-opacity:1;stroke:#fff;stroke-width:3;stroke-dasharray:none;stroke-opacity:1\" d=\"M203.013 226.644s-1.991-14.398 13.047-14.398 11.12 15.472 11.12 15.472m79.55 1.042s-1.991-14.397 13.047-14.397 11.121 15.472 11.121 15.472\" transform=\"matrix(.10019 0 0 .1008 .16 -.277)\"/></g>"
            },
        }
        decidedFace
    }
}
