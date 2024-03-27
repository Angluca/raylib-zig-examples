const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
    @cInclude("raygui.h");
});

const screen_width: i32 = 800;
const screen_height: i32 = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "to_image");
    rl.SetTargetFPS(60);

    var image = rl.LoadImage("assets/raylib_logo.png");
    var texture = rl.LoadTextureFromImage(image); // cpu RAM to gpu VRAM
    rl.UnloadImage(image);

    image = rl.LoadImageFromTexture(texture); // VRAM to RAM
    rl.UnloadTexture(texture);

    texture = rl.LoadTextureFromImage(image);
    rl.UnloadImage(image);
    //loops --
    var dt: f32 = 0;
    while (!rl.WindowShouldClose()) {
        dt = rl.GetFrameTime();
        //update --
        switch (rl.GetKeyPressed()) {
            0 => {},
            else => |key| std.debug.print("Input key:{}\n", .{key}),
        }
        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            rl.DrawTexture(texture, @divTrunc(screen_width, 2) - @divTrunc(texture.width, 2), @divTrunc(screen_height, 2) - @divTrunc(texture.height, 2), rl.LIGHTGRAY);
            rl.DrawText("This IS a texture load from an image!", 300, 370, 10, rl.WHITE);
        rl.EndDrawing();
    }
    //deinit --
    rl.UnloadTexture(texture);
    rl.CloseWindow();
}
