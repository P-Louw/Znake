const std = @import("std");
const SDLC = @import("sdl2-native");
const SDL = @import("sdl2-zig");

pub fn main() anyerror!void {
    std.log.info("Snake game.", .{});

    try SDL.init(.{
        .video = true,
        .events = true,
        .audio = true,
    });
    defer SDL.quit();

    var window = try SDL.createWindow(
        "Snake - zig",
        .{ .centered = {} },
        .{ .centered = {} },
        640,
        480,
        .{ .shown = true },
    );
    defer window.destroy();

    var renderer = try SDL.createRenderer(window, null, .{ .accelerated = true });
    defer renderer.destroy();

    try renderer.setColorRGB(0, 0, 0);
    try renderer.clear();

    try renderer.setColor(SDL.Color.red);
    try renderer.drawRect(SDL.Rectangle{
        .x = 270,
        .y = 215,
        .width = 100,
        .height = 50,
    });
    renderer.present();

    mainLoop: while (true) {
        while (SDL.pollEvent()) |ev| {
            switch (ev) {
                .quit => {
                    break :mainLoop;
                },
                .key_up => |key| {
                    switch (key.scancode) {
                        .escape => break :mainLoop,
                        .up, .down, .left, .right => {
                            std.log.info("Movement key was pressed: {}", .{key});
                        },
                        .left_control => std.log.info("Left ctrl was pressed", .{}),
                        else => std.log.info("Unhandeld keypress event.", .{}),
                    }
                },
                else => {},
            }
        }
        try renderer.setColorRGB(0, 0, 0);
        try renderer.clear();

        try renderer.setColor(SDL.Color.parse("#F7A41D") catch unreachable);
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
