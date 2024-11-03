package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

does_contains_at_least_one_component_with_default_change_detection_strategy :: proc(
	filepath: string,
) -> bool {
	data, ok := os.read_entire_file(filepath)
	if !ok {
		return false
	}
	defer delete(data)

	it := string(data)
	is_component := false

	for line in strings.split_lines_iterator(&it) {
		l := strings.trim_space(line)
		line_formatted, was_allocation := strings.remove_all(l, " ")
		defer if was_allocation {
			delete(line_formatted)
		}

		if strings.starts_with(line_formatted, "changeDetection:ChangeDetectionStrategy.OnPush") {
			// handle both the case where the line is equal to:
			// changeDetection:ChangeDetectionStrategy.OnPush,
			// or
			// changeDetection:ChangeDetectionStrategy.OnPush
			return false
		}

		if strings.starts_with(line_formatted, "@Component") {
			is_component = true
		}
	}

	return is_component
}

File_Read_User_Data :: struct {
	current_directory:                          string,
	num_of_files_with_default_change_detection: int, // Number of files containing at least one component with the default change detection strategy.
	print_filenames:                            bool,
}

on_file_info_read :: proc(
	info: os.File_Info,
	err: os.Error,
	user_data: rawptr,
) -> (
	err_out: os.Error,
	skip_dir: bool,
) {
	if err != os.ERROR_NONE {
		error_println("An error occured while retrieving the information for a file.", err)
		return
	}

	if filepath.ext(info.name) != ".ts" {
		return
	}

	if does_contains_at_least_one_component_with_default_change_detection_strategy(info.fullpath) {
		user_data := (^File_Read_User_Data)(user_data)
		user_data.num_of_files_with_default_change_detection += 1

		file_path, err := filepath.rel(user_data.current_directory, info.fullpath)
		if err != filepath.Relative_Error.None {
			error_println(
				"An error occurred while retrieving the file path relative to the current directory",
				err,
			)
			return
		}
		defer delete(file_path)

		if !user_data.print_filenames {
			return
		}

		info_println(file_path)
	}

	return
}

check_files_with_default_change_detection :: proc(
	root: string,
	print_filenames := true,
) -> (
	num_of_files_with_default_change_detection: int,
) {
	user_data := File_Read_User_Data {
		current_directory = os.get_current_directory(),
		print_filenames   = print_filenames,
	}
	defer delete(user_data.current_directory)

	filepath.walk(root, on_file_info_read, &user_data)

	return user_data.num_of_files_with_default_change_detection
}

main :: proc() {
	fmt.println("\nFiles with at least one component using change detection set to default:\n")

	num_of_files_with_default_change_detection := check_files_with_default_change_detection(
		"src/app",
	)

	fmt.println(
		"\nNumber of files with at least one component using change detection set to default:",
		num_of_files_with_default_change_detection,
	)
}
