//! https://adventofcode.com/2023/day/4

const std = @import("std");
const A = std.BoundedArray(u32, 32);

fn parseWins(line: []const u8, ns: *A) !usize {
    ns.len = 0;
    var win_count: usize = 0;
    var it = std.mem.splitScalar(u8, line, ':');
    _ = it.next().?;
    const x = it.next().?;
    var it2 = std.mem.splitScalar(u8, x, '|');
    const ws = it2.next().?;
    const nums = it2.next().?;
    var winiter = std.mem.tokenizeAny(u8, ws, ", ");
    while (winiter.next()) |win|
        try ns.append(try std.fmt.parseInt(u32, win, 10));
    var numiter = std.mem.tokenizeAny(u8, nums, ", ");
    while (numiter.next()) |num| {
        const n = try std.fmt.parseInt(u32, num, 10);
        if (std.mem.indexOfScalar(u32, ns.constSlice(), n)) |_|
            win_count += 1;
    }
    return win_count;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var part1: usize = 0;
    var part2: usize = 0;

    // init copies for part 2
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var lines_count: usize = 0;
    while (lines.next()) |_| lines_count += 1;
    lines.reset();
    var copies = try std.ArrayList(u32).initCapacity(alloc, lines_count);
    copies.expandToCapacity();
    @memset(copies.items, 1);

    var ns = try A.init(0);
    var cardid: usize = 0;
    while (lines.next()) |line| : (cardid += 1) {
        const wins = try parseWins(line, &ns);
        part1 += if (wins > 0)
            @as(usize, 1) << @as(u6, @intCast(wins)) - 1
        else
            wins;

        for (0..wins) |win_idx|
            copies.items[win_idx + cardid + 1] += copies.items[cardid];
        part2 += copies.items[cardid];
    }

    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    // std.debug.assert(part1 == 21088);
    // std.debug.assert(part2 == 6874754);
}
