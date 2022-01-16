#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "octopus.hpp"
#include "queue.hpp"
#define INPUT_BUF_LEN 1024
#define MAX_OCT_ARRAY_DIM 20

int main(int argc, char **argv) {
  if (argc != 2) {
    std::cout << "Usage: main <input>\n";
    return 1;
  }
  char *input_path = argv[1];

  std::ifstream input_file;
  input_file.open(input_path);
  if (input_file.fail()) {
    std::cout << "Could not open the file\n";
    return 1;
  }


  // this procedure skips calling the Octopus constructor,
  // which requires information we don't have yet.
  // we might be overallocating here,
  // but it's not a big deal
  // TODO: somehow this allocation is causing segfaults
  size_t array_len = MAX_OCT_ARRAY_DIM * sizeof(Octopus);
  Octopus** oct_array = (Octopus**)std::vector<char>(array_len * array_len).data();

  std::string line;
  size_t height = 0;
  size_t width;
  while (!input_file.eof()) {
    getline(input_file, line);
    width = line.length();
    for (int i = 0; i < width; i++) {
      int energy = std::stoi(std::string(&line[i], 1));
      oct_array[height][i] = Octopus(energy);
    }
    height++;
  }
  input_file.close();

  std::cout << oct_array[0][0].energy_level << '\n';
  return 0;
}
