//! https://adventofcode.com/2023/day/2

const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    const Color = enum { red, green, blue };
    var part1: usize = 0;
    var part2: usize = 0;
    const rgb_counts = [3]u8{ 12, 13, 14 };
    while (lines.next()) |line| {
        var it1 = std.mem.splitScalar(u8, line, ':');
        var rgb_maxs = [3]usize{ 0, 0, 0 };
        var is_possible = true;

        const game_raw = it1.next() orelse return error.ParseFailure;
        const gameid = try std.fmt.parseInt(u8, game_raw[5..], 10);
        const subsets_raw = it1.next() orelse return error.ParseFailure;
        var it2 = std.mem.tokenizeAny(u8, subsets_raw, "; ,");
        while (true) {
            const n_raw = it2.next() orelse break;
            const n = try std.fmt.parseInt(usize, n_raw, 10);
            const color_raw = it2.next() orelse return error.ParseFailure;
            const color = std.meta.stringToEnum(Color, color_raw) orelse
                return error.ParseFailure;

            const color_int = @intFromEnum(color);
            if (is_possible and n > rgb_counts[color_int])
                is_possible = false;

            rgb_maxs[color_int] = @max(rgb_maxs[color_int], n);
        }

        if (is_possible) part1 += gameid;
        // std.debug.print("gameid={} is_possible={}\n", .{ gameid, is_possible });

        const power = @reduce(.Mul, @as(@Vector(3, usize), rgb_maxs));
        part2 += power;
    }
    std.debug.print("part1={} part2={}\n", .{ part1, part2 });
}
