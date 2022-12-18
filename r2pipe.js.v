module r2pipe

import json

pub fn cmd(a string) string {
	mut res := ""
	#res = r2cmd(a);
	return res
}

/*
pub fn cmdj(a string) {
	mut res := ""
	#res = JSON.parse(r2cmd(a));
	return res
}
*/
