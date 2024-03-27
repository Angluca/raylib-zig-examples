const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
    @cInclude("raygui.h");
});

const screen_width: i32 = 800;
const screen_height: i32 = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.SetTraceLogLevel(rl.LOG_WARNING);
    rl.InitWindow(screen_width, screen_height, "myapp");
    rl.SetTargetFPS(60);
    //loops --
    var dt: f32 = 0;
    while (!rl.WindowShouldClose()) {
        dt = rl.GetFrameTime();
        //update --
        switch (rl.GetKeyPressed()) {
            0 => {},
            else => |key| std.debug.print("Input key:{}\n", .{key}),
        }

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);

        rl.EndDrawing();
    }
    //deinit --
    rl.CloseWindow();
}
