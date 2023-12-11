//! https://adventofcode.com/2023/day/4

const std = @import("std");
const A = std.BoundedArray(u32, 32);

fn parseWins(reader: anytype, ns: *A, buf: []u8) !u6 {
    ns.len = 0;
    _ = try reader.skipUntilDelimiterOrEof(':');
    const ws = (try reader.readUntilDelimiterOrEof(buf, '|')) orelse
        return error.EndOfStream;
    var winiter = std.mem.tokenizeScalar(u8, ws, ' ');
    while (winiter.next()) |win|
        try ns.append(try std.fmt.parseInt(u32, win, 10));
    const nums = (try reader.readUntilDelimiterOrEof(buf, '\n')).?;
    var numiter = std.mem.tokenizeScalar(u8, nums, ' ');
    var wins: u6 = 0;
    while (numiter.next()) |num| {
        const n = try std.fmt.parseInt(u32, num, 10);
        if (std.mem.indexOfScalar(u32, ns.constSlice(), n)) |_|
            wins += 1;
    }
    return wins;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    var br = std.io.bufferedReader(file.reader());

    var part1: usize = 0;
    var part2: usize = 0;

    // init copies for part 2
    var lines: usize = 1;
    var buf: [256]u8 = undefined;
    while (try br.reader().readUntilDelimiterOrEof(&buf, '\n')) |_| lines += 1;
    var copies = try alloc.alloc(u32, lines);
    @memset(copies, 1);

    try file.seekTo(0);
    var ns = try A.init(0);
    var cardid: usize = 0;
    while (true) : (cardid += 1) {
        const wins = parseWins(br.reader(), &ns, &buf) catch break;
        part1 += if (wins > 0)
            @as(usize, 1) << wins - 1
        else
            wins;

        for (1..wins + 1) |win_idx|
            copies[win_idx + cardid] += copies[cardid];
        part2 += copies[cardid];
    }

    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    // std.debug.assert(part1 == 21088);
    // std.debug.assert(part2 == 6874754);
}
