module main

import r2pipe
//
fn main() {
	mut r := r2pipe.spawn('/bin/ls', '') or {
		panic(err)
	}
	println(r.cmd('?E hello'))
	r.free()
}
