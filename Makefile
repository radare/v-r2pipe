all:
	v test .

test:
	v test .
	make -C examples

indent:
	v fmt -w .
