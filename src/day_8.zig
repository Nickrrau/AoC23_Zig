const std = @import("std");
const source = @import("days/day_8/day_8_input.zig");

pub fn partOneHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 8 - Part 1 ===\n", .{});
}

pub fn partTwoHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 8 - Part 2 ===\n", .{});
}

const Node = struct {
    name: []const u8,
    left: []u8,
    right: []u8,
};

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var node_map = std.StringHashMap(Node).init(alloc);

    try reader.streamUntilDelimiter(buffer_writer, '\n', null);
    const instructions = try process_buffer.toOwnedSlice();

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        if (process_buffer.items.len == 0) continue;

        var name = try alloc.alloc(u8, 3);
        @memcpy(name, process_buffer.items[0..3]);
        var left = try alloc.alloc(u8, 3);
        @memcpy(left, process_buffer.items[7..10]);
        var right = try alloc.alloc(u8, 3);
        @memcpy(right, process_buffer.items[12..15]);

        try node_map.put(name, Node{ .name = name, .left = left, .right = right });
        process_buffer.clearRetainingCapacity();
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var current_node: *Node = node_map.getPtr("AAA").?;
    var steps: usize = 0;
    exit: while (true) {
        for (instructions) |direction| {
            steps += 1;
            if (std.mem.eql(u8, &[1]u8{direction}, "R")) {
                if (std.mem.eql(u8, current_node.right, "ZZZ")) break :exit;
                current_node = node_map.getPtr(current_node.right).?;
                continue;
            }
            if (std.mem.eql(u8, &[1]u8{direction}, "L")) {
                if (std.mem.eql(u8, current_node.left, "ZZZ")) break :exit;
                current_node = node_map.getPtr(current_node.left).?;
                continue;
            }
            unreachable;
        }
    }

    try std.io.getStdOut().writer().print("{d}\n", .{steps});
}

// Glanced at HenningCode's solution for this one, thanks :)
fn lcm(values: []usize) usize {
    if (values.len == 1) return values[0];
    var a = values[0];
    var b = lcm(values[1..]);
    return a * b / std.math.gcd(a, b);
}

pub fn processPartTwo(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var node_map = std.StringArrayHashMap(Node).init(alloc);

    try reader.streamUntilDelimiter(buffer_writer, '\n', null);
    const instructions = try process_buffer.toOwnedSlice();

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        if (process_buffer.items.len == 0) continue;

        var name = try alloc.alloc(u8, 3);
        @memcpy(name, process_buffer.items[0..3]);
        var left = try alloc.alloc(u8, 3);
        @memcpy(left, process_buffer.items[7..10]);
        var right = try alloc.alloc(u8, 3);
        @memcpy(right, process_buffer.items[12..15]);

        try node_map.put(name, Node{ .name = name, .left = left, .right = right });
        process_buffer.clearRetainingCapacity();
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var starting_pos = std.ArrayList(*Node).init(alloc);
    for (node_map.values()) |*node| {
        if (node.name[2] == 'A') {
            try starting_pos.append(node);
        }
    }

    var ending_pos = std.ArrayList(usize).init(alloc);
    for (try starting_pos.toOwnedSlice()) |node| {
        var n: *Node = node;
        var index: usize = 0;
        var steps: usize = 0;
        while (true) {
            if (n.name[2] == 'Z') {
                try ending_pos.append(steps);
                break;
            }
            steps += 1;
            if (instructions[index] == 'R') {
                n = node_map.getPtr(n.right).?;
            } else if (instructions[index] == 'L') {
                n = node_map.getPtr(n.left).?;
            }
            if (index == instructions.len - 1) index = 0 else index += 1;
            continue;
        }
    }

    try std.io.getStdOut().writer().print("{d}\n", .{lcm(try ending_pos.toOwnedSlice())});
}
