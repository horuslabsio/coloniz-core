pub mod colonizColors {
    use core::array::ArrayTrait;

    pub fn get_random_color(seed: u256) -> felt252 {
        let colors = array![
            '#A0D170',
            '#FFD2DD',
            '#EAD7FF',
            '#D9E0FF',
            '#F8C944',
            '#FFE7F0',
            '#F3EAFF',
            '#ECF0FF',
            '#93A97D',
            '#EAAEC7',
            '#C3B3D5',
            '#ACB5DD',
            '#B96326',
            '#575757',
            '#DBDBDB',
            '#000',
            '#FF88A5',
            '#FFDFE7',
            '#FFCFEC',
            '#FF7F50',
            '#0074D9',
            '#FF851B',
            '#2ECC40',
            '#39CCCC',
            '#B10DC9',
            '#85144B',
            '#3D9970',
            '#FF4136',
            '#111111',
            '#AA00FF',
            '#FF00A0',
            '#008080',
            '#D81B60',
            '#5D4037'
        ];

        let len: u256 = colors.len().try_into().unwrap();
        let randomIndex: u32 = (seed % len).try_into().unwrap();

        return *colors.at(randomIndex);
    }
}
