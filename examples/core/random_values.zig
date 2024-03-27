const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width: i32 = 800;
const screen_height: i32 = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "raylib [core] example - generate random values");
    rl.SetTargetFPS(60);
    var rand_value = rl.GetRandomValue(-8, 5);
    var frame_counter: u32 = 0;
    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        frame_counter += 1;
        if(((frame_counter/120)%2) == 1) {
            rand_value = rl.GetRandomValue(-8, 5);
            frame_counter = 0;
        }
        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            rl.DrawText("Every 2 seconds a new random value is generated:", 130, 100, 20, rl.MAROON);
            rl.DrawText(rl.TextFormat("%i", rand_value), 360, 180, 80, rl.GRAY);
        rl.EndDrawing();
    }
    //deinit --
    rl.CloseWindow();
}
