const std = @import("std");
const SDLC = @import("sdl2-native");
const SDL = @import("sdl2-zig");
const Snake = @import("game.zig");

var width: usize = 640;
var height: usize = 480;
var lastTime: u32 = undefined;
// Considering 6 frames is the minimum.
const minFpsTime = (1000 / 6);

pub fn main() anyerror!void {
    lastTime = SDL.getTicks();
    const allocator = std.heap.page_allocator;
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
        width,
        height,
        .{ .shown = true },
    );
    defer window.destroy();
    var renderer = try SDL.createRenderer(window, null, .{ .accelerated = true });
    defer renderer.destroy();

    var game = try Snake.init(allocator, window.getSize());
    defer game.deinit();

    mainLoop: while (true) {
        var now = SDL.getTicks();
        while (SDL.pollEvent()) |ev| {
            switch (ev) {
                .quit => {
                    break :mainLoop;
                },
                .key_up => |key| {
                    switch (key.scancode) {
                        .escape => break :mainLoop,
                        else => game.handleKeyBoard(key.scancode),
                    }
                },
                else => {},
            }
        }
        if (lastTime < now) {
            const delta = now - lastTime;
            try renderer.setColorRGB(22, 0, 59);
            try renderer.clear();
            try game.update(delta);
            try game.render(&renderer);
            renderer.present();
            //try renderer.setColorRGB(0, 0, 0);
            //try renderer.clear();

            //try renderer.setColor(SDL.Color.parse("#F7A41D") catch unreachable);
        }
    }
}
