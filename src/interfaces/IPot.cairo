use starknet::ContractAddress;
use coloniz::base::constants::types::PotInstance;

#[starknet::interface]
pub trait IPot<TState> {
    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn create_instance(
        ref self: TState,
        community_id: u256,
        merkle_root: felt252,
        max_claim: u256,
        distribution_amount: u256,
        erc20_contract_address: ContractAddress,
        instance_start_time: u64,
        instance_duration: u64
    ) -> u256;
    fn claim(ref self: TState, instance_id: u256, claim_amount: u256, proof: Span<felt252>);
    fn withdraw(ref self: TState, instance_id: u256, address: ContractAddress);

    // *************************************************************************
    //                              GETTERS
    // *************************************************************************
    fn instance_is_active(self: @TState, instance_id: u256) -> bool;
    fn user_is_eligible(
        self: @TState,
        instance_id: u256,
        address: ContractAddress,
        amount: u256,
        proof: Span<felt252>
    ) -> bool;
    fn user_has_claimed(self: @TState, instance_id: u256, address: ContractAddress) -> bool;
    fn get_distributed_amount(self: @TState, instance_id: u256) -> u256;
    fn get_recent_community_instance(self: @TState, community_id: u256) -> u256;
    fn get_pot_instance_details(self: @TState, instance_id: u256) -> PotInstance;
    fn get_total_instances(self: @TState) -> u256;
}
