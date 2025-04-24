import { cairo, hash, merkle } from "starknet"

let amount1_low = cairo.uint256(25).low;
let amount1_high = cairo.uint256(25).high;

let amount2_low = cairo.uint256(50).low;
let amount2_high = cairo.uint256(50).high;

const leaves = [
    hash.computePedersenHashOnElements([
        amount1_low,
        amount1_high,
        BigInt("0x072966f3178Cd2f4eDF57EFC318b1c6026698Ff6091386BF4AC06bD51EC1fEDe")
    ]),
    hash.computePedersenHashOnElements([
        amount2_low,
        amount2_high,
        BigInt("0x02d904Aedff382C0D68F22444B525146ec5eA2926e271fC411845e8D9E751DE1")
    ]),
    hash.computePedersenHashOnElements([
        amount1_low,
        amount1_high, 
        BigInt("0x014237c152d3e5138bfe1bcae658c72d84c52fe9cc137bf9635f8561bd461bfd")
    ])
]

// tree
const tree = new merkle.MerkleTree(leaves);

// leaf
console.log('leaf hash: ', hash.computePedersenHashOnElements([amount2_low, amount2_high, BigInt("0x02d904Aedff382C0D68F22444B525146ec5eA2926e271fC411845e8D9E751DE1")]))

// root
console.log('root: ', tree.root)

// proof
console.log('proof: ', tree.getProof(
    hash.computePedersenHashOnElements([
        amount2_low,
        amount2_high,
        BigInt("0x02d904Aedff382C0D68F22444B525146ec5eA2926e271fC411845e8D9E751DE1")
    ])
))
