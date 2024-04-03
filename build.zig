const std = @import("std");
const Sdk = @import("libs/SDL.zig/Sdk.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    // Zig sdl wrapper setup.
    const sdk = Sdk.init(b, null);

    const exe = b.addExecutable(.{
        .name = "Snake",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    sdk.link(exe, .dynamic);

    exe.root_module.addImport("sdl2-zig", sdk.getWrapperModule());

    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2_ttf");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
