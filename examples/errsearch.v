import examples.r2pipe
import time

fn main() {
	mut r := r2pipe.r2spawn('/bin/ls', '')?
	r.on('errmsg', 0, fn (s r2pipe.R2PipeSide, msg string) bool {
		eprintln('errmsg.received(((${msg})))')
		return true
	})
	r.cmd('/ lib')
	time.sleep(1)
	r.free()
}
