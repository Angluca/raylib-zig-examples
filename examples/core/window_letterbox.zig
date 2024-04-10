const std = @import("std");
const math = std.math;
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "window_letterbox");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE | rl.FLAG_VSYNC_HINT);
    rl.SetWindowMinSize(320, 240);
    const game_screen_width: i32 = 640;
    const game_screen_height: i32 = 480;

    const target = rl.LoadRenderTexture(game_screen_width, game_screen_height);
    rl.SetTextureFilter(target.texture, rl.TEXTURE_FILTER_BILINEAR);
    defer rl.UnloadRenderTexture(target);

    var colors: [10]rl.Color = [_]rl.Color{.{.a=255}} ** 10;
    inline for(&colors)|*color| {
        color.r = @intCast(rl.GetRandomValue(100, 255));
        color.g = @intCast(rl.GetRandomValue(50, 150));
        color.b = @intCast(rl.GetRandomValue(10, 100));
    }

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        if(rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
            for(&colors)|*color| {
                color.* = .{.r=@intCast(rl.GetRandomValue(100, 255)), .g=@intCast(rl.GetRandomValue(50, 150)), .b=@intCast(rl.GetRandomValue(10, 100)), .a=255};
            }
        }

        const sw: f32 = @floatFromInt(rl.GetScreenWidth());
        const sh: f32 = @floatFromInt(rl.GetScreenHeight());
        const gsw: f32 = @floatFromInt(game_screen_width);
        const gsh: f32 = @floatFromInt(game_screen_height);
        const scale: f32 = @min(sw/gsw, sh/gsh);
        const mouse = rl.GetMousePosition();

        var virtual_mouse: rl.Vector2 = .{};
        const vx: f32 = (mouse.x - (sw - (gsw * scale)) * 0.5)/scale;
        const vy: f32 = (mouse.y - (sh - (gsh * scale)) * 0.5)/scale;
        virtual_mouse.x = math.clamp(vx, 0, gsw);
        virtual_mouse.y = math.clamp(vy, 0, gsh);

        //draw --
        rl.BeginTextureMode(target);
            for(&colors, 0..)|*color, i| {
                rl.DrawRectangle(0, game_screen_height/10 * @as(i32, @intCast(i)), game_screen_width, game_screen_height/10, color.*);
            }

            rl.DrawText("If executed inside a window,\nyou can resize the window,\nand see the screen scaling!", 10, 25, 20, rl.WHITE);
            rl.DrawText(rl.TextFormat("Default Mouse: [%i , %i]", @as(i32, @intFromFloat(mouse.x)), @as(i32, @intFromFloat(mouse.y))), 350, 25, 20, rl.GREEN);
            rl.DrawText(rl.TextFormat("Virtual Mouse: [%i , %i]", @as(i32, @intFromFloat(virtual_mouse.x)), @as(i32, @intFromFloat(virtual_mouse.y))), 350, 55, 20, rl.YELLOW);
        rl.EndTextureMode();

        const r1 = rl.Rectangle{.x=0,.y=0,.width=@floatFromInt(target.texture.width),.height=@floatFromInt(-target.texture.height)};
        const r2 = rl.Rectangle{.x=(sw - (gsw*scale))*0.5,.y=(sh - (gsh*scale))*0.5,.width=gsw*scale,.height=gsh*scale};
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            rl.DrawTexturePro(target.texture, r1, r2, rl.Vector2{.x=0,.y=0}, 0, rl.WHITE);
        rl.EndDrawing();
    }
    //deinit --
}
