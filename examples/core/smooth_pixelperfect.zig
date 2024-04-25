const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width: i32 = 800;
const screen_height: i32 = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.SetTraceLogLevel(rl.LOG_WARNING);
    rl.InitWindow(screen_width, screen_height, "smooth_pixelperfect");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    const vsw: i32 = 160;
    const vsh: i32 = 90;
    const vratio: f32 = @as(f32, screen_width) / @as(f32, @floatFromInt(vsw));

    var world_space_camera = rl.Camera2D{};
    world_space_camera.zoom = 1.0;
    var screen_space_camera = rl.Camera2D{};
    screen_space_camera.zoom = 1.0;

    const target = rl.LoadRenderTexture(vsw, vsh);
    defer rl.UnloadRenderTexture(target);
    const rec1 = rl.Rectangle{.x=70, .y=35, .width=20, .height=20};
    const rec2 = rl.Rectangle{.x=90, .y=55, .width=30, .height=10};
    const rec3 = rl.Rectangle{.x=80, .y=65, .width=15, .height=25};

    const source_rec = rl.Rectangle{.x=0, .y=0, .width=@as(f32, @floatFromInt(target.texture.width)), .height=-@as(f32, @floatFromInt(target.texture.height))};
    const dst_rec = rl.Rectangle{.x=-vratio, .y=-vratio, .width=screen_width + (vratio*2), .height=screen_height + (vratio*2)};

    const origin = rl.Vector2{.x=0, .y=0};
    var rotation: f32 = 0;
    var camera_x: f32 = 0;
    var camera_y: f32 = 0;

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        rotation += 60.0 * rl.GetFrameTime();
        const st: f64 = @sin(rl.GetTime()) * 50.0 - 10.0;
        const ct: f64 = @cos(rl.GetTime()) * 30.0;
        camera_x = @as(f32, @floatCast(st));
        camera_y = @as(f32, @floatCast(ct));

        screen_space_camera.target = rl.Vector2{.x=camera_x, .y=camera_y};

        world_space_camera.target.x = screen_space_camera.target.x;
        screen_space_camera.target.x -= world_space_camera.target.x;
        screen_space_camera.target.x *= vratio;

        world_space_camera.target.y = screen_space_camera.target.y;
        screen_space_camera.target.y -= world_space_camera.target.y;
        screen_space_camera.target.y *= vratio;

        //draw --
        rl.BeginTextureMode(target);
            rl.ClearBackground(rl.RAYWHITE);
            rl.BeginMode2D(world_space_camera);
                rl.DrawRectanglePro(rec1, origin, rotation, rl.BLACK);
                rl.DrawRectanglePro(rec2, origin, -rotation, rl.RED);
                rl.DrawRectanglePro(rec3, origin, rotation+45.0, rl.BLUE);
            rl.EndMode2D();
        rl.EndTextureMode();

        rl.BeginDrawing();
            rl.ClearBackground(rl.RED);

            rl.BeginMode2D(screen_space_camera);
                rl.DrawTexturePro(target.texture, source_rec, dst_rec, origin, 0, rl.WHITE);
            rl.EndMode2D();

            rl.DrawText(rl.TextFormat("Screen resolution: %ix%i", screen_width, screen_height), 10, 10, 20, rl.DARKBLUE);
            rl.DrawText(rl.TextFormat("World resolution: %ix%i", vsw, vsh), 10, 40, 20, rl.DARKGREEN);
            rl.DrawFPS(rl.GetScreenWidth() - 95, 10);

            const mouse = rl.GetMousePosition();
            rl.DrawCircle(@intFromFloat(mouse.x), @intFromFloat(mouse.y), 10.0, rl.GRAY);

        rl.EndDrawing();
    }
    //deinit --
}
