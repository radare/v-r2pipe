import radare.r2pipe

fn test_main() {
	r2 := r2pipe.new()
	println(r2.cmd('x'))
	r2.free()
}

