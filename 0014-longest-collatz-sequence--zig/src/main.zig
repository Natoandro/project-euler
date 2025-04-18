const std = @import("std");
const collatz = @import("collatz");
const CollatzSequence = collatz.CollatzSequence;

pub fn main() !void {
    const maxIndice = try collatz.getLongestCollatzSequence(1_000_000);
    std.debug.print("The number with the longest Collatz sequence under 1 million is: {d}\n", .{maxIndice});
}
