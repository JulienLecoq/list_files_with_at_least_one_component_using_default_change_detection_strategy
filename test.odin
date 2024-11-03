package main

import "core:testing"

@(test)
test_recursive_check :: proc(t: ^testing.T) {
	num_of_files_with_default_change_detection := print_files_with_default_change_detection(
		"test_files",
	)
	testing.expect_value(t, 9, num_of_files_with_default_change_detection)
}
