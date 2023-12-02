const std = @import("std");
const source = @import("days/day_2/day_2_input.zig");

pub fn partOneHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 2 - Part 1 ===\n", .{});
}

pub fn partTwoHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 2 - Part 2 ===\n", .{});
}

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    const num_red = 12;
    const num_green = 13;
    const num_blue = 14;

    var impossible_games = std.ArrayList(bool).init(alloc);

    try reader.skipUntilDelimiterOrEof(':'); // Toss 'Game x:'
    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var game = try impossible_games.addOne();
        var runs_iter = std.mem.splitScalar(u8, process_buffer.items, ';');

        outer: while (runs_iter.next()) |run| {
            var counts_iter = std.mem.splitScalar(u8, run, ',');

            while (counts_iter.next()) |cnt| {
                var colors_iter = std.mem.splitScalar(u8, std.mem.trim(u8, cnt, " "), ' ');
                const amount_str = colors_iter.next();
                const amount_int = try std.fmt.parseUnsigned(u64, amount_str.?, 0);
                const color = colors_iter.next();

                if ((std.mem.eql(u8, color.?, "red") and amount_int > num_red) or
                    (std.mem.eql(u8, color.?, "green") and amount_int > num_green) or
                    (std.mem.eql(u8, color.?, "blue") and amount_int > num_blue))
                {
                    game.* = true;
                    break :outer;
                } else {
                    game.* = false;
                }
            }
        }

        process_buffer.clearRetainingCapacity();
        try reader.skipUntilDelimiterOrEof(':'); // Toss 'Game x:'
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var sum_of_possible_game_ids: u64 = 0;
    for (try impossible_games.toOwnedSlice(), 0..) |g, id| {
        if (!g) {
            sum_of_possible_game_ids += (id + 1);
        }
    }

    try std.io.getStdOut().writer().print("{d}\n", .{sum_of_possible_game_ids});
}

pub fn processPartTwo(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var sum_power_of_all_games: u64 = 0;

    try reader.skipUntilDelimiterOrEof(':'); // Toss 'Game x:'
    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var red_min: u64 = 0;
        var green_min: u64 = 0;
        var blue_min: u64 = 0;

        var runs_iter = std.mem.splitScalar(u8, process_buffer.items, ';');
        while (runs_iter.next()) |run| {
            var counts_iter = std.mem.splitScalar(u8, run, ',');

            while (counts_iter.next()) |cnt| {
                var colors_iter = std.mem.splitScalar(u8, std.mem.trim(u8, cnt, " "), ' ');
                const amount_str = colors_iter.next();
                const amount_int = try std.fmt.parseUnsigned(u64, amount_str.?, 0);
                const color = colors_iter.next();

                if (std.mem.eql(u8, color.?, "red") and amount_int > red_min) {
                    red_min = amount_int;
                } else if (std.mem.eql(u8, color.?, "green") and amount_int > green_min) {
                    green_min = amount_int;
                } else if (std.mem.eql(u8, color.?, "blue") and amount_int > blue_min) {
                    blue_min = amount_int;
                }
            }
        }

        sum_power_of_all_games += (red_min * green_min * blue_min);

        process_buffer.clearRetainingCapacity();
        try reader.skipUntilDelimiterOrEof(':'); // Toss 'Game x:'
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    try std.io.getStdOut().writer().print("{d}\n", .{sum_power_of_all_games});
}
