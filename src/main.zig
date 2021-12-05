const std = @import("std");
const hlp = @import("helpers.zig");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");

pub fn main() anyerror!void {
    std.log.info("AOC 2021.", .{});
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    {
        const day1_in = try hlp.read_file_to_string_array("input_data/day1.txt", allocator);
        const day1_in_int = try hlp.to_ints(day1_in);
        defer {
            hlp.deinit_sl(day1_in);
            day1_in_int.deinit();
        }
        const resd011 = day1.run(day1_in_int.items, hlp.Task.first);
        std.log.info("day1 1 {}", .{resd011});
        const resd012 = day1.run(day1_in_int.items, hlp.Task.second);
        std.log.info("day1 2 {}", .{resd012});
    }
    {
        const day2_in = try hlp.read_file_to_string_array("input_data/day2.txt", allocator);
        defer hlp.deinit_sl(day2_in);
        const resd021 = day2.run(day2_in, hlp.Task.first);
        std.log.info("day2 1 {}", .{resd021});
        const resd022 = day2.run(day2_in, hlp.Task.second);
        std.log.info("day2 2 {}", .{resd022});
    }
}

test "test main" {
    try main();
}
