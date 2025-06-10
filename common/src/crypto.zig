const std = @import("std");

pub const Keypair = struct {
    public: [32]u8,
    private: [32]u8,
};

/// Temporary stub for keypair generation.
/// Later: replace with x25519 or similar secure crypto.
pub fn generate_keypair() Keypair {
    return Keypair{
        .public = [_]u8{0x01} ** 32,
        .private = [_]u8{0x02} ** 32,
    };
}
