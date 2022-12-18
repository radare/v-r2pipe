module r2pipe

pub fn cmd(a string) string {
	mut res := ""
	#res = r2cmd(a);
	return res
}

pub fn cmdj(a string) JS.Any {
	mut res := ""
	#res = JSON.parse(r2cmd(a));
	return res
}
