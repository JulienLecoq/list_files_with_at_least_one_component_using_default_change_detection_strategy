package main

import "core:fmt"

Colors :: enum {
	cyan,
	red,
}

Colors_ANSI_Code :: [Colors]string {
	.cyan = "\033[36m",
	.red  = "\033[31m",
}

RESET_ANSI_CODE :: "\033[0m"

error_println :: proc(args: ..any) {
	fmt.print(Colors_ANSI_Code[.red])
	fmt.println(..args)
	fmt.print(RESET_ANSI_CODE)
}

info_println :: proc(args: ..any) {
	fmt.print(Colors_ANSI_Code[.cyan])
	fmt.println(..args)
	fmt.print(RESET_ANSI_CODE)
}
