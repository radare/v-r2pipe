module r2pipe

import os

const (
	r2_path = 'radare2'
)

pub type SideCallback = fn (s R2PipeSide, msg string) bool

pub struct R2Pipe {
mut:
	inp   int
	out   int
	child int
	sides []&R2PipeSide
}

[heap]
pub struct R2PipeSide {
pub:
	name      string
	direction bool // 0 = read, 1 = write
pub mut:
	fd   int
	path      string
	user voidptr
	cb   SideCallback
	th thread
}

pub fn (s R2PipeSide) write(a string) {
	unsafe {
		fd := os.vfopen(s.path, 'wb') or { return }
		C.puts(a.str)
		C.fclose(fd)
	}
}

[direct_array_access]
pub fn r2spawn(file string, cmd string) ?R2Pipe {
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
		ch := u8(0)
		// parent
		res := C.read(output[0], &ch, 1)
		if res != 1 {
			return error('cannot read from child process')
		}
		if ch != 0 {
			C.fcntl(output[0], C.F_SETFL, C.O_NONBLOCK)
			mut msg := ''
			for true {
				if C.read(output[0], &ch, 1) != 1 {
					break
				}
				msg += rune(ch).str()
			}
			return error('unexpected handshake "$msg", expected null byte')
		}
	} else {
		C.close(0)
		C.close(1)
		C.dup2(input[0], 0)
		C.dup2(output[1], 1)
		if cmd == '' {
			os.execvp(r2_path, ['-q0', file]) ?
		} else {
			os.execvp(cmd, [file]) ?
		}
		C.close(0)
		C.close(1)
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

pub fn (mut s R2PipeSide) free() {
	if s.path != '' {
		os.rm(s.path) or {}
		s.path = ''
	}
	if s.fd != -1 {
		s.fd = -1
	}
	// XXX wait hangs forever
	// s.th = thread(0)
	// s.th.wait()
}

pub fn (mut s R2PipeSide) read_fifo(cb SideCallback) {
	unsafe {
		// fd := os.vfopen(s.path, 'rb') or { return }
		for {
			data := [4096]char{}
			res := C.read(s.fd, &data[0], data.len - 1)
			if res < 1 {
				eprintln('read error from fifo. closing')
				break
			}
			data[int(res)] = char(0)
			if !cb(s, (&data[0]).vstring()) {
				break
			}
		}
		s.free()
	}
}

pub fn (mut r2 R2Pipe) on(event string, user voidptr, cb SideCallback) &R2PipeSide {
	path := r2.cmd('===$event').trim_space()
	mut side := &R2PipeSide{
		name: event
		path: path
		direction: false
		user: user
		fd: C.open(path.str, C.O_CLOEXEC)
		cb: cb
	}
	// eprintln('redirect errmsg to $e.path')
	if side.direction {
		eprintln('writeable events not yet implemented')
	} else {
		side.th = go side.read_fifo(cb)
	}
	r2.sides << side
	return side
}

fn C.fcntl(int, int, int)
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
		mut ch := [1]u8{}
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
		for mut s in r2.sides {
			r2.cmd('===-$s.name')
			s.free()
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
		r2.child = -1
	}
}
