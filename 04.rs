use std::env;

fn parse_wins(line: &str) -> Result<usize, ()> {
    let mut ns = Vec::<u32>::new();
    let mut wins = 0;
    let ci = line.find(':').ok_or(())?;
    let line = &line[ci + 1..];
    let mut it = line.split('|');
    let ws = it.next().ok_or(())?;
    let nums = it.next().ok_or(())?;
    let winiter = ws.split(' ').filter(|s| !s.is_empty());
    for win in winiter {
        ns.push(win.parse::<u32>().or(Err(()))?)
    }
    let numiter = nums.split(' ').filter(|s| !s.is_empty());
    for num in numiter {
        let n = num.parse::<u32>().or(Err(()))?;
        if ns.contains(&n) {
            wins += 1;
        }
    }
    return Ok(wins);
}
pub fn main() -> Result<(), ()> {
    let mut args = env::args();
    _ = args.next().ok_or(())?;
    let filepath = args.next().ok_or(())?;
    let s = std::fs::read(filepath).or(Err(()))?;
    let input = String::from_utf8_lossy(&s);
    let mut copies = vec![1; input.split('\n').count() + 1];
    let mut part1: usize = 0;
    let mut part2: usize = 0;

    for (cardid, line) in input.split('\n').filter(|s| !s.is_empty()).enumerate() {
        let wins = parse_wins(line)?;
        part1 += if wins > 0 { 1 << wins - 1 } else { wins };
        for win_offset in 1..wins + 1 {
            copies[win_offset + cardid] += copies[cardid];
        }
        part2 += copies[cardid];
    }

    println!("part1 {}\npart2 {}", part1, part2);
    Ok(())
}
