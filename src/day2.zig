const std = @import("std");
const hlp = @import("helpers.zig");

pub const StringList = hlp.StrList;

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

pub fn run(input: StringList, task: hlp.Task) !i32 {
    switch (task) {
        hlp.Task.first => {
            var h_pos: i32 = 0;
            var d_pos: i32 = 0;
            for (input.items) |s| {
                const cmd = (try parse(s.items)).?;
                switch (cmd.dir) {
                    Dir.forward => h_pos += cmd.amount,
                    Dir.down => d_pos += cmd.amount,
                }
            }
            return d_pos * h_pos;
        },
        hlp.Task.second => {
            var h_pos: i32 = 0;
            var d_pos: i32 = 0;
            var aim: i32 = 0;
            for (input.items) |s| {
                const cmd = (try parse(s.items)).?;
                switch (cmd.dir) {
                    Dir.forward => {
                        h_pos += cmd.amount;
                        d_pos += cmd.amount * aim;
                    },
                    Dir.down => aim += cmd.amount,
                }
            }
            return d_pos * h_pos;
        },
    }
}

fn test_assert(s: []const u8, ref_amount: i32, ref_dir: Dir) !void {
    const parsed = (try parse(s)).?;
    try std.testing.expectEqual(parsed.amount, ref_amount);
    try std.testing.expectEqual(parsed.dir, ref_dir);
}

test "test day2" {
    try test_assert("forward 5"[0..], 5, Dir.forward);
    try test_assert("up 1"[0..], -1, Dir.down);
    try test_assert("down -25"[0..], -25, Dir.down);
    try test_assert("down 0"[0..], 0, Dir.down);
    try test_assert("down 1"[0..], 1, Dir.down);
}
