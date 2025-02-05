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
    rl.SetTraceLogLevel(rl.LOG_WARNING);
    rl.InitWindow(screen_width, screen_height, "2d_camera_platformer");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var player = Player.init(400, 200, 0);
    const envItems = [_]EnvItem {
        EnvItem.init(0, 0, 1000, 400, false, rl.LIGHTGRAY),
        EnvItem.init(0, 400, 1000, 200, true, rl.GRAY),
        EnvItem.init(300, 200, 400, 10, true, rl.GRAY),
        EnvItem.init(250, 300, 100, 10, true, rl.GRAY),
        EnvItem.init(650, 300, 100, 10, true, rl.GRAY),
    };
    var camera: rl.Camera2D = undefined;
    camera.target = player.position;
    camera.offset = .{.x=screen_width/2.0, .y=screen_height/2.0};
    camera.rotation = 0.0;
    camera.zoom = 1.0;
    const UpdateFn = *const fn(*rl.Camera2D,*Player,[]const EnvItem,f32,f32,f32) void;
    const cameraUpdates = [_]UpdateFn{
        &updateCameraCenterSmoothFollow,
        &updateCameraEvenOutOnLanding,
        &updateCameraInsideMap,
        &updateCameraCenter,
        &updateCameraPlayerBoundsPush,
    };
    var camera_option: usize = 0;
    const camera_descriptions = [_][*]const u8 {
        "Follow player center; smoothed",
        "Follow player center horizontally; update player center vertically after landing",
        "Follow player center, but clamp to map edges",
        "Follow player center",
        "Player push camera on getting too close to screen edge",
    };
    var recorder = Recorder.init(&player, &camera);
    defer recorder.deinit();

    //loops --
    var dt: f32 = 0;
    while (!rl.WindowShouldClose()) {
        //update --
        dt = rl.GetFrameTime();

        recorder.dropFile();
        updatePlayer(&player, &envItems, dt);

        camera.zoom += rl.GetMouseWheelMove() * 0.05;
        if(camera.zoom > 3.0) camera.zoom = 3.0
        else if(camera.zoom < 0.25) camera.zoom = 0.25;

        switch (rl.GetKeyPressed()) {
            rl.KEY_R => {
                recorder.resetScreen();
            },
            rl.KEY_C => camera_option = @mod(camera_option + 1, cameraUpdates.len),
            else => undefined,
        }

        cameraUpdates[camera_option](&camera, &player, &envItems, dt, screen_width, screen_height);
        recorder.update();

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.LIGHTGRAY);
            rl.BeginMode2D(camera);
                for(envItems)|it| {
                    rl.DrawRectangleRec(it.rect, it.color);
                }
                const player_rect = rl.Rectangle{.x=player.position.x - 20, .y=player.position.y - 40, .width=40, .height=40};
                rl.DrawRectangleRec(player_rect, rl.RED);
                rl.DrawCircle(@intFromFloat(player.position.x), @intFromFloat(player.position.y), 5, rl.GOLD);
            rl.EndMode2D();

            rl.DrawRectangle(10, 10, 290, 210, rl.Fade(rl.SKYBLUE, 0.5));
            rl.DrawRectangleLines(10, 10, 290, 210, rl.Fade(rl.BLUE, 0.8));

            rl.DrawText("Controls:", 20, 20, 10, rl.BLACK);
            rl.DrawText("- Right/Left or A/D to move", 40, 40, 10, rl.DARKGRAY);
            rl.DrawText("- Space to jump", 40, 60, 10, rl.DARKGRAY);
            rl.DrawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, rl.DARKGRAY);
            rl.DrawText("- C to change camera mode", 40, 100, 10, rl.DARKGRAY);
            rl.DrawText("Current camera mode:", 20, 120, 10, rl.BLACK);
            rl.DrawText(camera_descriptions[camera_option], 40, 140, 10, rl.DARKGRAY);
            recorder.draw();

        rl.EndDrawing();
    }
    //deinit --
}

fn updatePlayer(player: *Player, envItems: []const EnvItem, delta: f32) void {
    if(rl.IsKeyDown(rl.KEY_A) or rl.IsKeyDown(rl.KEY_LEFT)) {
        player.position.x -= player.hor_spd * delta;
    }
    else if(rl.IsKeyDown(rl.KEY_D) or rl.IsKeyDown(rl.KEY_RIGHT)) {
        player.position.x += player.hor_spd * delta;
    }
    if(player.can_jump and rl.IsKeyDown(rl.KEY_SPACE)) {
        player.speed = -player.jump_spd;
        player.can_jump = false;
    }
    var hit_obstacle = false;
    for(envItems)|it| {
        const pos = &player.position;
        if(it.blocking and
            it.rect.x <= pos.x and
            it.rect.x + it.rect.width >= pos.x and
            it.rect.y >= pos.y and
            it.rect.y <= pos.y + player.speed*delta)
        {
            hit_obstacle = true;
            player.speed = 0;
            pos.y = it.rect.y;
            break;
        }
    }
    if(!hit_obstacle) {
        player.position.y += player.speed * delta;
        player.speed += player.gravity * delta;
        player.can_jump = false;
    } else player.can_jump = true;

    const over_width: f32 = screen_width * 2;
    const over_height: f32 = screen_height * 3;
    if(player.position.x > over_width) player.position.x = -screen_width
    else if(player.position.x < -screen_width) player.position.x = over_width;
    if(player.position.y > over_height) player.position.y = -over_height
    else if(player.position.y < -screen_height) player.position.y = -screen_height;
}

fn updateCameraCenter(camera: *rl.Camera2D, player: *Player, envItems: []const EnvItem, delta: f32, width: f32, height: f32) void {
    _ = .{&player, &envItems, &delta};
    camera.target = player.position;
    camera.offset = .{.x=width/2.0, .y=height/2};
}

fn updateCameraInsideMap(camera: *rl.Camera2D, player: *Player, envItems: []const EnvItem, delta: f32, width: f32, height: f32) void {
    _ = .{&player, &envItems, &delta};
    camera.target = player.position;
    camera.offset = .{.x=width/2.0, .y=height/2};
    var minx: f32 = -400; var miny: f32 = -1000;
    var maxx: f32 = -minx; var maxy: f32 = -miny;
    for(envItems)|it| {
        minx = rl.fminf(it.rect.x, minx);
        maxx = rl.fmaxf(it.rect.x + it.rect.width * 1.4, maxx);
        miny = rl.fminf(it.rect.y, miny);
        maxy = rl.fmaxf(it.rect.y + it.rect.height, maxy);
    }
    const max = rl.GetWorldToScreen2D(.{.x=maxx, .y=maxy}, camera.*);
    const min = rl.GetWorldToScreen2D(.{.x=minx, .y=miny}, camera.*);
    if(max.x < width) camera.offset.x = width - (max.x - width/2);
    if(max.y < height) camera.offset.y = height - (max.y - height/2);
    if(min.x > 0) camera.offset.x = width/2 - min.x;
    if(min.y > 0) camera.offset.y = height/2 - min.y;
}

fn updateCameraCenterSmoothFollow(camera: *rl.Camera2D, player: *Player, envItems: []const EnvItem, delta: f32, width: f32, height: f32) void {
    _ = .{&player, &envItems, &delta};
    const tmp = struct {
        var min_speed: f32 = 200;
        var min_effect_length: f32 = 10;
        var fraction_speed: f32 = 0.8;
    };
    camera.offset = .{.x=width/2, .y=height/2};
    const diff = rl.Vector2Subtract(player.position, camera.target);
    const length = rl.Vector2Length(diff);
    if(length > tmp.min_effect_length) {
        const speed = rl.fmaxf(tmp.fraction_speed * length, tmp.min_speed);
        camera.target = rl.Vector2Add(camera.target, rl.Vector2Scale(diff, speed * delta/length));
    }
}

fn updateCameraEvenOutOnLanding(camera: *rl.Camera2D, player: *Player, envItems: []const EnvItem, delta: f32, width: f32, height: f32) void {
    _ = .{&player, &envItems, &delta};
    const tmp = struct {
        var even_out_speed: f32 = 700;
        var evening_out: bool = false;
        var even_out_taget: f32 = 0;
    }; _ = &tmp;
    camera.target.x = player.position.x;
    camera.offset = .{.x=width/2.0, .y=height/2};
    if(tmp.evening_out) {
        if(tmp.even_out_taget > camera.target.y) {
            camera.target.y += tmp.even_out_speed * delta * 0.3;
            if(camera.target.y > tmp.even_out_taget) {
                camera.target.y = tmp.even_out_taget;
                tmp.evening_out = false;
            }
        } else {
            camera.target.y -= tmp.even_out_speed * delta * 0.3;
            if(camera.target.y < tmp.even_out_taget) {
                camera.target.y = tmp.even_out_taget;
                tmp.evening_out = false;
            }
        }
    } else {
        if(player.can_jump and (player.speed == 0) and (player.position.y != camera.target.y)) {
            tmp.evening_out = true;
            tmp.even_out_taget = player.position.y;
        }
    }
}

fn updateCameraPlayerBoundsPush(camera: *rl.Camera2D, player: *Player, envItems: []const EnvItem, delta: f32, width: f32, height: f32) void {
    _ = .{&player, &envItems, &delta};
    const tmp = struct {
        var bbox: rl.Vector2 = .{.x=0.2, .y=0.2};
    }; _ = &tmp;
    const bbox_world_min = rl.GetScreenToWorld2D(.{.x=(1-tmp.bbox.x)*0.5*width, .y=(1-tmp.bbox.y)*0.5*height}, camera.*);
    const bbox_world_max = rl.GetScreenToWorld2D(.{.x=(1+tmp.bbox.x)*0.5*width, .y=(1+tmp.bbox.y)*0.5*height}, camera.*);
    camera.offset = .{.x=(1-tmp.bbox.x)*0.5*width, .y=(1-tmp.bbox.y)*0.5*height};
    if(player.position.x < bbox_world_min.x) camera.target.x = player.position.x
    else if(player.position.x > bbox_world_max.x) camera.target.x = bbox_world_min.x + (player.position.x - bbox_world_max.x);
    if(player.position.y < bbox_world_min.y) camera.target.y = player.position.y
    else if(player.position.y > bbox_world_max.y) camera.target.y = bbox_world_min.y + (player.position.y - bbox_world_max.y);
}

const Player = struct {
    const Self = @This();
    position: rl.Vector2,
    speed: f32,
    can_jump: bool,
    jump_spd: f32 = 450,
    hor_spd: f32 = 200,
    gravity: f32 = 1000,
    fn init(x: f32, y: f32, speed: f32) Self {
        return Self {
            .position = .{.x=x, .y=y},
            .speed = speed,
            .can_jump = false,
        };
    }
};

const EnvItem = struct {
    const Self = @This();
    rect: rl.Rectangle,
    blocking: bool,
    color: rl.Color,
    fn init(x: f32, y: f32, w: f32, h:f32, blocking: bool, color: rl.Color) Self {
        return Self {
            .rect = .{.x=x, .y=y, .width=w, .height=h},
            .blocking = blocking,
            .color = color,
        };
    }
};

const Recorder = struct {
    const Self = @This();
    var _self: Self = undefined;

    save_data: struct{Player, rl.Vector2},
    ate_list: rl.AutomationEventList,
    recording: bool = false,
    playing: bool = false,
    frame_counter: i32 = 0,
    play_frame_counter: u32 = 0,
    play_frame_cur: usize = 0,
    player: *Player,
    camera: *rl.Camera2D,
    fn init(player: *Player, camera: *rl.Camera2D) *Self {
        const self = &Recorder._self;
        self.player = player;
        self.camera = camera;
        self.ate_list = rl.LoadAutomationEventList(0);
        rl.SetAutomationEventList(&self.ate_list);
        self.saveData();
        return self;
    }
    fn deinit(self: *Self) void {
        rl.UnloadAutomationEventList(self.ate_list);
    }
    fn saveData(self: *Self) void {
        self.ate_list = rl.LoadAutomationEventList(0);
        self.save_data = .{self.player.*, self.camera.target};
    }
    fn loadDataSwap(self: *Self, b: bool) void {
        const tmp = .{self.player.*, self.camera.target};
        self.player.* = self.save_data[0];
        self.camera.target = self.save_data[1];
        self.camera.offset = .{.x=screen_width/2.0, .y=screen_height/2.0};
        if(b) self.save_data = tmp;
    }
    fn resetScreen(self: *Self) void {
        self.saveData();
        self.player.position = rl.Vector2{.x=400, .y=280};
        self.player.speed = 0;
        self.player.can_jump = false;

        self.camera.target = self.player.position;
        self.camera.offset = rl.Vector2{.x=screen_width/2.0, .y=screen_height/2.0};
        //self.camera.rotation = 0;
        self.camera.zoom = 1.0;
    }
    fn dropFile(self: *Self) void {
        if(rl.IsFileDropped()) {
            const dropped_files = rl.LoadDroppedFiles();
            defer rl.UnloadDroppedFiles(dropped_files);
            if(rl.IsFileExtension(dropped_files.paths[0], ".txt;.rae")) {
                rl.UnloadAutomationEventList(self.ate_list);
                self.ate_list = rl.LoadAutomationEventList(dropped_files.paths[0]);
                self.recording = false;
                self.playing = true;
                self.play_frame_counter = 0;
                self.play_frame_cur = 0;

                self.resetScreen();
            }
        }
    }
    fn update(self: *Self) void {
        if(rl.IsKeyPressed(rl.KEY_I)) {
            if(!self.playing) {
                if(self.recording) {
                    rl.StopAutomationEventRecording();
                    self.recording = false;
                    //_ = rl.ExportAutomationEventList(self.ate_list, "automation.rae");
                    rl.TraceLog(rl.LOG_INFO, "RECORDED FRAMES: %i", self.ate_list.count);
                } else {
                    rl.SetAutomationEventBaseFrame(0);
                    rl.StartAutomationEventRecording();
                    self.recording = true;
                    self.saveData();
                }
            }
        } else if(rl.IsKeyPressed(rl.KEY_O)) {
            if(!self.recording) {
                if(!self.playing and self.ate_list.count > 0) {
                    self.playing = true;
                    self.play_frame_counter = 0;
                    self.play_frame_cur = 0;
                    self.loadDataSwap(false);
                }
                //} else {
                    //self.playing = false;
                    //self.play_frame_cur = 0;
                    //self.play_frame_counter = 0;
                    //self.crossData(false);
                //}
            }
        }

        if(self.playing) {
            while(self.play_frame_counter > self.ate_list.events[self.play_frame_cur].frame) {
                const event = &self.ate_list.events[self.play_frame_cur];
                rl.TraceLog(rl.LOG_INFO, "PLAYING: PlayFrameCount: %i | currentPlayFrame: %i | Event Frame: %i, param: %i",
                    self.play_frame_counter, self.play_frame_cur, event.frame, event.params[0]);
                rl.PlayAutomationEvent(event.*);
                self.play_frame_cur += 1;
                if(self.play_frame_cur > self.ate_list.count) {
                    self.playing = false;
                    self.play_frame_cur = 0;
                    self.play_frame_counter = 0;
                    rl.TraceLog(rl.LOG_INFO, "FINISH PLAYING!");
                    break;
                }
            }
            self.play_frame_counter += 1;
        }

        if(self.recording or self.playing) self.frame_counter += 1
        else self.frame_counter = 0;
    }

    fn draw(self: *Self) void {
        rl.DrawText("Recorder:", 20, 160, 10, rl.BLACK);
        rl.DrawText("- I: START/STOP RECORDING INPUT EVENTS", 40, 180, 10, rl.DARKGRAY);
        rl.DrawText("- O: REPLAY LAST RECORDED INPUT EVENTS", 40, 200, 10, rl.DARKGRAY);

        const uy: i32 = 222;
        if(self.recording) {
            rl.DrawRectangle(10, uy, 290, 30, rl.Fade(rl.RED, 0.3));
            rl.DrawRectangleLines(10, uy, 290, 30, rl.Fade(rl.MAROON, 0.8));
            rl.DrawCircle(30, uy + 15, 10, rl.MAROON);
            if(@mod(@divTrunc(self.frame_counter, 15), 2) == 1)
                rl.DrawText(rl.TextFormat("RECORDING EVENTS... [%i]", self.ate_list.count), 50, uy+10, 10, rl.MAROON);
        } else if(self.playing) {
            rl.DrawRectangle(10, uy, 290, 30, rl.Fade(rl.LIME, 0.3));
            rl.DrawRectangleLines(10, uy, 290, 30, rl.Fade(rl.DARKGREEN, 0.8));
            rl.DrawTriangle(rl.Vector2{.x=20, .y=uy+5}, rl.Vector2{.x=20, .y=uy+25}, rl.Vector2{.x=40, .y=uy+15}, rl.DARKGREEN);
            if(@mod(@divTrunc(self.frame_counter, 15), 2) == 1)
                rl.DrawText(rl.TextFormat("PLAYING RECORDING EVENTS... [%i]", self.play_frame_cur), 50, uy+10, 10, rl.DARKGREEN);

        }
    }
};

