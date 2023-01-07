const std = @import("std");
const SDLC = @import("sdl2-native");
const SDL = @import("sdl2-zig");
const Snake = @import("game.zig");

var width: usize = 640;
var height: usize = 480;
var lastTime: u64 = undefined;

// TODO: Add fixed timestep:
// Considering 6 frames is the minimum for rendering updates.
//const minFpsTime = (1000 / 6);
// Fixed step is 60 fps for ticks
//const fixedStep = 1000 / 60;

pub fn render(game: *Snake, renderer: *SDL.Renderer) !void {
    try renderer.setColorRGB(22, 0, 59);
    try renderer.clear();
    try game.render(renderer);
    renderer.present();
}

pub fn main() anyerror!void {
    lastTime = SDL.getTicks64();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    try SDL.init(.{
        .video = true,
        .events = true,
        .audio = true,
    });
    try SDL.ttf.init();
    defer SDL.quit();

    var window = try SDL.createWindow(
        "Snake - zig",
        .{ .centered = {} },
        .{ .centered = {} },
        width,
        height,
        .{ .vis = .shown },
    );
    defer window.destroy();
    var renderer = try SDL.createRenderer(window, null, .{ .accelerated = true });
    defer renderer.destroy();

    var game = try Snake.init(allocator, window.getSize());
    defer game.deinit();
    try game.render(&renderer);

    mainLoop: while (!game.dead) {
        var now: u64 = SDL.getTicks64();
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
            const delta = (now - lastTime);
            try render(&game, &renderer);
            if (delta > 200) {
                lastTime = SDL.getTicks64();
                try game.update();
            }
        }
    }
}
