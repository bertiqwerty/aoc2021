const std = @import("std");
const hlp = @import("helpers.zig");

pub fn run(input: []const i32, task: hlp.Task) i32 {
    switch (task) {
        hlp.Task.first => {
            var sum: i32 = 0;
            for (input) |_, idx| {
                if (idx < input.len - 1 and input[idx + 1] > input[idx]) {
                    sum += 1;
                }
            }
            return sum;
        },
        hlp.Task.second => {
            var sum: i32 = 0;
            for (input) |_, idx| {
                if (idx > 0 and idx < input.len - 2) {
                    const cur_sum = input[idx - 1] + input[idx] + input[idx + 1];
                    const next_sum = input[idx] + input[idx + 1] + input[idx + 2];
                    if (cur_sum < next_sum) {
                        sum += 1;
                    }
                }
            }
            return sum;
        },
    }
}

test "test day1" {
    const input = [_]i32{ 199, 200, 208, 210, 200, 207, 240, 269, 260, 263 };
    const res = run(input[0..], hlp.Task.first);
    try std.testing.expectEqual(res, 7);
}
