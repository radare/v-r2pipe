module r2pipe

import os

// extern
// pub fn C.write(fd int, buf byteptr, len int) int
/*
pub fn C.read(fd int, buf byteptr, len int) int
pub fn C.close(fd int) int
pub fn C.fork() int
*/
pub fn C.pipe(fd [2]int) int
pub fn C.dup2(fd int, fd2 int) int
pub fn C.kill(pid int, sig int) int

pub struct R2Pipe {
mut:
	inp int
	out int
	child int
}

pub fn spawn(file, cmd string) ?R2Pipe {
	input := [2]int{}
	output := [2]int{}
	C.pipe (input)
	C.pipe (output)
	pid := C.fork()
	if pid < 0 {
		return error('cannot fork')
	}
//	os.setenv ("R2PIPE_IN", input[0], true)
//	os.setenv ("R2PIPE_OUT", output[1], true)
	if pid > 0 {
		ch := byte(0)
		// parent
		C.read(output[0], &ch, 1)
		if ch != 0 {
			return error('unexpected handshake $ch')
		}
	} else {
		C.close(0)
		C.close(1)
		C.dup2(input[0], 0)
		C.dup2(output[1], 1)
		if cmd == '' {
			os.system('r2 -q0 $file')
		} else {
			// child
			os.system('$cmd $file')
		}
		exit(0)
	}
	// spawn r2 -q0
	// read 00
	// write cmd + 00
	// read response + 00
	// C.pipe()
	return R2Pipe {
		inp: output[0]
		out: input[1]
		child: pid
	}
}

pub fn new() R2Pipe {
	inp := os.getenv('R2PIPE_IN')
	out := os.getenv('R2PIPE_OUT')
	if inp == '' || out == '' {
		eprintln('Cannot find R2PIPE_IN|OUT')
		return R2Pipe{-1, -1, -1}
}
	mut r2 := R2Pipe{}
	r2.inp = inp.int()
	r2.out = out.int()
	return r2
}

pub fn (r2 &R2Pipe)cmd(command string) string {
	if r2.inp < 0 {
		return ''
	}
	cmd := command.replace('\n', ';')
	sendcmd := '$cmd\n'
	C.write(r2.out, sendcmd.str, sendcmd.len)
	maxsz := 1024 * 32
	mut buf := malloc(maxsz)
	mut ch := [1]byte{}
	mut x := 0
	for x < maxsz {
		if C.read(r2.inp, ch, 1) == -1 {
			break
		}
		unsafe {
			buf[x] = ch[0]
		}
		if ch[0] == 0 {
			break
		}
		x++
	}
	unsafe {
		// return string(buf, x)
		return buf.vstring_with_len(x)
	}
}

pub fn (mut r2 R2Pipe)free() {
	if r2.inp >= 0 {
		C.close(r2.inp)
		r2.inp = -1
	}
	if r2.out >= 0 {
		C.close(r2.out)
		r2.inp = -1
	}
	if r2.child > 0 {
		C.kill(r2.child, 9)
	}
	//free(r2)
}
