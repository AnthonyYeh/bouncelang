const std=@import("std");

const raylib = @import("raylib.zig/build.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "temp2",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
    });

    b.installArtifact(exe);
    //std.debug.print("{any}", .{target});
    raylib.addTo(b, exe, target, mode, .{});
    
}

