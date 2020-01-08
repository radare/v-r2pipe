# r2pipe for V

This repository contains the r2pipe implementation in V

## Installation

```go
$ v install radare.r2pipe

```

## Usage

```go
$ r2 /bin/ls
[0x8048000]> #!pipe v
>>> import radare.r2pipe
>>> r2 := r2pipe.new()
>>> print(r2.cmd('?E Hello World'))
>>> r2.free()
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
