const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 800;
const screen_height = 450;

const player_size = 40;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "2d_camera_split_screen");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var player1 = rl.Rectangle{.x=200, .y=200, .width=player_size, .height=player_size};
    var player2 = rl.Rectangle{.x=250, .y=200, .width=player_size, .height=player_size};
    var camera1 = rl.Camera2D{};
    camera1.target = rl.Vector2{.x=player1.x, .y=player1.y};
    camera1.offset = rl.Vector2{.x=200, .y=200};
    camera1.rotation = 0.0;
    camera1.zoom = 1.0;

    var camera2 = rl.Camera2D{};
    camera2.target = rl.Vector2{.x=player2.x, .y=player2.y};
    camera2.offset = rl.Vector2{.x=200, .y=200};
    camera2.rotation = 0.0;
    camera2.zoom = 1.0;

    const screen_camera1 = rl.LoadRenderTexture(@divTrunc(screen_width, 2), screen_height);
    const screen_camera2 = rl.LoadRenderTexture(@divTrunc(screen_width, 2), screen_height);
    defer rl.UnloadRenderTexture(screen_camera1);
    defer rl.UnloadRenderTexture(screen_camera2);

    const split_screen_rect = rl.Rectangle{.x=0, .y=0, .width=@floatFromInt(screen_camera1.texture.width), .height=@floatFromInt(-screen_camera1.texture.height)};
    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        if(rl.IsKeyDown(rl.KEY_S)) player1.y += 3.0
        else if(rl.IsKeyDown(rl.KEY_W)) player1.y -= 3.0;
        if(rl.IsKeyDown(rl.KEY_A)) player1.x -= 3.0
        else if(rl.IsKeyDown(rl.KEY_D)) player1.x += 3.0;

        if(rl.IsKeyDown(rl.KEY_K)) player2.y += 3.0
        else if(rl.IsKeyDown(rl.KEY_I)) player2.y -= 3.0;
        if(rl.IsKeyDown(rl.KEY_J)) player2.x -= 3.0
        else if(rl.IsKeyDown(rl.KEY_L)) player2.x += 3.0;

        camera1.target = rl.Vector2{.x=player1.x, .y=player1.y};
        camera2.target = rl.Vector2{.x=player2.x, .y=player2.y};
        //draw --
        rl.BeginTextureMode(screen_camera1);
        {
            rl.ClearBackground(rl.DARKGRAY);
            rl.BeginMode2D(camera1);
                const wn = @divTrunc(screen_width,player_size)+1;
                const hn = @divTrunc(screen_height,player_size)+1;
                for(0..wn)|i| {
                    rl.DrawLineV(.{.x=@as(f32, player_size)*@as(f32, @floatFromInt(i)),.y=0}, .{.x=player_size*@as(f32, @floatFromInt(i)),.y=screen_height}, rl.GRAY);
                }
                for(0..hn)|i| {
                    rl.DrawLineV(.{.x=0, .y=@as(f32, player_size)*@as(f32, @floatFromInt(i))}, .{.x=screen_width,.y=player_size*@as(f32, @floatFromInt(i))}, rl.GRAY);
                }
                for(0..wn-1)|i| {
                    for(0..hn-1)|j| {
                        rl.DrawText(rl.TextFormat("[%i,%i]", i, j), 10 + player_size*@as(i32,@intCast(i)), 15 + player_size*@as(i32,@intCast(j)), 10, rl.LIGHTGRAY);
                    }
                }
                rl.DrawRectangleRec(player1, rl.RED);
                rl.DrawRectangleRec(player2, rl.BLUE);
            rl.EndMode2D();

            rl.DrawRectangle(0, 0, @divTrunc(rl.GetScreenWidth(),2), 30, rl.Fade(rl.RAYWHITE, 0.6));
            rl.DrawText("PLAYER1: W/S/A/D to move", 10, 10, 10, rl.MAROON);
        }
        rl.EndTextureMode();

        rl.BeginTextureMode(screen_camera2);
        {
            rl.ClearBackground(rl.DARKGRAY);
            rl.BeginMode2D(camera2);
                const wn = @divTrunc(screen_width,player_size)+1;
                const hn = @divTrunc(screen_height,player_size)+1;
                for(0..wn)|i| {
                    rl.DrawLineV(.{.x=@as(f32, player_size)*@as(f32, @floatFromInt(i)),.y=0}, .{.x=player_size*@as(f32, @floatFromInt(i)),.y=screen_height}, rl.GRAY);
                }
                for(0..hn)|i| {
                    rl.DrawLineV(.{.x=0, .y=@as(f32, player_size)*@as(f32, @floatFromInt(i))}, .{.x=screen_width,.y=player_size*@as(f32, @floatFromInt(i))}, rl.GRAY);
                }
                for(0..wn-1)|i| {
                    for(0..hn-1)|j| {
                        rl.DrawText(rl.TextFormat("[%i,%i]", i, j), 10 + player_size*@as(i32,@intCast(i)), 15 + player_size*@as(i32,@intCast(j)), 10, rl.LIGHTGRAY);
                    }
                }
                rl.DrawRectangleRec(player1, rl.RED);
                rl.DrawRectangleRec(player2, rl.BLUE);
            rl.EndMode2D();

            rl.DrawRectangle(0, 0, @divTrunc(rl.GetScreenWidth(),2), 30, rl.Fade(rl.RAYWHITE, 0.6));
            rl.DrawText("PLAYER2: I/J/K/L to move", 10, 10, 10, rl.DARKBLUE);
        }
        rl.EndTextureMode();

        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            rl.DrawTextureRec(screen_camera1.texture, split_screen_rect, rl.Vector2{.x=0,.y=0}, rl.WHITE);
            rl.DrawTextureRec(screen_camera2.texture, split_screen_rect, rl.Vector2{.x=screen_width / @as(f32,2),.y=0}, rl.WHITE);

            rl.DrawRectangle(@divTrunc(rl.GetScreenWidth(),2) - 2, 0, 4, rl.GetScreenHeight(), rl.LIGHTGRAY);

        rl.EndDrawing();
    }
    //deinit --
}
