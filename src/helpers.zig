const std = @import("std");
pub const Task = enum { first, second };
pub const max_str_len = 1000;
const ArrayList = std.ArrayList;
pub const StrList = ArrayList(ArrayList(u8));

pub fn deinit_sl(sl: StrList) void {
    for (sl.items) |elt| {
        elt.deinit();
    }
    sl.deinit();
}

pub fn read_file_to_string_array(fname: []const u8, allocator: *std.mem.Allocator) !StrList {
    var file = try std.fs.cwd().openFile(fname, .{});
    defer file.close();

    var sl = StrList.init(allocator);
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [max_str_len]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var s = ArrayList(u8).init(allocator);
        try s.appendSlice(line);
        try sl.append(s);
    }
    return sl;
}

pub fn to_ints(comptime T: type, input: StrList, radix: u8, allocator: *std.mem.Allocator) !ArrayList(T) {
    var res = ArrayList(T).init(allocator);
    for (input.items) |s| {
        const parsed = try std.fmt.parseInt(T, s.items, radix);
        try res.append(parsed);
    }
    return res;
}

pub fn get_bit(comptime T: type, a: T, bit_pos: usize) T {
    const one: T = 1;
    return std.math.shl(T, a, -@intCast(i9, bit_pos)) & 1;
}

pub fn set_bit(comptime T: type, a: T, bit_pos: usize) T {
    const one: T = 1;
    const shifted: T = std.math.shl(T, one, bit_pos);
    return a | shifted;
}

pub fn unset_bit(comptime T: type, a: T, bit_pos: usize) T {
    const one: T = 1;
    const shifted: T = std.math.shl(T, one, bit_pos);
    return a & ~shifted;
}

pub const Range = struct {
    len: usize,
    idx: usize = 0,
    pub fn next(self: *Range) ?usize {
        if (self.idx < self.len) {
            self.idx += 1;
            return self.idx - 1;
        }
        return null;
    }
    pub fn make(len: usize) Range {
        return Range{ .len = len };
    }
};

test "range" {
    var counter: usize = 0;
    var range = Range.make(50);
    while (range.next()) |idx| {
        try std.testing.expectEqual(counter, idx);
        counter += 1;
    }
}

fn test_get_bit(a: u8, pos: u8, ref: u8) !void {
    try std.testing.expectEqual(get_bit(u8, a, pos), ref);
}

fn test_set_bit(a: u8, pos: u8, ref: u8) !void {
    try std.testing.expectEqual(set_bit(u8, a, pos), ref);
}
fn test_unset_bit(a: u8, pos: u8, ref: u8) !void {
    try std.testing.expectEqual(unset_bit(u8, a, pos), ref);
}

test "bit stuff" {
    try test_get_bit(0, 0, 0);
    try test_get_bit(1, 0, 1);
    try test_get_bit(2, 0, 0);
    try test_get_bit(2, 1, 1);
    try test_get_bit(4, 1, 0);
    try test_get_bit(4, 2, 1);
    try test_set_bit(0, 0, 1);
    try test_set_bit(0, 1, 2);
    try test_set_bit(0, 2, 4);
    try test_set_bit(1, 0, 1);
    try test_set_bit(7, 1, 7);
    try test_unset_bit(4, 2, 0);
    try test_unset_bit(2, 1, 0);
    try test_unset_bit(7, 1, 5);
    try test_unset_bit(0, 0, 0);
}

test "test read" {
    const res = try read_file_to_string_array("input_data/day1.txt", std.testing.allocator);
    defer deinit_sl(res);
    const parsed = try std.fmt.parseInt(i32, res.items[0].items, 10);
    try std.testing.expectEqual(parsed, 170);
}

test "to ints" {
    var allocator = std.testing.allocator;
    const strings = try read_file_to_string_array("input_data/day1.txt", allocator);
    defer deinit_sl(strings);
    const x = try to_ints(i32, strings, 10, allocator);
    defer x.deinit();
    try std.testing.expectEqual(x.items[0], 170);
    try std.testing.expectEqual(x.items[x.items.len - 1], 7181);
}
