const std = @import("std");
const hlp = @import("helpers.zig");

pub const StrList = hlp.StrList;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const GammaEpsPair = struct { gamma: LrBits(u64), eps: LrBits(u64) };

pub fn to_bits(comptime T: type, input: StrList, radix: u8, allocator: *Allocator) !ArrayList(LrBits(T)) {
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

const NActivesIdxPair = struct { n_actives: usize, last_idx: usize };

fn count_actives(are_items_active: ArrayList(bool)) NActivesIdxPair {
    var n_actives: u64 = 0;
    var last_idx: u64 = 0;
    for (are_items_active.items) |is_active, idx| {
        if (is_active) {
            n_actives += 1;
            last_idx = idx;
        }
    }
    return NActivesIdxPair{ .n_actives = n_actives, .last_idx = last_idx };
}

fn compute_gamma_eps(input: ArrayList(LrBits(u64)), are_items_active: ?ArrayList(bool), allocator: *Allocator) !GammaEpsPair {
    const bit_len = input.items[0].len;
    var sumlist = try ArrayList(u64).initCapacity(allocator, bit_len);
    defer sumlist.deinit();
    sumlist.appendNTimesAssumeCapacity(0, bit_len);

    for (input.items) |a, input_idx| {
        for (sumlist.items) |_, bit_pos| {
            if (are_items_active) |aia| {
                if (aia.items[input_idx]) {
                    sumlist.items[bit_pos] += a.at(bit_pos);
                }
            } else {
                sumlist.items[bit_pos] += a.at(bit_pos);
            }
        }
    }
    const relevant_len = if (are_items_active) |aia| count_actives(aia).n_actives else input.items.len;
    var gamma = LrBits(u64).make(0, bit_len);
    var epsilon = LrBits(u64).make(0, bit_len);
    for (sumlist.items) |s, idx| {
        if (s >= @intCast(i64, relevant_len) - @intCast(i64, s)) {
            gamma = gamma.set(idx);
        } else {
            epsilon = epsilon.set(idx);
        }
    }
    return GammaEpsPair{ .gamma = gamma, .eps = epsilon };
}

const NoValidFoundError = error{
    NoValidNoValidFound,
};

const CommonBit = enum { most, least };

fn filter(common_bit: CommonBit, input: ArrayList(LrBits(u64))) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    var are_items_still_active = try ArrayList(bool).initCapacity(allocator, input.items.len);
    are_items_still_active.appendNTimesAssumeCapacity(true, input.items.len);

    var bit_range = hlp.Range.make(input.items[0].len);
    while (bit_range.next()) |bit_pos| {
        const gamma_eps = try compute_gamma_eps(input, are_items_still_active, allocator);
        const decisive_bits = if (common_bit == CommonBit.most) gamma_eps.gamma else gamma_eps.eps;

        for (input.items) |item_bits, idx| {
            if (are_items_still_active.items[idx]) {
                const item_bit = item_bits.at(bit_pos);
                const decisive_bit = decisive_bits.at(bit_pos);
                if (item_bit != decisive_bit) {
                    are_items_still_active.items[idx] = false;
                }
            }
        }
        const nactives_idx_pair = count_actives(are_items_still_active);
        if (nactives_idx_pair.n_actives == 1) {
            return input.items[nactives_idx_pair.last_idx].a;
        }
    }
    return NoValidFoundError.NoValidNoValidFound;
}

pub fn run(input: std.ArrayList(LrBits(u64)), task: hlp.Task) !u64 {
    const n_bits = input.items[0].len;
    switch (task) {
        hlp.Task.first => {
            var gamma_eps = try compute_gamma_eps(input, null, std.testing.allocator);
            return gamma_eps.gamma.a * gamma_eps.eps.a;
        },
        hlp.Task.second => {
            const oxy = try filter(CommonBit.most, input);
            const co2 = try filter(CommonBit.least, input);
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
    var y = StrList.init(allocator);
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
