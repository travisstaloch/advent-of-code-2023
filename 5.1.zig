//! https://adventofcode.com/2023/day/5

const std = @import("std");
const Pairs = std.ArrayList([2]isize);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var part1: isize = std.math.maxInt(isize);

    var lines = std.mem.tokenizeSequence(u8, input, "\n\n");
    var seeds = std.ArrayList(isize).init(alloc);

    const l = 8;
    const L = std.ArrayList([3]isize);
    var map = [1]L{L.init(alloc)} ** (l - 1);
    var linei: usize = 0;
    while (lines.next()) |line| : (linei += 1) {
        const start = (std.mem.indexOfScalar(u8, line, ':') orelse unreachable) + 1;
        if (linei == 0) {
            var ns = std.mem.tokenizeScalar(u8, line[start..], ' ');
            while (ns.next()) |n|
                try seeds.append(try std.fmt.parseInt(isize, n, 10));
            continue;
        }
        var sublines = std.mem.tokenizeScalar(u8, line[start..], '\n');
        const m = &map[linei - 1];
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
    var p2 = std.ArrayList(isize).init(alloc);
    var a = Pairs.init(alloc);
    var nr = Pairs.init(alloc);
    while (seedi < seeds.items.len) : (seedi += 2) {
        const seedstart = seeds.items[seedi];
        const seedend = seedstart + seeds.items[seedi + 1];
        var r = Pairs.init(alloc);
        try r.append(.{ seedstart, seedend });

        for (0..l - 1) |i| {
            a.clearRetainingCapacity();
            for (map[i].items) |e| {
                const dest, const src, const len = e;
                const src_end = src + len;
                nr.clearRetainingCapacity();
                while (r.popOrNull()) |se| {
                    // std.debug.print("r.items.len={}\n", .{r.items.len});
                    //     # [st                                     ed)
                    //     #          [src       src_end]
                    //     # [BEFORE ][INTER            ][AFTER        )
                    //     (st,ed) = R.pop()
                    const start, const end = se;

                    //     # (src,sz) might cut (st,ed)
                    const before: [2]isize = .{ start, @min(end, src) };
                    const inter: [2]isize = .{ @max(start, src), @min(src_end, end) };
                    const after: [2]isize = .{ @max(src_end, start), end };
                    if (before[1] > before[0])
                        try nr.append(before);
                    if (inter[1] > inter[0])
                        try a.append(.{ inter[0] - src + dest, inter[1] - src + dest });
                    if (after[1] > after[0])
                        try nr.append(after);
                }
                r.clearRetainingCapacity();
                try r.appendSlice(nr.items);
            }
            try r.appendSlice(a.items);
        }
        // std.debug.print("r={any}\n", .{r.items});
        var min: isize = std.math.maxInt(isize);
        for (r.items) |e| min = @min(min, e[0]);
        try p2.append(min);
    }

    // std.debug.print("p2={any}\n", .{p2.items});
    const part2 = std.mem.min(isize, p2.items);
    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    std.debug.assert(part1 == 111627841);
    std.debug.assert(part2 == 69323688);
}
