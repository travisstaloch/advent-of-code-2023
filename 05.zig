//! https://adventofcode.com/2023/day/5

const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var part1: isize = std.math.maxInt(isize);
    var part2: isize = std.math.maxInt(isize);

    // parse
    var maps = std.mem.tokenizeSequence(u8, input, "\n\n");
    var seeds = std.ArrayList(isize).init(alloc);
    const l = 8;
    const L = std.ArrayList([3]isize);
    var map = [1]L{L.init(alloc)} ** (l - 1);
    var mapi: usize = 0;
    while (maps.next()) |line| : (mapi += 1) {
        const start = std.mem.indexOfScalar(u8, line, ':').? + 1;
        if (mapi == 0) {
            var ns = std.mem.tokenizeScalar(u8, line[start..], ' ');
            while (ns.next()) |n|
                try seeds.append(try std.fmt.parseInt(isize, n, 10));
            continue;
        }
        var sublines = std.mem.tokenizeScalar(u8, line[start..], '\n');
        const m = &map[mapi - 1];
        while (sublines.next()) |sl| {
            var ns = std.mem.tokenizeScalar(u8, sl, ' ');
            try m.append(.{
                try std.fmt.parseInt(isize, ns.next().?, 10),
                try std.fmt.parseInt(isize, ns.next().?, 10),
                try std.fmt.parseInt(isize, ns.next().?, 10),
            });
        }
    }
    // part 1
    for (seeds.items) |seed| {
        var x = seed;
        for (0..l - 1) |i| {
            for (map[i].items) |e| {
                const sourcestart = e[1];
                const sourceend = e[1] + e[2];
                if (sourcestart <= x and x < sourceend) {
                    x += e[0] - e[1];
                    break;
                }
            }
        }
        part1 = @min(part1, x);
    }
    // part 2
    var seedi: usize = 0;
    while (seedi < seeds.items.len) : (seedi += 2) {
        var seed = seeds.items[seedi];
        while (seed < seeds.items[seedi] + seeds.items[seedi + 1]) : (seed += 1) {
            var x = seed;
            for (0..l - 1) |i| {
                for (map[i].items) |e| {
                    const sourcestart = e[1];
                    const sourceend = e[1] + e[2];
                    if (sourcestart <= x and x < sourceend) {
                        x += e[0] - e[1];
                        break;
                    }
                }
            }
            part2 = @min(part2, x);
        }
    }

    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    // std.debug.assert(part1 == 111627841);
    // std.debug.assert(part2 == 69323688);
}
