const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "window_flags");
    defer rl.CloseWindow();
    rl.SetTargetFPS(120);

    var frame_counter: u32 = 0;
    var ball_position = rl.Vector2{.x=screen_width/2, .y=screen_height/2};
    var ball_speed = rl.Vector2{.x=4.0, .y=2.0};
    const ball_radius: f32 = 60;

    var mouse = rl.GetMousePosition();
    const mouse_radius: f32 = 40;
    var old_mouse = mouse;
    var is_collision = false;

    //rl.SetConfigFlags(rl.FLAG_WINDOW_TRANSPARENT | rl.FLAG_MSAA_4X_HINT | rl.FLAG_WINDOW_HIGHDPI);
    //rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT | rl.FLAG_WINDOW_HIGHDPI);
    rl.SetWindowState(rl.FLAG_VSYNC_HINT | rl.FLAG_WINDOW_RESIZABLE);

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        if(rl.IsKeyPressed(rl.KEY_F)) rl.ToggleFullscreen();
        if(rl.IsKeyPressed(rl.KEY_R)) {
            if(rl.IsWindowState(rl.FLAG_WINDOW_RESIZABLE))
                rl.ClearWindowState(rl.FLAG_WINDOW_RESIZABLE)
            else rl.SetWindowState(rl.FLAG_WINDOW_RESIZABLE);
        }
        if(rl.IsKeyPressed(rl.KEY_D)) {
            if(rl.IsWindowState(rl.FLAG_WINDOW_UNDECORATED))
                rl.ClearWindowState(rl.FLAG_WINDOW_UNDECORATED)
            else rl.SetWindowState(rl.FLAG_WINDOW_UNDECORATED);
        }

        if(rl.IsKeyPressed(rl.KEY_H)) {
            if(rl.IsWindowState(rl.FLAG_WINDOW_HIDDEN))
                rl.SetWindowState(rl.FLAG_WINDOW_HIDDEN);
            frame_counter = 0;
        }
        if(rl.IsWindowState(rl.FLAG_WINDOW_HIDDEN)) {
            frame_counter += 1;
            if(frame_counter >= 240) rl.ClearWindowState(rl.FLAG_WINDOW_HIDDEN);
        }

        if(rl.IsKeyPressed(rl.KEY_N)) {
            if(rl.IsWindowState(rl.FLAG_WINDOW_MINIMIZED)) rl.MinimizeWindow();
            frame_counter = 0;
        }
        if(rl.IsWindowState(rl.FLAG_WINDOW_MINIMIZED)) {
            frame_counter += 1;
            if(frame_counter >= 240) rl.RestoreWindow();
        }

        if(rl.IsKeyPressed(rl.KEY_M)) {
            if(rl.IsWindowState(rl.FLAG_WINDOW_MAXIMIZED)) rl.RestoreWindow()
            else rl.MaximizeWindow();
        }
        if(rl.IsKeyPressed(rl.KEY_U)) {
            if(rl.IsWindowState(rl.FLAG_WINDOW_UNFOCUSED))
                rl.ClearWindowState(rl.FLAG_WINDOW_UNFOCUSED)
            else rl.SetWindowState(rl.FLAG_WINDOW_UNFOCUSED);
        }
        if(rl.IsKeyPressed(rl.KEY_T)) {
            if(rl.IsWindowState(rl.FLAG_WINDOW_TOPMOST))
                rl.ClearWindowState(rl.FLAG_WINDOW_TOPMOST)
            else rl.SetWindowState(rl.FLAG_WINDOW_TOPMOST);
        }
        if(rl.IsKeyPressed(rl.KEY_A)) {
            if(rl.IsWindowState(rl.FLAG_WINDOW_ALWAYS_RUN))
                rl.ClearWindowState(rl.FLAG_WINDOW_ALWAYS_RUN)
            else rl.SetWindowState(rl.FLAG_WINDOW_ALWAYS_RUN);
        }
        if(rl.IsKeyPressed(rl.KEY_V)) {
            if(rl.IsWindowState(rl.FLAG_VSYNC_HINT))
                rl.ClearWindowState(rl.FLAG_VSYNC_HINT)
            else rl.SetWindowState(rl.FLAG_VSYNC_HINT);
        }

        const sw: f32 = @floatFromInt(rl.GetScreenWidth());
        const sh: f32 = @floatFromInt(rl.GetScreenHeight());
        mouse = rl.GetMousePosition();
        is_collision = rl.CheckCollisionCircles(mouse, mouse_radius, ball_position, ball_radius);
        if(is_collision) {
            //const on = rl.Vector2{.x=mou}
            const vec = rl.Vector2Subtract(mouse, ball_position);
            //const rv = rl.Vector2Normalize(rl.Vector2Refract(mouse, vec, ball_radius + mouse_radius));
            const rv = rl.Vector2Normalize(rl.Vector2Refract(mouse, vec, ball_radius + mouse_radius));
            //const dist = @sqrt(vec.x * vec.x + vec.y * vec.y);
            //const sp = rl.Vector2Distance(mouse, old_mouse);
            ball_speed.x = rv.x * 10;//+ rv.x * dist * 0.1;
            ball_speed.y = rv.x * 10;//+ rv.y * dist * 0.1;
            //if(dist < (ball_radius + mouse_radius)) {
                //ball_speed.x *= 1.6;
                //ball_speed.y *= 1.6;
            //}
        }
        ball_position.x += ball_speed.x;
        ball_position.y += ball_speed.y;
        ball_speed.x *= 0.99;
        ball_speed.y *= 0.99;

        if((ball_position.x >= (sw - ball_radius)) or (ball_position.x <= ball_radius)) {
            ball_speed.x *= -1.0;
            ball_position.x = if(ball_position.x > sw/2) sw-ball_radius else ball_radius;
        }
        if((ball_position.y >= (sh - ball_radius)) or (ball_position.y <= ball_radius)) {
            ball_speed.y *= -1.0;
            ball_position.y = if(ball_position.y > sh/2) sh-ball_radius else ball_radius;
        }

        old_mouse = mouse;

        //draw --
        rl.BeginDrawing();
            if(rl.IsWindowState(rl.FLAG_WINDOW_TRANSPARENT))
                rl.ClearBackground(rl.BLANK)
            else rl.ClearBackground(rl.DARKGRAY);

            rl.DrawCircleV(ball_position, ball_radius, rl.MAROON);
            rl.DrawRectangleLinesEx(rl.Rectangle{.x=0,.y=0,.width=sw,.height=sh}, 4, rl.RAYWHITE);
            rl.DrawCircleV(mouse, mouse_radius, rl.DARKBLUE);
            rl.DrawFPS(10, 10);
            rl.DrawText(rl.TextFormat("Screen Size: [%i, %i]", sw, sh), 10, 40, 10, rl.GREEN);

            rl.DrawText("Following flags can be set after window creation:", 10, 60, 10, rl.GRAY);
            if (rl.IsWindowState(rl.FLAG_FULLSCREEN_MODE)) rl.DrawText("[F] FLAG_FULLSCREEN_MODE: on", 10, 80, 10, rl.LIME)
            else rl.DrawText("[F] FLAG_FULLSCREEN_MODE: off", 10, 80, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_WINDOW_RESIZABLE)) rl.DrawText("[R] FLAG_WINDOW_RESIZABLE: on", 10, 100, 10, rl.LIME)
            else rl.DrawText("[R] FLAG_WINDOW_RESIZABLE: off", 10, 100, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_WINDOW_UNDECORATED)) rl.DrawText("[D] FLAG_WINDOW_UNDECORATED: on", 10, 120, 10, rl.LIME)
            else rl.DrawText("[D] FLAG_WINDOW_UNDECORATED: off", 10, 120, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_WINDOW_HIDDEN)) rl.DrawText("[H] FLAG_WINDOW_HIDDEN: on", 10, 140, 10, rl.LIME)
            else rl.DrawText("[H] FLAG_WINDOW_HIDDEN: off", 10, 140, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_WINDOW_MINIMIZED)) rl.DrawText("[N] FLAG_WINDOW_MINIMIZED: on", 10, 160, 10, rl.LIME)
            else rl.DrawText("[N] FLAG_WINDOW_MINIMIZED: off", 10, 160, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_WINDOW_MAXIMIZED)) rl.DrawText("[M] FLAG_WINDOW_MAXIMIZED: on", 10, 180, 10, rl.LIME)
            else rl.DrawText("[M] FLAG_WINDOW_MAXIMIZED: off", 10, 180, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_WINDOW_UNFOCUSED)) rl.DrawText("[G] FLAG_WINDOW_UNFOCUSED: on", 10, 200, 10, rl.LIME)
            else rl.DrawText("[U] FLAG_WINDOW_UNFOCUSED: off", 10, 200, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_WINDOW_TOPMOST)) rl.DrawText("[T] FLAG_WINDOW_TOPMOST: on", 10, 220, 10, rl.LIME)
            else rl.DrawText("[T] FLAG_WINDOW_TOPMOST: off", 10, 220, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_WINDOW_ALWAYS_RUN)) rl.DrawText("[A] FLAG_WINDOW_ALWAYS_RUN: on", 10, 240, 10, rl.LIME)
            else rl.DrawText("[A] FLAG_WINDOW_ALWAYS_RUN: off", 10, 240, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_VSYNC_HINT)) rl.DrawText("[V] FLAG_VSYNC_HINT: on", 10, 260, 10, rl.LIME)
            else rl.DrawText("[V] FLAG_VSYNC_HINT: off", 10, 260, 10, rl.MAROON);

            rl.DrawText("Following flags can only be set before window creation:", 10, 300, 10, rl.GRAY);
            if (rl.IsWindowState(rl.FLAG_WINDOW_HIGHDPI)) rl.DrawText("FLAG_WINDOW_HIGHDPI: on", 10, 320, 10, rl.LIME)
            else rl.DrawText("FLAG_WINDOW_HIGHDPI: off", 10, 320, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_WINDOW_TRANSPARENT)) rl.DrawText("FLAG_WINDOW_TRANSPARENT: on", 10, 340, 10, rl.LIME)
            else rl.DrawText("FLAG_WINDOW_TRANSPARENT: off", 10, 340, 10, rl.MAROON);
            if (rl.IsWindowState(rl.FLAG_MSAA_4X_HINT)) rl.DrawText("FLAG_MSAA_4X_HINT: on", 10, 360, 10, rl.LIME)
            else rl.DrawText("FLAG_MSAA_4X_HINT: off", 10, 360, 10, rl.MAROON);

        rl.EndDrawing();
    }
    //deinit --
}
