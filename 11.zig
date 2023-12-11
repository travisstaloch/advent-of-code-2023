//! https://adventofcode.com/2023/day/11

const std = @import("std");
const Pt = @Vector(2, isize);
const Map = std.AutoArrayHashMap(Pt, void);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var map = Map.init(alloc);
    var extents: Pt = .{ 0, 0 };
    // parse
    var y: isize = 0;
    while (lines.next()) |line| : (y += 1) {
        var x: isize = 0;
        for (line) |c| {
            if (c == '#') try map.put(.{ x, y }, {});
            x += 1;
        }
        extents[0] = x;
    }
    extents[1] = y;

    var map2 = try map.clone();
    var extents2 = extents;
    const part1 = try solve(&map, &extents, 1);
    const part2 = try solve(&map2, &extents2, 999_999);
    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    std.debug.assert(part1 == 10289334);
    std.debug.assert(part2 == 649862989626);
}

fn solve(map: *Map, extents: *Pt, comptime expansion: comptime_int) !usize {
    { // vertical expansion
        var y: isize = 0;
        while (y < extents[1]) : (y += 1) {
            const any = blk: {
                var x: isize = 0;
                while (x < extents[0]) : (x += 1) {
                    if (map.contains(.{ x, y })) break :blk true;
                }
                break :blk false;
            };
            if (!any) {
                for (map.keys()) |*pt| {
                    if (pt[1] > y) pt[1] += expansion;
                }
                y += expansion;
                extents[1] += expansion;
                try map.reIndex();
            }
        }
    }
    { // horizontal expansion
        var x: isize = 0;
        while (x < extents[0]) : (x += 1) {
            const any = for (map.keys()) |k| {
                if (k[0] == x) break true;
            } else false;
            if (!any) {
                for (0..map.keys().len) |i| {
                    const pt = &map.keys()[i];
                    if (pt[0] > x) pt[0] += expansion;
                }
                x += expansion;
                extents[0] += expansion;
                try map.reIndex();
            }
        }
    }
    var sum: usize = 0;
    for (1..map.count()) |i| {
        const first = map.keys()[i - 1];
        for (map.keys()[i..]) |next|
            sum += @reduce(.Add, @abs(first - next));
    }
    return sum;
}

fn drawMap(map: Map, extents: Pt) void {
    // std.debug.print("extents={any}\n", .{extents});
    var y: isize = 0;
    while (y < extents[1]) : (y += 1) {
        var x: isize = 0;
        while (x < extents[0]) : (x += 1) {
            if (map.contains(.{ x, y })) {
                std.debug.print("#", .{});
            } else std.debug.print(".", .{});
        }
        std.debug.print("\n", .{});
    }
}
