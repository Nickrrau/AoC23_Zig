const std = @import("std");
const source = @import("days/day_2/day_2_input.zig");

pub fn partOneHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 2 - Part 1 ===\n", .{});
}

pub fn partTwoHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 2 - Part 2 ===\n", .{});
}

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_sample1);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();
    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |line| {
        _ = line;
        // Process input here
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
}


pub fn processPartTwo(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_sample2);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();
    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |line| {
        _ = line;
        // Process input here
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
}
