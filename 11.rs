use std::env;

fn main() -> Result<(), ()> {
    let args = env::args();
    let filepath = args.skip(1).next().ok_or(())?;
    let s = std::fs::read(filepath).or(Err(()))?;
    let input = String::from_utf8_lossy(&s);
    let mut map = Vec::<[usize; 2]>::new();
    let extents = [
        input.bytes().position(|c| c == b'\n').ok_or(())?,
        input.bytes().fold(0, |acc, c| acc + (c == b'\n') as usize),
    ];

    for (y, line) in input.split("\n").filter(|s| !s.is_empty()).enumerate() {
        for (x, c) in line.chars().enumerate() {
            if c == '#' {
                map.push([x, y]);
            }
        }
    }

    let mut map2 = map.clone();
    let part1 = solve(&mut map, extents, 1);
    let part2 = solve(&mut map2, extents, 999_999);
    println!("part1 {part1} part2 {part2}");
    assert!(part1 == 10289334);
    assert!(part2 == 649862989626);
    Ok(())
}

fn adjust(map: &mut Vec<[usize; 2]>, extents: &mut [usize; 2], expansion: usize, idx: usize) {
    let mut coord: usize = 0;
    while coord < extents[idx] {
        if map.iter().find(|pt| pt[idx] == coord).is_none() {
            for pt in map.iter_mut() {
                if pt[idx] > coord {
                    pt[idx] += expansion;
                }
            }
            coord += expansion;
            extents[idx] += expansion;
        }
        coord += 1;
    }
}

fn solve(map: &mut Vec<[usize; 2]>, extents: [usize; 2], expansion: usize) -> usize {
    let mut extents = extents;
    adjust(map, &mut extents, expansion, 0);
    adjust(map, &mut extents, expansion, 1);

    let mut sum: usize = 0;
    for i in 1..map.len() {
        let first = map[i - 1];
        for next in &map[i..] {
            sum += ((first[0] as isize - next[0] as isize).abs()
                + (first[1] as isize - next[1] as isize).abs()) as usize;
        }
    }
    sum
}
