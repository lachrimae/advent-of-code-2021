#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#define MAX_STACK_SIZE 128

// one global stack region which can be reused over and over again
char stack[MAX_STACK_SIZE];

void push(size_t* index, char val) {
  if (*index >= MAX_STACK_SIZE) {
    perror("ran out of stack space");
    exit(1);
  }
  stack[*index] = val;
  *index += 1;
  return;
}

char pop(size_t *index) {
  if (*index < 1) {
    return -1;
  }
  *index -= 1;
  char res = stack[*index];
  return res;
}

int is_open_brace(char val) {
  return 
    val == '('
      || val == '['
      || val == '{'
      || val == '<';
}

int braces_match(char left_brace, char right_brace) {
  switch(left_brace) {
    case '(':
      return right_brace == ')';
    case '[':
      return right_brace == ']';
    case '{':
      return right_brace == '}';
    case '<':
      return right_brace == '>';
    default:
      return 0;
  }
}

int error_value(char brace) {
  switch(brace) {
    case ')':
      return 3;
    case ']':
      return 57;
    case '}':
      return 1197;
    case '>':
      return 25137;
    default:
      return 0;
  }
}

int check_line_for_error(char* cursor, ssize_t line_len) {
  size_t index = 0;
  // the final character on the cursor will be '\n', so we
  // subtract one from line_len because we don't care about it
  for (int i = 0; i < line_len - 1; i += 1) {
    char c = cursor[i];
    if (is_open_brace(c)) {
      push(&index, c);
    }
    else {
      char left_brace = pop(&index);
      if (!braces_match(left_brace, c)) {
        return error_value(c);
      }
    }
  }
  return 0;
}

int main(int argc, char* argv[]) {
  if (argc != 2) {
    perror("bad arguments");
    exit(1);
  }

  char *line = NULL;
  size_t len = 0;
  ssize_t nread;

  FILE *stream = fopen(argv[1], "r");
  if (stream == NULL) {
    perror("fopen");
    exit(1);
  }

  int result1 = 0;
  // getline implicitly calls malloc when line = NULL.
  // This could be made faster by preallocating
  // one buffer that is sufficiently large to load every
  // line into it.
  while ((nread = getline(&line, &len, stream)) != -1) {
    int new_res = check_line_for_error(line, nread);
    result1 += new_res;

    free(line);
    line = NULL;
  }
  fclose(stream);

  printf("result1 = %d\n", result1);
  exit(0);
}
