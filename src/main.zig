const std = @import("std");
const SDLC = @import("sdl2-native");
const SDL = @import("sdl2-zig");
const Snake = @import("game.zig");

var widht: usize = 640;
var height: usize = 480; 

pub fn main() anyerror!void {
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

    var game = try Snake.init(allocator);
    defer game.deinit();

    mainLoop: while (true) {
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
        try renderer.setColorRGB(22, 0, 59);
        try renderer.clear();
        try game.render(&renderer);
        renderer.present();
        //try renderer.setColorRGB(0, 0, 0);
        try renderer.clear();

        //try renderer.setColor(SDL.Color.parse("#F7A41D") catch unreachable);
    }
}
