//! https://adventofcode.com/2023/day/16

const std = @import("std");
const Visited = std.AutoArrayHashMap(usize, std.EnumSet(Dir));
const Dir = enum { up, right, down, left };

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = std.mem.trim(
        u8,
        try file.readToEndAlloc(alloc, std.math.maxInt(u32)),
        &std.ascii.whitespace,
    );
    const w = std.mem.indexOfScalar(u8, input, '\n').?;
    const h = @divExact(input.len + 1, w) - 1;
    const stride = w + 1;
    // part 1
    var visited = Visited.init(alloc);
    var part1: usize = 0;
    try energize(&visited, input, 0, .right, stride, &part1);
    // part 2
    var part2 = part1;
    const lastrow = (h - 1) * stride;
    // skip first row going right - its the same as part 1
    try energize(&visited, input, w + lastrow - 1, .left, stride, &part2); // bottom-right
    for (0..w) |x| { // energize top and bottom rows
        try energize(&visited, input, x, .down, stride, &part2);
        try energize(&visited, input, x + lastrow, .up, stride, &part2);
    }
    try energize(&visited, input, 0, .down, stride, &part2); // top-left
    try energize(&visited, input, w + lastrow - 1, .up, stride, &part2); // bottom-right
    for (0..h) |y| { // energize left and right columns
        try energize(&visited, input, y * stride, .right, stride, &part2);
        try energize(&visited, input, y * stride + w - 1, .left, stride, &part2);
    }
    std.debug.print("part1 {} part2 {}\n", .{ part1, part2 });
    std.debug.assert(part1 == 7632);
    std.debug.assert(part2 == 8023);
}

fn energize(visited: *Visited, input: []const u8, pos: usize, dir: Dir, stride: usize, count: *usize) !void {
    visited.clearRetainingCapacity();
    try visit(visited, input, pos, dir, stride);
    count.* = @max(count.*, visited.count());
}

fn getNext(pos: usize, dir: Dir, stride: usize, input: []const u8) ?usize {
    const n = switch (dir) {
        .up => pos -% stride,
        .right => pos + 1,
        .down => pos + stride,
        .left => pos -% 1,
    };
    return if (n < input.len and input[n] != '\n') n else null;
}

fn visit(visited: *Visited, input: []const u8, pos: usize, dir: Dir, stride: usize) std.mem.Allocator.Error!void {
    const gop = try visited.getOrPut(pos);
    if (!gop.found_existing)
        gop.value_ptr.* = .{}
    else if (gop.value_ptr.contains(dir)) // done if same pos+dir
        return;
    gop.value_ptr.insert(dir);

    var next_dir: ?Dir = null;
    const c = input[pos];
    switch (c) {
        '-' => switch (dir) {
            .left, .right => {},
            .up, .down => {
                if (getNext(pos, .right, stride, input)) |next|
                    try visit(visited, input, next, .right, stride);
                next_dir = .left;
            },
        },
        '|' => switch (dir) {
            .up, .down => {},
            .left, .right => {
                if (getNext(pos, .up, stride, input)) |next|
                    try visit(visited, input, next, .up, stride);
                next_dir = .down;
            },
        },
        '/' => next_dir = switch (dir) {
            .left => .down,
            .right => .up,
            .up => .right,
            .down => .left,
        },
        '\\' => next_dir = switch (dir) {
            .left => .up,
            .right => .down,
            .up => .left,
            .down => .right,
        },
        '.' => {},
        else => unreachable,
    }

    const d = next_dir orelse dir;
    if (getNext(pos, d, stride, input)) |next|
        try visit(visited, input, next, d, stride);
}
