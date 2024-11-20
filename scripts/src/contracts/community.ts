// import "core::starknet::contract_address::ContractAddress";
import { cairo, Uint256 } from "starknet";
import { Call } from "starknet-tokenbound-sdk";
import { coloniz_HUB_CONTRACT_ADDRESS, PROFILE_ADDRESS_ONE, PROFILE_ADDRESS_TWO } from "../helpers/constants";
import tokenbound from "../index";



const execute_create_community = async() =>{
    let call:Call = {
        to: "0x07f1bfe30248603d742c4134f25057d03e520d80b65f11febf68434df2972f32",    
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
        to: "0x07f1bfe30248603d742c4134f25057d03e520d80b65f11febf68434df2972f32",  // "0x1ed1829c127c96ef9af1037ef53e4bd302b2467084e87d7831ef8a7b766d54d", //"0x00a21ac387d13c35370bd5539fd9f7cdcbcdec82a6a18e424a83611379facfa3", //coloniz_HUB_CONTRACT_ADDRESS,
        selector:"0x33a3cd19c446a4483d4288f10983bf9316ce813aa8ee81acae99b36fc6022d0",
        calldata:["0x2", "0x00"] 
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
        to: "0x1ed1829c127c96ef9af1037ef53e4bd302b2467084e87d7831ef8a7b766d54d", //coloniz_HUB_CONTRACT_ADDRESS,
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
        to: "0x07f1bfe30248603d742c4134f25057d03e520d80b65f11febf68434df2972f32",
        selector:"0x4520555a219f5c8f5c5dba38600b2ef90052dda2c3bd82d24968e43fb54207",
         calldata:["0x2", "0x00"] 
        }
        try {
            const Resp = await tokenbound?.execute("0x00a9c598e441d71343a7bef075371db4c32927b5206f1a258e6d489a99543977", [call])
            console.log('execution-response=:', Resp)
        } catch (error) {
            console.log(error)
        }
    
}



const execute_make_post = async() =>{
     
     
     //  assume this is community_id is 1, since SDK does not return functionn final return value after execution
     // https://github.com/horuslabsio/tokenbound-sdk/blob/develop/src/TokenboundClient.ts#L155
    
    interface  PostParams {
      content_URI: any,
        profile_address: any,
        channel_id: Uint256,
        community_id: Uint256
     };

 
    
const postParams = { type: 'PostParams', content_URI: 'this is the right text', 
 profile_address: '0x0752455822e9d8b10db3451035312703c1aae43a', channel_id: cairo.uint256(2), community_id: cairo.uint256(2) };




    let call:Call = {
        to: "0x07f1bfe30248603d742c4134f25057d03e520d80b65f11febf68434df2972f32",
        selector:"0x3023f17c6c151428a83e388ec4de34e239b102d8cb4b01068f4cdc2ed6b83b6",
        calldata: [postParams]
        }


        try {
            console.log('execution call data =:', call)
            const Resp = await tokenbound?.execute("0x075a4558a2e9d8b10fdb3d94d51b35312703cc7aae43a1ff95e234512e83783f", [call])
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
 // execute_create_community();
// execute_create_channel();
// execute_join_community();
execute_make_post();
// execute_add_comment()
// execute_comment();
// execute_repost();
// execute_upvote();
// execute_downvote();


