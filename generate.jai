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
];

// These are already defined in an non-rl-prefixed version, they come from rlgl
// It is necessary to omit them otherwise the bindings will generate two TraceLogLevel for example
DUPLICATE_DECLARATIONS :: string.[
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

        File.make_directory_if_it_does_not_exist(tprint("%/build", RAYLIB_PATH));

        build_type := ifx compile_debug then { "Debug"; } else { "Release"; }

        config_command := Process.break_command_into_strings(tprint("cmake -DBUILD_EXAMPLES=OFF -DOPENGL_VERSION=4.3 -DINCLUDE_EVERYTHING=ON -DCMAKE_BUILD_TYPE=% -B build/", build_type));
        result, out, error := Process.run_command(..config_command, RAYLIB_PATH, capture_and_return_output = true, print_captured_output = true);
        if result.exit_code != 0 {
            print("CMake configuration failed with exit code : %", result.exit_code);
            return false;
        }

        build_command := Process.break_command_into_strings(tprint("cmake --build build/ -t raylib --config %", build_type));
        result, out, error = Process.run_command(..build_command, RAYLIB_PATH, capture_and_return_output = true, print_captured_output = true);
        if result.exit_code != 0 {
            print("CMake build failed with exit code : %", result.exit_code);
            return false;
        }

        #if OS == .WINDOWS {
            FileUtils.copy_file(tprint("%/build/raylib/Release/raylib.lib", RAYLIB_PATH), "windows/raylib.lib");
        } else {
            assert(false);
        }
    }

    output_filename: string;
    opts: Generator.Generate_Bindings_Options;
    {
        using opts;

        #if OS == .WINDOWS {
            array_add(*libpaths, "windows");
            output_filename = "windows.jai";

            // This will replace `#include <math.h>` with `#include "math.h"` in raymath.h and place it in raymath_pachted.h
            // Needed because clang doesn't have math.h so we want it to use our local math.h.
            could_patch := patch_raymath();
            assert(could_patch);
            array_add(*source_files, tprint("%/src/raylib.h", RAYLIB_PATH));
            // raymath.h must be added after raylib.h because otherwise it tries to generate multiple Vector2 etc
            array_add(*source_files, tprint("%/src/raymath_patched.h", RAYLIB_PATH));
            array_add(*source_files, tprint("%/src/rlgl.h", RAYLIB_PATH));
            array_add(*extra_clang_arguments, "-Wno-microsoft-include");
        } else {
            assert(false);
            // Hopefully this will work on other platforms...
            array_add(*source_files, tprint("%/src/raylib.h", RAYLIB_PATH));
            array_add(*source_files, tprint("%/src/raymath.h", RAYLIB_PATH));
            array_add(*source_files, tprint("%/src/rlgl.h", RAYLIB_PATH));
        }

        array_add(*libnames, "raylib");
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
            "-DGRAPHICS_API_OPENGL_43",
        );
        array_add(*strip_prefixes, "rl");

        // This is because we want to be able to add function declarations in module.jai that are bound to functions in raylib.lib
        generate_library_declarations = false;

        visitor   = raylib_visitor;
    }

    return Generator.generate_bindings(opts, output_filename);
}

raylib_visitor :: (decl: *Generator.Declaration, parent_decl: *Generator.Declaration) -> Generator.Declaration_Visit_Result
{
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

        if array_find(DUPLICATE_DECLARATIONS, decl.name) {
            decl.decl_flags |= .OMIT_FROM_OUTPUT;
            return .STOP;
        }
    }

    return .RECURSE;
}

check_has_cmake :: () -> bool {
    command := Process.break_command_into_strings("cmake --version");
    result := Process.run_command(..command);
    return result.exit_code == 0;
}

patch_raymath :: () -> bool {
    // If this file is there, raylib was already patched
    patched_raymath_path := tprint("%/src/raymath_patched.h", RAYLIB_PATH);
    already_patched := FileUtils.file_exists(patched_raymath_path);
    if already_patched then return true;

    raymath_content := File.read_entire_file(tprint("%/src/raymath.h", RAYLIB_PATH));
    patched_raymath_content := String.replace(raymath_content, "#include <math.h>", "#include \"math.h\"",, temp);
    success := File.write_entire_file(patched_raymath_path, patched_raymath_content);

    return success;
}

using Basic :: #import "Basic";
Generator :: #import "Bindings_Generator";
Compiler :: #import "Compiler";
String :: #import "String";
BuildCpp :: #import "BuildCpp";
File :: #import "File";
WindowsResources :: #import "Windows_Resources";
Process :: #import "Process";
FileUtils :: #import "File_Utilities";
