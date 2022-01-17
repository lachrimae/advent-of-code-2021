#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "octopus.hpp"
#include "oct_array.hpp"
#include "queue.hpp"
#define INPUT_BUF_LEN 1024
#define ARRAY_INDEX_LEN 200

static int total_flashes = 0;

void step1(OctopusArray *arr, Queue<OctopusArrayIndex> *octopi_flashed_at) {
  for (int i = 0; i < arr->max_height; i++) {
    for (int j = 0; j < arr->max_width; j++) {
      OctopusArrayIndex idx = OctopusArrayIndex { i, j };
      Octopus *oct = arr->get(idx);
      oct->energy_level++;
      if (oct->energy_level > 9) {
        oct->has_flashed = true;
        total_flashes++;
        std::vector<OctopusArrayIndex> newly_flashed_at = arr->neighbours(idx);
	for (auto & element : newly_flashed_at) {
          octopi_flashed_at->queue(element);
	}
      }
    }
  }
}

void step2(OctopusArray *arr, Queue<OctopusArrayIndex> *octopi_flashed_at) {
  while (!octopi_flashed_at->empty()) {
    auto idx = octopi_flashed_at->dequeue();
    Octopus *oct = arr->get(idx);
    oct->energy_level++;
    if (oct->energy_level > 9 && !oct->has_flashed) {
      oct->has_flashed = true;
      total_flashes++;
      auto newly_flashed_at_octs = arr->neighbours(idx);
      for (auto & neighbour_idx : newly_flashed_at_octs) {
        octopi_flashed_at->queue(neighbour_idx);
      }
    }
  }
}

void step3(OctopusArray *arr) {
  for (int i = 0; i < arr->max_height; i++) {
    for (int j = 0; j < arr->max_width; j++) {
      OctopusArrayIndex idx = OctopusArrayIndex { i, j };
      Octopus *oct = arr->get(idx);
      if (oct->has_flashed) {
        oct->has_flashed = false;
	oct->energy_level = 0;
      }
    }
  }
}

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

  OctopusArray oct_array;
  OctopusArrayIndex indices_array[ARRAY_INDEX_LEN];
  auto octopi_flashed_at = Queue<OctopusArrayIndex>(indices_array, ARRAY_INDEX_LEN);

  std::string line;
  int height = 0;
  int width;
  while (!input_file.eof()) {
    getline(input_file, line);
    width = line.length();
    for (int i = 0; i < width; i++) {
      int energy = std::stoi(std::string(&line[i], 1));
      Octopus oct = Octopus(energy);
      oct_array.set(OctopusArrayIndex { height, i }, &oct);
    }
    height++;
  }
  input_file.close();

  int num_octopi = oct_array.max_width * oct_array.max_height;
  int num_flashes_after_100_iters = -1;
  int first_synchronized_flash = -1;
  bool found_first_synchronized_flash = false;
  int iteration = 0;
  oct_array.display();
  while (!found_first_synchronized_flash || iteration < 100) {
    int initial_num_flashes = total_flashes;

    step1(&oct_array, &octopi_flashed_at);
    step2(&oct_array, &octopi_flashed_at);
    oct_array.display();
    step3(&oct_array);

    iteration++;
    if (iteration == 100) {
      num_flashes_after_100_iters = total_flashes;
    }

    int final_num_flashes = total_flashes;
    int new_additional_flashes = final_num_flashes - initial_num_flashes;
    if (new_additional_flashes == num_octopi) {
      found_first_synchronized_flash = true;
      first_synchronized_flash = iteration;
    }
  }
  std::cout << "total flashes: " << num_flashes_after_100_iters << "\n";
  std::cout << "first synchronized flash: " << first_synchronized_flash << "\n";
  return 0;
}
