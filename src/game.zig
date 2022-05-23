const std = @import("std");
const Allocator = std.mem.Allocator;
const linkedlist = @import("linked_list");
const SDLC = @import("sdl2-native");
const SDL = @import("sdl2-zig");

const SnakeGame = @This();

// TODO: This could be a generic entity?
const Block = struct {
    x: u64,
    y: u64,
};

// TODO: Is this needed? This should be known or derived implicitly.
const Moves = enum(SDL.key.scancode) {
    up,
    down,
    left,
    right,
};

allocator: std.mem.Allocator,
bodyLength: usize = 5,
body: std.ArrayList(*Block),
pickups: std.ArrayList(*Block),
score: u64,

pub fn init(ally: std.mem.Allocator) !SnakeGame {
    var self = SnakeGame{
        .allocator = ally,
        .bodyLength = 3,
        .body = std.ArrayList(*Block).init(ally),
        .pickups = std.ArrayList(*Block).init(ally),
        .score = 0,
    };
    // TODO: Remove i statement.
    var i: usize = 0;
    while (i < self.bodyLength) : (i += 1) {
        const block = try self.allocator.create(Block);
        try self.body.append(block);
    }
    // TODO: add pickup.
    return self;
}

pub fn deinit(self: *SnakeGame) void {
    self.body.deinit();
    self.pickups.deinit();
}

/// Updates a given frame in game, delta is time elapsed sine previous update.
pub fn update(delta: u32) !void {
    try movePlayer();
    std.log.info("Elapsed delta: {d}\n", .{delta});
}

/// Draw game.
pub fn render(self: *SnakeGame, renderer: *SDL.Renderer) !void {
    //std.log.info("Used render of game:\n", .{});
    try renderer.setColor(SDL.Color.parse("#F7A41D") catch unreachable);
    //try renderer.setColor(SDL.Color.red);
    std.log.info("body length: {d}\n", .{self.bodyLength});
    //try renderer.setColor(SDL.Color.red);
    try renderer.drawRect(SDL.Rectangle{
        .x = 270,
        .y = 215,
        .width = 100,
        .height = 50,
    });
}

fn movePlayer() !void {}

pub fn handleKeyBoard(scanCode: SDL.Scancode) void {
    switch (scanCode) {
        .up, .down, .left, .right => {
            std.log.info("Movement key was pressed: {}", .{scanCode});
        },
        .left_control => std.log.info("Left ctrl was pressed", .{}),
        else => {},
    }
}
