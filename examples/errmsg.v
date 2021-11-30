module main

import r2pipe

fn main() {
	mut works := false
	mut r := r2pipe.spawn('/bin/ls', '') or { panic(err) }
	print('cmd: ${r.cmd('?e hello')}')
	// receive messages asyncronously taken from r2's stderr
	// ATM only errmsg is supported and it's experimental feature
	r.on('errmsg', works, fn (s r2pipe.R2PipeSide, msg string) bool {
		unsafe {
			mut works := &bool(s.user)
			eprintln('err:((( $msg )))')
			if msg.contains('Invalid') {
				*works = true
			}
			// close the side channel and the waiting thread
			// commented out because we want to ensure r2pipe deinitializes it properly
			// return false
		}
		return true
	})
	r.cmd('Z') // trigger invalid command
	// print('cmd: ${r.cmd("?e world")}')
	// input_side := r.on('child_input', fn (err string) { })
	// input_side.write('HELLO WORLD\n')
//	C.sleep(1)

	// Close and remove all the event handlers
	r.free()

	// Conclussion
	if works {
		println('It Works!!')
	} else {
		println('test failed, no errmsg was received')
		exit(1)
	}

	exit(0)
}
