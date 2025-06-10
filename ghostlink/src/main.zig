const std = @import("std");
const common = @import("common");

/// Entrypoint for the ghostlink client
pub fn main() void {
    std.debug.print("ghostlink (client) running!\n", .{});

    // Load or generate keypair
    var keypair: common.crypto.Keypair = undefined;
    const key_path = "keypair.bin";

    // Try to read keypair from disk
    const open_result = std.fs.cwd().openFile(key_path, .{ .read = true });
    if (open_result) |file| {
        defer file.close();
        const bytes = file.readToEndAlloc(std.heap.page_allocator, 64) catch {
            std.debug.print("Failed to read keypair from file.\n", .{});
            return;
        };
        if (bytes.len == 64) {
            keypair = common.crypto.Keypair{
                .public = bytes[0..32].*,
                .private = bytes[32..64].*,
            };
        } else {
            std.debug.print("Invalid key length: expected 64 bytes.\n", .{});
            return;
        }
    } else |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("No keypair found, generating new one...\n", .{});
            keypair = common.crypto.generate_keypair();

            const file_out = std.fs.cwd().createFile(key_path, .{}) catch {
                std.debug.print("Failed to save keypair to disk.\n", .{});
                return;
            };
            defer file_out.close();
            _ = file_out.writeAll(&keypair.public) catch {};
            _ = file_out.writeAll(&keypair.private) catch {};
        },
        else => {
            std.debug.print("Error opening key file: {s}\n", .{@errorName(err)});
            return;
        },
    }

    std.debug.print("Loaded public key: {any}\n", .{keypair.public});
    std.debug.print("Loaded private key: {any}\n", .{keypair.private});

    // --- TCP Registration to coordination server ---
    const addr = try std.net.Address.parseIp("127.0.0.1", 9000);
    var stream = try addr.connect(.{});
    defer stream.close();

    var hex = [_]u8{0} ** 64;
    _ = std.fmt.bufPrint(&hex, "REGISTER:{x}", .{keypair.public}) catch {
        std.debug.print("Hex encode error\n", .{});
        return;
    };
    try stream.writer().writeAll(&hex);
    try stream.writer().writeAll("\n");

    std.debug.print("[✓] Public key sent to coordination server.\n", .{});
}
