const std = @import("std");
pub const Task = enum { first, second };
pub const max_str_len = 1000;
pub const StringList = std.ArrayList(std.ArrayList(u8));

pub fn deinit_sl(sl: StringList) void {
    for (sl.items) |elt| {
        elt.deinit();
    }
    sl.deinit();
}

pub fn read_file_to_string_array(fname: []const u8, allocator: *std.mem.Allocator) !StringList {
    var file = try std.fs.cwd().openFile(fname, .{});
    defer file.close();

    var sl = StringList.init(allocator);
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [max_str_len]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var s = std.ArrayList(u8).init(allocator);
        try s.appendSlice(line);
        try sl.append(s);
    }
    return sl;
}

pub fn to_ints(input: StringList) !std.ArrayList(i32) {
    var res = std.ArrayList(i32).init(std.heap.page_allocator);
    for (input.items) |s| {
        const parsed = try std.fmt.parseInt(i32, s.items, 10);
        try res.append(parsed);
    }
    return res;
}

test "test read" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const res = try read_file_to_string_array("input_data/day1.txt", &arena.allocator);
    defer deinit_sl(res);
    const parsed = try std.fmt.parseInt(i32, res.items[0].items, 10);
    try std.testing.expectEqual(parsed, 170);
}

test "to ints" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;
    const x = try to_ints(try read_file_to_string_array("input_data/day1.txt", allocator));
    defer x.deinit();
    try std.testing.expectEqual(x.items[0], 170);
    try std.testing.expectEqual(x.items[x.items.len - 1], 7181);
}
