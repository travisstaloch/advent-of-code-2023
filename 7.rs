// https://adventofcode.com/2023/day/7

use std::env;

#[derive(Eq, Ord, PartialEq, PartialOrd)]
struct Hand {
    rank: (u8, usize),
    bid: u32,
}

const RANKS: &[u8] = b"23456789TJQKA";
const RANKS_P2: &[u8] = b"J23456789TQKA";

fn rank(line: &str, part: u8) -> (u8, usize) {
    // convert cards to ranks
    let card_ranks = if part == 1 { RANKS } else { RANKS_P2 };
    let cards: Vec<u8> = line[0..5]
        .bytes()
        .map(|c| card_ranks.iter().position(|&cr| cr == c).unwrap() as u8)
        .collect();

    // build a counts array, list of [count,rank] entries and sort by count desc
    // for example: before sorting, the hand "33455" becomes
    //   [[0,'2'],[2,'3'],[1,'4'],[2,'5'],[0,'6']...]
    let mut counts = [[0u8, 0]; RANKS.len()];
    for i in 0..counts.len() {
        counts[i][1] = card_ranks[i];
    }
    for i in 0..5 {
        counts[cards[i] as usize][0] += 1;
    }
    counts.sort_by(|a, b| b.cmp(a));

    if part == 2 {
        // add count of 'J' to next highest count and overwrite 'J' entry with next
        for i in 0..5 {
            if counts[i][1] == b'J' {
                if i == 0 {
                    // 'J' comes first. add its count to second count
                    counts[1][0] += counts[0][0];
                    counts[0] = counts[1];
                    counts[1] = counts[2];
                    break;
                } else {
                    // 'J' not first
                    counts[0][0] += counts[i][0];
                    counts[i] = counts[i + 1];
                    break;
                }
            }
        }
    }

    let hand = usize::from_be_bytes([0, 0, 0, cards[0], cards[1], cards[2], cards[3], cards[4]]);
    (counts[0][0] * 2 + counts[1][0], hand)
}

pub fn main() -> Result<(), ()> {
    let mut args = env::args();
    _ = args.next().ok_or(())?;
    let filepath = args.next().ok_or(())?;
    let s = std::fs::read(filepath).or(Err(()))?;
    let input = String::from_utf8_lossy(&s);
    let mut hands = Vec::<Hand>::new();
    let parts = &mut [0, 0];
    for part in 1..3 {
        hands.clear();
        for line in input.split('\n').filter(|s| !s.is_empty()) {
            hands.push(Hand {
                rank: rank(line, part),
                bid: line[6..].parse().or(Err(()))?,
            });
        }
        hands.sort();
        parts[part as usize - 1] = hands
            .iter()
            .enumerate()
            .map(|(i, s)| (i + 1) * s.bid as usize)
            .sum()
    }
    println!("part1 {}\npart2 {}", parts[0], parts[1]);
    assert!(parts[0] == 249638405);
    assert!(parts[1] == 249776650);
    Ok(())
}
