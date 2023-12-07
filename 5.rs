// brute force solution
// when compiled with -O3, runs in around 1m30s on my machine
use std::env;

fn map_seed(seed_range: (isize, isize), maps: &Vec<Vec<(isize, isize, isize)>>, part: &mut isize) {
    let mut seed = seed_range.0;
    while seed < seed_range.0 + seed_range.1 {
        let mut result = seed;
        for map in maps {
            for e in map {
                let &(dest, src, len) = e;
                if src <= result && result < src + len {
                    result += dest - src;
                    break;
                }
            }
        }
        *part = isize::min(*part, result);
        seed += 1;
    }
}

pub fn main() -> Result<(), ()> {
    let mut args = env::args();
    _ = args.next().ok_or(())?;
    let filepath = args.next().ok_or(())?;
    let s = std::fs::read(filepath).or(Err(()))?;
    let input = String::from_utf8_lossy(&s);

    let mut seeds = Vec::<isize>::new();
    let mut maps = vec![Vec::<(isize, isize, isize)>::new(); 7];

    // parse seeds
    let mut inputit = input.split("\n\n");
    for s in inputit.next().ok_or(())?[7..].split(' ') {
        seeds.push(s.parse().or(Err(()))?);
    }

    // parse maps
    for map in maps.iter_mut() {
        let mapstr = inputit.next().ok_or(())?;
        let start = mapstr.find(':').ok_or(())? + 1;
        let maplines = mapstr[start + 1..].split('\n').filter(|s| !s.is_empty());
        for line in maplines {
            let mut lineit = line.split(' ');
            map.push((
                lineit.next().ok_or(())?.parse::<isize>().or(Err(()))?,
                lineit.next().ok_or(())?.parse::<isize>().or(Err(()))?,
                lineit.next().ok_or(())?.parse::<isize>().or(Err(()))?,
            ));
        }
    }

    // part 1
    let mut part1 = isize::MAX;
    for &s in &seeds {
        // start = s, length = 1
        map_seed((s, 1), &maps, &mut part1);
    }

    // part 2
    let mut part2 = isize::MAX;
    for i in (0..seeds.len()).step_by(2) {
        map_seed((seeds[i], seeds[i + 1]), &maps, &mut part2);
    }

    println!("part1 {}\npart2 {}", part1, part2);
    Ok(())
}
