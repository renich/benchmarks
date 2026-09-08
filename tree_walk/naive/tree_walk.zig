const std = @import("std");

const Workers = 8;

fn BoundedQueue(comptime T: type, comptime capacity: usize) type {
    return struct {
        const Self = @This();

        items: [capacity]T = undefined,
        head: usize = 0,
        tail: usize = 0,
        length: usize = 0,
        closed: bool = false,
        mutex: std.Io.Mutex = .init,
        not_empty: std.Io.Condition = .init,
        not_full: std.Io.Condition = .init,

        fn push(self: *Self, io: std.Io, item: T) void {
            self.mutex.lockUncancelable(io);
            defer self.mutex.unlock(io);
            while (self.length == capacity) self.not_full.waitUncancelable(io, &self.mutex);
            std.debug.assert(!self.closed);
            self.items[self.tail] = item;
            self.tail = (self.tail + 1) % capacity;
            self.length += 1;
            self.not_empty.signal(io);
        }

        fn pop(self: *Self, io: std.Io) ?T {
            self.mutex.lockUncancelable(io);
            defer self.mutex.unlock(io);
            while (self.length == 0 and !self.closed) self.not_empty.waitUncancelable(io, &self.mutex);
            if (self.length == 0) return null;
            const item = self.items[self.head];
            self.head = (self.head + 1) % capacity;
            self.length -= 1;
            self.not_full.signal(io);
            return item;
        }

        fn close(self: *Self, io: std.Io) void {
            self.mutex.lockUncancelable(io);
            defer self.mutex.unlock(io);
            self.closed = true;
            self.not_empty.broadcast(io);
        }
    };
}

const PathQueue = BoundedQueue([]const u8, 500);
const Context = struct { paths: PathQueue = .{} };

fn collectFiles(root: std.Io.Dir, io: std.Io, allocator: std.mem.Allocator, context: *Context, file_count: *usize) !void {
    var walker = try root.walk(allocator);
    defer walker.deinit();
    while (try walker.next(io)) |entry| {
        if (entry.kind == .file and std.mem.endsWith(u8, entry.path, ".txt")) {
            context.paths.push(io, try allocator.dupe(u8, entry.path));
            file_count.* += 1;
        }
    }
}

fn countFiles(context: *Context, root: std.Io.Dir, io: std.Io, count: *usize) void {
    var buffer: [64 * 1024]u8 = undefined;
    while (context.paths.pop(io)) |path| {
        var file = root.openFile(io, path, .{}) catch continue;
        {
            defer file.close(io);
            var reader = file.reader(io, &.{});
            const length = reader.interface.readSliceShort(&buffer) catch continue;
            const bytes = buffer[0..length];
            var position: usize = 0;
            while (std.mem.indexOfPos(u8, bytes, position, "category=")) |match| {
                count.* += 1;
                position = match + "category=".len;
            }
        }
    }
}

pub fn main(init: std.process.Init) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.smp_allocator);
    defer arena.deinit();

    const io = init.io;
    var root = std.Io.Dir.cwd().openDir(io, "../../_data", .{ .iterate = true }) catch try std.Io.Dir.cwd().openDir(io, "_data", .{ .iterate = true });
    defer root.close(io);

    var context = Context{};
    var counts = [_]usize{0} ** Workers;
    var threads: [Workers]std.Thread = undefined;
    for (0..Workers) |index| threads[index] = try std.Thread.spawn(.{}, countFiles, .{ &context, root, io, &counts[index] });

    var file_count: usize = 0;
    collectFiles(root, io, arena.allocator(), &context, &file_count) catch |err| {
        context.paths.close(io);
        for (&threads) |*thread| thread.join();
        return err;
    };
    context.paths.close(io);
    for (&threads) |*thread| thread.join();

    var matches: usize = 0;
    for (counts) |count| matches += count;
    var output: [96]u8 = undefined;
    const line = try std.fmt.bufPrint(&output, "Tree walk complete: files={d}, matches={d}\n", .{ file_count, matches });
    try std.Io.File.stdout().writeStreamingAll(io, line);
}
