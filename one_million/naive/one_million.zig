const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var line: [64]u8 = undefined;
    for (0..1_000_000) |n| {
        const output = try std.fmt.bufPrint(&line, "Hello, this is iteration number: {d}\n", .{n});
        try std.Io.File.stdout().writeStreamingAll(init.io, output);
    }
}
