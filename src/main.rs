use std::net::TcpListener;

use zero2prod::run;

#[tokio::main]
async fn main() -> std::io::Result<()> {
    // Bubble up the io::Error if we failed to bind the address
    let listener = TcpListener::bind("127.0.0.1:0").expect("Failed to bind random port");
    // Call await on the returned `Server`
    run(listener)?.await
}
