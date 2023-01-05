const std = @import("std");
const Allocator = std.mem.Allocator;
const linkedlist = @import("linked_list");
const SDLC = @import("sdl2-native");
const SDL = @import("sdl2-zig");
const SDLTTF = @cImport({
    @cInclude("SDL_ttf.h");
});

const SnakeGame = @This();

const Block = struct {
    x: i32,
    y: i32,
};

// TODO: Fix buffered input, move is set on key press but results in false evalution when
//       onother input is given after since changes to a entity location isn't given on input.
// TODO: Is this needed? This should be known or derived implicitly.
const Moves = enum(usize) {
    up = @enumToInt(SDL.Scancode.up),
    down = @enumToInt(SDL.Scancode.down),
    left = @enumToInt(SDL.Scancode.left),
    right = @enumToInt(SDL.Scancode.right),
};

allocator: std.mem.Allocator,
area_x: i32,
area_y: i32,
tile_size: i32 = 10,
score: u64 = 0,

body_color: SDL.Color = SDL.Color.parse("#F7A41D") catch unreachable,
body_length: usize = 3,
body: std.ArrayList(*Block),
direction: Moves = Moves.left,
next_direction: Moves = Moves.left,
dead: bool = false,

pickup_color: SDL.Color = SDL.Color.parse("#1C9E49") catch unreachable,
pickup: *Block,

pub fn init(ally: std.mem.Allocator, screen: SDL.Size) !SnakeGame {
    var self = SnakeGame{
        .tile_size = 20,
        .area_x = screen.width,
        .area_y = screen.height,
        .allocator = ally,
        .body_length = 3,
        .body = std.ArrayList(*Block).init(ally),
        .pickup = try ally.create(Block),
        .score = 0,
    };

    self.placePickup();
    var i: usize = 0;
    var pos_x: i32 = @divTrunc(self.area_x, 2);
    var pos_y: i32 = @divTrunc(self.area_y, 2);

    while (i < self.body_length) : ({
        i += 1;
        pos_x += self.tile_size;
    }) {
        var block = try self.allocator.create(Block);
        block.* = Block{
            .x = pos_x,
            .y = pos_y,
        };
        try self.body.append(block);
    }
    return self;
}

pub fn deinit(self: *SnakeGame) void {
    self.body.deinit();
    self.allocator.destroy(self.pickup);
}

pub fn update(self: *SnakeGame) !void {
    var i = self.body.items.len - 1;
    while (i > 0) : (i -= 1) {
        self.body.items[i].x = self.body.items[i - 1].x;
        self.body.items[i].y = self.body.items[i - 1].y;
    }
    switch (self.next_direction) {
        .up => self.body.items[0].*.y -= self.tile_size,
        .down => self.body.items[0].*.y += self.tile_size,
        .left => self.body.items[0].*.x -= self.tile_size,
        .right => self.body.items[0].*.x += self.tile_size,
    }
    self.direction = self.next_direction;
    if (isColliding(self.body.items[0], self.pickup)) {
        try self.onPickup();
    }
    if (try self.detectGameover(self.body.items[0])) {
        self.dead = true;
    }
    for (self.body.items[2..]) |bod| {
        if (isColliding(self.body.items[0], bod)) {
            self.dead = true;
        }
    }
}

pub fn render(self: *SnakeGame, renderer: *SDL.Renderer) !void {
    try renderer.setColor(self.body_color);
    for (self.body.items) |bod| {
        try renderer.fillRect(SDL.Rectangle{
            .x = @intCast(c_int, bod.x),
            .y = @intCast(c_int, bod.y),
            .width = @intCast(c_int, self.tile_size),
            .height = @intCast(c_int, self.tile_size),
        });
    }
    try renderer.setColor(self.pickup_color);
    try renderer.fillRect(SDL.Rectangle{
        .x = @intCast(c_int, self.pickup.x),
        .y = @intCast(c_int, self.pickup.y),
        .width = @intCast(c_int, self.tile_size),
        .height = @intCast(c_int, self.tile_size),
    });
}

fn detectGameover(self: *SnakeGame, head: *Block) !bool {
    if (head.x < 0 or head.x > (self.area_x - self.tile_size)) {
        return true;
    } else if (head.y < 0 or head.y > (self.area_y - self.tile_size)) {
        return true;
    }
    return false;
}

/// Check if two blocks are colliding.
fn isColliding(blockA: *Block, blockB: *Block) bool {
    // TODO: Magic numbers should be tile_size field.
    const rightA = blockA.x + 10;
    const bottomA = blockA.y + 10;
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
    //If none of the sides from A are outside B it's a collision.
    return true;
}

var prng = std.rand.DefaultPrng.init(640);
const rand = &prng.random();

/// Generates rng x and y point then assign it to pickup x y.
fn assignRngPickup(self: SnakeGame) void {
    self.pickup.x = rand.intRangeAtMost(i32, 0, @divTrunc(self.area_x - self.tile_size, 20)) * 20;
    self.pickup.y = rand.intRangeAtMost(i32, 0, @divTrunc(self.area_y - self.tile_size, 20)) * 20;
}

fn placePickup(self: SnakeGame) void {
    assignRngPickup(self);
    for (self.body.items) |b| {
        if (isColliding(self.pickup, b)) {
            assignRngPickup(self);
            break;
        }
    }
}

fn onPickup(self: *SnakeGame) !void {
    self.score += 5;
    var block = try self.allocator.create(Block);
    block.* = Block{
        .x = self.body.items[self.body.items.len - 1].x,
        .y = self.body.items[self.body.items.len - 1].y,
    };
    try self.body.append(block);
    self.placePickup();
}

pub fn handleKeyBoard(self: *SnakeGame, scanCode: SDL.Scancode) void {
    switch (scanCode) {
        .up => if (self.direction != Moves.down) {
            self.next_direction = Moves.up;
        },
        .down => if (self.direction != Moves.up) {
            self.next_direction = Moves.down;
        },
        .left => if (self.direction != Moves.right) {
            self.next_direction = Moves.left;
        },
        .right => if (self.direction != Moves.left) {
            self.next_direction = Moves.right;
        },
        else => {},
    }
}
