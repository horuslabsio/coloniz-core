pub mod colonizColors {
    use core::array::ArrayTrait;

    pub fn get_random_color(local_name: u256) -> felt252 {
        let colors = array![
            '#A0D170',
            '#FFD2DD',
            '#EAD7FF',
            '#D9E0FF',
            '#F8C944',
            '#F4FFDC',
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
            '#E3F7FF',
            '#FF88A5',
            '#FFDFE7',
            '#FFCFEC'
        ];

        let len: u256 = colors.len().try_into().unwrap();
        let randomIndex: u32 = (local_name % len).try_into().unwrap();

        return *colors.at(randomIndex);
    }
}
