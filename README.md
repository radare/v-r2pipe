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
