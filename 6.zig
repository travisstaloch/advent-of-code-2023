//! https://adventofcode.com/2023/day/6

const std = @import("std");

fn solve(tds: []const [2]usize) usize {
    var result: usize = 1;
    for (tds) |td| {
        var sum: usize = 0;
        const time, const dist = td;
        for (1..time) |t| {
            const tleft = time - t;
            const d = tleft * t;
            if (d > dist) sum += 1;
        }
        result *= sum;
    }
    return result;
}

pub fn main() !void {
    var it = std.mem.tokenizeScalar(u8, @embedFile("6.in"), '\n');
    var timesit = std.mem.tokenizeScalar(u8, it.next().?["Time:".len..], ' ');
    var distsit = std.mem.tokenizeScalar(u8, it.next().?["Distance:".len..], ' ');
    var tds = try std.BoundedArray([2]usize, 4).init(0);
    const A = std.BoundedArray(u8, 32);
    var ns = [2]A{ try A.init(0), try A.init(0) };

    while (timesit.next()) |t| {
        const d = distsit.next().?;
        for (t) |c| try ns[0].append(c);
        for (d) |c| try ns[1].append(c);
        try tds.append(.{
            try std.fmt.parseInt(usize, t, 10),
            try std.fmt.parseInt(usize, d, 10),
        });
    }

    const part1 = solve(tds.constSlice());
    const part2 = solve(&.{.{
        try std.fmt.parseInt(usize, ns[0].constSlice(), 10),
        try std.fmt.parseInt(usize, ns[1].constSlice(), 10),
    }});
    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    std.debug.assert(part1 == 275724);
    std.debug.assert(part2 == 37286485);
}
