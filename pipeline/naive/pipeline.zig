const std = @import("std");

const Workers = 8;
const TaskCount = 100_000;

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
            self.not_full.broadcast(io);
        }
    };
}

const Task = struct { id: usize };
const TaskResult = struct { checksum: u64 };
const TaskQueue = BoundedQueue(Task, 1_000);
const ResultQueue = BoundedQueue(TaskResult, 1_000);
const Context = struct { tasks: TaskQueue = .{}, results: ResultQueue = .{} };

fn fnv1a(bytes: []const u8) u64 {
    var hash: u64 = 0xcbf29ce484222325;
    for (bytes) |byte| hash = (hash ^ byte) *% 0x100000001b3;
    return hash;
}

fn runWorker(context: *Context, io: std.Io) void {
    var payload: [32]u8 = undefined;
    while (context.tasks.pop(io)) |task_id| {
        const task = std.fmt.bufPrint(&payload, "task:item:{d}", .{task_id.id}) catch |err| {
            std.debug.panic("payload formatting failed: {s}", .{@errorName(err)});
        };
        context.results.push(io, .{ .checksum = fnv1a(task) });
    }
}

fn produceTasks(context: *Context, io: std.Io) void {
    for (0..TaskCount) |id| context.tasks.push(io, .{ .id = id });
    context.tasks.close(io);
}

fn closeResults(context: *Context, workers: *[Workers]std.Thread, io: std.Io) void {
    for (workers.*) |thread| thread.join();
    context.results.close(io);
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var context = Context{};
    var workers: [Workers]std.Thread = undefined;
    for (&workers) |*worker| worker.* = try std.Thread.spawn(.{}, runWorker, .{ &context, io });
    const producer = try std.Thread.spawn(.{}, produceTasks, .{ &context, io });
    const closer = try std.Thread.spawn(.{}, closeResults, .{ &context, &workers, io });

    var checksum: u64 = 0;
    var count: u64 = 0;
    while (context.results.pop(io)) |result| {
        checksum +%= result.checksum;
        count += 1;
    }
    producer.join();
    closer.join();

    var output: [128]u8 = undefined;
    const line = try std.fmt.bufPrint(&output, "Pipeline complete: processed={d}, checksum={d}\n", .{ count, checksum });
    try std.Io.File.stdout().writeStreamingAll(io, line);
}
