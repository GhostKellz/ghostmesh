const std = @import("std");

// Common utility library for the GhostMesh ecosystem.
// All reusable modules (crypto, utils, etc.) are exposed here.
pub const crypto = @import("crypto.zig");

// Optional general-purpose test entrypoint for the common module.
pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});
    try bw.flush();
}

// Example allocator test
test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

// Simple fuzzing example
test "fuzz example" {
    const Context = struct {
        fn testOne(_: @This(), input: []const u8) anyerror!void {
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}

// Optional API hook
pub fn hello() void {
    std.debug.print("Hello, World! from the common library!\n", .{});
}
