module r2pipe

import os

// extern
pub fn C.write(fd int, buf byteptr, len int) int
pub fn C.read(fd int, buf byteptr, len int) int
pub fn C.close(fd int) int

pub struct R2Pipe {
mut:
	inp int
	out int
}

pub fn spawn() R2Pipe {
	eprintln('R2Pipe.spawn is not yet implemented')
	// spawn r2 -q0
	// read 00
	// write cmd + 00
	// read response + 00
	// C.pipe()
}

pub fn new() R2Pipe {
	inp := os.getenv('R2PIPE_IN')
	out := os.getenv('R2PIPE_OUT')
	if inp == '' || out == '' {
		eprintln('Cannot find R2PIPE_IN|OUT')
		return &R2Pipe{-1,-1}
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
 	sendcmd := '${command}\n'
 	C.write(r2.out, sendcmd.str, sendcmd.len)
 	maxsz := 4096
 	mut buf := malloc(maxsz)
 	mut ch := [1]byte
 	mut x := 0
 	for x < maxsz {
 		eprintln('lets read from ${r2.inp}')
 		C.read(r2.inp, ch, 1)
 		buf[x++] = ch[0]
 		if ch[0] == 0 {
 			break
 		}
 	}
 	return string(buf, x)
}

pub fn (r2 &R2Pipe)free() {
 	if r2.inp >= 0 {
 		C.close(r2.inp)
 	}
 	if r2.out >= 0 {
 		C.close(r2.out)
 	}
 	//free(r2)
}
