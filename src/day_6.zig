const std = @import("std");
const source = @import("days/day_6/day_6_input.zig");

pub fn partOneHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 6 - Part 1 ===\n", .{});
}

pub fn partTwoHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 6 - Part 2 ===\n", .{});
}

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var times = std.ArrayList(u64).init(alloc);
    var dists = std.ArrayList(u64).init(alloc);
    var btn_hold_times = std.ArrayList(u64).init(alloc);

    try reader.streamUntilDelimiter(buffer_writer, '\n', null);

    var time_iter = std.mem.splitAny(u8, process_buffer.items, " ");
    _ = time_iter.first();
    while (time_iter.next()) |v| {
        var tmp_time = std.mem.trim(u8, v, " ");
        if (tmp_time.len == 0) continue;
        try times.append(try std.fmt.parseUnsigned(u64, tmp_time, 0));
    }
    process_buffer.clearRetainingCapacity();

    try reader.streamUntilDelimiter(buffer_writer, '\n', null);

    var dist_iter = std.mem.splitScalar(u8, process_buffer.items, ' ');
    _ = dist_iter.first();
    while (dist_iter.next()) |v| {
        var tmp_dist = std.mem.trim(u8, v, " ");
        if (tmp_dist.len == 0) continue;
        try dists.append(try std.fmt.parseUnsigned(u64, tmp_dist, 0));
    }

    for (times.items, dists.items) |time, dist| {
        try calcButtonHoldTimes(time, dist, &btn_hold_times);
    }

    var options_product: u64 = 0;
    for (try btn_hold_times.toOwnedSlice()) |t| {
        if (options_product == 0) {
            options_product = t;
        } else {
            options_product = options_product * t;
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{options_product});
}

fn calcButtonHoldTimes(time: u64, dist: u64, list: *std.ArrayList(u64)) !void {
    var counter: u64 = 0;
    for (1..time) |seconds| {
        if ((time - seconds) * (seconds * 1) > dist) {
            counter += 1;
        }
    }
    try list.append(counter);
}

pub fn processPartTwo(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var times = std.ArrayList(u8).init(alloc);
    var dists = std.ArrayList(u8).init(alloc);
    var btn_hold_times = std.ArrayList(u64).init(alloc);

    try reader.streamUntilDelimiter(buffer_writer, '\n', null);

    var time_iter = std.mem.splitAny(u8, process_buffer.items, ":");
    _ = time_iter.first();
    for (time_iter.next().?) |c| {
        if (std.ascii.isDigit(c)) try times.append(c);
    }
    process_buffer.clearRetainingCapacity();

    try reader.streamUntilDelimiter(buffer_writer, '\n', null);

    var dist_iter = std.mem.splitScalar(u8, process_buffer.items, ':');
    _ = dist_iter.first();
    for (dist_iter.next().?) |c| {
        if (std.ascii.isDigit(c)) try dists.append(c);
    }

    try calcButtonHoldTimes(
        try std.fmt.parseUnsigned(u64, try times.toOwnedSlice(), 0),
        try std.fmt.parseUnsigned(u64, try dists.toOwnedSlice(), 0),
        &btn_hold_times,
    );

    try std.io.getStdOut().writer().print("{d}\n", .{btn_hold_times.items[0]});
}
