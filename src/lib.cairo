pub mod coloniznft;
pub mod interfaces;
pub mod profile;
pub mod base;
pub mod follownft;
pub mod mocks;
pub mod publication;
pub mod namespaces;
pub mod presets;
pub mod hub;
pub mod jolt;
pub mod community;
pub mod channel;


use coloniz::base::token_uris::handle_token_uri::HandleTokenUri::get_token_uri;

fn main() {
    let name = 'ezi____nne';
    let namespace = 'clz';

    let token_uri: ByteArray = get_token_uri(1, name, namespace);
    println!("{:?}", token_uri);
}
