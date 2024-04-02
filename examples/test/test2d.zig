const std = @import("std");
//const m = std.math;
pub const rl = @cImport({
    @cInclude("raylib.h");
    //@cInclude("raymath.h");
    @cInclude("raygui.h");
});
const bufPrintZ = std.fmt.bufPrintZ;

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.SetTraceLogLevel(rl.LOG_WARNING);
    rl.InitWindow(screen_width, screen_height, "test2d");
    rl.InitAudioDevice();
    defer rl.CloseWindow();
    defer rl.CloseAudioDevice();
    rl.SetTargetFPS(60);

    //music & sound
    var bgm = rl.LoadMusicStream("assets/sot.mp3");
    const fx_wav = rl.LoadSound("assets/sound.wav");
    const fx_ogg = rl.LoadSound("assets/target.ogg");
    defer rl.UnloadMusicStream(bgm);
    defer rl.UnloadSound(fx_wav);
    defer rl.UnloadSound(fx_ogg);

    std.debug.assert(rl.IsMusicReady(bgm));
    rl.PlayMusicStream(bgm);
    bgm.looping = true;

    const tx_background = rl.LoadTexture("assets/background.png");
    const tx_sprite = rl.LoadTexture("assets/scarfy.png");
    defer rl.UnloadTexture(tx_background);
    defer rl.UnloadTexture(tx_sprite);

    //sprite
    var player = Sprite().init(100, 300);
    var mouse_xy: rl.Vector2 = .{};
    var is_mouse_move = false;
    var is_key_down = false;
    var dt: u32 = 0;

    //gui & font
    const font_total = "你我他来中文吧你了太月亮啦23456!,";
    var code_points_count: i32 = 0;
    const code_points = rl.LoadCodepoints(font_total, &code_points_count);
    const font_zh = rl.LoadFontEx("assets/ark_pixel_zh.ttf", 64, code_points, code_points_count);
    defer rl.UnloadFont(font_zh);
    //rl.UnloadCodepoints(code_points);
    rl.GuiSetFont(font_zh);
    rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_SIZE, 24);
    const font_test1: [*]const u8 = "中文中中中";
    const font_test2 = "月亮月月";
    var font_ptr = font_test1;

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        rl.UpdateMusicStream(bgm);
        if(rl.IsKeyDown(rl.KEY_P)) {
            if(rl.IsMusicStreamPlaying(bgm)) rl.PauseMusicStream(bgm)
            else rl.ResumeMusicStream(bgm);
        }
        if(rl.IsKeyDown(rl.KEY_R)) {
            rl.StopMusicStream(bgm);
            rl.PlayMusicStream(bgm);
        }
        if(rl.IsKeyDown(rl.KEY_SPACE)) {
            rl.PlaySound(fx_wav);
        }
        if(rl.IsKeyDown(rl.KEY_ENTER)) {
            rl.PlaySound(fx_ogg);
        }
        if(rl.IsKeyDown(rl.KEY_A)) {
            player.move(-1, 0);
            is_key_down = true;
        } else if(rl.IsKeyDown(rl.KEY_D)) {
            player.move(1, 0);
            is_key_down = true;
        }
        if(rl.IsKeyDown(rl.KEY_W)) {
            player.move(0, -1);
            is_key_down = true;
        } else if(rl.IsKeyDown(rl.KEY_S)) {
            player.move(0, 1);
            is_key_down = true;
        }
        if(rl.IsMouseButtonDown(rl.MOUSE_LEFT_BUTTON)) {
            is_mouse_move = true;
            mouse_xy = rl.GetMousePosition();
        }
        if(is_key_down) is_mouse_move = false;
        if(is_mouse_move) {
            player.moveTo(mouse_xy);
        } else is_mouse_move = false;
        is_key_down = false;
        player.fixPos(rl.Rectangle{.x=0, .y=0, .width=screen_width, .height=screen_height});
        if(dt > 10) { dt = 0;
            player.frame = @rem((player.frame+1) , player.frame_len);
        } dt += 1;
        const frame_x: f32 = player.frame * player.frame_size;
        //draw --
        rl.BeginDrawing();
            rl.DrawTexture(tx_background, 0, 0, rl.WHITE);
            rl.DrawText("Press SPACE to PLAY the WAV sound!", 10, 30, 20, rl.GRAY);
            rl.DrawText("Press ENTER to PLAY the OGG sound!", 10, 50, 20, rl.GRAY);
            rl.DrawText("Press R to REPLAY the MP3!", 10, 70, 20, rl.DARKBROWN);
            rl.DrawTextureRec(tx_sprite, .{.x=frame_x, .y=0, .width=player.frame_size, .height=player.frame_size}, .{.x=player.x-player.frame_size/2, .y=player.y-player.frame_size/2}, rl.WHITE);

            if(rl.GuiButton(rl.Rectangle{.x=500,.y=10,.width=100,.height=30}, "222太亮") != 0) {
                font_ptr = font_test2;
            }
            rl.DrawTextEx(font_zh, font_ptr, rl.Vector2{.x=500, .y=40}, 24, 1, rl.WHITE);
        rl.EndDrawing();
    }
    //deinit --
}
fn Sprite() type {
    return struct {
        const Self = @This();
        x: f32,
        y: f32,
        frame_size: f32 = 128,
        frame_len: f32 = 6,
        frame: f32 = 0,
        speed: f32 = 1,
        fn init(x:f32, y:f32) Self {
            var self = Self{.x=x, .y=y};
            self.x = x;
            self.y = y;
            return self;
        }
        fn move(self:*Self, x:f32, y:f32) void {
            self.x += x;
            self.y += y;
        }
        fn moveTo(self:*Self, vec:rl.Vector2) void {
            if(self.x < vec.x) self.x += self.speed;
            if(self.x > vec.x) self.x -= self.speed;
            if(self.y < vec.y) self.y += self.speed;
            if(self.y > vec.y) self.y -= self.speed;
        }
        fn fixPos(self:*Self, rect:rl.Rectangle) void {
            const hs = rect.x - self.frame_size/2;
            const he = rect.x + rect.width + self.frame_size/2;
            const vs = rect.y - self.frame_size/2;
            const ve = rect.y + rect.height + self.frame_size/2;
            if(self.x < hs) self.x = he
            else if(self.x > he) self.x = hs;
            if(self.y < vs) self.y = ve
            else if(self.y > ve) self.y = vs;
        }
    };
}
