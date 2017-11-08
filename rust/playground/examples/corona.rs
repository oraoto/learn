#![feature(duration_from_micros)]
extern crate corona;
extern crate tokio_core;

use std::time::Duration;
use corona::prelude::*;
use tokio_core::reactor::{Core, Timeout};

fn main() {
    let mut core = Core::new().unwrap();

    let handle = core.handle();

    let coro = Coroutine::with_defaults(core.handle(), move || {
        let timeout = Timeout::new(Duration::from_micros(50), &handle).unwrap();

        timeout.coro_wait().unwrap();

        42
    });

    assert_eq!(42, core.run(coro).unwrap());
}
