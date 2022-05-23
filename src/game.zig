const std = @import("std");
const Allocator = std.mem.Allocator;
const linkedlist = @import("linked_list");
const SDLC = @import("sdl2-native");
const SDL = @import("sdl2-zig");

const Self = @This();

const Block = struct {
    x: u64,
    y: u64,
};

allocator: std.mem.Allocator,
bodyLength: u32 = 5,
body: std.ArrayList(*Block),
pickups: std.ArrayList(*Block),

score: u64,

pub fn init(ally: std.mem.Allocator) !*Self {
    Self.allocator = ally;
    Self.body = std.ArrayList(*Block).init(ally);
    Self.pickups = std.ArrayList(*Block).init(ally);
    // TODO: Random placement pickups.
    // TODO: Remove i statement.
    var i = 0;
    while(i <= bodyLength) : (i+=1) {
        const block = try allocator.create(bodyBlock);
        try body.append(block);
    }
}

pub fn deInit() !void {
    Self.body.deinit();
    Self.pickups.deinit();
}

/// Updates a given frame in game, delta is time elapsed sine previous update.
pub fn update(delta: u32) !void {
    std.log.info("Elapsed delta: {d}\n", .{delta});
}

/// Draw game.
pub fn render(renderer: * SDL.Renderer) !void {
    std.log.info("Used render of game:\n", .{});
}

const Player = struct {
    length: u32,
    color: []const u8,

    pub fn init() void {
        _ = linkedlist(bodyBlock);
    }

    pub fn deInit() void {
    }

    pub fn addBlock(self: *Player) !bool {
        self.color = "Red";
        return true;
    }
};
