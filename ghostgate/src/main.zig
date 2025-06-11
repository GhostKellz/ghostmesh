const std = @import("std");
const c = @cImport({
    @cInclude("sys/socket.h");
    @cInclude("netinet/in.h");
    @cInclude("arpa/inet.h");
    @cInclude("unistd.h");
    @cInclude("string.h");
});

const Error = error{
    SocketCreateFailed,
    BindFailed,
    RecvFailed,
};

pub fn main() !void {
    std.debug.print("ghostgate (UDP relay) running on port 3478\n", .{});

    // Create socket
    const sock_fd = c.socket(c.AF_INET, c.SOCK_DGRAM, 0);
    if (sock_fd < 0) return Error.SocketCreateFailed;
    defer _ = c.close(sock_fd);

    // Setup address to bind
    var addr: c.struct_sockaddr_in = std.mem.zeroInit(c.struct_sockaddr_in, .{});
    addr.sin_family = c.AF_INET;
    addr.sin_port = c.htons(3478);
    addr.sin_addr.s_addr = c.inet_addr("0.0.0.0");

    const addr_ptr: *c.struct_sockaddr = @ptrCast(&addr);
    const addr_len: c.socklen_t = @intCast(@sizeOf(c.struct_sockaddr_in));

    if (c.bind(sock_fd, addr_ptr, addr_len) != 0)
        return Error.BindFailed;

    var buf: [1500]u8 = undefined;
    var client_addr: c.struct_sockaddr_in = undefined;
    var client_len: c.socklen_t = @intCast(@sizeOf(c.struct_sockaddr_in));

    while (true) {
        const client_ptr: *c.struct_sockaddr = @ptrCast(&client_addr);
        const recv_len = c.recvfrom(sock_fd, &buf, buf.len, 0, client_ptr, &client_len);
        if (recv_len < 0) return Error.RecvFailed;

        std.debug.print("[UDP] Received {d} bytes\n", .{recv_len});

        // Echo
        _ = c.sendto(sock_fd, &buf, @intCast(recv_len), 0, client_ptr, client_len);
    }
}
