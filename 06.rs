// https://adventofcode.com/2023/day/6
use std::env;

fn solve(tds: &[(usize, usize)]) -> usize {
    let mut result: usize = 1;
    for td in tds {
        let mut sum: usize = 0;
        let &(time, dist) = td;
        for t in 1..time {
            let tleft = time - t;
            let d = tleft * t;
            if d > dist {
                sum += 1;
            }
        }
        result *= sum;
    }
    return result;
}

pub fn main() -> Result<(), ()> {
    let mut args = env::args();
    _ = args.next().ok_or(())?;
    let filepath = args.next().ok_or(())?;
    let s = std::fs::read(filepath).or(Err(()))?;
    let input = String::from_utf8_lossy(&s);
    let mut it = input.split('\n');
    let timesit = it.next().ok_or(())?[5..]
        .split(' ')
        .filter(|s| !s.is_empty());
    let distsit = it.next().ok_or(())?[9..]
        .split(' ')
        .filter(|s| !s.is_empty());
    let mut tds = Vec::<(usize, usize)>::new();
    let mut ns = (String::new(), String::new());
    for (t, d) in timesit.zip(distsit) {
        ns.0.push_str(t);
        ns.1.push_str(d);
        tds.push((t.parse().or(Err(()))?, d.parse().or(Err(()))?));
    }
    let part1 = solve(&tds);
    let part2 = solve(&[(ns.0.parse().or(Err(()))?, ns.1.parse().or(Err(()))?)]);
    println!("part1 {}\npart2 {}", part1, part2);
    // assert!(part1 == 275724);
    // assert!(part2 == 37286485);
    Ok(())
}
