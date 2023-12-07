//! https://adventofcode.com/2023/day/7

const std = @import("std");

const Class = enum { hicard, pair, twopair, threekind, fullhouse, fourkind, fivekind };
const ranks = "23456789TJQKA".*;
const ranks_p2 = "J23456789TQKA".*;

const Hand = struct {
    rank: Rank,
    bid: u32,
    pub const Rank = struct { class: Class, hand: u40 };
    fn lessThan(_: void, lhs: Hand, rhs: Hand) bool {
        const l = (@as(usize, @intFromEnum(lhs.rank.class)) << 40) | lhs.rank.hand;
        const r = (@as(usize, @intFromEnum(rhs.rank.class)) << 40) | rhs.rank.hand;
        return l < r;
    }
};

fn int16(x: [2]u8) u16 {
    return @bitCast(x);
}

fn handRank(line: []const u8, part: u8) Hand.Rank {
    var cards = line[0..5].*;
    // convert cards to ranks
    const card_ranks = if (part == 1) ranks else ranks_p2;
    for (0..5) |i|
        cards[i] = @intCast(std.mem.indexOfScalar(u8, &card_ranks, cards[i]).?);
    // build a counts array, list of [count,rank] entries and sort by count desc
    // for example: before sorting, the hand "33455" becomes
    //   [[0,'2'],[2,'3'],[1,'4'],[2,'5'],[0,'6']...]
    var counts = [1][2]u8{.{ 0, undefined }} ** ranks.len;
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
    return switch (int16(.{ counts[0][0], counts[1][0] })) {
        int16(.{ 5, 0 }) => .{ .class = .fivekind, .hand = hand },
        int16(.{ 4, 1 }) => .{ .class = .fourkind, .hand = hand },
        int16(.{ 3, 2 }) => .{ .class = .fullhouse, .hand = hand },
        int16(.{ 3, 1 }) => .{ .class = .threekind, .hand = hand },
        int16(.{ 2, 2 }) => .{ .class = .twopair, .hand = hand },
        int16(.{ 2, 1 }) => .{ .class = .pair, .hand = hand },
        int16(.{ 1, 1 }) => .{ .class = .hicard, .hand = hand },
        else => unreachable,
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
        while (lines.next()) |line| {
            try hands.append(.{
                .rank = handRank(line, part),
                .bid = try std.fmt.parseInt(u32, line[6..], 10),
            });
        }

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
