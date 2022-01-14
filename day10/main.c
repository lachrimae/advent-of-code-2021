#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

char stack[128];

void push(size_t* index, char val) {
  stack[*index] = val;
  *index += 1;
  return;
}

char pop(size_t *index) {
  char res = stack[*index];
  *index -= 1;
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

int check_line_for_error(char* line) {
  size_t index = 0;
  char c;
  while(c = *line) {
    if (is_open_brace(c)) {
      push(&index, c);
    }
    else {
      char left_brace = pop(&index);
      if (!braces_match(left_brace, c)) {
        return error_value(c);
      }
    }
    line += 1;
  }
  return 0;
}

int main(int argc, char* argv[]) {
  if (argc != 2) {
    perror("bad arguments");
    exit(1);
  }

  FILE *f = fopen(argv[1], "w");

  char *buffer;
  size_t bufsize = 32;
  size_t characters;

  buffer = (char*)malloc(bufsize * sizeof(char));
  if (buffer == NULL) {
    perror("couldn't allocate buffer");
    exit(1);
  }

  int result = 0;
  while(1) {
    characters = getline(&buffer, &bufsize, f);
    if (characters == -1) {
      break;
    }
    buffer[characters] = '\0';

    result += check_line_for_error(buffer);
  }

  printf("result = %d", result);
  return 0;
}
