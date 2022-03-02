use std::collections::HashMap;
use std::vec::Vec;

// Initially I tried this stack-based solution.
// It was way too slow for the second part.
// However, it did run in linear space, which is cool.

#[derive(Debug)]
struct Frame {
    element: char,
    from_iteration: usize,
}

fn rule(left: &char, right: &char) -> Option<char> {
    match (*left, *right) {
        ('C', 'H') => Some('B'),
        ('H', 'H') => Some('N'),
        ('C', 'B') => Some('H'),
        ('N', 'H') => Some('C'),
        ('H', 'B') => Some('C'),
        ('H', 'C') => Some('B'),
        ('H', 'N') => Some('C'),
        ('N', 'N') => Some('C'),
        ('B', 'H') => Some('H'),
        ('N', 'C') => Some('B'),
        ('N', 'B') => Some('B'),
        ('B', 'N') => Some('B'),
        ('B', 'B') => Some('N'),
        ('B', 'C') => Some('B'),
        ('C', 'C') => Some('N'),
        ('C', 'N') => Some('C'),
        _ => None,
    }
}

pub fn main(max_iterations: usize) {
    // hardcode the example into this program; no parsing routine
    let template = vec!['N', 'N', 'C', 'B'];
    let mut element_counts = HashMap::<char, u64>::new();

    let mut stack: Vec<Frame> = Vec::with_capacity(10);
    let mut leftmost_element = template[0];
    let mut leftmost_element_iteration: usize = 0;
    let mut template_index: usize = 2;
    let mut current_frame = Frame {
        element: template[1],
        from_iteration: 0,
    };

    *element_counts.entry(template[0]).or_insert(0) += 1;
    *element_counts.entry(template[1]).or_insert(0) += 1;

    loop {
        let max_depth_condition = leftmost_element_iteration < max_iterations
            && current_frame.from_iteration < max_iterations;
        if max_depth_condition {
            // expand leftmost_element and current_frame.element to produce middle_element,
            // push current_frame onto the stack and create a new frame
            let middle_element = rule(&leftmost_element, &current_frame.element).unwrap();
            let new_frame_iteration =
                std::cmp::max(leftmost_element_iteration, current_frame.from_iteration) + 1;
            *element_counts.entry(middle_element).or_insert(0) += 1;
            stack.push(current_frame);
            current_frame = Frame {
                element: middle_element,
                from_iteration: new_frame_iteration,
            };
        } else {
            // reached the maximum iteration depth.
            // try to pop off the stack or the template and continue
            leftmost_element = current_frame.element;
            leftmost_element_iteration = current_frame.from_iteration;
            let next_frame = stack.pop().or_else(|| {
                template.get(template_index).map(|element| {
                    template_index += 1;
                    *element_counts.entry(*element).or_insert(0) += 1;
                    Frame {
                        element: *element,
                        from_iteration: 0,
                    }
                })
            });
            match next_frame {
                None => {
                    break;
                }
                Some(frame) => {
                    current_frame = frame;
                }
            }
        }
    }
    println!("{:?}", element_counts);
}
