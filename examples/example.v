import r2pipe

fn main() {
	mut r2 := r2pipe.r2spawn('/bin/ls', '') or { panic(err) }
	r := r2.cmd('?e hell')
	println(r)
	r2.free()
}
