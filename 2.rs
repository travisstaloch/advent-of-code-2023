use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::cmp::max;
use std::simd;

pub fn main() -> Result<(), ()> {
    let mut args = env::args();
    _ = args.next().ok_or(())?;
    let filepath = args.next().ok_or(())?;
    let mut file = File::open(filepath).or(Err(()))?;
    let mut input = String::new();
    file.read_to_string(&mut input).or(Err(()))?;
 
    let lines = input
        .trim()
        .split('\n')
        .collect::<Vec<_>>();
    let rgb_limits : &[u8] = &[12, 13, 14];
    let parts: &mut[usize] = &mut[0,0];
    for line in lines {
        let powers : &mut [usize] = &mut [0, 0, 0];
        let mut lineit = line.split(':');
        let mut gameid = lineit
            .next()
            .ok_or(())?[5..]
            .parse::<usize>()
            .or(Err(()))?;
        let mut it = lineit.next().ok_or(())?
            .split(&[';', ' ', ','])
            .filter(|s| !s.is_empty());
        loop  {
            let Some(n_raw) = it.next() else { break; };
            let n = n_raw.parse::<u8>().or(Err(()))?;
            let color_raw = it.next().ok_or(())?;
            let color_int = match color_raw {
                "red" => 0,
                "green" => 1,
                "blue" => 2,
                _ => return Err(()),
            };

            gameid *= (n <= rgb_limits[color_int]) as usize;
            powers[color_int] = max(powers[color_int], n as usize);
        }
        
        parts[0] += gameid;
        parts[1] += powers[0] * powers[1] * powers[2];
    }
    println!("part1={} part2={}", parts[0], parts[1]);
    Ok(())
}