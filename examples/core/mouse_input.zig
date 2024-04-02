const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width: i32 = 800;
const screen_height: i32 = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "mouse_input");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var ball_position = rl.Vector2{.x=-100, .y=-100};
    var ball_color = rl.DARKBLUE;

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        ball_position = rl.GetMousePosition();
        if(rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) ball_color = rl.MAROON
        else if(rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_MIDDLE)) ball_color = rl.LIME
        else if(rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT)) ball_color = rl.DARKBLUE
        else if(rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_SIDE)) ball_color = rl.PURPLE
        else if(rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_EXTRA)) ball_color = rl.YELLOW
        else if(rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_FORWARD)) ball_color = rl.ORANGE
        else if(rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_BACK)) ball_color = rl.BEIGE;
        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            rl.DrawCircleV(ball_position, 40, ball_color);
            rl.DrawText("move ball with mouse and click mouse button to change color", 10, 10, 20, rl.WHITE);


        rl.EndDrawing();
    }
    //deinit --
}
