all:
	v run example.v
	v run test.v
	v run errmsg.v

r2qjs:
	v -b js_freestanding qjstest.v
	mv qjstest.js qjstest.qjs
	r2 -qi qjstest.qjs /bin/ls
