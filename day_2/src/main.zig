const std = @import("std");

pub fn main() !void {
    std.debug.print("Program started\n", .{});

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var line_reader = buf_reader.reader();

    var line_buf: [1000]u8 = undefined;

    var unsafe_count: i32 = 0;

    while (try line_reader.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        var split_str = std.mem.splitSequence(u8, line, " ");
        
        var previous  = try std.fmt.parseInt(i32, split_str.first(), 10);
        const initial_next_int = try std.fmt.parseInt(i32, split_str.next().?, 10);
        const increasing = previous < initial_next_int;

        const initial_diff = @abs(previous - initial_next_int);

        if (initial_diff > 3 or initial_diff == 0) {
            std.debug.print("Bad diff: {d}\n", .{initial_diff});
            std.debug.print("Previous: {d}, Next: {d}\n", .{previous, initial_next_int});
            std.debug.print("Line: {s}\n", .{line});
            unsafe_count += 1;
            continue;
        }

        previous = initial_next_int;

        while (split_str.next()) |next_str| {
            const next_int = try std.fmt.parseInt(i32, next_str, 10);

            if (increasing) {
                if (next_int <= previous) {
                    unsafe_count += 1;
                    std.debug.print("Bad increasing: Previous: {d}, Next: {d}\n", .{previous, next_int});
                    break;
                }
            } else {
                if (next_int >= previous) {
                    unsafe_count += 1;
                    std.debug.print("Bad decreasing: Previous: {d}, Next: {d}\n", .{previous, next_int});
                    break;
                }
            }

            const diff = @abs(previous - next_int);

            if (diff > 3 or diff == 0) {
                std.debug.print("Bad diff: {d}\n", .{diff});
                std.debug.print("Previous: {d}, Next: {d}\n", .{previous, next_int});
                std.debug.print("Line: {s}\n", .{line});
                unsafe_count += 1;
                break;
            }

            previous = next_int;
        }
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Result 1: {d}\n", .{1000 - unsafe_count});

    try bw.flush(); // don't forget to flush!
}
