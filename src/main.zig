const std = @import("std");
const day1 = @import("day1.zig");
const hlp = @import("helpers.zig");

fn to_ints(input: hlp.ArrayListOfStr) !std.ArrayList(i32) {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var res = std.ArrayList(i32).init(&gpa.allocator);
    for (input.items) |s| {
        const parsed = try std.fmt.parseInt(i32, s.items, 10);
        try res.append(parsed);
    }
    return res;
}

pub fn main() anyerror!void {
    std.log.info("AOC 2021.", .{});
    const day1_in = try to_ints(try hlp.read_file_to_string_array("input_data/day1.txt"));
    const resd011 = day1.run(day1_in.items, hlp.Task.first);
    std.log.info("day1 1 {}", .{resd011});
    const resd012 = day1.run(day1_in.items, hlp.Task.second);
    std.log.info("day1 2 {}", .{resd012});
    
}

test "to ints" {
    const x = try to_ints(try hlp.read_file_to_string_array("input_data/day1.txt"));
    try std.testing.expectEqual(x.items[0], 170);
    try std.testing.expectEqual(x.items[x.items.len-1], 7181);
}
