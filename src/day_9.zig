const std = @import("std");
const source = @import("days/day_9/day_9_input.zig");

pub fn partOneHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 9 - Part 1 ===\n", .{});
}

pub fn partTwoHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 9 - Part 2 ===\n", .{});
}

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var base_sequences = std.ArrayList([]i64).init(alloc);
    var sum_of_extrapolated: i64 = 0;

    var split_buf = std.ArrayList(i64).init(alloc);
    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var split = std.mem.splitScalar(u8, process_buffer.items, ' ');

        while (split.next()) |num| {
            try split_buf.append(try std.fmt.parseInt(i64, num, 0));
        }

        sum_of_extrapolated += try extrapolateForward(alloc, split_buf.items);

        try base_sequences.append(try split_buf.toOwnedSlice());

        process_buffer.clearRetainingCapacity();
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    std.debug.print("{any}\n", .{sum_of_extrapolated});
}

fn extrapolateForward(alloc: std.mem.Allocator, numbers: []i64) !i64 {
    if (numbers.len == 1) return 0;
    var min_max = std.mem.minMax(i64, numbers);
    if (min_max.max == 0 and min_max.min == 0) return 0;

    var sub_numbers = std.ArrayList(i64).init(alloc);
    var id: usize = 0;
    while (id < numbers.len - 1) {
        try sub_numbers.append(numbers[id + 1] - numbers[id]);
        id += 1;
    }

    return numbers[numbers.len - 1] + try extrapolateForward(alloc, sub_numbers.items);
}
fn extrapolateBackward(alloc: std.mem.Allocator, numbers: []i64) !i64 {
    if (numbers.len == 1) return 0;
    var min_max = std.mem.minMax(i64, numbers);
    if (min_max.max == 0 and min_max.min == 0) return 0;

    var sub_numbers = std.ArrayList(i64).init(alloc);
    var id: usize = 0;
    while (id < numbers.len - 1) {
        try sub_numbers.append(numbers[id + 1] - numbers[id]);
        id += 1;
    }

    return numbers[0] - try extrapolateBackward(alloc, sub_numbers.items);
}

pub fn processPartTwo(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var base_sequences = std.ArrayList([]i64).init(alloc);
    var sum_of_extrapolated: i64 = 0;

    var split_buf = std.ArrayList(i64).init(alloc);
    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var split = std.mem.splitScalar(u8, process_buffer.items, ' ');

        while (split.next()) |num| {
            try split_buf.append(try std.fmt.parseInt(i64, num, 0));
        }

        sum_of_extrapolated += try extrapolateBackward(alloc, split_buf.items);

        try base_sequences.append(try split_buf.toOwnedSlice());

        process_buffer.clearRetainingCapacity();
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    std.debug.print("{any}\n", .{sum_of_extrapolated});
}
