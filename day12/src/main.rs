use std::io::BufRead;
use std::string::String;
use std::vec::Vec;

struct UnorderedPair<T> {
    lesser: T,
    greater: T,
}

impl<T: std::cmp::Ord + Clone> UnorderedPair<T> {
    pub fn new(first: &T, second: &T) -> Self {
        if first < second {
            UnorderedPair {
                lesser: first.clone(),
                greater: second.clone(),
            }
        } else {
            UnorderedPair {
                lesser: second.clone(),
                greater: first.clone(),
            }
        }
    }

    fn contains(&self, val: &T) -> bool {
        self.lesser == *val || self.greater == *val
    }

    fn lesser(&self) -> &T {
        &self.lesser
    }

    fn greater(&self) -> &T {
        &self.greater
    }

    fn other_one(&self, val: T) -> std::option::Option<&T> {
        if val == self.lesser {
            Some(&self.greater)
        } else if val == self.greater {
            Some(&self.lesser)
        } else {
            None
        }
    }
}

struct Frame {
    node_index: usize,
    // the max_node_followed records the maximum
    // index that has been followed so far.
    max_node_followed: usize,
}

fn is_large_node(node: &String) -> bool {
    for c in node.chars() {
        if !c.is_uppercase() {
            return false;
        }
    }
    return true;
}

fn small_node_was_not_visited(exploration_stack: &Vec<Frame>, node_index: usize) -> bool {
    for frame in exploration_stack {
        if frame.node_index == node_index {
            return false;
        }
    }
    return true;
}

fn main() {
    let args = std::env::args();
    if args.len() != 2 {
        println!("usage: day12 <file>");
        return;
    }

    // represent the graph as a list of edges
    let edge_list: Vec<UnorderedPair<String>> = {
        let mut edge_list: Vec<UnorderedPair<String>> = vec![];
        let file_name = args.last().unwrap();
        let path = std::path::Path::new(&file_name);
        let display = path.display();
        let lines = match std::fs::File::open(&path) {
            Err(why) => panic!("Couldn't open {}: {}", display, why),
            Ok(file) => std::io::BufReader::new(file).lines(),
        };
        for line in lines {
            let line = line.unwrap();
            let pair: Vec<String> = line.split("-").map(String::from).collect();
            edge_list.push(UnorderedPair::new(&pair[0], &pair[1]));
        }
        edge_list
    };

    // extract a vector of all the nodes. each node will be
    // uniquely identified by its index in this vector.
    let nodes: Vec<String> = {
        let mut nodes: Vec<String> = vec![];
        for edge in edge_list.iter() {
            let lesser = String::from(edge.lesser());
            if !nodes.contains(&lesser) {
                nodes.push(lesser);
            }
            let greater = String::from(edge.greater());
            if !nodes.contains(&greater) {
                nodes.push(greater);
            }
        }
        nodes
    };

    // rearticulate the graph as a 2-dimensional vector of booleans
    let adjacency_matrix: Vec<Vec<bool>> = {
        let mut adjacency_matrix: Vec<Vec<bool>> = vec![vec![false; nodes.len()]; nodes.len()];
        for node in nodes.iter() {
            for edge in edge_list.iter() {
                if edge.contains(node) {
                    let n1_index = nodes.iter().position(|x| x == node).unwrap();
                    let n2 = edge.other_one(node.to_string()).unwrap();
                    let n2_index = nodes.iter().position(|x| x == n2).unwrap();
                    adjacency_matrix[n1_index][n2_index] = true;
                    adjacency_matrix[n2_index][n1_index] = true;
                }
            }
        }
        adjacency_matrix
    };

    let start_index = nodes.iter().position(|x| x == &"start").unwrap();
    let end_index = nodes.iter().position(|x| x == &"end").unwrap();

    // PART 1
    {
        let mut paths_to_end: u32 = 0;
        let mut exploration_stack: Vec<Frame> = vec![];
        let mut current_frame = Frame {
            node_index: start_index,
            max_node_followed: 0,
        };
        let mut dead_end;

        loop {
            dead_end = true;
            for (node_index, is_adjacent) in adjacency_matrix[current_frame.node_index]
                .iter()
                .enumerate()
                .collect::<Vec<(usize, &bool)>>()[current_frame.max_node_followed..]
                .iter()
            {
                if !(*is_adjacent) {
                    continue;
                } else if *node_index == start_index {
                    continue;
                } else if *node_index == end_index {
                    paths_to_end += 1;
                    continue;
                } else if is_large_node(&nodes[*node_index])
                    || small_node_was_not_visited(&exploration_stack, *node_index)
                {
                    dead_end = false;
                    current_frame.max_node_followed = *node_index;
                    exploration_stack.push(current_frame);
                    current_frame = Frame {
                        node_index: *node_index,
                        max_node_followed: 0,
                    };
                    break;
                }
            }
            if dead_end {
                if exploration_stack.len() == 0 {
                    break;
                }
                current_frame = exploration_stack.pop().unwrap();
                current_frame.max_node_followed += 1;
            }
        }
        println!("{}", paths_to_end);
    }

    // PART 2
    {
        let mut paths_to_end: u32 = 0;
        let mut exploration_stack: Vec<Frame> = vec![];
        let mut current_frame = Frame {
            node_index: start_index,
            max_node_followed: 0,
        };
        let mut dead_end;
        // the solution to part2 is very similar to the solution to part1,
        // but we track whether we have visited any small caves twice using
        // these two variables:
        let mut selected_special_small_cave_at_height: Option<usize> = None;
        let mut stack_height: usize = 0;
        loop {
            dead_end = true;
            for (node_index, is_adjacent) in adjacency_matrix[current_frame.node_index]
                .iter()
                .enumerate()
                .collect::<Vec<(usize, &bool)>>()[current_frame.max_node_followed..]
                .iter()
            {
                if !(*is_adjacent) {
                    continue;
                } else if *node_index == start_index {
                    continue;
                } else if *node_index == end_index {
                    paths_to_end += 1;
                    continue;
                } else {
                    let old_condition = is_large_node(&nodes[*node_index])
                        || small_node_was_not_visited(&exploration_stack, *node_index);
                    let new_condition = !old_condition && {
                        // !old_condition implies that the node is small, and that we have
                        // visited it before
                        match selected_special_small_cave_at_height {
                            // if we haven't selected a special node to go through twice yet,
                            // we can do so here to bypass the fact we have visited the small
                            // node already
                            None => {
                                selected_special_small_cave_at_height = Some(stack_height);
                                true
                            }
                            Some(_) => false,
                        }
                    };
                    if old_condition || new_condition {
                        dead_end = false;
                        current_frame.max_node_followed = *node_index;
                        exploration_stack.push(current_frame);
                        stack_height += 1;
                        current_frame = Frame {
                            node_index: *node_index,
                            max_node_followed: 0,
                        };
                        break;
                    }
                }
            }
            if dead_end {
                if stack_height == 0 {
                    break;
                }
                current_frame = exploration_stack.pop().unwrap();
                current_frame.max_node_followed += 1;
                stack_height -= 1;
                if selected_special_small_cave_at_height
                    .map_or(false, |height| height == stack_height)
                {
                    // we are backtracking through a position at which we selected a small
                    // cave to go through twice, so we can clear our selection
                    selected_special_small_cave_at_height = None;
                }
            }
        }
        println!("{}", paths_to_end);
    }
}
