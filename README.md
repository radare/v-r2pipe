# r2pipe for V

This repository contains the r2pipe implementation in V

## Installation

```go
$ v install radare.r2pipe

```

## Usage

This module can be used to interact with an already existing session of r2:

```go
$ r2 /bin/ls
[0x8048000]> #!pipe v
>>> import radare.r2pipe
>>> r2 := r2pipe.new()
>>> print(r2.cmd('?E Hello World'))
>>> r2.free()
```

or

```sh
$ r2 -i test.v /bin/ls
> . test.v
```

But it can also be used to spawn new instances of r2:

```go
module main

import radare.r2pipe

fn main() {
  c := r2pipe.spawn('/bin/ls', '')
  print(c.cmd('?E Hello'))
  c.free()
}

```

## Side Channel

r2pipe.v introduces a new api to capture the output of the stderr messages printed by r2
to the user. This channel is async, and can contain anything unstructured, so it's not
breaking backward compatibility and enables the users to also use this side pipe to
comunicate with the target process when running in debugger mode for example.

This is implemented by making r2pipe run a command in r2 that redirects the stderr to
a pipe, socket or file, which is then handled as an event captured in the r2 side.

```go
import r2pipe
import time

fn main() {
	mut r := r2pipe.spawn('/bin/ls', '')
	r.on('errmsg', works, fn (s r2pipe.R2PipeSide, msg string) bool {
		eprintln('errmsg.received($msg)')
		return true
	})
	r.cmd('Z')
	r.free()
}
```

## Example

```go
module main

import radare.r2pipe

fn main() {
  c := r2pipe.new()
  print(c.cmd('?E Hello'))
  c.free()
}

```
