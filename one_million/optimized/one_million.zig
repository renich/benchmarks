const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var buffer: [64 * 1024]u8 = undefined;
    var used: usize = 0;
    for (0..1_000_000) |n| {
        var line: [48]u8 = undefined;
        const output = try std.fmt.bufPrint(&line, "Hello, this is iteration number: {d}\n", .{n});
        if (used + output.len > buffer.len) {
            try std.Io.File.stdout().writeStreamingAll(init.io, buffer[0..used]);
            used = 0;
        }
        @memcpy(buffer[used..][0..output.len], output);
        used += output.len;
    }
    try std.Io.File.stdout().writeStreamingAll(init.io, buffer[0..used]);
}
