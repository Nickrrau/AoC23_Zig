const std = @import("std");
const source = @import("days/day_10/day_10_input.zig");

pub fn partOneHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 10 - Part 1 ===\n", .{});
}

pub fn partTwoHeader() !void {
    try std.io.getStdOut().writer().print("=== AoC'23 Day 10 - Part 2 ===\n", .{});
}

pub fn processPartOne(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var grid: Grid = .{ .internal_list = std.ArrayList([]u8).init(alloc), .width = 0, .height = 0 };
    var start: Coords = .{ .x = 0, .y = 0 };

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        if (grid.width == 0) grid.width = process_buffer.items.len;
        for (process_buffer.items, 0..) |x, i| {
            if (x == 'S') {
                start.x = i;
                start.y = grid.internal_list.items.len;
            }
        }
        try grid.internal_list.append(try process_buffer.toOwnedSlice());
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    grid.height = grid.internal_list.items.len;
    var steps: u64 = 0;

    grid.set(start.x, start.y, grid.inferVal(start.x, start.y));

    // Thought I could predict the future here and the next part would involve getting the direction with least number of turns... Oh Well...
    var crawler1: Crawler = .{ .pos = .{ .x = start.x, .y = start.y }, .direction = .NA };
    var crawler2: Crawler = .{ .pos = .{ .x = start.x, .y = start.y }, .direction = .NA };

    while (true) {
        // Left Search
        switch (grid.access(crawler1.pos.x, crawler1.pos.y).?) {
            '|' => if (crawler1.direction == .SOUTH or crawler1.direction == .NA) crawler1.move(.SOUTH) else crawler1.move(.NORTH),
            '-' => if (crawler1.direction == .EAST or crawler1.direction == .NA) crawler1.move(.EAST) else crawler1.move(.WEST),
            'L' => if (crawler1.direction == .SOUTH or crawler1.direction == .NA) crawler1.move(.EAST) else crawler1.move(.NORTH),
            'J' => if (crawler1.direction == .SOUTH or crawler1.direction == .NA) crawler1.move(.WEST) else crawler1.move(.NORTH),
            '7' => if (crawler1.direction == .NORTH or crawler1.direction == .NA) crawler1.move(.WEST) else crawler1.move(.SOUTH),
            'F' => if (crawler1.direction == .NORTH or crawler1.direction == .NA) crawler1.move(.EAST) else crawler1.move(.SOUTH),
            else => unreachable,
        }
        // Right Search
        switch (grid.access(crawler2.pos.x, crawler2.pos.y).?) {
            '|' => if (crawler2.direction == .SOUTH) crawler2.move(.SOUTH) else crawler2.move(.NORTH),
            '-' => if (crawler2.direction == .EAST) crawler2.move(.EAST) else crawler2.move(.WEST),
            'L' => if (crawler2.direction == .SOUTH) crawler2.move(.EAST) else crawler2.move(.NORTH),
            'J' => if (crawler2.direction == .SOUTH) crawler2.move(.WEST) else crawler2.move(.NORTH),
            '7' => if (crawler2.direction == .NORTH) crawler2.move(.WEST) else crawler2.move(.SOUTH),
            'F' => if (crawler2.direction == .NORTH) crawler2.move(.EAST) else crawler2.move(.SOUTH),
            else => unreachable,
        }

        steps += 1;
        if (steps > 0) {
            if (crawler1.pos.equals(crawler2.pos)) break;
        }
    }

    try std.io.getStdOut().writer().print("{d}\n", .{steps});
}

const Crawler = struct {
    pos: Coords,
    direction: enum { NORTH, EAST, SOUTH, WEST, NA },

    pub fn move(self: *@This(), dir: @TypeOf(self.direction)) void {
        if (dir == .SOUTH) self.pos.y += 1;
        if (dir == .NORTH) self.pos.y -= 1;
        if (dir == .EAST) self.pos.x += 1;
        if (dir == .WEST) self.pos.x -= 1;
        self.direction = dir;
    }
};

const Coords = struct {
    x: u64,
    y: u64,

    pub fn equals(self: @This(), eql: Coords) bool {
        return self.x == eql.x and self.y == eql.y;
    }

    pub fn move(self: *@This(), to: Coords) void {
        self.x = to.x;
        self.y = to.y;
    }
};

const Grid = struct {
    internal_list: std.ArrayList([]u8),
    width: u64,
    height: u64,

    pub fn access(self: @This(), x: u64, y: u64) ?u8 {
        if ((x < 0 or x > self.width - 1) or (y < 0 or y > self.height - 1)) return null;
        return self.internal_list.items[y][x];
    }

    pub fn set(self: @This(), x: u64, y: u64, val: u8) void {
        if ((x < 0 or x > self.width - 1) or (y < 0 or y > self.height - 1)) return;
        self.internal_list.items[y][x] = val;
    }

    pub fn inferVal(self: @This(), x: u64, y: u64) u8 {
        if (self.internal_list.items[y][x] == 'S') {
            var north: u8 = 0;
            if (y != 0) {
                north = switch (self.access(x, y - 1).?) {
                    '|', 'F', '7' => self.access(x, y - 1).?,
                    else => 0,
                };
            }
            var east: u8 = 0;
            if (x != self.width - 1) {
                east = switch (self.access(x + 1, y).?) {
                    '7', '-', 'J' => self.access(x + 1, y).?,
                    else => 0,
                };
            }

            var south: u8 = 0;
            if (y != self.height - 1) {
                south = switch (self.access(x, y + 1).?) {
                    '|', 'L', 'J' => self.access(x, y + 1).?,
                    else => 0,
                };
            }

            var west: u8 = 0;
            if (x != 0) {
                west = switch (self.access(x - 1, y).?) {
                    'F', '-', 'L' => self.access(x - 1, y).?,
                    else => 0,
                };
            }

            if (north > 0) {
                if (south > 0) return '|';
                if (west > 0) return 'J';
                if (east > 0) return 'L';
            }
            if (south > 0) {
                if (west > 0) return '7';
                if (east > 0) return 'F';
            }
            if (west > 0) {
                if (east > 0) return '-';
            }
        }

        return self.internal_list.items[y][x];
    }
};

pub fn processPartTwo(alloc: std.mem.Allocator) !void {
    var stream = std.io.fixedBufferStream(source.input_src);
    var reader = stream.reader();
    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    var buffer_writer = process_buffer.writer();

    var grid: Grid = .{ .internal_list = std.ArrayList([]u8).init(alloc), .width = 0, .height = 0 };
    var start: Coords = .{ .x = 0, .y = 0 };

    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |_| {
        if (grid.width == 0) grid.width = process_buffer.items.len;
        for (process_buffer.items, 0..) |x, i| {
            if (x == 'S') {
                start.x = i;
                start.y = grid.internal_list.items.len;
            }
        }
        try grid.internal_list.append(try process_buffer.toOwnedSlice());
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    grid.height = grid.internal_list.items.len;
    grid.set(start.x, start.y, grid.inferVal(start.x, start.y));

    var crawler1: Crawler = .{ .pos = .{ .x = start.x, .y = start.y }, .direction = .NA };

    // Probably could do some work here to use a map so that we can access only the coords that land on a specifc y index.
    // This would allow us later on to avoid iterating over potentially the entire path each check for visitation.
    var visited = std.ArrayList(Coords).init(alloc);
    try visited.append(.{ .x = start.x, .y = start.y });

    var smallest_x: u64 = start.x;
    var smallest_y: u64 = start.x;
    var largest_x: u64 = start.y;
    var largest_y: u64 = start.y;

    while (true) {
        // Left Search
        switch (grid.access(crawler1.pos.x, crawler1.pos.y).?) {
            '|' => if (crawler1.direction == .SOUTH or crawler1.direction == .NA) crawler1.move(.SOUTH) else crawler1.move(.NORTH),
            '-' => if (crawler1.direction == .EAST or crawler1.direction == .NA) crawler1.move(.EAST) else crawler1.move(.WEST),
            'L' => if (crawler1.direction == .SOUTH or crawler1.direction == .NA) crawler1.move(.EAST) else crawler1.move(.NORTH),
            'J' => if (crawler1.direction == .SOUTH or crawler1.direction == .NA) crawler1.move(.WEST) else crawler1.move(.NORTH),
            '7' => if (crawler1.direction == .NORTH or crawler1.direction == .NA) crawler1.move(.WEST) else crawler1.move(.SOUTH),
            'F' => if (crawler1.direction == .NORTH or crawler1.direction == .NA) crawler1.move(.EAST) else crawler1.move(.SOUTH),
            else => unreachable,
        }
        try visited.append(.{ .x = crawler1.pos.x, .y = crawler1.pos.y });
        if (crawler1.pos.x > largest_x) largest_x = crawler1.pos.x;
        if (crawler1.pos.x < smallest_x) smallest_x = crawler1.pos.x;

        if (crawler1.pos.y > largest_y) largest_y = crawler1.pos.y;
        if (crawler1.pos.y < smallest_y) smallest_y = crawler1.pos.y;

        if (crawler1.pos.equals(start)) break;
    }

    var inside_cells_count: u64 = 0;
    for (grid.internal_list.items, 0..) |row, row_index| {
        if (row_index < smallest_y or row_index > largest_y) continue;
        for (0..row.len) |col_index| {
            if (col_index < smallest_x or col_index > largest_x) continue;

            var found = for (visited.items) |vis| {
                if (vis.x == col_index and row_index == vis.y) break true;
            } else false;

            if (found) continue;

            var collisions = raycast(row_index, col_index, row[col_index..], visited);

            if (collisions % 2 == 1 and collisions != 0) {
                inside_cells_count += 1;
            }
        }
    }

    try std.io.getStdOut().writer().print("{d}\n", .{inside_cells_count});
}

// This is pretty naive and takes over 10 seconds, would be better to track successive runs
// and return this, then we could skip over large swaths empty space.
fn raycast(row_index: usize, offset: usize, row: []u8, polygon: std.ArrayList(Coords)) u64 {
    var intersections: u64 = 0;
    for (row, offset..) |ray_pos, i| {
        var found = for (polygon.items) |vis| {
            if (vis.x == i and row_index == vis.y) {
                break true;
            }
        } else false;

        if (found) {
            if (ray_pos != '-' and ray_pos != 'L' and ray_pos != 'J') {
                intersections += 1;
            }
        }
    }
    return intersections;
}
