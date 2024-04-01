const std = @import("std");

const examples = .{
    //.{"", .{"main"}},
    .{"core", .{"random_values", "custom_logging"}},
    .{"textures", .{"to_image"}},
    .{"test", .{"test2d", "test3d"}},
};
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_optimize = b.option(
        std.builtin.OptimizeMode,
        "raylib-optimize",
        "Prioritize performance, safety, or binary size (-O flag), defaults to value of optimize option",
    ) orelse optimize;

    const strip = b.option(
        bool,
        "strip",
        "Strip debug info to reduce binary size, defaults to false",
    ) orelse false;
    const strip_flags = .{"-O3"};
    //const strip_flags = if(strip) .{
        //"-O3",
    //} else .{
        //"-g", "-fno-sanitize=undefined", "-O3",
    //};

    const raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = raylib_optimize,
    });

    const raygui_dep = b.dependency("raygui", .{
        .target = target,
        .optimize = raylib_optimize,
    });

    inline for(examples)|e| {
        const dir = e[0];
        const names = e[1];
        inline for(names)|name| {
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
            exe.addIncludePath(raygui_dep.path("src"));
            exe.addIncludePath(.{.path = "src"});
            exe.addIncludePath(.{.path = "libs"});
            exe.addCSourceFile(.{
                .file = .{.path = "libs/libs.c"},
                .flags = &strip_flags,
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
            if(dir.len > 0)
                b.step(dir ++ "-" ++ name, "Run " ++ name).dependOn(&run_cmd.step);
        }
    }
}
