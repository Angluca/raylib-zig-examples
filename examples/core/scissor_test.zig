const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "scissor_test");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var scissor_area = rl.Rectangle{.x=0,.y=0,.width=300,.height=300};
    var scissor_mode = true;

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        if(rl.IsKeyPressed(rl.KEY_SPACE)) scissor_mode = !scissor_mode;
        if(rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT)) scissor_mode = !scissor_mode;

        scissor_area.x = @as(f32, @floatFromInt(rl.GetMouseX())) - scissor_area.width/2;
        scissor_area.y = @as(f32, @floatFromInt(rl.GetMouseY())) - scissor_area.height/2;

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);

            if(scissor_mode) rl.BeginScissorMode(@intFromFloat(scissor_area.x), @intFromFloat(scissor_area.y), @intFromFloat(scissor_area.width), @intFromFloat(scissor_area.height));

                rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.RED);
                rl.DrawText("Move the mouse around to reveal this text!", 190, 200, 20, rl.LIGHTGRAY);

            if(scissor_mode) rl.EndScissorMode();

            rl.DrawRectangleLinesEx(scissor_area, 1, rl.BLACK);
            rl.DrawText("Press Space or M.Left to toggle scissor test", 10, 10, 20, rl.BLACK);

        rl.EndDrawing();
    }
    //deinit --
}
