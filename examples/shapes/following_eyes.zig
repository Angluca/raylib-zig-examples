const std = @import("std");
const math = std.math;
pub const rl = @cImport({
    @cInclude("raylib.h");
});

pub fn main() !void {
    //init --
    const screen_width: f32 = 800;
    const screen_height: f32 = 450;
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.SetTraceLogLevel(rl.LOG_WARNING);
    rl.InitWindow(screen_width, screen_height, "following_eyes");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var left_eye = Eye().init(screen_width/2.0-100.0, screen_height/2.0, screen_width/2.0-100, screen_height/2.0, 80, 24);
    var right_eye = Eye().init(screen_width/2.0+100.0, screen_height/2.0, screen_width/2.0+100, screen_height/2.0, 80, 24);
    //loops --
    while (!rl.WindowShouldClose()) {
        //update --
        update(&left_eye);
        update(&right_eye);
        //draw --
        rl.BeginDrawing();
            rl.ClearBackground(rl.GRAY);
            draw(&left_eye);
            draw(&right_eye);
            rl.DrawFPS(10, 10);
        rl.EndDrawing();
    }
    //deinit --
}

fn Eye() type {
    return struct {
        const Circle = struct { pos: rl.Vector2, radius: f32 };
        const Self = @This();
        sclera: Circle = undefined,
        iris: Circle = undefined,
        fn init(x:f32, y:f32, xx:f32, yy:f32, r: f32, rr:f32) Self {
            return Self {
                .sclera = .{.pos=rl.Vector2{.x=x, .y=y}, .radius=r},
                .iris = .{.pos=rl.Vector2{.x=xx, .y=yy}, .radius=rr},
            };
        }
    };
}
fn update(self: *Eye()) void {
    const iris = &self.iris;
    const sclera = &self.sclera;
    iris.pos = rl.GetMousePosition();
    if(!rl.CheckCollisionPointCircle(iris.pos, sclera.pos, sclera.radius - iris.radius)) {
        const dx: f32 = iris.pos.x - sclera.pos.x;
        const dy: f32 = iris.pos.y - sclera.pos.y;
        const angle: f32 = math.atan2(dy, dx);
        const dxx: f32 = (sclera.radius - iris.radius) * math.cos(angle);
        const dyy: f32 = (sclera.radius - iris.radius) * math.sin(angle);
        iris.pos.x = sclera.pos.x + dxx;
        iris.pos.y = sclera.pos.y + dyy;
    }
}
fn draw(self: anytype) void {
    rl.DrawCircleV(self.sclera.pos, self.sclera.radius, rl.LIGHTGRAY);
    rl.DrawCircleV(self.iris.pos, self.iris.radius, rl.BROWN);
    rl.DrawCircleV(self.iris.pos, 10, rl.BLACK);
}
