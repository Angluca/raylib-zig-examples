const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width: i32 = 800;
const screen_height: i32 = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "mouse_wheel");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var box_position_y = screen_height/2 - 40;
    const scroll_speed = 4;

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        box_position_y -= @intFromFloat(rl.GetMouseWheelMove() * scroll_speed);
        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            rl.DrawRectangle(screen_width/2 - 40, box_position_y, 80, 80, rl.MAROON);
            rl.DrawText("Use mouse wheel to move the cube up and down!", 10, 10, 20, rl.GRAY);
            rl.DrawText(rl.TextFormat("Box position Y: %03i", box_position_y), 10, 40, 20, rl.LIGHTGRAY);

        rl.EndDrawing();
    }
    //deinit --
}
