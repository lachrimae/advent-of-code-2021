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

int check_line_for_error(char* line, ssize_t line_len, size_t *final_stack_index) {
  size_t index = 0;
  // the final character on the line will be '\n', so we
  // subtract one from line_len because we don't care about it
  for (int line_cursor = 0; line_cursor < line_len - 1; line_cursor += 1) {
    char c = line[line_cursor];
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
  *final_stack_index = index;
  return 0;
}

long long int score_autocomplete(size_t stack_index) {
  char left_brace;
  long long int score = 0;
  while ((left_brace = pop(&stack_index)) != -1) {
    score *= 5;
    switch (left_brace) {
      case '(':
        score += 1;
	break;
      case '[':
        score += 2;
	break;
      case '{':
	score += 3;
	break;
      case '<':
	score += 4;
	break;
      default:
	break;
    }
  }
  return score;
}

// more or less copy-pasted from http://www.cplusplus.com/reference/cstdlib/qsort/
int cmp(const void* a, const void* b) {
  if ( *(long long int*)a <  *(long long int*) b) return -1;
  if ( *(long long int*)a == *(long long int*) b) return 0;
  if ( *(long long int*)a >  *(long long int*) b) return 1;
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
  long long int result2 = 0;
  size_t num_result2s = 0;
  long long int result2s[90];
  // getline implicitly calls malloc when line = NULL.
  // This could be made faster by preallocating
  // one buffer that is sufficiently large to load every
  // line into it.
  while ((nread = getline(&line, &len, stream)) != -1) {
    size_t stack_index;
    int new_res = check_line_for_error(line, nread, &stack_index);

    if (new_res == 0) {
      result2s[num_result2s] = score_autocomplete(stack_index);
      num_result2s += 1;
    } else {
      result1 += new_res;
    }

    free(line);
    line = NULL;
  }
  fclose(stream);

  qsort(result2s, num_result2s, sizeof(long long int), cmp);
  size_t median_index = num_result2s / 2;
  result2 = result2s[median_index];

  printf("result1 = %d\n", result1);
  printf("result2 = %lld\n", result2);
  exit(0);
}
