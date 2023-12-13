//! https://adventofcode.com/2023/day/13

const std = @import("std");
const usizex2 = @Vector(2, usize);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var grids = std.mem.tokenizeSequence(u8, input, "\n\n");
    var part1: usize = 0;
    var part2: usize = 0;
    while (grids.next()) |grid| {
        const w = std.mem.indexOfScalar(u8, grid, '\n').?;
        part1 += @reduce(.Add, solve(w, grid, 0) * usizex2{ 1, 100 });
        part2 += @reduce(.Add, solve(w, grid, 1) * usizex2{ 1, 100 });
    }
    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    std.debug.assert(part1 == 30158);
    std.debug.assert(part2 == 36474);
}

fn solve(w: usize, grid: []const u8, expected_diffs: u8) usizex2 {
    const stride = w + 1;
    var result = usizex2{ 0, 0 };

    // check vertical symmetry
    x: for (1..w) |x| {
        var diffs: u8 = 0;
        const width = @min(w - x, x);
        var y: usize = 0;
        while (y < grid.len) : (y += stride) {
            for (0..width) |xoffset| {
                const cl = grid[y + x - xoffset - 1];
                const cr = grid[y + x + xoffset];
                diffs += @intFromBool(cl != cr);
                if (diffs > expected_diffs) continue :x;
            }
        }
        if (diffs == expected_diffs) {
            result[0] = x;
            break;
        }
    }

    // check horizontal symmetry
    var y: usize = stride;
    y: while (y < grid.len) : (y += stride) {
        var diffs: u8 = 0;
        for (0..w) |x| {
            const height = @min(grid.len - y, y);
            var yoffset: usize = 0;
            while (yoffset < height) : (yoffset += stride) {
                const ca = grid[y - yoffset - stride + x];
                const cb = grid[y + yoffset + x];
                diffs += @intFromBool(ca != cb);
                if (diffs > expected_diffs) continue :y;
            }
        }
        if (diffs == expected_diffs) {
            result[1] = y / stride;
            break;
        }
    }

    return result;
}
