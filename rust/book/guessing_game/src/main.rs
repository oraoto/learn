extern crate rand;

use std::io;
use rand::Rng;

fn main() {
    println!("Guessing Game");

    let secret_number = rand::thread_rng().gen_range(1, 101);

    let mut guest = String::new();      // mutable variable

    io::stdin().read_line(&mut guest)   // mutable references (to an mutable variable)
        .expect("Failed to read line"); // Result must be used

    println!("You guessed {}", guest);

}