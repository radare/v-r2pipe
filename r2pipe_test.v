module r2pipe

fn test_main() {
	mut r2 := new()
	println(r2.cmd('i')) // ?e hello world'))
	r2.free()
}

