import { Call } from "starknet-tokenbound-sdk";
import { coloniz_HUB_CONTRACT_ADDRESS, PROFILE_ADDRESS_ONE, PROFILE_ADDRESS_TWO } from "../helpers/constants";
import tokenbound from "../index";
import { cairo, CallData,CairoCustomEnum, Uint256 } from "starknet";

import abi from "../abi/hub.json";

export const CommunityType = {
    Free: "Free",
    Standard: "Standard",
    Business:"Business"
  } as const;

export const GateKeepType = {
    Open: "Open",
    NFTGating: "NFTGating",
    PermissionedGating: "PermissionedGating",
    PaidGating: "PaidGating",
} as const;

const execute_create_community = async() =>{
    let community_id = cairo.uint256(16);

    let call:Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,  
        selector:"0x8945c258076d05a649eb76dca07fe609b43b360775b41226e3a345e9593ab4",
         calldata: CallData.compile([community_id])
    }
    try {
        const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call])
        console.log('execution-response=:', Resp);
    } catch (error) {
        console.log(error)
    }
}

const execute_create_channel = async() =>{
    let channel_id = cairo.uint256(29);
    let community_id = cairo.uint256(819);

    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS, //coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x033a3cd19c446a4483d4288f10983bf9316ce813aa8ee81acae99b36fc6022d0",
        calldata: CallData.compile([channel_id, community_id]) 
    }
    
    try {
        const create_channel_Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call])
        console.log('execution-response=:', create_channel_Resp)
    } catch (error) {
        console.log(error)
    }
}

const execute_join_community = async() =>{
    let community_id = cairo.uint256(819);

    let call:Call = {
        to:coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x4520555a219f5c8f5c5dba38600b2ef90052dda2c3bd82d24968e43fb54207",
         calldata: CallData.compile([community_id])
        }

    try {
        const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call])
        console.log('execution-response=:', Resp)
    } catch (error) {
        console.log(error)
    } 
}

const execute_add_mod = async() =>{
    let community_id = cairo.uint256(962)
    let address = ["0x047e64015c4b5a9fa7a67c0d010c560eb41fbad49573fe78fc3138f0b4ab3e83", "0x014237c152d3e5138bfe1bcae658c72d84c52fe9cc137bf9635f8561bd461bfd"];

    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector: "0x020855da45f2c45300363a4ad7339e4c49de86fa97280baafa3137c2531a22e3",
        calldata: CallData.compile([community_id, address])
    }

    try {
        const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call])
        console.log('execution-response=:', Resp)
    } catch (error) {
        console.log(error)
    } 
}

const execute_add_channel_mod = async() =>{
    let channel_id = cairo.uint256(7)
    let address = ["0x0688008cb60a5d23689df1ebcbb5e15704e83642d453957441cdbeeda81bdb2c", "0x014237c152d3e5138bfe1bcae658c72d84c52fe9cc137bf9635f8561bd461bfd"];

    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector: "0x01056471e50214407d31a6ca2fa3b9250e350d89827032cd741552145ea28090",
        calldata: CallData.compile([channel_id, address])
    }

    try {
        const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call])
        console.log('execution-response=:', Resp)
    } catch (error) {
        console.log(error)
    } 
}

const execute_make_post = async() =>{
    let post_params = {
    content_URI: "Content URL ...",
    profile_address: PROFILE_ADDRESS_TWO,
    channel_id: "0x1",
    community_id: "0x1"
    };

    let call:Call = {
        to:coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x03023f17c6c151428a83e388ec4de34e239b102d8cb4b01068f4cdc2ed6b83b6",
        calldata:[post_params]
    }
    try {
        const Resp = await tokenbound?.execute(PROFILE_ADDRESS_TWO, [call])
        console.log('execution-response=:', Resp)
    } catch (error) {
        console.log(error)
    }  
}

// comment
const execute_add_comment = async() =>{
    let post_params = {
    content_URI: "Content URL ...",
    profile_address: PROFILE_ADDRESS_TWO,
    channel_id: "0x1",
    community_id: "0x1"
    };

    let call:Call = {
        to:coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x03023f17c6c151428a83e388ec4de34e239b102d8cb4b01068f4cdc2ed6b83b6",
        calldata:[post_params]
    }
    try {
        const Resp = await tokenbound?.execute(PROFILE_ADDRESS_TWO, [call])
        console.log('execution-response=:', Resp)
    } catch (error) {
        console.log(error)
    }   
}

const execute_comment = async () => {
    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector:
            "0x29ce70c72e2e7191b71ef82881773fbf30510f24a3450f02d555b5f04ac9702",
        calldata: [{
            content_URI: "test comment publication...",
            profile_address: PROFILE_ADDRESS_TWO,
            pointed_profile_address: PROFILE_ADDRESS_ONE,
            pointed_pub_id: "0x1",
            reference_pub_type: "Comment",
        }],
    };
    try {
        const Resp = await tokenbound?.execute(PROFILE_ADDRESS_TWO, [call]);
        console.log("execution-response=:", Resp);
    } catch (error) {
        console.log(error);
    }
};

const execute_repost = async () => {
    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector:
            "0x01d2dbb7f2c4890417100d064e363f8dc67af1dbdf7fd6cc9538d82c7566c39b",
        calldata: [{
            profile_address: PROFILE_ADDRESS_TWO,
            pointed_profile_address: PROFILE_ADDRESS_ONE,
            pointed_pub_id: "0x1",
        }],
    };
    try {
        const Resp = await tokenbound?.execute(PROFILE_ADDRESS_TWO, [call]);
        console.log("execution-response=:", Resp);
    } catch (error) {
        console.log(error);
    }
};


const execute_upvote = async () => {
    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector:
            "0x02051ad9768cb00721e0522429c7257f589ea08adf6eb43865204cf1cc60b61c",
        calldata: [PROFILE_ADDRESS_TWO, "0x1"],
    };
    try {
        const Resp = await tokenbound?.execute(PROFILE_ADDRESS_TWO, [call]);
        console.log("execution-response=:", Resp);
    } catch (error) {
        console.log(error);
    }
};

const execute_downvote = async () => {
    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector:
            "0x4cbaff62234695102a38001164ecf4c8534f4771b1eabdf5c19fd8384157a5",
        calldata: [PROFILE_ADDRESS_TWO, "0x1"],
    };
    try {
        const Resp = await tokenbound?.execute(PROFILE_ADDRESS_TWO, [call]);
        console.log("execution-response=:", Resp);
    } catch (error) {
        console.log(error);
    }
};

// create subscription
const create_subscription = async() => {
    let erc20_address:string = "0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d";
    let admin: string = "0x02d904Aedff382C0D68F22444B525146ec5eA2926e271fC411845e8D9E751DE1";
    let amount = cairo.uint256(10000000000000000000);

    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector:
            "0x030326c786e65473aacbd943f9dfef0e20cc86348cecd85b2aae83177847887b",
        calldata: CallData.compile([admin, amount, erc20_address]),
    }

    try {
        const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call]);
        console.log("execution-response=:", Resp);
    } catch (error) {
        console.log(error);
    }
}

// set fee address
const set_fee_address = async() => {
    let community_id = cairo.uint256(5);
    let fee_address = "0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f";

    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector:
            "0x010f3295f8924198820502d3f7acae513667a4665d746920186e02e5fdd3de1b",
        calldata: CallData.compile([community_id, fee_address]),
    }

    try {
        const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call]);
        console.log("execution-response=:", Resp);
    } catch (error) {
        console.log(error);
    }
}

// set permissioned address
const set_permissioned_address = async() => {
    let community_id = cairo.uint256(4);
    let address = [1, "0x14237c152d3e5138bfe1bcae658c72d84c52fe9cc137bf9635f8561bd461bfd"];

    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector:
            "0x03b81e9c3edbf0df5b44072e7cf1ccc473d907ba141d16d822548f386a7d52e7",
        calldata: CallData.compile([community_id, address]),
    }

    try {
        const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call]);
        console.log("execution-response=:", Resp);
    } catch (error) {
        console.log(error);
    }
}

// execute upgrade
const execute_upgrade = async() => {
    let community_id = cairo.uint256(13);
    let community_type = new CairoCustomEnum({ Business: {} });
    let erc20_address:string = "0x006e1698dcd0665757dd213a59aff489624bab8c970ce0482c23937a78879b04";
    let sub_id: Uint256 = cairo.uint256(
        '0x040e69be8f56d2da824600bc2861852e77f233e43ca1dce3152c9c08f671af87'
      );

    let call1: Call = {
        to: erc20_address,
        selector:
            "0x0219209e083275171774dab1df80982e9df2096516f06319c5c6d71ae0a8480c",
        calldata: CallData.compile([coloniz_HUB_CONTRACT_ADDRESS, cairo.uint256(50)]),
    }

    const contractCallData: CallData = new CallData(abi);
    let call2: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector:
            "0x027ead9fee9c84e7422ab84c28d91eea938d139fafc7d1102ef3982f3d087f88",
        calldata: contractCallData.compile('upgrade_community', [community_id, community_type, sub_id, false, cairo.uint256(0)]),
    }

    try {
        const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call1, call2]);
        console.log("execution-response=:", Resp);
    } catch (error) {
        console.log(error);
    }
}

// execute gatekeep
const execute_gatekeep = async() =>{
    let community_id = cairo.uint256(13);
    let gatekeep_type = new CairoCustomEnum({ [GateKeepType.PermissionedGating]: {} });
    let permissioned_address = [1, "0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f"];
    let erc20_address:string = "0x006e1698dcd0665757dd213a59aff489624bab8c970ce0482c23937a78879b04";
    let amount = cairo.uint256(50);
    let erc721_address = "0x0000003697660a0981d734780731949ecb2b4a38d6a58fc41629ed611e8defda";
    let paid_gating_details = {
        "0": erc20_address,
        "1": amount
    };
    const contractCallData: CallData = new CallData(abi);

    let call: Call = {
        to: coloniz_HUB_CONTRACT_ADDRESS,
        selector:
            "0x3494f4762774ed2020c6906a4da6be06137fc4a0a5ee07fbb404b10c1ae60e8",
        calldata: contractCallData.compile('gatekeep', {
            community_id: community_id, 
            gate_keep_type: gatekeep_type, 
            nft_contract_address: erc721_address, 
            permissioned_addresses: permissioned_address, 
            paid_gating_details
        }),
    }
    try {
        const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call]);
        console.log("execution-response=:", Resp);
    } catch (error) {
        console.log(error);
    }
}

// execute_get_community();
// execute_create_community();
// execute_upgrade()
// execute_gatekeep()
// set_fee_address()
// set_permissioned_address()
// create_subscription()
// execute_create_channel();
execute_add_mod();
// execute_add_channel_mod();
// execute_join_community();
// execute_make_post();
// execute_add_comment()
// execute_comment();
// execute_repost();
// execute_upvote();
// execute_downvote();


