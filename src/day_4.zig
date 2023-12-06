const std = @import("std");
const source = @import("days/day_4/day_4_input.zig");

pub fn partOneHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 4 - Part 1 ===\n", .{});
}

pub fn partTwoHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 4 - Part 2 ===\n", .{});
}

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var cards = std.ArrayList(u32).init(alloc);
    var pulled_numbers = std.ArrayList(u64).init(alloc);
    var winning_numbers = std.ArrayList(u64).init(alloc);

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var number_split_iter = std.mem.splitScalar(u8, process_buffer.items, '|');
        var card_and_winning = std.mem.splitScalar(u8, number_split_iter.first(), ':');
        _ = card_and_winning.first();

        var winning_numbers_iter = std.mem.splitScalar(u8, std.mem.trim(u8, card_and_winning.next().?, " "), ' ');
        var numbers_pulled_iter = std.mem.splitScalar(u8, std.mem.trim(u8, number_split_iter.next().?, " "), ' ');

        defer pulled_numbers.clearRetainingCapacity();
        while (numbers_pulled_iter.next()) |num| {
            if (std.mem.eql(u8, num, "")) continue;
            try pulled_numbers.append(try std.fmt.parseUnsigned(u64, std.mem.trim(u8, num, " "), 0));
        }

        defer winning_numbers.clearRetainingCapacity();
        while (winning_numbers_iter.next()) |num| {
            if (std.mem.eql(u8, num, "")) continue;
            try winning_numbers.append(try std.fmt.parseUnsigned(u64, std.mem.trim(u8, num, " "), 0));
        }

        var card_score: u32 = 0;
        var matched: bool = false;
        for (pulled_numbers.items) |num| {
            for (winning_numbers.items) |win_num| {
                if (win_num == num) {
                    if (matched) {
                        card_score = card_score * 2;
                    } else {
                        matched = true;
                        card_score += 1;
                    }
                }
            }
        }

        try cards.append(card_score);

        process_buffer.clearRetainingCapacity();
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var sum_of_cards: u32 = 0;
    for (cards.items) |card| {
        sum_of_cards += card;
    }

    try std.io.getStdOut().writer().print("{d}\n", .{sum_of_cards});
}

pub fn processPartTwo(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var pulled_numbers = std.ArrayList(u64).init(alloc);
    var winning_numbers = std.ArrayList(u64).init(alloc);
    var card_instances = std.AutoArrayHashMap(usize, usize).init(alloc);
    var card_id: usize = 1;

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var number_split_iter = std.mem.splitScalar(u8, process_buffer.items, '|');
        var card_and_winning = std.mem.splitScalar(u8, number_split_iter.first(), ':');
        _ = card_and_winning.first();

        var winning_numbers_iter = std.mem.splitScalar(u8, std.mem.trim(u8, card_and_winning.next().?, " "), ' ');
        var numbers_pulled_iter = std.mem.splitScalar(u8, std.mem.trim(u8, number_split_iter.next().?, " "), ' ');

        defer pulled_numbers.clearRetainingCapacity();
        while (numbers_pulled_iter.next()) |num| {
            if (std.mem.eql(u8, num, "")) continue;
            try pulled_numbers.append(try std.fmt.parseUnsigned(u64, std.mem.trim(u8, num, " "), 0));
        }

        defer winning_numbers.clearRetainingCapacity();
        while (winning_numbers_iter.next()) |num| {
            if (std.mem.eql(u8, num, "")) continue;
            try winning_numbers.append(try std.fmt.parseUnsigned(u64, std.mem.trim(u8, num, " "), 0));
        }

        var matches: usize = 0;
        for (pulled_numbers.items) |num| {
            for (winning_numbers.items) |win_num| {
                if (win_num == num) {
                    matches += 1;
                }
            }
        }

        var instances: ?usize = card_instances.get(card_id);
        if (instances) |inst| {
            instances = inst + 1;
        } else {
            instances = 1;
        }
        try card_instances.put(card_id, instances.?);

        for ((card_id + 1)..((card_id + 1) + matches)) |id| {
            var instance_mult: usize = instances.?;

            if (card_instances.get(id)) |pn| {
                var total: usize = pn + (1 * instance_mult);
                try card_instances.put(id, total);
            } else {
                try card_instances.put(id, instance_mult);
            }
        }

        process_buffer.clearRetainingCapacity();
        card_id += 1;
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var sum_of_cards: u64 = 0;
    for (card_instances.values()) |card| {
        sum_of_cards += card;
    }

    try std.io.getStdOut().writer().print("{d}\n", .{sum_of_cards});
}
