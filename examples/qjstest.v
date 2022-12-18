module main
import r2pipe

fn main() {
	res := r2pipe.cmd("x")
	println("hello: " + res)
	/*
	j := r2pipe.cmdj("ij")
	println("file: " + file)
	*/
}
