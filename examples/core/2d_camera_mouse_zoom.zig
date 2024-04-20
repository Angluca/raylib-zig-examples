const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
    @cInclude("rlgl.h");
});

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "2d_camera_mouse_zoom");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var camera = rl.Camera2D{};
    camera.zoom = 1.0;

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        if(rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT) or
            rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT)) {
            var delta = rl.GetMouseDelta();
            delta =rl.Vector2Scale(delta, @as(f32, -1.0) / camera.zoom);
            camera.target = rl.Vector2Add(camera.target, delta);
        }

        const wheel = rl.GetMouseWheelMove();
        if(wheel != 0) {
            const mouse_world_pos = rl.GetScreenToWorld2D(rl.GetMousePosition(), camera);
            camera.offset = rl.GetMousePosition();
            camera.target = mouse_world_pos;
            const zoom_increment: f32 = 0.125;
            camera.zoom += (wheel * zoom_increment);
            if(camera.zoom < zoom_increment) camera.zoom = zoom_increment;
        }

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            rl.BeginMode2D(camera);
                rl.rlPushMatrix();
                    rl.rlTranslatef(0, 25*50, 0);
                    rl.rlRotatef(90, 1, 0, 0);
                    rl.DrawGrid(100, 50);
                rl.rlPopMatrix();

                rl.DrawCircle(100, 100, 50, rl.BLUE);
            rl.EndMode2D();

            rl.DrawText("Mouse left or right button drag to move, mouse wheel to zoom", 10, 10, 20, rl.WHITE);
        rl.EndDrawing();
    }
    //deinit --
}
