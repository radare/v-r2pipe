all:
	v -shared .
	v test .

test:
	v test .
	make -C examples

indent:
	v fmt -w .
