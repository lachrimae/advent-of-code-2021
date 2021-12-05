#include <iostream>

// This is a program written for the C preprocessor,
// which outputs a template metaprogram, which outputs
// a C++ program, which prints the answer to the challenge
// from the second day of Advent of Code 2021.

#ifdef PART1
#include "part1.h"
#else
#include "part2.h"
#endif

/*
  We want to be able to run a recursive macro.
  But the C preprocessor has rules making this difficult.
  These helper functions will assist.
  I learned this approach from Jon Jagger's NDC talk entitled
    Everything you've ever wanted to know about the
    C/C++ preprocessor but didn't know you could ask!
    https://www.youtube.com/watch?v=OAuRkAAh6Hk
  And Paul Fultz II's StackOverflow response here:
    https://stackoverflow.com/questions/12447557/can-we-have-recursive-macros
*/
#define EMPTY(...)
#define DEFER(...) __VA_ARGS__ EMPTY()
#define OBSTRUCT(...) __VA_ARGS__ DEFER(EMPTY)()

// Combining this BLOCK macro with __VA_OPT__(true),
// we can create a macro with essentially the opposite
// behaviour of __VA_OPT__. I.e., the argument "x" in
//   BLOCK(__VA_OPT__(true))(x)
// is only expressed if the variadic argument to the
// enclosing context is absent.
#define BLOCK(b_block) BLOCK_##b_block
#define BLOCK_true(x)
#define BLOCK_(x) x

// EXECUTE takes as input a long list of arguments and constructs
// from them a template metaprogram. It is more or less the "fold"
// function from functional programming, with function composition
// as the accumulation operation, and a value named "initial"
// as the initial condition.
//
// "initial" is defined in part1.h and/or part2.h.
#define EXECUTE(head, n, ...) \
  head< /* we choose the metafunction according to the first argument */ \
    n, /* and pass it the second argument to that metafunction */ \
    __VA_OPT__( /* then, under the circumstance that there are more metafunctions to call... */ \
      OBSTRUCT(EXECUTE_INDIRECT) () (__VA_ARGS__) /* we pass the remaining arguments to them */ \
    ) \
    BLOCK(__VA_OPT__(true))(initial) /* but otherwise we pass in the initial state*/\
  >::value /* and then run the entire metaprogram */
#define EXECUTE_INDIRECT() EXECUTE

// Avert your eyes... this is part of how we bully
// the preprocessor into doing recursion.
// (There are more elegant ways of doing this, but they 
// require you to teach the preprocessor basic logic
// and arithmetic.)
#define EVAL(...)  EVAL1(EVAL1(EVAL1(__VA_ARGS__)))
#define EVAL1(...) EVAL2(EVAL2(EVAL2(__VA_ARGS__)))
#define EVAL2(...) EVAL3(EVAL3(EVAL3(__VA_ARGS__)))
#define EVAL3(...) EVAL4(EVAL4(EVAL4(__VA_ARGS__)))
#define EVAL4(...) EVAL5(EVAL5(EVAL5(__VA_ARGS__)))
#define EVAL5(...) EVAL6(EVAL6(EVAL6(__VA_ARGS__)))
#define EVAL6(...) EVAL7(EVAL7(EVAL7(__VA_ARGS__)))
#define EVAL7(...) __VA_ARGS__

// Using the macro directives defined above, this header
// writes a template metaprogram to solve the challenge,
// resulting in an output struct called "terminal".
//
// This template metaprogram will look something like this:
//
//   struct Position terminal = forward< 5, down< 5, forward< 8, up< 3, down< 8, forward< 2, initial >::value >::value >::value >::value >::value >::value

#include "input.h"

int main() {
  std::cout << terminal.x * terminal.y << '\n';
  return 0;
}
