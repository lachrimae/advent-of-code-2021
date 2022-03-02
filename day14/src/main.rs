use std::collections::HashMap;
use std::collections::HashSet;
use std::io::BufRead;
use std::vec::Vec;

pub struct Mutation {
    left: char,
    right: char,
    summand: i64,
}

pub fn main() {
    let args: Vec<_> = std::env::args().collect();
    if args.len() != 3 {
        println!("usage: day14 <file> <iterations>");
        return;
    }
    let file_name = &args[1];
    let path = std::path::Path::new(file_name);
    let file = std::fs::File::open(&path).ok().unwrap();
    let mut lines = std::io::BufReader::new(file).lines();

    let template: Vec<char> = lines.next().unwrap().ok().unwrap().chars().collect();
    let _empty_line = lines.next().unwrap();

    let rules = {
        let mut rules: HashMap<(char, char), char> = HashMap::new();
        for rule_line in lines {
            let line = rule_line.ok().unwrap();
            let pair = line.split(" -> ").collect::<Vec<_>>();
            rules.insert(
                (
                    pair[0].chars().nth(0).unwrap(),
                    pair[0].chars().nth(1).unwrap(),
                ),
                pair[1].chars().nth(0).unwrap(),
            );
        }
        rules
    };
    let max_iterations = args[2].parse::<usize>().unwrap();

    let elements = {
        let mut elements: HashSet<&char> = HashSet::from_iter(template.iter());
        for ((left, right), production) in &rules {
            elements.insert(left);
            elements.insert(right);
            elements.insert(production);
        }
        elements
    };

    let mut buckets: HashMap<(char, char), i64> = HashMap::new();
    for pair in template.windows(2) {
        let first = pair[0];
        let second = pair[1];
        let entry = buckets.entry((first, second)).or_insert(0);
        *entry += 1;
    }

    // This vector's length is bounded by the square of the number of distinct elements.
    let mut bucket_mutations: Vec<Mutation> = Vec::with_capacity(elements.len() * elements.len());
    // We can't iterate over the hashmap and mutate it at the same time.
    // Here we use the interpreter pattern to defer the mutation until after iteration.
    for _ in 0..max_iterations {
        // Here we build an expression out of Mutation terms:
        for (left, right) in buckets.keys() {
            let pair = &(*left, *right);
            let pair_count = *buckets.get(pair).unwrap();
            if pair_count > 0 {
                let production = rules.get(pair).unwrap();
                bucket_mutations.push(Mutation {
                    left: *left,
                    right: *right,
                    summand: -pair_count,
                });
                bucket_mutations.push(Mutation {
                    left: *left,
                    right: *production,
                    summand: pair_count,
                });
                bucket_mutations.push(Mutation {
                    left: *production,
                    right: *right,
                    summand: pair_count,
                });
            }
        }
        // Here we interpret the expression:
        while let Some(mutation) = bucket_mutations.pop() {
            let entry = buckets.entry((mutation.left, mutation.right)).or_insert(0);
            *entry += mutation.summand
        }
    }

    let mut element_counts: HashMap<char, i64> = HashMap::new();
    for (left, right) in buckets.keys() {
        let pair_count = *buckets.get(&(*left, *right)).unwrap();
        *element_counts.entry(*left).or_insert(0) += pair_count;
        *element_counts.entry(*right).or_insert(0) += pair_count;
    }
    *element_counts
        .entry(*template.first().unwrap())
        .or_insert(0) += 1;
    *element_counts.entry(*template.last().unwrap()).or_insert(0) += 1;
    for element in elements {
        let entry = element_counts.entry(*element).or_insert(0);
        *entry = *entry / 2;
    }

    let least = element_counts.values().min();
    let most = element_counts.values().max();
    let difference = most.unwrap() - least.unwrap();
    println!("{:?}", difference);
}
