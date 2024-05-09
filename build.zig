const std = @import("std");

const examples = .{
    .{"core", .{
        "base_window","random_values","custom_logging","mouse_input",
        "keyboard_input","mouse_wheel","scissor_test","drop_files",
        "storage_values","window_letterbox","window_flags","input_gestures",
        "loading_thread","frame_control","2d_camera_mouse_zoom","2d_camera",
        "2d_camera_split_screen","smooth_pixelperfect","2d_camera_platformer",
        "3d_camera_first_person",
    }},
    .{"textures", .{
        "to_image",
    }},
    .{"test", .{
        "test2d", "test3d",
    }},
};
var target: std.Build.ResolvedTarget = undefined;
var optimize: std.builtin.OptimizeMode = undefined;
var raylib_optimize: std.builtin.OptimizeMode = undefined;
var raylib_dep: *std.Build.Dependency = undefined;
//var strip_flags: [][]const u8 = undefined;
var strip: bool = undefined;
pub fn build(b: *std.Build) void {
    target = b.standardTargetOptions(.{});
    optimize = b.standardOptimizeOption(.{});

    raylib_optimize = b.option(
        std.builtin.OptimizeMode,
        "raylib-optimize",
        "Prioritize performance, safety, or binary size (-O flag), defaults to value of optimize option",
    ) orelse optimize;

    raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = raylib_optimize,
    });
    //const raygui_dep = b.dependency("raygui", .{
        //.target = target,
        //.optimize = raylib_optimize,
    //});

    strip = b.option(
        bool,
        "strip",
        "Strip debug info to reduce binary size, defaults to false",
    ) orelse false;
    //strip_flags = if(strip) .{
        //"-O3",
    //} else .{
        //"-O3",
        ////"-fno-sanitize=undefined", "-O3",
        ////"-g",
    //};

    const is_test = b.option(
        bool,
        "test",
        "only build one test",
    ) orelse false;

    if(is_test) {  // -Dtest
        buildExample(b, "core", "3d_camera_first_person", true);
    } else {
        inline for(examples)|e| {
            const dir = e[0];
            const names = e[1];
            inline for(names)|name| {
                buildExample(b, dir, name, false);
            }
        }
    }
}

fn buildExample(b: *std.Build, comptime dir: []const u8, comptime name: []const u8, comptime only_one: bool) void {
    const cur_dir = "examples/" ++ dir ++ "/";
    const path = cur_dir ++ name ++ ".zig";
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = path },
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.strip = strip;
    exe.addIncludePath(raylib_dep.path("src"));
    //exe.addIncludePath(raygui_dep.path("src"));
    exe.addIncludePath(.{.path = "src"});
    exe.addIncludePath(.{.path = "libs"});
    exe.addCSourceFile(.{
        .file = .{.path = "libs/libs.c"},
        //.flags = &strip_flags,
        .flags = &.{"-O3"},
        //.flags = &.{"-g"},
    });
    exe.linkLibrary(raylib_dep.artifact("raylib"));
    exe.linkLibC();

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    b.step(name, "Run " ++ name).dependOn(&run_cmd.step);
    if(dir.len > 0) b.step(dir ++ "/" ++ name, "Run " ++ name).dependOn(&run_cmd.step);
    if(only_one) {
        b.step("run", "Run " ++ name).dependOn(&run_cmd.step);
    }
}
