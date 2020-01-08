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
	if r2.inp == -1 {
		eprintln('No R2PIPE_IN|OUT found.')
		return ''
	}
	C.write(r2.out, '${command}\n'.str, command.len + 1)
	eprintln('written')
	mut buf := [1024]int
	for true {
		C.read(r2.inp, buf, 1)
		println('FIRST CHAR ${buf[0]}')
	}
	return 'jiji'
}

pub fn (r2 &R2Pipe)free() {
	C.close(r2.inp)
	C.close(r2.out)
	free(r2)
}
