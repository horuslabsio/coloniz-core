import { Call } from "starknet-tokenbound-sdk";
import { coloniz_HUB_CONTRACT_ADDRESS, PROFILE_ADDRESS_ONE, PROFILE_ADDRESS_TWO } from "../helpers/constants";
import tokenbound from "../index";


const execute_create_community = async() =>{
    let call:Call = {
        to:coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x8945c258076d05a649eb76dca07fe609b43b360775b41226e3a345e9593ab4",
         calldata:[]
        }
        try {
            const Resp = await tokenbound?.execute("0x206b999eeed11da16898664d6ad251563e6796a564c6eaddfae4d84350d4cf1", [call])
            console.log('execution-response=:', Resp);
        } catch (error) {
            console.log(error)
        }
    
}

const execute_create_channel = async() =>{
     
     // assume this is community_id is 1, since SDK does not return functionn final return value after execution
     // https://github.com/horuslabsio/tokenbound-sdk/blob/develop/src/TokenboundClient.ts#L155
     
    let call:Call = {
        to:coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x033a3cd19c446a4483d4288f10983bf9316ce813aa8ee81acae99b36fc6022d0",
         calldata:["0x1"]
        }
        try {
            const Resp = await tokenbound?.execute(PROFILE_ADDRESS_ONE, [call])
            console.log('execution-response=:', Resp)
        } catch (error) {
            console.log(error)
        }
    
}

const execute_join_community = async() =>{
     //  assume this is community_id is 1, since SDK does not return functionn final return value after execution
     // https://github.com/horuslabsio/tokenbound-sdk/blob/develop/src/TokenboundClient.ts#L155
     
    let call:Call = {
        to:coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x4520555a219f5c8f5c5dba38600b2ef90052dda2c3bd82d24968e43fb54207",
         calldata:["0x1"]
        }
        try {
            const Resp = await tokenbound?.execute(PROFILE_ADDRESS_TWO, [call])
            console.log('execution-response=:', Resp)
        } catch (error) {
            console.log(error)
        }
    
}

const execute_make_post = async() =>{
     
     
     //  assume this is community_id is 1, since SDK does not return functionn final return value after execution
     // https://github.com/horuslabsio/tokenbound-sdk/blob/develop/src/TokenboundClient.ts#L155
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
     
     //  assume this is community_id is 1, since SDK does not return functionn final return value after execution
     // https://github.com/horuslabsio/tokenbound-sdk/blob/develop/src/TokenboundClient.ts#L155
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


execute_create_community();
execute_create_channel();
execute_join_community();
execute_make_post();
execute_add_comment()
execute_comment();
execute_repost();
execute_upvote();
execute_downvote();