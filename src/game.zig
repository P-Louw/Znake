const std = @import("std");
const Allocator = std.mem.Allocator;
const linkedlist = @import("linked_list");
const SDLC = @import("sdl2-native");
const SDL = @import("sdl2-zig");
const SDLTTF = @cImport({
    @cInclude("SDL_ttf.h");
});

const SnakeGame = @This();

// TODO: This could be a generic entity?
const Block = struct {
    x: u32,
    y: u32,
};

// TODO: Is this needed? This should be known or derived implicitly.
const Moves = enum(usize) {
    up = @enumToInt(SDL.Scancode.up),
    down = @enumToInt(SDL.Scancode.down),
    left = @enumToInt(SDL.Scancode.left),
    right = @enumToInt(SDL.Scancode.right),
};

allocator: std.mem.Allocator,
areaX: u32,
areaY: u32,
bodyLength: usize = 3,
tileSize: u32 = 10,
score: u64 = 0,
body: std.ArrayList(*Block),
pickup: *Block,
direction: Moves = Moves.left,

pub fn init(ally: std.mem.Allocator, screen: SDL.Size) !SnakeGame {
    var firstPickup = try ally.create(Block);
    firstPickup.* = Block{
        .x = 0,
        .y = 0,
    };
    var self = SnakeGame{
        .tileSize = 10,
        .areaX = @intCast(u32, @divTrunc(screen.width, 10)),
        .areaY = @intCast(u32, @divTrunc(screen.height, 10)),
        .allocator = ally,
        .bodyLength = 3,
        .body = std.ArrayList(*Block).init(ally),
        .pickup = firstPickup,
        .score = 0,
    };
    self.placePickup(firstPickup);
    var i: usize = 0;
    //var x: u64 = @divTrunc(@intCast(u64, screen.width), 2) - (self.bodyLength * (self.tileSize / 2));
    //var y: u64 = @divTrunc(@intCast(u64, screen.height), 2) - (self.tileSize / 2);
    var stepX: u32 = @divTrunc(self.areaX, 2);
    var y: u32 = @divTrunc(self.areaY, 2) * self.tileSize;
    while (i < self.bodyLength) : ({
        i += 1;
        stepX += self.tileSize;
    }) {
        var block = try self.allocator.create(Block);
        block.* = Block{
            .x = stepX,
            .y = y,
        };
        try self.body.append(block);
    }
    return self;
}

pub fn deinit(self: *SnakeGame) void {
    self.body.deinit();
    self.allocator.destroy(self.pickup);
}

var lastTime: u64 = 0;
/// Updates a given frame in game, delta is time elapsed sine previous update.
pub fn update(self: *SnakeGame, delta: u64) !void {
    if (lastTime < 6000) {
        lastTime += delta;
        return;
    }
    lastTime = 0;
    var i = self.body.items.len - 1;
    while (i > 0) : (i -= 1) {
        self.body.items[i].x = self.body.items[i - 1].x;
        self.body.items[i].y = self.body.items[i - 1].y;
    }
    switch (self.direction) {
        .up => self.body.items[0].*.y -= self.tileSize,
        .down => self.body.items[0].*.y += self.tileSize,
        .left => self.body.items[0].*.x -= self.tileSize,
        .right => self.body.items[0].*.x += self.tileSize,
    }
    std.log.info("Head: {any} - P: {any}.\n", .{ self.body.items[0], self.pickup });
    if (detectCollision(self.body.items[0], self.pickup)) {
        try self.onPickup();
    }
    //for (self.body.items[1..]) |bod| {
    //    self.detectCollision(bod);
    //}

    // TODO: Border collision.
    // max colission length: -2 from head
    // TODO: Self collision.
}

// Draw game.
pub fn render(self: *SnakeGame, renderer: *SDL.Renderer) !void {
    try renderer.setColor(SDL.Color.parse("#F7A41D") catch unreachable);
    //std.log.info("body length: {d}\n", .{self.bodyLength});
    for (self.body.items) |bod| {
        try renderer.fillRect(SDL.Rectangle{
            .x = @intCast(c_int, bod.x),
            .y = @intCast(c_int, bod.y),
            .width = @intCast(c_int, self.tileSize),
            .height = @intCast(c_int, self.tileSize),
        });
    }
    try renderer.setColor(SDL.Color.parse("#1C9E49") catch unreachable);
    try renderer.fillRect(SDL.Rectangle{
        .x = @intCast(c_int, self.pickup.x),
        .y = @intCast(c_int, self.pickup.y),
        .width = @intCast(c_int, self.tileSize),
        .height = @intCast(c_int, self.tileSize),
    });
    //drawScore(renderer);
}

fn detectCollision(blockA: *Block, blockB: *Block) bool {
    //Calculate the sides of rect A
    const rightA = blockA.x + 10;
    const bottomA = blockA.y + 10;

    //Calculate the sides of rect B
    const rightB = blockB.x + 10;
    const bottomB = blockB.y + 10;
    //If any of the sides from A are outside of B
    if (bottomA <= blockB.y) {
        return false;
    }
    if (blockA.y >= bottomB) {
        return false;
    }
    if (rightA <= blockB.x) {
        return false;
    }
    if (blockA.x >= rightB) {
        return false;
    }
    //If none of the sides from A are outside B
    return true;
}
var prng = std.rand.DefaultPrng.init(640);
const rand = &prng.random();
fn placePickup(self: SnakeGame, item: *Block) void {
    item.x = rand.intRangeAtMost(u32, 0, self.areaX) * self.tileSize;
    item.y = rand.intRangeAtMost(u32, 0, self.areaY) * self.tileSize;
}

fn onPickup(self: *SnakeGame) !void {
    std.log.info("Pickup detected", .{});
    self.score += 5;
    var block = try self.allocator.create(Block);
    block.* = Block{
        .x = self.body.items[self.body.items.len - 1].x,
        .y = self.body.items[self.body.items.len - 1].y,
    };
    try self.body.append(block);
    self.placePickup(self.pickup);
}

pub fn handleKeyBoard(self: *SnakeGame, scanCode: SDL.Scancode) void {
    //std.log.info("Entity part size: {any}", .{self.tileSize});
    switch (scanCode) {
        .up => if (self.direction != Moves.down) {
            self.direction = Moves.up;
        },
        .down => if (self.direction != Moves.up) {
            self.direction = Moves.down;
        },
        .left => if (self.direction != Moves.right) {
            self.direction = Moves.left;
        },
        .right => if (self.direction != Moves.left) {
            self.direction = Moves.right;
        },
        .left_control => std.log.info("Move type size: {any}", .{(@TypeOf(Moves.up))}),
        else => {},
    }
}
