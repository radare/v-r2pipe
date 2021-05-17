module r2pipe

fn test_main() {
	mut r2 := new()
	println(r2.cmd('i'))
	r2.free()
}

fn test_spawn() {
	// XXX this is hanging under v test
	/*
	mut r2 := spawn('/bin/ls', '') or { panic(err) }
	println(r2.cmd('i'))
	r2.free()
	*/
}
