import { Call } from "starknet-tokenbound-sdk";
import { coloniz_HUB_CONTRACT_ADDRESS, PROFILE_ADDRESS_ONE, PROFILE_ADDRESS_TWO } from "../helpers/constants";
import tokenbound from "../index";

// "0x072426e3716e48a68accd60e3c67e666e08327a6f74cfe3a4accba5f9dddea3c"

const execute_create_community = async() =>{
    let call:Call = {
        to: "0x02408783725e0ad8badb2683f3ad243bd2cc5f431d970aaa532182501e3e6ae7",  // "0x630c718a29c62798e2b96e9f16fc65f4b22855fa49a4bd9339bcc950af037f5", // "0xa21ac387d13c35370bd5539fd9f7cdcbcdec82a6a18e424a83611379facfa3", // coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x8945c258076d05a649eb76dca07fe609b43b360775b41226e3a345e9593ab4",
         calldata:[]
        }
        try {
            const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call])
            console.log('execution-response=:', Resp);
        } catch (error) {
            console.log(error)
        }
    
}

const execute_create_channel = async() =>{
     
     // assume this is community_id is 1, since the SDK does not return functionn final return value after execution
     // https://github.com/horuslabsio/tokenbound-sdk/blob/develop/src/TokenboundClient.ts#L155
     
        let call:Call = {
        to: "0x00a21ac387d13c35370bd5539fd9f7cdcbcdec82a6a18e424a83611379facfa3", //coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x33a3cd19c446a4483d4288f10983bf9316ce813aa8ee81acae99b36fc6022d0",
        calldata:["0x1", "0x0"] //calldata:[1, 0] // calldata:["0x1", "0x0"]
        }
     
        try {
            const create_channel_Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call])
            console.log('execution-response=:', create_channel_Resp)
        } catch (error) {
            console.log(error)
        }
    
}

const execute_get_community = async() =>{
     

         let call:Call = {
        to: "0x00a21ac387d13c35370bd5539fd9f7cdcbcdec82a6a18e424a83611379facfa3", //coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x20bf8f15f5ae139bc6cb98412fbee613a66d1b0950e1f7406e74903621f8fc5",
         calldata:["0x1", "0x00"]
        }
        try {
            const create_channel_Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call])
            console.log('execution-response=:', create_channel_Resp)
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

// execute_get_community();
execute_create_community();
// execute_create_channel();
// execute_join_community();
// execute_make_post();
// execute_add_comment()
// execute_comment();
// execute_repost();
// execute_upvote();
// execute_downvote();


