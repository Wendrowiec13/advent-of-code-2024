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

    while (try line_reader.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {

        var split_str = std.mem.splitSequence(u8, line, "   ");
        
        const first = split_str.first();
        const second = split_str.next().?;

        try list_1.append(try std.fmt.parseInt(i32, first, 10));
        try list_2.append(try std.fmt.parseInt(i32, second, 10));
    }

    std.mem.sort(i32, list_1.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, list_2.items, {}, std.sort.asc(i32));

    var result: u32 = 0;

    for (list_1.items, list_2.items) |item_1, item_2| {
        result += @abs(item_1 - item_2);
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Result: {d}\n", .{result});

    try bw.flush(); // don't forget to flush!
}
