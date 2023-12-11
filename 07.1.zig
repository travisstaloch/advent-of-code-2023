//! https://adventofcode.com/2023/day/7

const std = @import("std");

const part_ranks = [_][13]u8{ "23456789TJQKA".*, "J23456789TQKA".* };

const Hand = struct {
    rank: struct { u8, u40 },
    bid: u32,
    fn lessThan(_: void, lhs: Hand, rhs: Hand) bool {
        const l = (@as(usize, lhs.rank[0]) << 40) | lhs.rank[1];
        const r = (@as(usize, rhs.rank[0]) << 40) | rhs.rank[1];
        return l < r;
    }
};

fn parseHand(line: []const u8, part: u8) !Hand {
    var cards = line[0..5].*;
    // convert cards to ranks
    const card_ranks = part_ranks[part - 1];
    for (0..5) |i|
        cards[i] = @intCast(std.mem.indexOfScalar(u8, &card_ranks, cards[i]).?);

    // build a counts array, list of [count,rank] entries and sort by count desc
    // for example: before sorting, the hand "33455" becomes
    //   [[0,'2'],[2,'3'],[1,'4'],[2,'5'],[0,'6']...]
    var counts = [1][2]u8{.{ 0, undefined }} ** 13;
    for (0..counts.len) |i| counts[i][1] = card_ranks[i];
    for (0..5) |i| counts[cards[i]][0] += 1;
    std.mem.sort([2]u8, &counts, {}, struct {
        fn lessThan(_: void, l: [2]u8, r: [2]u8) bool {
            return l[0] > r[0];
        }
    }.lessThan);

    if (part == 2) {
        // add count of 'J' to next highest count and overwrite 'J' entry with next
        for (0..5) |i| {
            if (counts[i][1] == 'J') {
                if (i == 0) { // 'J' comes first. add its count to second count
                    counts[1][0] += counts[0][0];
                    counts[0..2].* = counts[1..3].*;
                    break;
                } else { // 'J' not first
                    counts[0][0] += counts[i][0];
                    counts[i] = counts[i + 1];
                    break;
                }
            }
        }
    }

    const hand = std.mem.readInt(u40, &cards, .big);
    return .{
        .rank = .{ counts[0][0] * 2 + counts[1][0], hand },
        .bid = try std.fmt.parseInt(u32, line[6..], 10),
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const args = try std.process.argsAlloc(alloc);
    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();
    const input = try file.readToEndAlloc(alloc, std.math.maxInt(u32));

    var hands = std.ArrayList(Hand).init(alloc);
    var parts: [2]usize = undefined;
    for ([_]u8{ 1, 2 }) |part| {
        hands.clearRetainingCapacity();
        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        while (lines.next()) |line|
            try hands.append(try parseHand(line, part));

        std.mem.sort(Hand, hands.items, {}, Hand.lessThan);
        var sum: usize = 0;
        for (hands.items, 1..) |s, i|
            sum += i * s.bid;
        parts[part - 1] = sum;
    }
    std.debug.print("part1 {} part2 {}\n", .{ parts[0], parts[1] });
    std.debug.assert(parts[0] == 249638405);
    std.debug.assert(parts[1] == 249776650);
}
