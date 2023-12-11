use std::env;

fn interpolate(lists: &mut Vec<Vec<isize>>, add: u8) {
    let mut i = lists.len() - 1;
    loop {
        let l = &lists[i];
        let o = l[if add == 0 { l.len() - 1 } else { 0 }];
        let ll = &mut lists[i - 1];
        let p = if add == 0 {
            ll[ll.len() - 1] + o
        } else {
            ll[0] - o
        };
        if add == 0 {
            ll.push(p)
        } else {
            ll.insert(0, p)
        }
        i -= 1;
        if i == 0 {
            break;
        }
    }
}

fn main() -> Result<(), ()> {
    let args = env::args();
    let filepath = args.skip(1).next().ok_or(())?;
    let s = std::fs::read(filepath).or(Err(()))?;
    let input = String::from_utf8_lossy(&s);
    let mut lists = Vec::<Vec<isize>>::new();
    let mut part1 = 0;
    let mut part2 = 0;
    for line in input.split("\n").filter(|s| !s.is_empty()) {
        lists.clear();
        lists.push(
            line.split(' ')
                .filter(|s| !s.is_empty())
                .map(|s| s.parse::<isize>().unwrap())
                .collect(),
        );
        loop {
            let ms = &lists[lists.len() - 1];
            let mut ns = Vec::<_>::new();
            let mut n = &ms[0];
            for m in &ms[1..] {
                ns.push(m - n);
                n = m;
            }
            lists.push(ns.clone());
            if ns.iter().all(|&n| n == 0) {
                interpolate(&mut lists, 0);
                part1 += lists[0][lists[0].len() - 1];
                interpolate(&mut lists, 1);
                part2 += lists[0][0];
                break;
            }
        }
    }
    println!("part1 {part1} part2 {part2}");
    Ok(())
}
