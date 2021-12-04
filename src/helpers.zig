const std = @import("std");
pub const str_len = 256;
pub const ArrayListOfStr = std.ArrayList(std.ArrayList(u8));

pub const Task = enum { first, second };

pub fn read_file_to_string_array(fname:[]const u8) !ArrayListOfStr {
    var file = try std.fs.cwd().openFile(fname, .{});
    defer file.close();
    
    var res = ArrayListOfStr.init(std.heap.page_allocator);
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [str_len]u8 = undefined;
    var gpa_inner = std.heap.GeneralPurposeAllocator(.{}){};
        
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var s = std.ArrayList(u8).init(&gpa_inner.allocator);
        try s.appendSlice(line);
        try res.append(s);
    }
    return res;
}

test "test io" {
    const res = try read_file_to_string_array("input_data/day1.txt");
    try std.testing.expectEqual(std.fmt.parseInt(i32, res.items[0].items, 10), 170);
}