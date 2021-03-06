module r2pipe

import os

pub type SideCallback = fn (s R2PipeSide, msg string)

pub struct R2Pipe {
mut:
	inp   int
	out   int
	child int
	sides []R2PipeSide
}

pub struct R2PipeSide {
pub:
	name      string
	path      string
	direction bool // 0 = read, 1 = write
pub mut:
	user voidptr
	cb   SideCallback
}

pub fn (s R2PipeSide) write(a string) {
	unsafe {
		fd := os.vfopen(s.path, 'wb') or { return }
		C.puts(a.str)
		C.fclose(fd)
	}
}

[direct_array_access]
pub fn spawn(file string, cmd string) ?R2Pipe {
	input := [2]int{}
	output := [2]int{}
	C.pipe(&input[0])
	C.pipe(&output[0])
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
	return R2Pipe{
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
		return R2Pipe{-1, -1, -1, []}
	}
	mut r2 := R2Pipe{}
	r2.inp = inp.int()
	r2.out = out.int()
	return r2
}

pub fn (s R2PipeSide) read_fifo(cb SideCallback) {
	unsafe {
		fd := C.open(s.path.str, 0)
		// fd := os.vfopen(s.path, 'rb') or { return }
		go s.read_fifo_loop(fd, cb)
	}
}

// fn (s R2PipeSide)read_fifo_loop(fd &C.FILE, cb SideCallback) {
fn (s R2PipeSide) read_fifo_loop(fd int, cb SideCallback) {
	unsafe {
		for {
			data := [1024]char{}
			res := C.read(fd, &data[0], data.len)
			eprintln('${int(res)}')
			if res <= 0 {
				eprintln('read error from fifo. closing')
				break
			}
			data[int(res)] = char(0)
			cb(s, (&data[0]).vstring())
		}
		C.fclose(fd)
	}
}

pub fn (mut r2 R2Pipe) on(event string, user voidptr, cb SideCallback) &R2PipeSide {
	path := r2.cmd('===$event').trim_space()
	e := &R2PipeSide{
		name: event
		path: path
		direction: false
		user: user
		cb: cb
	}
	r2.sides << e
	// eprintln('redirect errmsg to $e.path')
	if e.direction {
		eprintln('writeable events not yet implemented')
	} else {
		e.read_fifo(cb)
	}
	return e
}

[direct_array_access]
pub fn (r2 &R2Pipe) cmd(command string) string {
	if r2.inp < 0 {
		return ''
	}
	cmd := command.replace('\n', ';')
	sendcmd := '$cmd\n'
	C.write(r2.out, sendcmd.str, sendcmd.len)
	maxsz := 1024 * 32
	unsafe {
		mut buf := malloc(maxsz)
		mut ch := [1]byte{}
		mut x := 0
		for x < maxsz {
			if C.read(r2.inp, voidptr(&ch), 1) == -1 {
				break
			}
			if ch[0] == 0 {
				break
			}
			buf[x] = ch[0]
			x++
		}
		return buf.vstring_with_len(x)
	}
}

pub fn (mut r2 R2Pipe) free() {
	if r2.sides.len > 0 {
		// r2cmd
		for s in r2.sides {
			r2.cmd('===-$s.name')
			os.rm(s.path) or {}
		}
	}
	r2.sides = []
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
}
