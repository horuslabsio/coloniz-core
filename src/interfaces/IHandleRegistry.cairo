use starknet::{ContractAddress, ClassHash};
// *************************************************************************
//                              INTERFACE OF HANDLE REGISTRY
// *************************************************************************
#[starknet::interface]
pub trait IHandleRegistry<TState> {
    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn link(ref self: TState, handle_id: u256, profile_address: ContractAddress);
    fn unlink(ref self: TState, handle_id: u256, profile_address: ContractAddress);
    fn upgrade(ref self: TState, new_class_hash: ClassHash);
    // *************************************************************************
    //                              GETTERS
    // *************************************************************************
    fn resolve(self: @TState, handle_id: u256) -> ContractAddress;
    fn get_handle(self: @TState, profile_address: ContractAddress) -> u256;
}
