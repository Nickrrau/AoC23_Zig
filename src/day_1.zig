const std = @import("std");
const source = @import("days/day_1/day_1_input.zig");

pub fn partOneHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 1 - Part 1 ===\n", .{});
}

pub fn partTwoHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 1 - Part 2 ===\n", .{});
}

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_sample1);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var numbers = std.ArrayList(u64).init(alloc);

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var first: ?u8 = null;
        var last: ?u8 = null;

        for (try process_buffer.toOwnedSlice()) |char| {
            if (std.ascii.isDigit(char)) {
                if (first == null) first = char;
                last = char;
            }
        }

        var num = try std.fmt.parseUnsigned(u64, &.{ first.?, last.? }, 0);
        try numbers.append(num);
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var total_number: u64 = 0;
    for (try numbers.toOwnedSlice()) |num| {
        total_number += num;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total_number});
}

const written_digits = &[_][]const u8{
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
};

pub fn processPartTwo(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var numbers = std.ArrayList(u64).init(alloc);

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var first: ?u8 = null;
        var last: ?u8 = null;

        var prev_buffer = try std.ArrayList(u8).initCapacity(alloc, process_buffer.items.len);

        for (try process_buffer.toOwnedSlice()) |char| {
            if (std.ascii.isDigit(char)) {
                if (first == null) first = char;
                last = char;
                prev_buffer.clearAndFree();
            } else {
                try prev_buffer.append(char);
                var tmp = prev_buffer.items;

                if (prev_buffer.items.len > 2) {
                    for (written_digits, 0..) |digit, i| {
                        if (std.mem.lastIndexOf(u8, tmp, digit)) |_| {
                            if (first == null) first = (try std.fmt.allocPrint(alloc, "{d}", .{i + 1}))[0];
                            last = (try std.fmt.allocPrint(alloc, "{d}", .{i + 1}))[0];

                            var pop = prev_buffer.pop();
                            prev_buffer.clearAndFree();
                            try prev_buffer.append(pop);
                        }
                    }
                }
            }
        }

        var num = try std.fmt.parseUnsigned(u64, &.{ first.?, last.? }, 0);
        try numbers.append(num);

        first = null;
        last = null;
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var total_number: u64 = 0;
    for (try numbers.toOwnedSlice()) |num| {
        total_number += num;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total_number});
}

pub fn main() !void {
    var allocator = std.heap.HeapAllocator.init();
    {
        try std.io.getStdOut().writer().print("=== AoC'23 Day 1 - Part 1 ===\n", .{});
        var arena = std.heap.ArenaAllocator.init(allocator.allocator());
        defer arena.deinit();
        try processPartOne(arena.allocator());
    }
    {
        try std.io.getStdOut().writer().print("=== AoC'23 Day 1 - Part 2 ===\n", .{});
        var arena = std.heap.ArenaAllocator.init(allocator.allocator());
        defer arena.deinit();
        try processPartTwo(arena.allocator());
    }
}
