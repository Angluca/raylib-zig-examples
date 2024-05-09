const std = @import("std");
pub const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("rcamera.h");
});

const screen_width = 800;
const screen_height = 450;

pub fn main() !void {
    //init --
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.SetTraceLogLevel(rl.LOG_WARNING);
    rl.InitWindow(screen_width, screen_height, "3d_camera_first_person");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    rl.DisableCursor();
    var world = World(20).init();
    _ = &world;

    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        update(&world);

        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.DARKGRAY);
            draw(&world);

        rl.EndDrawing();
    }
    //deinit --
}

const Cube = struct {
    const Self = @This();
    pos: rl.Vector3 = undefined,
    high: f32 = 0,
    color: rl.Color = undefined,
    fn init(x: f32, y: f32, z: f32, h: f32, r: u8, g: u8, b: u8) Self {
        return Self { .pos = rl.Vector3{.x=x,.y=y,.z=z}, .high = h,
            .color = rl.Color{.r=r,.g=g,.b=b,.a=255},
    };}
};
fn World(n: comptime_int) type {
    return struct {
        const Self = @This();
        //var _self: Self = undefined;
        camera: rl.Camera = undefined,
        camera_mode: i32 = rl.CAMERA_PERSPECTIVE,
        cubes: [n]Cube = undefined,
        fn init() Self {
            return ret: {
                var self: Self = undefined;
                self.camera.position = .{.x=0, .y=2, .z=4};
                self.camera.target = .{.x=0, .y=2, .z=0};
                self.camera.up = .{.x=0, .y=1, .z=0};
                self.camera.fovy = 60;
                self.camera.projection = rl.CAMERA_PERSPECTIVE;
                self.camera_mode = rl.CAMERA_FIRST_PERSON;
                for(&self.cubes)|*it| {
                    const h: f32 = @floatFromInt(rl.GetRandomValue(1, 12));
                    it.* = Cube.init(
                        @floatFromInt(rl.GetRandomValue(-15, 15)), h/2.0,
                        @floatFromInt(rl.GetRandomValue(-15, 15)), h,
                        @intCast(rl.GetRandomValue(20, 255)),
                        @intCast(rl.GetRandomValue(10, 255)), 30
                    );
                }
                break :ret self;
        };}
    };
}
fn Vec3f(x: f32, y: f32, z: f32) rl.Vector3 {
    return rl.Vector3 { .x=x, .y=y, .z=z };
}
fn update(self: anytype) void {
    const camera = &self.camera;
    switch (rl.GetKeyPressed()) {
        rl.KEY_ONE => {
            self.camera_mode =rl.CAMERA_FREE;
            self.camera.up = Vec3f(0, 1, 0);
        },
        rl.KEY_TWO => {
            self.camera_mode =rl.CAMERA_FIRST_PERSON;
            self.camera.up = Vec3f(0, 1, 0);
        },
        rl.KEY_THREE => {
            self.camera_mode =rl.CAMERA_THIRD_PERSON;
            self.camera.up = Vec3f(0, 1, 0);
        },
        rl.KEY_FOUR => {
            self.camera_mode =rl.CAMERA_ORBITAL;
            self.camera.up = Vec3f(0, 1, 0);
        },
        rl.KEY_F => {
            switch(self.camera.projection) {
                rl.CAMERA_PERSPECTIVE => {
                    self.camera_mode = rl.CAMERA_THIRD_PERSON;
                    camera.position = Vec3f(0, 2, -100);
                    camera.target = Vec3f(0, 2, 0);
                    camera.up = Vec3f(0, 1, 0);
                    camera.projection = rl.CAMERA_ORTHOGRAPHIC;
                    camera.fovy = 20;
                    rl.CameraYaw(camera, -134.0 * rl.DEG2RAD, true);
                    rl.CameraPitch(camera, -45.0 * rl.DEG2RAD, true, true, false);
                },
                rl.CAMERA_ORTHOGRAPHIC => {
                    self.camera_mode = rl.CAMERA_THIRD_PERSON;
                    camera.position = Vec3f(0, 2, 10);
                    camera.target = Vec3f(0, 2, 0);
                    camera.up = Vec3f(0, 1, 0);
                    camera.projection = rl.CAMERA_PERSPECTIVE;
                    camera.fovy = 60;
                },
                else => unreachable,
            }
        },
        else => {},
    }
    rl.UpdateCamera(camera, self.camera_mode);
}
fn draw(self: anytype) void {
    const camera = &self.camera;
    const cubes = &self.cubes;
    rl.BeginMode3D(camera.*);
        rl.DrawPlane(Vec3f(0,0,0), .{.x=32,.y=32}, rl.LIGHTGRAY);
        rl.DrawCube(Vec3f(-16,2.5,0), 1, 5, 32, rl.BLUE);
        rl.DrawCube(Vec3f(16,2.5,0), 1, 5, 32, rl.LIME);
        rl.DrawCube(Vec3f(0,2.5,16), 32, 5, 1, rl.GOLD);
        for(cubes)|it| {
            rl.DrawCube(it.pos, 2, it.high, 2, it.color);
            rl.DrawCubeWires(it.pos, 2, it.high, 2.0, rl.MAROON);
        }
        if(self.camera_mode == rl.CAMERA_THIRD_PERSON) {
            rl.DrawCube(camera.target, 0.5, 0.5, 0.5, rl.PURPLE);
            rl.DrawCubeWires(camera.target, 0.5, 0.5, 0.5, rl.DARKPURPLE);
        }
    rl.EndMode3D();

    rl.DrawRectangle(5, 5, 330, 100, rl.Fade(rl.SKYBLUE, 0.5));
    rl.DrawRectangleLines(5, 5, 330, 100, rl.BLUE);

    rl.DrawText("Camera controls:", 15, 15, 10, rl.BLACK);
    rl.DrawText("- Move keys: W, A, S, D, Space, Left-Ctrl", 15, 30, 10, rl.BLACK);
    rl.DrawText("- Look around: arrow keys or mouse", 15, 45, 10, rl.BLACK);
    rl.DrawText("- Camera mode keys: 1, 2, 3, 4", 15, 60, 10, rl.BLACK);
    rl.DrawText("- Zoom keys: num-plus, num-minus or mouse scroll", 15, 75, 10, rl.BLACK);
    rl.DrawText("- Camera projection key: F", 15, 90, 10, rl.BLACK);

    rl.DrawRectangle(600, 5, 195, 100, rl.Fade(rl.SKYBLUE, 0.5));
    rl.DrawRectangleLines(600, 5, 195, 100, rl.BLUE);

    rl.DrawText("Camera status:", 610, 15, 10, rl.BLACK);
    const mode_str: [*c]const u8 = switch(self.camera_mode) {
        rl.CAMERA_FREE => "FREE",
        rl.CAMERA_FIRST_PERSON => "FIRST_PERSON",
        rl.CAMERA_THIRD_PERSON => "THIRD_PERSON",
        rl.CAMERA_ORBITAL => "ORBITAL",
        else => "CUSTOM"
    };
    rl.DrawText(rl.TextFormat("- Mode: %s", mode_str), 610, 30, 10, rl.BLACK);
    const projection_str: [*c]const u8 = switch(camera.projection) {
        rl.CAMERA_PERSPECTIVE => "PERSPECTIVE",
        rl.CAMERA_ORTHOGRAPHIC => "ORTHOGRAPHIC",
        else => "CUSTOM"
    };
    rl.DrawText(rl.TextFormat("- Projection: %s", projection_str), 610, 45, 10, rl.BLACK);

    rl.DrawText(rl.TextFormat("- Position: (%06.3f, %06.3f, %06.3f)", camera.position.x, camera.position.y, camera.position.z), 610, 60, 10, rl.BLACK);
    rl.DrawText(rl.TextFormat("- Target: (%06.3f, %06.3f, %06.3f)", camera.target.x, camera.target.y, camera.target.z), 610, 75, 10, rl.BLACK);
    rl.DrawText(rl.TextFormat("- Up: (%06.3f, %06.3f, %06.3f)", camera.up.x, camera.up.y, camera.up.z), 610, 90, 10, rl.BLACK);
}

