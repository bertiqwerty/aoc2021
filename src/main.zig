const std = @import("std");
const hlp = @import("helpers.zig");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");

pub fn main() anyerror!void {
    std.log.info("AOC 2021.", .{});
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    {
        const day1_in = try hlp.read_file_to_string_array("input_data/day1.txt", allocator);
        const day1_in_int = try hlp.to_ints(i32, day1_in, 10, allocator);
        defer {
            hlp.deinit_sl(day1_in);
            day1_in_int.deinit();
        }
        const resd011 = day1.run(day1_in_int.items, hlp.Task.first);
        std.log.info("day1 1 {}", .{resd011});
        try std.testing.expectEqual(resd011, 1477);
        const resd012 = day1.run(day1_in_int.items, hlp.Task.second);
        std.log.info("day1 2 {}", .{resd012});
        try std.testing.expectEqual(resd012, 1523);
    }
    {
        const day2_in = try hlp.read_file_to_string_array("input_data/day2.txt", allocator);
        defer hlp.deinit_sl(day2_in);
        const resd021 = day2.run(day2_in, hlp.Task.first);
        std.log.info("day2 1 {}", .{resd021});
        try std.testing.expectEqual(resd021, 1694130);
        const resd022 = day2.run(day2_in, hlp.Task.second);
        std.log.info("day2 2 {}", .{resd022});
        try std.testing.expectEqual(resd022, 1698850445);
    }
    {
        const day3_in = try hlp.read_file_to_string_array("input_data/day3.txt", allocator);
        const day3_in_bits = try day3.to_bits(u64, day3_in, 2, allocator);
        defer {
            hlp.deinit_sl(day3_in);
            day3_in_bits.deinit();
        }
        const resd031 = day3.run(day3_in_bits, hlp.Task.first);
        std.log.info("day3 1 {}", .{resd031});
        try std.testing.expectEqual(resd031, 741950);
        const resd032 = day3.run(day3_in_bits, hlp.Task.second);
        std.log.info("day3 2 {}", .{resd032});
        try std.testing.expectEqual(resd032, 903810);
    }
}

test "test main" {
    try main();
}
