const std = @import("std");
const source = @import("days/day_7/day_7_input.zig");

pub fn partOneHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 7 - Part 1 ===\n", .{});
}

pub fn partTwoHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 7 - Part 2 ===\n", .{});
}

fn mapCardToValue(c: u8, pt2: bool) u64 {
    var incr: u64 = 0;
    if (pt2) incr += 1;
    switch (c) {
        'A' => return 13 + incr,
        'K' => return 12 + incr,
        'Q' => return 11 + incr,
        'T' => return 9 + incr,
        '9' => return 8 + incr,
        '8' => return 7 + incr,
        '7' => return 6 + incr,
        '6' => return 5 + incr,
        '5' => return 4 + incr,
        '4' => return 3 + incr,
        '3' => return 2 + incr,
        '2' => return 1 + incr,
        'J' => {
            if (pt2) return 1 else return 10;
        },
        else => unreachable,
    }
}

const Hand = struct {
    const Self = @This();
    bid: u64,
    cards: [5]u64,
    rank_val: u64 = 0,
    joker_rules: bool = false,

    pub fn rank(self: Self, alloc: std.mem.Allocator) !u64 {
        var frequency = std.AutoArrayHashMap(u64, u64).init(alloc);
        defer frequency.deinit();

        var jokers: u64 = 0;
        for (self.cards) |c| {
            const res = try frequency.getOrPut(c);
            if (res.found_existing) {
                res.value_ptr.* += 1;
            } else {
                res.value_ptr.* = 1;
            }
            if (self.joker_rules and c == 1) jokers += 1;
        }

        const frequency_sort = struct {
            freq: []u64,
            pub fn lessThan(ctx: @This(), a: usize, b: usize) bool {
                return ctx.freq[a] > ctx.freq[b];
            }
        };
        frequency.sort(frequency_sort{ .freq = frequency.values() });

        for (frequency.values(), frequency.keys(), 0..) |freq, card, i| {
            if (freq == 5) return 6;
            if (card == 1 and self.joker_rules) {
                continue;
            } else {
                if (freq + jokers == 1) return 0;
                if (freq + jokers == 5) return 6;
                if (freq + jokers == 4) return 5;
                if (freq + jokers == 3) {
                    if (i + 1 < frequency.values().len and
                        frequency.values()[i + 1] == 2) return 4; // full house
                    return 3;
                }
                if (freq + jokers == 2) {
                    if (i + 1 < frequency.values().len and
                        frequency.values()[i + 1] == 2) return 2;
                    return 1;
                }
            }
        }
        return 0;
    }

    pub fn greaterThan(self: Self, other: Hand) bool {
        if (self.rank_val > other.rank_val) return true;
        if (self.rank_val < other.rank_val) return false;
        for (self.cards, other.cards) |c, oc| {
            if (c > oc) return true;
            if (c < oc) return false;
        }
        return false;
    }

    pub fn sort(ctx: void, lhs: Hand, rhs: Hand) bool {
        _ = ctx;
        return rhs.greaterThan(lhs);
    }
};

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var hands = std.ArrayList(Hand).init(alloc);

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var h = try hands.addOne();
        for (process_buffer.items[0..5], 0..) |c, i| {
            h.cards[i] = mapCardToValue(c, false);
        }

        var bid_raw = std.mem.trim(u8, process_buffer.items[5..], " ");
        h.bid = try std.fmt.parseUnsigned(u64, bid_raw, 0);

        h.rank_val = try h.rank(alloc);

        process_buffer.clearRetainingCapacity();
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var slice = try hands.toOwnedSlice();
    std.mem.sort(Hand, slice, {}, Hand.sort);
    var total_winnings: u64 = 0;

    for (slice, 0..) |*hand, i| {
        hand.rank_val = i + 1;
        total_winnings += hand.rank_val * hand.bid;
    }

    try std.io.getStdOut().writer().print("{d}\n", .{total_winnings});
}

pub fn processPartTwo(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var hands = std.ArrayList(Hand).init(alloc);

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var h = try hands.addOne();
        for (process_buffer.items[0..5], 0..) |c, i| {
            h.cards[i] = mapCardToValue(c, true);
        }

        var bid_raw = std.mem.trim(u8, process_buffer.items[5..], " ");
        h.bid = try std.fmt.parseUnsigned(u64, bid_raw, 0);

        h.*.joker_rules = true;
        h.*.rank_val = try h.rank(alloc);

        process_buffer.clearRetainingCapacity();
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var slice = try hands.toOwnedSlice();
    std.mem.sort(Hand, slice, {}, Hand.sort);
    var total_winnings: u64 = 0;

    for (slice, 0..) |*hand, i| {
        hand.rank_val = i + 1;
        total_winnings += hand.rank_val * hand.bid;
    }

    try std.io.getStdOut().writer().print("{d}\n", .{total_winnings});
}
