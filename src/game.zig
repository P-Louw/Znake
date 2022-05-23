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
score: u64 = 0,
body: std.ArrayList(*Block),
pickups: std.ArrayList(*Block),
direction: Moves = Moves.left,

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
    var x: i32 = 0;
    var y: i32 = 0;
    while (i < self.bodyLength) : ({
        i += 1;
        x += 50;
        y += 0;
    }) {
        var block = try self.allocator.create(Block);
        block.* = Block{
            .x = x,
            .y = y,
        };
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
    try renderer.setColor(SDL.Color.parse("#F7A41D") catch unreachable);
    std.log.info("body length: {d}\n", .{self.bodyLength});

    try renderer.fillRect(SDL.Rectangle{
        .x = 0,
        .y = 0,
        .width = 50,
        .height = 50,
    });
    //try renderer.drawRect();
}

fn movePlayer(self: *SnakeGame) !void {
    
}

pub fn handleKeyBoard(self: *SnakeGame, scanCode: SDL.Scancode) void {
    switch (scanCode) {
        .up => Move.up,
        .down => Move.down,
        .left => Move.right, 
        .right => Move.right,
        .left_control => std.log.info("Left ctrl was pressed", .{}),
        else => {},
    }
}
