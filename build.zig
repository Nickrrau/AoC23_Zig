const std = @import("std");

const SessionKey = @embedFile("key.secret");

const DaySrcTemplate =
    \\const std = @import("std");
    \\
    \\pub const input_src = @embedFile("day_{d}_input.txt");
    \\pub const input_sample1 = @embedFile("day_{d}_sample_1.txt");
    \\pub const input_sample2 = @embedFile("day_{d}_sample_2.txt");
    \\
;
const DayScaffoldTemplate =
    \\const std = @import("std");
    \\const source = @import("days/day_{d}/day_{d}_input.zig");
    \\
    \\pub fn partOneHeader() !void {{
    \\    try std.io.getStdOut().writer().print("=== AoC'23 Day {d} - Part 1 ===\n", .{{}});
    \\}}
    \\
    \\pub fn partTwoHeader() !void {{
    \\    try std.io.getStdOut().writer().print("=== AoC'23 Day {d} - Part 2 ===\n", .{{}});
    \\}}
    \\
    \\pub fn processPartOne(alloc: std.mem.Allocator) !void {{
    \\    var stream = std.io.fixedBufferStream(source.input_sample1);
    \\    var reader = stream.reader();
    \\    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    \\    var buffer_writer = process_buffer.writer();
    \\    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |line| {{
    \\        _ = line;
    \\        // Process input here
    \\    }} else |err| switch (err) {{
    \\        error.EndOfStream => {{}},
    \\        else => return err,
    \\    }}
    \\}}
    \\
    \\
    \\pub fn processPartTwo(alloc: std.mem.Allocator) !void {{
    \\    var stream = std.io.fixedBufferStream(source.input_sample2);
    \\    var reader = stream.reader();
    \\    var process_buffer = try std.ArrayList(u8).initCapacity(alloc, source.input_src.len);
    \\    var buffer_writer = process_buffer.writer();
    \\    while (reader.streamUntilDelimiter(buffer_writer, '\n', null)) |line| {{
    \\        _ = line;
    \\        // Process input here
    \\    }} else |err| switch (err) {{
    \\        error.EndOfStream => {{}},
    \\        else => return err,
    \\    }}
    \\}}
    \\
;

fn getInput(alloc: std.mem.Allocator, day: usize) ![]const u8 {
    var url = .{ .url = try std.fmt.allocPrint(alloc, "https://adventofcode.com/2023/day/{d}/input", .{day}) };
    var headers = std.http.Headers.init(alloc);

    try headers.append("Cookie", SessionKey);
    defer headers.deinit();

    var cl = std.http.Client{ .allocator = alloc };
    defer cl.deinit();
    const t = try cl.fetch(alloc, .{
        .location = url,
        .headers = headers,
    });

    var buf = try alloc.alloc(u8, t.body.?.len);
    @memcpy(buf, t.body.?);
    return buf;
}

fn buildDay(b: *std.Build, s: *std.Build.Step) !void {
    var alloc = b.allocator;
    const day_param = b.option(usize, "day", "Day in December to generate");
    if (day_param == null) return;

    const scaffold_filepath = try std.fmt.allocPrint(alloc, "src/day_{d}.zig", .{day_param.?});

    const day_filename = try std.fmt.allocPrint(alloc, "day_{d}_input.zig", .{day_param.?});
    const day_path = try std.fmt.allocPrint(alloc, "src/days/day_{d}", .{day_param.?});
    const day_filepath = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ day_path, day_filename });

    const day_sample1_filename = try std.fmt.allocPrint(alloc, "day_{d}_sample_1.txt", .{day_param.?});
    const day_sample1_filepath = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ day_path, day_sample1_filename });
    const day_sample2_filename = try std.fmt.allocPrint(alloc, "day_{d}_sample_2.txt", .{day_param.?});
    const day_sample2_filepath = try std.fmt.allocPrint(alloc, "{s}/{s}", .{ day_path, day_sample2_filename });

    const day_input_filename = try std.fmt.allocPrint(alloc, "day_{d}_input.txt", .{day_param.?});
    const day_input_filepath = try std.fmt.allocPrint(alloc, "{s}/day_{d}_input.txt", .{ day_path, day_param.? });

    const scaffold = try std.fmt.allocPrint(alloc, DayScaffoldTemplate, .{ day_param.?, day_param.?, day_param.?, day_param.? });
    const day_file_contents = try std.fmt.allocPrint(alloc, DaySrcTemplate, .{ day_param.?, day_param.?, day_param.? });
    const input = try getInput(alloc, day_param.?);

    const write_files = b.addWriteFiles();
    const copy_files = b.addWriteFiles();

    const input_sample1 = write_files.add(day_sample1_filename, "");
    const input_sample2 = write_files.add(day_sample2_filename, "");
    const input_src = write_files.add(day_input_filename, input);
    const input_zig = write_files.add(day_filename, day_file_contents);
    const scaffold_zig = write_files.add(scaffold_filepath, scaffold);
    copy_files.addCopyFileToSource(input_sample1, day_sample1_filepath);
    copy_files.addCopyFileToSource(input_sample2, day_sample2_filepath);
    copy_files.addCopyFileToSource(input_src, day_input_filepath);
    copy_files.addCopyFileToSource(input_zig, day_filepath);
    copy_files.addCopyFileToSource(scaffold_zig, scaffold_filepath);

    s.dependOn(b.getInstallStep());
    s.dependOn(&write_files.step);
    s.dependOn(&copy_files.step);
}

pub fn build(b: *std.Build) !void {
    const cwd = std.fs.cwd();
    var days_dir = try cwd.makeOpenPathIterable("src/days", .{});
    var days_it = days_dir.iterate();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var commands = std.ArrayList(*std.Build.Step).init(b.allocator);
    defer commands.deinit();
    while (try days_it.next()) |entry| {
        if (std.mem.eql(u8, entry.name[0..4], "day_")) {
            const step = b.step(entry.name, "");

            const mod = b.createModule(.{ .source_file = .{ .path = try std.fmt.allocPrint(b.allocator, "src/{s}.zig", .{entry.name}) } });

            const exe = b.addExecutable(.{
                .name = try std.fmt.allocPrint(b.allocator, "advent_of_code_2023_day_{s}", .{entry.name}),
                .root_source_file = .{ .path = "src/main.zig" },
                .target = target,
                .optimize = optimize,
            });
            exe.addModule("day", mod);
            b.installArtifact(exe);

            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(b.getInstallStep());
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }

            step.dependOn(&run_cmd.step);
            try commands.append(step);
        }
    }
    days_dir.close();

    const new_day = b.step("new", "Start a new day in AoC'23");
    try buildDay(b, new_day);
}
