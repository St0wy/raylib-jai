AT_COMPILE_TIME :: true;

RAYLIB_PATH :: "raylib";

DECLARATIONS_TO_OMIT :: string.[
	// These have custom declarations in module.jai
	"Vector2",
	"Vector3",
	"Vector4",
	"Quaternion",
	"Matrix",
	"PI",
	"Camera3D",
	"GetGamepadButtonPressed",
	"TraceLogCallback",

	// These are already defined in an non-rl-prefixed version, they come from rlgl
	// It is necessary to omit them otherwise the bindings will generate two TraceLogLevel for example
	"rlTraceLogLevel",
	"rlPixelFormat",
	"rlTextureFilter",
	"rlBlendMode",
	"rlShaderLocationIndex",
	"rlShaderAttributeDataType",
	"rlShaderUniformDataType",
];

#if AT_COMPILE_TIME {
	#run,stallable {
		Compiler.set_build_options_dc(.{do_output=false});
		root_options := Compiler.get_build_options();
		args := root_options.compile_time_command_line;
		if !generate_bindings(args) {
			Compiler.compiler_set_workspace_status(.FAILED);
		}
	}
} else {
	#import "System";

	main :: () {
		set_working_directory(path_strip_filename(get_path_of_running_executable()));
		args := get_command_line_arguments();
		if !generate_bindings(args) {
			exit(1);
		}
	}
}

generate_bindings :: (args: [] string) -> bool
{
	compile := array_find(args, "-compile");
	compile_debug := array_find(args, "-debug");

	glfw_include := tprint("%/src/external/glfw/include", RAYLIB_PATH);

	if compile {
		if !check_has_cmake() {
			write_string("Building raylib requires CMake but it seems like it is not installed on your system.\n");
			write_string("Other building methods could be added to this library (such as Zig, or Makefiles on Unix), feel free to raise an issue or create a pull request.\n");
			return false;
		}

		ok := build_raylib(compile_debug, shared_lib=false);
		ok &&= build_raylib(compile_debug, shared_lib=true);
		if !ok then return false;
	}

	output_filename: string;
	opts: Generator.Generate_Bindings_Options;
	{
		using opts;

		array_add(*source_files, tprint("%/src/raylib.h", RAYLIB_PATH));
		array_add(*source_files, tprint("%/src/rlgl.h", RAYLIB_PATH));
		// raymath.h must be added after raylib.h because otherwise it tries to generate multiple Vector2 etc
		array_add(*source_files, tprint("%/src/raymath.h", RAYLIB_PATH));

		#if OS == .WINDOWS {
			array_add(*library_search_paths, "windows");
			array_add(*extra_clang_arguments, "-Wno-microsoft-include");
			output_filename = "windows.jai";
		} else #if OS == .LINUX {
			array_add(*library_search_paths, "linux");
			output_filename = "linux.jai";
		} else #if OS == .MACOS {
			array_add(*library_search_paths, "macos");
			output_filename = "macos.jai";
		} else {
			log_error("Platform not supported, please raise an Issue on GitHub.");
			assert(false);
		}

		array_add(*libraries, .{filename="raylib"});
		array_add(*include_paths, RAYLIB_PATH);
		array_add(*include_paths, glfw_include);
		array_add(
			*extra_clang_arguments,
			"-c",
			"-DSUPPORT_MODULE_RSHAPES",
			"-DSUPPORT_MODULE_RTEXTURES",
			"-DSUPPORT_MODULE_RTEXT",
			"-DSUPPORT_MODULE_RMODELS",
			"-DSUPPORT_MODULE_RAUDIO",
			"-DPLATFORM_DESKTOP_GLFW",
		);
		#if OS == .MACOS {
			array_add(*extra_clang_arguments, "-DGRAPHICS_API_OPENGL_33");
		} else {
			array_add(*extra_clang_arguments, "-DGRAPHICS_API_OPENGL_43");
		}

		array_add(*strip_prefixes, "rl");

		// This is because we want to be able to add function declarations in module.jai that are bound to functions in raylib.lib
		generate_library_declarations = false;
		generate_compile_time_struct_checks = false;
		log_stripped_declarations = false;

		visitor   = raylib_visitor;
	}

	return Generator.generate_bindings(opts, output_filename);
}

raylib_visitor :: (decl: *Generator.Declaration, parent_decl: *Generator.Declaration) -> Generator.Declaration_Visit_Result {
	if !parent_decl && array_find(DECLARATIONS_TO_OMIT, decl.name)
	{
		decl.decl_flags |= .OMIT_FROM_OUTPUT;
		return .STOP;
	}

	if decl.kind == .ENUM {
		en := cast(*Generator.Enum)decl;
		if String.contains(decl.name, "Flags") || decl.name == "Gesture" {
			en.flags |= .IS_ENUM_FLAGS;
			en.flags |= .VALUES_IN_HEX;

			if en.type {
				if en.type.size == {
					case 1;
						en.type = context.generator.type_def_u8;
					case 2;
						en.type = context.generator.type_def_u16;
					case 4;
						en.type = context.generator.type_def_u32;
					case 8;
						en.type = context.generator.type_def_u64;
				}
			}
		}
	}

	return .RECURSE;
}

check_has_cmake :: () -> bool {
	command := Process.break_command_into_strings("cmake --version");
	result := Process.run_command(..command);
	return result.exit_code == 0;
}

build_raylib :: (compile_debug: bool, shared_lib: bool) -> bool {
	build_dir := tprint("build_%", ifx shared_lib "shared/" else "static/");
	full_build_dir := tprint("%/%", RAYLIB_PATH, build_dir);
	if FileUtils.is_directory(full_build_dir) then {
		could_delete_build_dir := File.delete_directory(full_build_dir);
		assert(could_delete_build_dir);
	}
	could_make_dir := File.make_directory_if_it_does_not_exist(full_build_dir);
	assert(could_make_dir);

	build_type := ifx compile_debug "Debug" else "Release";
	config_command_string := tprint("cmake -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=% -DCMAKE_BUILD_TYPE=% -B %", ifx shared_lib "ON" else "OFF", build_type, build_dir);

	#if OS == .MACOS {
		could_make_lib_dir := File.make_directory_if_it_does_not_exist("macos");
		assert(could_make_lib_dir);

		// Build arm64
		config_command := Process.break_command_into_strings(config_command_string);
		array_add(*config_command, "-DCMAKE_OSX_DEPLOYMENT_TARGET=11.0.0");
		array_add(*config_command, "-DCMAKE_OSX_ARCHITECTURES=arm64");

		result := Process.run_command(..config_command, RAYLIB_PATH, print_captured_output = true);
		if result.exit_code != 0 {
			print("CMake configuration failed with exit code : %", result.exit_code);
			return false;
		}

		build_command := Process.break_command_into_strings(tprint("cmake --build % -t raylib --config %", build_dir, build_type));
		result = Process.run_command(..build_command, RAYLIB_PATH, print_captured_output = true);
		if result.exit_code != 0 {
			print("CMake build failed with exit code : %", result.exit_code);
			return false;
		}

		ext := ifx shared_lib "dylib" else "a";
		could_copy := FileUtils.copy_file(tprint("%/raylib/libraylib.%", full_build_dir, ext), tprint("macos/raylib_arm64.%", ext));
		assert(could_copy);

		could_delete_build_dir := File.delete_directory(full_build_dir);
		assert(could_delete_build_dir);

		// Build x86
		config_command = Process.break_command_into_strings(config_command_string);
		array_add(*config_command, "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.13.0");
		array_add(*config_command, "-DCMAKE_OSX_ARCHITECTURES=x86_64");

		result = Process.run_command(..config_command, RAYLIB_PATH, print_captured_output = true);
		if result.exit_code != 0 {
			print("CMake configuration failed with exit code : %", result.exit_code);
			return false;
		}

		result = Process.run_command(..build_command, RAYLIB_PATH, print_captured_output = true);
		if result.exit_code != 0 {
			print("CMake build failed with exit code : %", result.exit_code);
			return false;
		}

		could_copy = FileUtils.copy_file(tprint("%/raylib/libraylib.%", full_build_dir, ext), tprint("macos/raylib_x86.%", ext));
		assert(could_copy);

		// Make universal binary
		result = Process.run_command("lipo", "-create", tprint("macos/raylib_x86.%", ext), tprint("macos/raylib_arm64.%", ext), "-output", tprint("macos/raylib.%", ext));
		assert(result.exit_code == 0);
		File.file_delete(tprint("macos/raylib_x86.%", ext));
		File.file_delete(tprint("macos/raylib_arm64.%", ext));
	} else {
		config_command := Process.break_command_into_strings(config_command_string);
		array_add(*config_command, "-DOPENGL_VERSION=4.3");
		result := Process.run_command(..config_command, RAYLIB_PATH, print_captured_output = true);
		if result.exit_code != 0 {
			print("CMake configuration failed with exit code : %", result.exit_code);
			return false;
		}

		build_command := Process.break_command_into_strings(tprint("cmake --build % -t raylib --config %", build_dir, build_type));
		result = Process.run_command(..build_command, RAYLIB_PATH, print_captured_output = true);
		if result.exit_code != 0 {
			print("CMake build failed with exit code : %", result.exit_code);
			return false;
		}
	}

	#if OS == .WINDOWS {
		could_make_lib_dir := File.make_directory_if_it_does_not_exist("windows");
		assert(could_make_lib_dir);

		ext := ifx shared_lib "dll" else "lib";
		could_copy := FileUtils.copy_file(tprint("%/raylib/Release/raylib.%", full_build_dir, ext), tprint("windows/raylib.%", ext));
		assert(could_copy);
	} else #if OS == .LINUX {
		could_make_lib_dir := File.make_directory_if_it_does_not_exist("linux");
		assert(could_make_lib_dir);

		ext := ifx shared_lib "so" else "a";
		could_copy := FileUtils.copy_file(tprint("%/raylib/libraylib.%", full_build_dir, ext), tprint("linux/raylib.%", ext));
		assert(could_copy);
	}

	return true;
}

using Basic :: #import "Basic";
Generator :: #import "Bindings_Generator";
Compiler :: #import "Compiler";
String :: #import "String";
BuildCpp :: #import "BuildCpp";
File :: #import "File";
Process :: #import "Process";
FileUtils :: #import "File_Utilities";
