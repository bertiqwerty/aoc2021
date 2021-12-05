const std = @import("std");
const hlp = @import("helpers.zig");

pub const StringList = hlp.StringList;

const GammaEps = struct { gamma: u64, eps: u64 };

fn compute_gamma_eps(input: std.ArrayList(u64)) GammaEps {
    var sumlist = [_]u64{0} ** 64;
    for (input.items) |a| {
        for (sumlist) |_, idx| {
            const reverse_idx = sumlist.len - 1 - idx;
            sumlist[idx] += hlp.get_bit(u64, a, @intCast(u8, reverse_idx));
        }
    }
    var gamma: u64 = 0;
    var epsilon: u64 = 0;
    for (sumlist) |s, idx| {
        const reverse_idx = sumlist.len - 1 - idx;
        if (s > 0) {
            if (s > @intCast(i64, input.items.len) - @intCast(i64, s)) {
                gamma = hlp.set_bit(u64, gamma, @intCast(u8, reverse_idx));
            } else {
                epsilon = hlp.set_bit(u64, epsilon, @intCast(u8, reverse_idx));
            }
        }
    }
    return GammaEps{ .gamma = gamma, .eps = epsilon };
}

pub fn run(input: std.ArrayList(u64), task: hlp.Task) !u64 {
    switch (task) {
        hlp.Task.first => {
            var gamma_eps = compute_gamma_eps(input);
            return gamma_eps.gamma * gamma_eps.eps;
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
