const std = @import("std");

const day = @import("day");

pub fn main() !void {
    var allocator = std.heap.HeapAllocator.init();
    {
        try day.partOneHeader();
        var arena = std.heap.ArenaAllocator.init(allocator.allocator());
        defer arena.deinit();
        try day.processPartOne(arena.allocator());
    }
    {
        try day.partTwoHeader();
        var arena = std.heap.ArenaAllocator.init(allocator.allocator());
        defer arena.deinit();
        try day.processPartTwo(arena.allocator());
    }
}
