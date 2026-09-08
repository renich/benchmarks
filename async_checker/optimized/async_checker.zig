const std = @import("std");

const Workers = 16;
const Tasks = 10_000;

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

const TaskResult = struct { latency: u16, status: u16 };
const ResultQueue = BoundedQueue(TaskResult, 1_000);
const Context = struct { results: ResultQueue = .{} };

fn runWorker(index: usize, context: *Context, io: std.Io) void {
    const start = index * (Tasks / Workers);
    const end = if (index + 1 == Workers) Tasks else start + (Tasks / Workers);
    for (start..end) |id| {
        const seed: u64 = (@as(u64, id) *% 1_664_525 +% 1_013_904_223) & 0xffffffff;
        const latency: u16 = @intCast(10 + (seed % 990));
        const status: u16 = if (seed % 7 != 0) 200 else if (seed % 3 == 0) 429 else 500;
        context.results.push(io, .{ .latency = latency, .status = status });
    }
}

fn closeResults(context: *Context, workers: *[Workers]std.Thread, io: std.Io) void {
    for (workers.*) |thread| thread.join();
    context.results.close(io);
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var context = Context{};
    var workers: [Workers]std.Thread = undefined;
    for (&workers, 0..) |*worker, index| worker.* = try std.Thread.spawn(.{}, runWorker, .{ index, &context, io });
    const closer = try std.Thread.spawn(.{}, closeResults, .{ &context, &workers, io });

    var histogram = [_]u16{0} ** 1000;
    var received: usize = 0;
    var ok: u64 = 0;
    var rate_limited: u64 = 0;
    var errors: u64 = 0;
    var latency_sum: u64 = 0;
    while (context.results.pop(io)) |result| {
        histogram[result.latency] += 1;
        received += 1;
        latency_sum += @as(u64, result.latency);
        switch (result.status) {
            200 => ok += 1,
            429 => rate_limited += 1,
            500 => errors += 1,
            else => return error.InvalidStatus,
        }
    }
    closer.join();
    if (received != Tasks) return error.IncompleteResults;

    var cumulative: usize = 0;
    var percentiles: [3]usize = undefined;
    var next: usize = 0;
    const targets = [_]usize{ 5001, 9501, 9901 };
    for (histogram, 0..) |count, latency| {
        cumulative += @as(usize, count);
        while (next < targets.len and cumulative >= targets[next]) : (next += 1) {
            percentiles[next] = latency;
        }
        if (next == targets.len) break;
    }
    if (next != targets.len) return error.IncompleteHistogram;
    var output: [192]u8 = undefined;
    const line = try std.fmt.bufPrint(
        &output,
        "Async complete: tasks={d}, ok={d}, rate_limited={d}, errors={d}, " ++
            "latency_sum={d}, p50={d}, p95={d}, p99={d}\n",
        .{ Tasks, ok, rate_limited, errors, latency_sum, percentiles[0], percentiles[1], percentiles[2] },
    );
    try std.Io.File.stdout().writeStreamingAll(init.io, line);
}
