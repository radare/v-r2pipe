module main

import examples.r2pipe

fn main() {
	mut r := r2pipe.r2spawn('/bin/ls', '') or { panic(err) }
	println(r.cmd('?E hello'))
	r.free()
}
