const std = @import("std");
const hlp = @import("helpers.zig");

pub const StringList = hlp.StringList;
const ArrayList = std.ArrayList;
const GammaEps = struct { gamma: LrBits(u64), eps: LrBits(u64) };

pub fn to_bits(comptime T: type, input: StringList, radix: u8, allocator: *std.mem.Allocator) !ArrayList(LrBits(T)) {
    var res = ArrayList(LrBits(T)).init(allocator);
    for (input.items) |s| {
        const parsed = try std.fmt.parseInt(T, s.items, radix);
        try res.append(LrBits(T).make(parsed, s.items.len));
    }
    return res;
}

// The first bit is the leftmost bit as in the AOC task.
pub fn LrBits(comptime T: type) type {
    return struct {
        const Self = @This();
        a: T,
        len: usize,
        pub fn at(self: Self, bit_pos: usize) u8 {
            if (bit_pos > self.len - 1) {
                std.debug.panic("bit position {} out of bounds {}", .{ bit_pos, self.len });
            }
            const idx = self.len - 1 - bit_pos;
            return @intCast(u8, hlp.get_bit(T, self.a, idx));
        }
        pub fn set(self: Self, bit_pos: usize) Self {
            if (bit_pos > self.len - 1) {
                std.debug.panic("bit position {} out of bounds {}", .{ bit_pos, self.len });
            }
            const idx = self.len - 1 - bit_pos;
            return Self{ .a = hlp.set_bit(T, self.a, idx), .len = self.len };
        }
        pub fn unset(self: Self, bit_pos: usize) Self {
            if (bit_pos > self.len - 1) {
                std.debug.panic("bit position {} out of bounds {}", .{ bit_pos, self.len });
            }
            const idx = self.len - 1 - bit_pos;
            return Self{ .a = hlp.unset_bit(T, self.a, idx), .len = self.len };
        }
        pub fn invert(self: Self) Self {
            const n_type_bits = @sizeOf(T) * 8;
            const bit_diff = @intCast(i16, n_type_bits - self.len);
            const a = std.math.shl(T, std.math.shl(T, ~self.a, bit_diff), -bit_diff);
            return Self{ .a = a, .len = self.len };
        }
        pub fn make(a: T, len: usize) Self {
            return Self{ .a = a, .len = len };
        }
        pub fn debug_warn(self: Self) void {
            var range = hlp.Range.make(self.len);
            std.debug.warn("Printing bits {} of len {}\n", .{ self.a, self.len });
            while (range.next()) |i| {
                std.debug.warn("{}", .{self.at(i)});
            }
            std.debug.warn("\n", .{});
        }
    };
}

fn compute_gamma_eps(input: std.ArrayList(LrBits(u64)), allocator: *std.mem.Allocator) !GammaEps {
    const bit_len = input.items[0].len;
    var sumlist = try ArrayList(u64).initCapacity(allocator, bit_len);
    defer sumlist.deinit();
    sumlist.appendNTimesAssumeCapacity(0, bit_len);
    for (input.items) |a| {
        for (sumlist.items) |_, idx| {
            sumlist.items[idx] += a.at(idx);
        }
    }
    var gamma = LrBits(u64).make(0, bit_len);
    var epsilon = LrBits(u64).make(0, bit_len);
    for (sumlist.items) |s, idx| {
        if (s >= @intCast(i64, input.items.len) - @intCast(i64, s)) {
            gamma = gamma.set(idx);
        } else {
            epsilon = epsilon.set(idx);
        }
    }
    return GammaEps{ .gamma = gamma, .eps = epsilon };
}

fn filter(dominant_bit: u8, input: std.ArrayList(LrBits(u64))) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    var range = hlp.Range.make(input.items[0].len);
    var filtered = input;
    while (range.next()) |i| {
        const gamma_eps = try compute_gamma_eps(filtered, allocator);
        const decisive_bits = if (dominant_bit == 1) gamma_eps.gamma else gamma_eps.eps;
        var tmp = std.ArrayList(LrBits(u64)).init(allocator);
        for (filtered.items) |item_bits| {
            const item_bit = item_bits.at(i);
            const decisive_bit = decisive_bits.at(i);
            if (item_bit == decisive_bit) {
                try tmp.append(item_bits);
            }
        }
        filtered = tmp;
        if (filtered.items.len == 1) {
            return filtered.items[0].a;
        }
    }
    return 0;
}

pub fn run(input: std.ArrayList(LrBits(u64)), task: hlp.Task) !u64 {
    const n_bits = input.items[0].len;
    switch (task) {
        hlp.Task.first => {
            var gamma_eps = try compute_gamma_eps(input, std.testing.allocator);
            return gamma_eps.gamma.a * gamma_eps.eps.a;
        },
        hlp.Task.second => {
            const oxy = try filter(1, input);
            const co2 = try filter(0, input);
            return oxy * co2;
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
    var y_int = try to_bits(u64, y, 2, allocator);

    defer y_int.deinit();

    const one = LrBits(u64).make(8, 4);
    try std.testing.expectEqual(one.invert().a, 7);

    try std.testing.expectEqual(run(y_int, hlp.Task.first), 198);
    try std.testing.expectEqual(run(y_int, hlp.Task.second), 230);
}
