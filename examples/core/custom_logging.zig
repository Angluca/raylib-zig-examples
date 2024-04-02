const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});
pub const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("time.h");
});

const screen_width = 800;
const screen_height = 450;

pub fn customLog(msg_type: c_int, fmt:[*:0]const u8, ...) callconv(.C) void {
    const time_str: [*]u8 = @constCast(&([_]u8{0} ** 64));
    const now = c.time(0);
    const tm_info = c.localtime(&now);
    _ = c.strftime(time_str, 64, "%Y-%m-%d %H:%M:%S", tm_info);
    _ = c.printf("[%s]", time_str);
    switch(msg_type) {
        rl.LOG_INFO => _ = c.printf("[INFO]"),
        rl.LOG_ERROR => _ = c.printf("[ERROR]"),
        rl.LOG_WARNING => _ = c.printf("[WARNING]"),
        rl.LOG_DEBUG => _ = c.printf("[DEBUG]"),
        else => _ = c.printf("[ANOTHER]"),
    }
    var ap = @cVaStart();
    defer @cVaEnd(&ap);
    _ = c.vprintf(fmt, @ptrCast(&ap));
    _ = c.printf("\n");
}

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "custom_logging");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    rl.SetTraceLogCallback(@ptrCast(&customLog));

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            rl.DrawText("Check out the console output to see the custom logger in action!", 60, 200, 20, rl.LIGHTGRAY);

        rl.EndDrawing();
    }
    //deinit --
}
