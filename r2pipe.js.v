module r2pipe

pub fn cmd(a string) string {
	mut res := ""
	#res = r2cmd(a);
	return res
}
