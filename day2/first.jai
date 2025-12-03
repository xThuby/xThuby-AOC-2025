Process :: #import "Process";

PROJECT_NAME           :: "aoc";
BUILD_OUTPUT_DIRECTORY :: "run_tree/";

run_game: bool;
release: bool;
track_allocations: bool;

jails_diagnostics: bool;

output_executable_name: string = ---;

plugins: [..] *Metaprogram_Plugin;
plugins_to_create: [..] Plugin_To_Create;

build :: () {
    make_directory_if_it_does_not_exist(BUILD_OUTPUT_DIRECTORY, recursive = true);

    w := compiler_create_workspace(tprint("Target Program: %", PROJECT_NAME));
    if !w {
        print("Workspace creation failed.\n");
        return;
    }


    options := get_build_options(w);
    copy_commonly_propagated_fields(get_build_options(), *options);
    options.temporary_storage_size = 5 * 1024 * 1024; // 5MB temp storage. Default is 32k

    options.output_path = BUILD_OUTPUT_DIRECTORY;

    args := options.compile_time_command_line;
    set_build_options_dc(.{do_output = false, write_added_strings = false});

    run_game = array_find(args, "run");
    release = array_find(args, "release");
    track_allocations = array_find(args, "track_allocations");

    plugin_start_index := -1;
    index := 0;
    while index < args.count {
        defer index += 1;
        it := args[index];
        if it[0] == #char "+" {
            plugin_start_index = index;
            break;
        }
    }

    success: bool;
    // @CopyPasta from Default_Metaprogram
    if plugin_start_index >= 0 {
        success, plugins_to_create = parse_plugin_arguments(args, plugin_start_index);
        if !success  exit(1);
    }

    init_plugins(plugins_to_create, *plugins, w);
    assert(plugins.count == plugins_to_create.count);

    all_success := true;
    for p: plugins {
        c := *plugins_to_create[it_index];
        if p.init {
            success := p.init(p, c.options);
            all_success &&= success;
        } else if c.options {
            log_error("Plugin % takes no options, but these options were given: %\n", c.name, c.options);
        }
    }

    if release {
        if track_allocations print("####################\nTracking allocations in release build!\n####################\n");
        set_optimization(*options, .VERY_OPTIMIZED, false);
        output_executable_name = PROJECT_NAME;
    } else {
        output_executable_name = tprint("%_debug", PROJECT_NAME);
    }
    options.output_executable_name = output_executable_name;

    #if #exists(JAILS_DIAGNOSTICS_BUILD)
    {
        options.output_type = .NO_OUTPUT;
        jails_diagnostics = true;
    }

    set_build_options(options, w);

    // Begin interception
    intercept_flags: Intercept_Flags;
    for plugins if it.before_intercept it.before_intercept(it, *intercept_flags);

    compiler_begin_intercept(w, intercept_flags);

    if track_allocations add_build_string(tprint("TRACK_ALLOCATIONS :: true;\n"), w);
    else add_build_string(tprint("TRACK_ALLOCATIONS :: false;\n"), w);

    if release {
        add_build_string(tprint("DEBUG :: false;\n"), w);
    } else {
        add_build_string(tprint("DEBUG :: true;\n"), w);
    }

    for plugins if it.add_source it.add_source(it);
    add_build_file("main.jai", w);

    message_loop();

    compiler_end_intercept(w);

    for plugins if it.finish   it.finish  (it);
    for plugins if it.shutdown it.shutdown(it);
}

message_loop :: () {
    while true {
        message := compiler_wait_for_message();

        for plugins if it.message it.message(it, message);

        if message.kind == {
            case .ERROR;
                exit(1);
            case .COMPLETE;
                if run_game && !jails_diagnostics {
                    print("\n");
                    Process.run_command(tprint("%/%", BUILD_OUTPUT_DIRECTORY, output_executable_name));
                }
                break;
        }
    }
}

#run,stallable build();

// #run {
//     options := get_build_options();
//     copy_commonly_propagated_fields(get_build_options(), *options);
//
//     args := options.compile_time_command_line;
//     clean := array_find(args, "clean");
//     if clean {
//         clean_build_dir();
//     } else {
//         build();
//     }
// }


#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "String";
#import "Sort";
#import "Metaprogram_Plugins";
