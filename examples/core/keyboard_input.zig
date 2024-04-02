const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width: i32 = 800;
const screen_height: i32 = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "keyboard_input");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var ball_position = rl.Vector2{.x=@floatFromInt(screen_width/2), .y=@floatFromInt(screen_height/2)};

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        if(rl.IsKeyDown(rl.KEY_A)) ball_position.x -= 2.0
        else if(rl.IsKeyDown(rl.KEY_D)) ball_position.x += 2.0;
        if(rl.IsKeyDown(rl.KEY_W)) ball_position.y -= 2.0
        else if(rl.IsKeyDown(rl.KEY_S)) ball_position.y += 2.0;

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            rl.DrawText("move the ball with arrow keys", 10, 10, 20, rl.DARKGRAY);
            rl.DrawCircleV(ball_position, 50, rl.MAROON);

        rl.EndDrawing();
    }
    //deinit --
}
