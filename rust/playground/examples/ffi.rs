extern crate libc;

use libc::c_double;
use libc::c_uchar;
use libc::size_t;
use std::ffi::CString;

#[link(name = "legacy_stdio_definitions")]
extern {
    fn cos(d: c_double) -> c_double;
    fn printf(_: *const libc::c_char) ->  size_t;
}

fn main() {
    let x = unsafe { cos(1.0) };
    println!("cos(1.0) = {}", x);
    let hello = CString::new("Hello, World!\n").unwrap();
    let y = unsafe {
        let ptr = hello.as_ptr();
        printf(ptr)
    };
    println!("{} chars printed", y);
}
