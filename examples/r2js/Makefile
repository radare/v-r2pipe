

all:
	v -b js_freestanding qjstest.v
	echo '(()=>{' > qjstest.r2.js
	cat qjstest.js >> qjstest.r2.js
	echo '})();' >> qjstest.r2.js
	r2 -qi qjstest.r2.js /bin/ls
