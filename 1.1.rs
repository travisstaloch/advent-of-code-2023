use std::env;

const STR_DIGITS: &[&[u8]] = &[b"one", b"two", b"three", b"four", b"five", b"six", b"seven", b"eight", b"nine"];

fn digit_sum(line: &[u8], p2: bool) -> Result<usize,()> {
    let mut xs = (0..line.len()).filter_map(|i| match line[i] {
        b'0'..=b'9' => Some(line[i] - b'0'),
        _ if p2 => STR_DIGITS
            .iter()
            .enumerate()
            .find_map(|(wi, w)| line[i..]
                .starts_with(w)
                .then_some((wi+1) as u8)),
        _ => None,
    });
    let a = xs.next().ok_or(())?;
    let b = xs.last().unwrap_or(a);
    return Ok((a * 10 + b) as usize);
}

pub fn main() -> Result<(), ()> {
    let mut args = env::args();
    _ = args.next().ok_or(())?;
    let input = args.next().ok_or(())?;
    let lines = input
        .trim()
        .split('\n')
        .map(str::as_bytes)
        .collect::<Vec<_>>();
    let part1: Result<usize,()> = lines
        .iter()
        .map(|line| digit_sum(line, false))
        .sum();
    let part2: Result<usize,()> = lines
        .iter()
        .map(|line| digit_sum(line, true))
        .sum();
    println!("{part1:?} {part2:?}");
    Ok(())
}