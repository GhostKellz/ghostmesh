const std = @import("std");

// Entry point for the GhostMesh coordination server
pub fn main() !void {
    std.debug.print("ghostmesh controller running!\n", .{});

    // Bind to port 443 for QUIC/control connections
    const address = try std.net.Address.parseIp("0.0.0.0", 443);
    var listener = try address.listen(.{});
    defer listener.deinit();

    std.debug.print("Listening on 0.0.0.0:443...\n", .{});

    while (true) {
        var connection = try listener.accept();
        std.debug.print("[+] New connection\n", .{});

        // TODO: Replace this TCP stream with QUIC/TLS handling when available
        var buf: [128]u8 = undefined;
        const len = try connection.stream.reader().readUntilDelimiterOrEof(&buf, '\n');
        if (len) |msg| {
            std.debug.print("Received: {s}\n", .{msg});
            if (std.mem.startsWith(u8, msg, "REGISTER:")) {
                const pubkey = msg[8..];
                std.debug.print("[*] Registered key: {s}\n", .{pubkey});
                try connection.stream.writer().writeAll("ACK\n");
            } else {
                std.debug.print("[!] Invalid message\n", .{});
                try connection.stream.writer().writeAll("ERR\n");
            }
        }
        connection.stream.close();
    }
}

// TODO:
// - Replace std.net TCP with QUIC bindings (via C FFI or std when QUIC lands)
// - Wrap registration/messages in TLS with client cert support
// - Add control message router (register, ping, route-update, peer-list, etc)
// - Eventually implement stateful session store and ephemeral peer channels
