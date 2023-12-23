const std = @import("std");
const source = @import("days/day_11/day_11_input.zig");

pub fn partOneHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 11 - Part 1 ===\n", .{});
}

pub fn partTwoHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 11 - Part 2 ===\n", .{});
}

const Cell = struct {
    t: enum { SPACE, GALAXY },
    weight: u64,
    x: u64,
    y: u64,
    parent: ?*Cell = null,
};

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_sample1);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var grid = std.ArrayList([]Cell).init(alloc);
    var current_y: u64 = 0;

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        var hit_galaxy: bool = false;
        var line = try alloc.alloc(Cell, process_buffer.items.len);
        for (process_buffer.items, line, 0..) |char, *cell, x| {
            switch (char) {
                '.' => {
                    cell.t = .SPACE;
                    cell.weight = 0;
                    cell.x = x;
                    cell.y = current_y;
                },
                '#' => {
                    cell.t = .GALAXY;
                    cell.weight = 0;
                    cell.x = x;
                    cell.y = current_y;
                    hit_galaxy = true;
                },
                else => unreachable,
            }
        }

        try grid.append(line);
        current_y += 1;

        if (!hit_galaxy) {
            var expanded_line = try alloc.alloc(Cell, process_buffer.items.len);
            for (expanded_line, 0..) |*c, i| {
                c.t = .SPACE;
                c.x = i;
                c.y = current_y;
                c.weight = 0;
            }
            try grid.append(expanded_line);
            current_y += 1;
        }

        process_buffer.clearRetainingCapacity();
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    var expansion_indexs = std.ArrayList(u64).init(alloc);
    for (0..grid.items[0].len) |x_ind| {
        var found_galaxy = false;
        for (0..grid.items.len) |y_ind| {
            if (grid.items[y_ind][x_ind].t == .GALAXY) found_galaxy = true;
        }

        if (!found_galaxy) {
            try expansion_indexs.append(x_ind);
        }
    }

    for (try expansion_indexs.toOwnedSlice(), 0..) |x_ind, offset| {
        for (0..grid.items.len) |y_ind| {
            var new_line = std.ArrayList(Cell).fromOwnedSlice(alloc, grid.orderedRemove(y_ind));

            try new_line.insert(x_ind + offset, .{
                .x = x_ind,
                .y = y_ind,
                .t = .SPACE,
                .weight = 0,
                .parent = null,
            });

            for (new_line.items, 0..new_line.items.len) |*nl_c, ind| {
                nl_c.x = ind;
                nl_c.y = y_ind;
            }

            try grid.insert(y_ind, try new_line.toOwnedSlice());
        }
    }

    var galaxy_points = std.ArrayList(Cell).init(alloc);
    for (grid.items) |y| {
        for (y) |x| {
            if (x.t == .GALAXY) try galaxy_points.append(.{ .x = x.x, .y = x.y, .t = x.t, .weight = 0 });
        }
    }

    var sum_of_path: u64 = 0;
    for (galaxy_points.items, 0..) |start, i| {
        sum_of_path += try dijkstraPathLens(alloc, start, galaxy_points.items[i + 1 ..], grid.items);
    }

    try std.io.getStdOut().writer().print("{d}\n", .{sum_of_path});
}

fn weightSort(ctx: void, a: *Cell, b: *Cell) std.math.Order {
    _ = ctx;
    if (a.weight < b.weight) return .lt;
    if (b.weight < a.weight) return .gt;

    return .lt;
}

fn dijkstraPathLens(alloc: std.mem.Allocator, start: Cell, targets: []Cell, grid: [][]Cell) !u64 {
    var visit_queue = std.PriorityQueue(*Cell, void, weightSort).init(alloc, {});
    try visit_queue.ensureTotalCapacity(grid.len * grid[0].len);
    defer visit_queue.deinit();

    var explored_map = std.AutoHashMap(u64, *Cell).init(alloc);
    defer explored_map.clearAndFree();

    var neighbors = try std.ArrayList(Cell).initCapacity(alloc, 4);
    defer neighbors.clearAndFree();

    try visit_queue.add(&grid[start.y][start.x]);

    var steps: u64 = 0;
    end: while (true) {
        var found: *Cell = while (true) {
            var c = visit_queue.removeOrNull();
            if (c == null) break :end;

            var target_found: ?*Cell = for (targets) |target| {
                if (c.?.x == target.x and c.?.y == target.y) {
                    break &grid[c.?.y][c.?.x];
                }
            } else null;
            if (target_found != null) break target_found.?;

            if (c.?.y > 0) try neighbors.append(grid[c.?.y - 1][c.?.x]);
            if (c.?.x < grid[0].len - 1) try neighbors.append(grid[c.?.y][c.?.x + 1]);
            if (c.?.y < grid.len - 1) try neighbors.append(grid[c.?.y + 1][c.?.x]);
            if (c.?.x > 0) try neighbors.append(grid[c.?.y][c.?.x - 1]);

            for (neighbors.items) |n| {
                if (explored_map.get(coordKey(n.x, n.y)) == null) {
                    try explored_map.put(coordKey(n.x, n.y), &grid[c.?.y][c.?.x]);
                    try visit_queue.add(&grid[n.y][n.x]);
                }
            }

            neighbors.clearRetainingCapacity();
        } else unreachable;

        steps +=
            (@max(found.x, start.x) - @min(found.x, start.x)) +
            (@max(found.y, start.y) - @min(found.y, start.y));
    }

    return steps;
}

fn coordKey(x: u64, y: u64) u64 {
    return x +
        (y + ((x + 1) / 2)) *
        (y + ((x + 1) / 2));
}

pub fn processPartTwo(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_sample2);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        // Process input here
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }
}
