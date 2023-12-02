const std = @import("std");
const source = @import("days/day_1/day_1_input.zig");

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_sample);
    var reader = stream.reader();
    var process_buffer = std.ArrayList(u8).init(alloc);
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
    var stream = std.io.fixedBufferStream(source.input_sample);
    var reader = stream.reader();
    var process_buffer = std.ArrayList(u8).init(alloc);
    var buffer_writer = process_buffer.writer();
    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |line| {
        _ = line;
        // Process input here
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
}

pub fn main() !void {
    var allocator = std.heap.HeapAllocator.init();
    {
        var arena = std.heap.ArenaAllocator.init(allocator.allocator());
        defer arena.deinit();
        try processPartOne(arena.allocator());
    }
    {
        var arena = std.heap.ArenaAllocator.init(allocator.allocator());
        defer arena.deinit();
        try processPartTwo(arena.allocator());
    }
}
