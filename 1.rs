use std::env;
use std::fs::File;
use std::io::prelude::*;

pub fn main2() -> std::io::Result<()> {

    let path = env::args().skip(1).next().unwrap();
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    let mut sum: u32 = 0;
    const DIGIT_NAMES: &'static [&'static str] = &["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];
    for line in contents.split('\n') {
        if line.len() == 0 { continue; }
        let mut first_digit = None;
        'outer: for i in 0..line.len() {
            let c = line.chars().nth(i).unwrap();
            if c.is_ascii_digit() { first_digit = Some(c); break ;}
            for (j, dn) in DIGIT_NAMES.iter().enumerate() {
                // eprintln!("{j} {dn}");
                if line[i..].starts_with(dn) { 
                    first_digit = char::from_u32((j + 49) as u32); break 'outer;
                }
            }
        }
        let mut last_digit = None;
        'outer: for i in (0..line.len()).rev() {
            let c = line.chars().nth(i).unwrap();
            if c.is_ascii_digit() { last_digit = Some(c); break ;}
            for (j, dn) in DIGIT_NAMES.iter().enumerate() {    
                if line[i..].starts_with(dn) { 
                    last_digit = char::from_u32((j + 49) as u32); break 'outer; 
                }
            }
        }
        // eprintln!("{line} {first_digit:?} {last_digit:?}");
        sum += first_digit.unwrap().to_digit(10).unwrap() * 10 + last_digit.unwrap().to_digit(10).unwrap();
    }
    println!("sum {sum}");
    Ok(())
}

const STR_DIGITS: &[&[u8]] = &[b"one", b"two", b"three", b"four", b"five", b"six", b"seven", b"eight", b"nine"];

fn digit_sum(line: &[u8], p2: bool) -> usize {
    let mut digits = (0..line.len()).filter_map(|i| match line[i] {
        b'0'..=b'9' => Some((line[i] - b'0') as usize),
        _ if(p2) => STR_DIGITS.iter()
        .enumerate()
        .find_map(|(di, d)| line[i..].starts_with(d).then_some(di+1)),
        _ => None,
    });

    let a = digits.next().unwrap();
    let b = digits.last().unwrap_or(a);
    return a*10 + b;
}

fn main() -> std::io::Result<()> {
    let path = env::args().skip(1).next().unwrap();
    let mut file = File::open(path)?;
    let mut input = String::new();
    file.read_to_string(&mut input)?;
    let lines = input.trim().split('\n').map(str::as_bytes).collect::<Vec<_>>();
    let p1: usize = lines.iter().map(|line| digit_sum(line, false)).sum();
    let p2: usize = lines.iter().map(|line| digit_sum(line, true)).sum();
    eprintln!("{p1} {p2}");
    Ok(())
}