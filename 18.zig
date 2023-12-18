//! https://adventofcode.com/2023/day/18

const std = @import("std");
const Pt = @Vector(2, isize);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    var points = std.ArrayList(Pt).init(alloc);

    var parts: [2]u64 = undefined;
    for (0..2) |parti| {
        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        var cur: Pt = .{ 0, 0 };
        var border: u64 = 0;
        points.clearRetainingCapacity();
        while (lines.next()) |line| {
            const idx = std.mem.indexOfScalar(u8, line[2..], ' ').?;
            const nr = line[idx + 5 ..];
            const n = if (parti == 0)
                try std.fmt.parseInt(isize, line[2..][0..idx], 10)
            else
                try std.fmt.parseInt(isize, nr[0..5], 16);
            border += @intCast(n);
            cur += switch (if (parti == 0) line[0] else nr[5]) {
                'U', '3' => .{ 0, -n },
                'R', '0' => .{ n, 0 },
                'D', '1' => .{ 0, n },
                'L', '2' => .{ -n, 0 },
                else => unreachable,
            };
            try points.append(cur);
        }
        // find area via shoelace formula adding the border
        var sum: isize = 0;
        for (0..points.items.len - 1) |i| {
            const x1, const y1 = points.items[i];
            const x2, const y2 = points.items[i + 1];
            sum += x1 * y2 - x2 * y1; // det(pt_i, pt_i+1)
        }
        parts[parti] = @abs(sum) / 2 + border / 2 + 1;
    }

    std.debug.print("part1 {} part2 {}\n", .{ parts[0], parts[1] });
    std.debug.assert(parts[0] == 47045);
    std.debug.assert(parts[1] == 147839570293376);
}
