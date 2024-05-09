const std = @import("std");
pub const rl = @cImport({
    //@cDefine("SUPPORT_CUSTOM_FRAME_CONTROL", "1"); //must define in config.h
    @cInclude("raylib.h");
});

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "custom frame_control");
    defer rl.CloseWindow();
    //rl.SetTargetFPS(60);

    var previous_time: f64 = rl.GetTime();
    var current_time: f64 = 0;
    var update_draw_time: f64 = 0;
    var wait_time: f64 = 0;

    var time_counter: f32 = 0;
    var position: f32 = 0;
    var is_pause = false;
    var target_fps: i32 = 60;

    //loops --
    var dt: f32 = 0;
    while (!rl.WindowShouldClose()) {
        //update --
        rl.PollInputEvents();
        if(rl.IsKeyPressed(rl.KEY_SPACE)) is_pause = !is_pause;
        if(rl.IsKeyPressed(rl.KEY_W)) target_fps += 20
        else if(rl.IsKeyPressed(rl.KEY_S)) target_fps -= 20;
        if(target_fps < 0) target_fps = 1;

        if(!is_pause) {
            position += 200 * dt;
            if(@as(i32, @intFromFloat(position)) >= rl.GetScreenWidth()) position = 0;
            time_counter += dt;
        }

        //draw --
        var i: i32 = 0;
        const gsw = rl.GetScreenWidth();
        const gsh = rl.GetScreenHeight();
        const gsw_half: i32 = @divTrunc(gsw, 2);
        const csw: i32 = @divTrunc(gsw, 200);
        const pos: i32 = @intFromFloat(position);
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            while(i < csw):(i += 1) {
                rl.DrawRectangle(200*i, 0, 1, gsh, rl.SKYBLUE);
            }
            rl.DrawCircle(pos, @divTrunc(gsh, 2) - 25, 50, rl.RED);
            rl.DrawText(rl.TextFormat("%03.0f ms", time_counter*1000.0), pos - 40, gsw_half - 100, 20, rl.MAROON);
            rl.DrawText(rl.TextFormat("PosX: %03.0f", position), pos - 50, gsw_half + 40, 20, rl.BLACK);

            rl.DrawText("Circle is moving at a constant 200 pixels/sec,\nindependently of the frame rate.", 10, 10, 20, rl.DARKGRAY);
            rl.DrawText("PRESS SPACE to PAUSE MOVEMENT", 10, gsh - 60, 20, rl.GRAY);
            rl.DrawText("PRESS W | S to CHANGE TARGET FPS", 10, gsh - 30, 20, rl.GRAY);
            rl.DrawText(rl.TextFormat("TARGET FPS: %i", target_fps), gsw - 220, 10, 20, rl.LIME);
            //const ff: f32 = if(dt > 0) @divExact(1, dt) else 0.0;
            const ff: f32 = @as(f32, 1.0) / if(dt>0) dt else 0.0001;
            const fps: i32 = @intFromFloat(ff);
            rl.DrawText(rl.TextFormat("CURRENT FPS: %i", fps), gsw - 220, 40, 20, rl.GREEN);

        rl.EndDrawing();

        rl.SwapScreenBuffer();

        current_time = rl.GetTime();
        update_draw_time = current_time - previous_time;
        if(target_fps > 0) {
            //const dd: f64 = @divExact(1.0, @as(f64, @floatFromInt(target_fps)));
            //wait_time = @divExact(1.0, @as(f64, @floatFromInt(target_fps))) - update_draw_time;
            //const dd: f64 = @as(f64, 1.0) / @as(f64, @floatFromInt(target_fps));
            wait_time = @as(f64, 1.0) / @as(f64, @floatFromInt(target_fps)) - update_draw_time;
            //std.debug.print("w:{}, dd:{}, u:{}, t:{}\n", .{wait_time, dd, update_draw_time, target_fps});
            if(wait_time > 0.0) {
                rl.WaitTime(wait_time);
                current_time = rl.GetTime();
                dt = @floatCast(current_time - previous_time);
            }
        } else dt = @floatCast(update_draw_time);
        previous_time = current_time;
    }
    //deinit --
}
