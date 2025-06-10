const std = @import("std");
const common = @import("common");

/// Entrypoint for the ghostlink client
pub fn main() void {
    std.debug.print("ghostlink (client) running!\n", .{});

    // Generate a dummy keypair (to be replaced with real crypto later)
    const kp = common.crypto.generate_keypair();
    std.debug.print("Generated public key: {any}\n", .{kp.public});
    std.debug.print("Generated private key: {any}\n", .{kp.private});
}
