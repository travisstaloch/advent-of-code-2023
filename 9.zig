//! https://adventofcode.com/2023/day/9

const std = @import("std");
const L = std.ArrayListUnmanaged(isize);
const LL = std.ArrayList(L);

fn interpolate(lists: LL, alloc: std.mem.Allocator, add: bool) !void {
    var i = lists.items.len - 1;
    while (true) {
        const l = lists.items[i];
        const o = l.items[if (add) l.items.len - 1 else 0];
        const ll = &lists.items[i - 1];
        const p = if (add)
            ll.items[ll.items.len - 1] + o
        else
            ll.items[0] - o;
        try if (add) ll.append(alloc, p) else ll.insert(alloc, 0, p);
        i -= 1;
        if (i == 0) break;
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var part1: isize = 0;
    var part2: isize = 0;

    while (lines.next()) |line| {
        var lists = LL.init(alloc);
        const l0 = try lists.addOne();
        l0.* = .{};
        var nsiter = std.mem.tokenizeScalar(u8, line, ' ');
        while (nsiter.next()) |n|
            try l0.append(alloc, try std.fmt.parseInt(isize, n, 10));
        outer: while (true) {
            const ns = try lists.addOne();
            ns.* = .{};
            const ms = &lists.items[lists.items.len - 2];
            var lastn = ms.items[0];
            for (ms.items[1..]) |n| {
                try ns.append(alloc, n - lastn);
                lastn = n;
            }
            if (std.mem.allEqual(isize, ns.items, 0)) {
                try interpolate(lists, alloc, true);
                part1 += lists.items[0].items[lists.items[0].items.len - 1];
                try interpolate(lists, alloc, false);
                part2 += lists.items[0].items[0];
                break :outer;
            }
        }
    }

    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    std.debug.assert(part1 == 1972648895);
    std.debug.assert(part2 == 919);
}
