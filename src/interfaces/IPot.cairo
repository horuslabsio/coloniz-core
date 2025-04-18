// the pot is a central wallet from which projects could provide liquidity for their community points. can be funded with whatever tokens they please
// the pot is activated with a merkle root, token contract address, max claim, amount to be distributed, and duration (time for which claiming should stay)
// when users claim, we check their profile against the root and distribute the right amount of reward. If expected reward exceeds the max claim, we send them the max claim.
// the pot has a withdraw function to withdraw/transfer the remaining tokens after claiming is over from the pot.


use starknet::ContractAddress;

#[starknet::interface]
pub trait IPot<TState> {
    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn activate(
        ref self: TState,
        community_id: u256,
        root: u256,
        max_claim: u256,
        distribution_amount: u256,
        erc20_contract_address: ContractAddress,
        instance_start_time: u64,
        instance_duration: u64
    ) -> u256;
    fn claim(ref self: TState, instance_id: u256);
    fn withdraw(ref self: TState, instance_id: u256, address: ContractAddress);

    // *************************************************************************
    //                              GETTERS
    // *************************************************************************
    fn instance_is_active(self: @TState, instance_id: u256) -> bool;
    fn user_is_eligible(self: @TState, instance_id: u256, address: ContractAddress) -> (bool, u256);
}