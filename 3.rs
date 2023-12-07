// this is a port of my zig solution https://zigbin.io/523bd7

use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::prelude::*;

pub fn main() -> Result<(), ()> {
    let mut args = env::args();
    _ = args.next().ok_or(())?;
    let filepath = args.next().ok_or(())?;
    let mut file = File::open(filepath).or(Err(()))?;
    let mut input = String::new();
    file.read_to_string(&mut input).or(Err(()))?;
    let bytes = input.as_bytes();
    let linelen = input.find('\n').unwrap() + 1;

    let mut part1: usize = 0;
    let mut part2: usize = 0;
    let mut gears: HashMap<usize, (usize, usize)> = HashMap::new();
    let mut digstart: Option<usize> = None;

    for i in 0..bytes.len() {
        let isdig = bytes[i].is_ascii_digit();
        if digstart.is_none() && isdig {
            digstart = Some(i);
        } else if digstart.is_some() && !isdig {
            let dig = &input[digstart.unwrap()..i];
            digstart = None;
            let abovei = if i > linelen { i - linelen } else { i };
            let belowi = if i + linelen < input.len() {
                i + linelen
            } else {
                i
            };
            let mut mnbsym: Option<usize> = None;
            'sym: for endi in &[abovei, i, belowi] {
                for i in (endi - dig.len()).saturating_sub(1)..endi + 1 {
                    let c = bytes[i];
                    if c != b'.' && !c.is_ascii_whitespace() && !c.is_ascii_digit() {
                        mnbsym = Some(i);
                        break 'sym;
                    }
                }
            }

            if let Some(symidx) = mnbsym {
                let n = dig.parse::<usize>().unwrap();
                part1 += n;
                if bytes[symidx] == b'*' {
                    if !gears.contains_key(&symidx) {
                        gears.insert(symidx, (0, 1));
                    }
                    let e = gears.get_mut(&symidx).unwrap();
                    e.0 += 1;
                    e.1 *= n;
                }
            }
        }
    }

    for (_, e) in gears {
        if e.0 == 2 {
            part2 += e.1;
        }
    }
    println!("part1 {}\npart2 {}", part1, part2);
    Ok(())
}
