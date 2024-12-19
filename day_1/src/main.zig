const std = @import("std");

pub fn main() !void {
    std.debug.print("Program started\n", .{});

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var line_reader = buf_reader.reader();

    var line_buf: [1000]u8 = undefined;

    var gpa_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa_allocator.allocator();
    defer _ = gpa_allocator.deinit();

    var list_1 = std.ArrayList(i32).init(allocator);
    defer list_1.deinit();
    var list_2 = std.ArrayList(i32).init(allocator);
    defer list_2.deinit();

    var occurrence_count_map = std.AutoHashMap(i32, i32).init(allocator);
    defer occurrence_count_map.deinit();

    while (try line_reader.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        var split_str = std.mem.splitSequence(u8, line, "   ");
        
        const first = try std.fmt.parseInt(i32, split_str.first(), 10);
        const second = try std.fmt.parseInt(i32, split_str.next().?, 10);
        try list_1.append(first);
        try list_2.append(second);

        if (occurrence_count_map.get(second)) |count| {
            try occurrence_count_map.put(second, count + 1);
        } else {
            try occurrence_count_map.put(second, 1);
        }
    }

    std.mem.sort(i32, list_1.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, list_2.items, {}, std.sort.asc(i32));

    var result_1: u32 = 0;
    var result_2: i32 = 0;

    for (list_1.items, list_2.items) |item_1, item_2| {
        result_1 += @abs(item_1 - item_2);
    }

    for (list_1.items) |item| {
        if (occurrence_count_map.get(item)) |count| {
            result_2 += item * count;
        }
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Result 1: {d}\n", .{result_1});
    try stdout.print("Result 2: {d}\n", .{result_2});

    try bw.flush(); // don't forget to flush!
}
