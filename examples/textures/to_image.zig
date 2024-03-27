const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
});

const screen_width: i32 = 800;
const screen_height: i32 = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.InitWindow(screen_width, screen_height, "raylib [textures] example - texture loading and drawing");
    rl.SetTargetFPS(60);

    var image = rl.LoadImage("assets/raylib_logo.png");
    var texture = rl.LoadTextureFromImage(image); // cpu RAM to gpu VRAM
    rl.UnloadImage(image);

    image = rl.LoadImageFromTexture(texture); // VRAM to RAM
    rl.UnloadTexture(texture);

    texture = rl.LoadTextureFromImage(image);
    rl.UnloadImage(image);
    //loops --
    while (!rl.WindowShouldClose()) {
        //update --

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
