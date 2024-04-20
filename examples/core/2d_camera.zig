const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 800;
const screen_height = 450;

const max_buildings = 100;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "2d_camera");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var player = rl.Rectangle{.x=400, .y=280, .width=40, .height=40};
    var buildings = [_]rl.Rectangle{.{}} ** max_buildings;
    var build_colors: [max_buildings]rl.Color = undefined;
    var spacing: f32 = 0;
    _ = .{&player, &buildings, &build_colors};
    for(0..max_buildings)|i| {
        buildings[i].width = @floatFromInt(rl.GetRandomValue(50, 200));
        buildings[i].height = @floatFromInt(rl.GetRandomValue(100, 800));
        buildings[i].y = screen_height - 130.0 - buildings[i].height;
        buildings[i].x = @as(f32, -6000.0) + spacing;

        spacing += buildings[i].width;
        build_colors[i] = .{.r=@intCast(rl.GetRandomValue(200,200)), .g=@intCast(rl.GetRandomValue(200,240)), .b=@intCast(rl.GetRandomValue(200,250)), .a=255};
    }

    var camera = rl.Camera2D{};
    camera.target = .{.x=player.x + 20.0, .y=player.y + 20.0};
    camera.offset = .{.x=@divTrunc(screen_width, 2), .y=@divTrunc(screen_height, 2)};
    camera.rotation = 0.0;
    camera.zoom = 1.0;

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        if(rl.IsKeyDown(rl.KEY_D)) player.x += 2
        else if(rl.IsKeyDown(rl.KEY_A)) player.x -= 2;
        camera.target = .{.x=player.x+20, .y=player.y+20};

        if(rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)) camera.rotation -= 1
        else if(rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT)) camera.rotation += 1;
        if(camera.rotation > 40) camera.rotation = 40
        else if(camera.rotation < -40) camera.rotation = -40;

        camera.zoom += rl.GetMouseWheelMove() * 0.5;
        if(camera.zoom > 3.0) camera.zoom = 3.0
        else if(camera.zoom < 0.1) camera.zoom = 0.1;

        if(rl.IsKeyPressed(rl.KEY_R)) {
            camera.zoom = 1.0;
            camera.rotation = 0;
        }

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            rl.BeginMode2D(camera);
                rl.DrawRectangle(-6000, 320, 13000, 8000, rl.DARKGRAY);
                for(0..max_buildings)|i| rl.DrawRectangleRec(buildings[i], build_colors[i]);
                rl.DrawRectangleRec(player, rl.RED);
                rl.DrawLine(@intFromFloat(camera.target.x), -screen_height*10, @intFromFloat(camera.target.x), screen_height*10, rl.GREEN);
                rl.DrawLine(-screen_width*10, @intFromFloat(camera.target.y), screen_width*10, @intFromFloat(camera.target.y), rl.GREEN);
            rl.EndMode2D();

            rl.DrawText("SCREEN AREA", 640, 10, 20, rl.RED);

            rl.DrawRectangle(0, 0, screen_width, 5, rl.RED);
            rl.DrawRectangle(0, 5, 5, screen_height - 10, rl.RED);
            rl.DrawRectangle(screen_width - 5, 5, 5, screen_height - 10, rl.RED);
            rl.DrawRectangle(0, screen_height - 5, screen_width, 5, rl.RED);

            rl.DrawText("Free 2d camera controls:", 20, 20, 10, rl.BLACK);
            rl.DrawText("- D / A to move Offset", 40, 40, 10, rl.DARKGRAY);
            rl.DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, rl.DARKGRAY);
            rl.DrawText("- Mouse left / right to Rotate", 40, 80, 10, rl.DARKGRAY);
            rl.DrawText("- R to reset Zoom and Rotation", 40, 100, 10, rl.DARKGRAY);
        rl.EndDrawing();
    }
    //deinit --
}
