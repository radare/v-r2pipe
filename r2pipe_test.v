module r2pipe

fn test_main() {
	// running an r2pipe local script from outside r2pipe
	mut r2 := new()
	res := r2.cmd('i')
	if res != "" {
		panic("Expected an 'Cannot find R2PIPE_IN|OUT' error")
	}
	r2.free()
}

fn test_spawn() {
	// XXX this is hanging under v test
	mut r2 := r2spawn('/bin/ls', '') or { panic(err) }
	res := r2.cmd('i')
	idx := res.index('file') or { panic(err) }
	if idx > 0 {
		println(r2.cmd('i'))
	} else {
		panic("Expected file in i output")
	}
	r2.free()
}
