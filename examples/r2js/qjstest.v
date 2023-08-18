module main

import examples.r2pipe

fn main() {
	res := r2pipe.cmd('?E Hello World')
	println('hello:\n' + res)
}
