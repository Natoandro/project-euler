const std = @import("std");

pub const CollatzSequence = struct {
    pub fn length(n: usize) usize {
        if (n == 0) {
            @panic("Collatz sequence is not defined for 0");
        }
        if (n == 1) {
            return 1;
        }

        return 1 + CollatzSequence.length(CollatzSequence.next(n));
    }

    pub fn next(n: usize) usize {
        if (n % 2 == 0) {
            return n / 2;
        } else {
            return 3 * n + 1;
        }
    }
};

const CollatzSequenceLength = struct {
    cache1: std.ArrayList(usize),
    cache2: std.AutoHashMap(usize, usize),

    fn init(allocator: std.mem.Allocator, capacity: usize) !CollatzSequenceLength {
        var cache1 = try std.ArrayList(usize).initCapacity(allocator, capacity);
        try cache1.resize(capacity);
        for (0..cache1.items.len) |i| {
            cache1.items[i] = 0;
        }
        return CollatzSequenceLength{
            .cache1 = cache1,
            .cache2 = std.AutoHashMap(usize, usize).init(allocator),
        };
    }

    fn get(self: *CollatzSequenceLength, n: usize) !usize {
        if (n == 0) {
            @panic("Collatz sequence is not defined for 0");
        }
        if (n == 1) {
            return 1;
        }

        if (self.cache1.items.len <= n) {
            if (self.cache2.get(n)) |cached| {
                return cached;
            } else {
                const nextLen = try self.get(CollatzSequence.next(n));
                try self.cache2.put(n, nextLen + 1);
                return nextLen + 1;
            }
        } else {
            const cached = self.cache1.items[n];
            if (cached != 0) {
                return cached;
            }

            const nextLen = try self.get(CollatzSequence.next(n));
            self.cache1.items[n] = nextLen + 1;

            return nextLen + 1;
        }
    }
};

pub fn getLongestCollatzSequence(limit: usize) !usize {
    var maxLength: usize = 1;
    var maxIndice: usize = 1;

    const allocator = std.heap.page_allocator;
    var collatzSeqLen = try CollatzSequenceLength.init(allocator, limit + 1);

    for (2..limit) |n| {
        std.debug.print("computing collatz seq len for {d}\n", .{n});
        const length = try collatzSeqLen.get(@intCast(n));
        std.debug.print("    len={d}\n", .{length});
        if (length > maxLength) {
            maxLength = length;
            maxIndice = @intCast(n);
        }
    }

    return maxIndice;
}
