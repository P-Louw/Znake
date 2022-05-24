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
const Moves = enum(usize) {
    up = @enumToInt(SDL.Scancode.up),
    down = @enumToInt(SDL.Scancode.down),
    left = @enumToInt(SDL.Scancode.left),
    right = @enumToInt(SDL.Scancode.right),
};

allocator: std.mem.Allocator,
bodyLength: usize = 5,
partSize: usize = 50,
speed: u64 = 50,
score: u64 = 0,
body: std.ArrayList(*Block),
pickups: std.ArrayList(*Block),
direction: Moves = Moves.left,

pub fn init(ally: std.mem.Allocator, screen: SDL.Size) !SnakeGame {
    var self = SnakeGame{
        .allocator = ally,
        .bodyLength = 3,
        .body = std.ArrayList(*Block).init(ally),
        .pickups = std.ArrayList(*Block).init(ally),
        .score = 0,
    };
    // TODO: Remove i statement.
    var i: usize = 0;
    var x: u64 = @divTrunc(@intCast(u64, screen.width), 2) - (self.bodyLength * (self.partSize / 2));
    var y: u64 = @divTrunc(@intCast(u64, screen.height), 2) - (self.partSize / 2);
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
pub fn update(self: *SnakeGame, delta: u64) !void {
    try self.movePlayer();
    std.log.info("Elapsed delta: {d}\n", .{delta});
    var i = self.body.items.len - 1;
    while (i > 0) : (i -= 1) {
        self.body.items[i].x = self.body.items[i - 1].x;
        self.body.items[i].y = self.body.items[i - 1].y;
    }
    switch (self.direction) {
        .up => self.body.items[0].*.y += self.speed,
        .down => self.body.items[0].*.y -= self.speed,
        .left => self.body.items[0].*.x += self.speed,
        .right => self.body.items[0].*.x -= self.speed,
    }
}

/// Draw game.
pub fn render(self: *SnakeGame, renderer: *SDL.Renderer) !void {
    try renderer.setColor(SDL.Color.parse("#F7A41D") catch unreachable);
    //std.log.info("body length: {d}\n", .{self.bodyLength});
    for (self.body.items) |bod| {
        try renderer.fillRect(SDL.Rectangle{
            .x = @intCast(c_int, bod.x),
            .y = @intCast(c_int, bod.y),
            .width = @intCast(c_int, self.partSize),
            .height = @intCast(c_int, self.partSize),
        });
    }
    //try renderer.drawRect();
}

fn movePlayer(self: *SnakeGame, move: Moves) !void {
    std.log.info("Pressed key: {any}", .{move});
    var i = self.body.items.len - 1;
    while (i > 0) : (i -= 1) {
        std.log.info("Moving block {d}\nFrom {any}\n", .{ i, self.body.items[i] });
        self.body.items[i].x = self.body.items[i - 1].x;
        self.body.items[i].y = self.body.items[i - 1].y;
        std.log.info("to {any}\n", .{(self.body.items[i - 1])});
    }
    std.log.info("Moving block {d}\nFrom {any}\n", .{ 0, self.body.items[0] });
    switch (self.direction) {
        .up => self.body.items[0].y += self.speed,
        .down => self.body.items[0].y -= self.speed,
        .left => self.body.items[0].x -= self.speed,
        .right => self.body.items[0].x += self.speed,
    }
    std.log.info("to {any}\n", .{(self.body.items[0])});
}

pub fn handleKeyBoard(self: *SnakeGame, scanCode: SDL.Scancode) void {
    std.log.info("Entity part size: {any}", .{self.partSize});
    switch (scanCode) {
        .up => try self.movePlayer(Moves.up),
        .down => try self.movePlayer(Moves.down),
        .left => try self.movePlayer(Moves.left),
        .right => try self.movePlayer(Moves.right),
        .left_control => std.log.info("Left ctrl was pressed", .{}),
        else => {},
    }
    //switch (scanCode) {
    //    .up => self.direction = Moves.up,
    //    .down => self.direction = Moves.down,
    //    .left => self.direction = Moves.left,
    //    .right => self.direction = Moves.right,
    //    .left_control => std.log.info("Left ctrl was pressed", .{}),
    //    else => {},
    //}
}
