const std = @import("std");
const hlp = @import("helpers.zig");

pub const StringList = hlp.StringList;

const Dir = enum { forward, down };

const Cmd = struct { dir: Dir, amount: i32 };

const ParseError = error{UnknownLetter};

fn parse(s: []const u8) !?Cmd {
    var splitted = std.mem.split(s, " ");
    const dir_char = splitted.next().?[0];
    const amount = try std.fmt.parseInt(i32, splitted.next().?, 10);
    switch (dir_char) {
        'f' => return Cmd{ .dir = Dir.forward, .amount = amount },
        'd' => return Cmd{ .dir = Dir.down, .amount = amount },
        'u' => return Cmd{ .dir = Dir.down, .amount = -amount },
        else => return ParseError.UnknownLetter,
    }
}

pub fn run(input: std.ArrayList(u64), task: hlp.Task) !u64 {
    switch (task) {
        hlp.Task.first => {
            var sumlist = [_]u64{0} ** 64;
            for (input.items) |a| {
                for (sumlist) |_, idx| {
                    const reverse_idx = sumlist.len - 1 - idx;
                    sumlist[idx] += hlp.get_bit(u64, a, @intCast(i16, reverse_idx));
                }
            }
            var gamma: u64 = 0;
            var epsilon: u64 = 0;
            for (sumlist) |s, idx| {
                const reverse_idx = sumlist.len - 1 - idx;
                if (s > 0) {
                    if (s > @intCast(i64, input.items.len) - @intCast(i64, s)) {
                        gamma = hlp.set_bit(u64, gamma, @intCast(i16, reverse_idx));
                    } else {
                        epsilon = hlp.set_bit(u64, epsilon, @intCast(i16, reverse_idx));
                    }
                }
            }
            return  gamma * epsilon;
        },
        hlp.Task.second => {
            return 0;
        },
    }
}


test "test day3" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    const s = "00100,11110,10110,10111,10101,01111,00111,11100,10000,11001,00010,01010";
    var splitted = std.mem.split(s, ",");
    var y = StringList.init(allocator);
    defer hlp.deinit_sl(y);
    while (splitted.next()) |bin_str| {
        var tmp = std.ArrayList(u8).init(allocator);
        try tmp.appendSlice(bin_str[0..]);
        try y.append(tmp);
    }
    var y_int = try hlp.to_ints(u64, y, 2, allocator);
    defer y_int.deinit();

    try std.testing.expectEqual(run(y_int, hlp.Task.first), 198);
}
