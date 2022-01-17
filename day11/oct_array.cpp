#include "oct_array.hpp"
#include <iostream>

OctopusArray::OctopusArray() {
  this->arr = (Octopus*)(new char[ARRAY_LEN*ARRAY_LEN]);
}

OctopusArray::~OctopusArray() {
  delete this->arr;
}

Octopus *OctopusArray::get(OctopusArrayIndex idx) {
  return &this->arr[idx.i * ARRAY_LEN + idx.j];
}

void OctopusArray::set(OctopusArrayIndex idx, Octopus *oct) {
  this->arr[idx.i * ARRAY_LEN + idx.j] = *oct;
  if (idx.i + 1 > this->max_height)
    this->max_height = idx.i + 1;
  if (idx.j + 1 > this->max_width)
    this->max_width = idx.j + 1;
}

std::vector<OctopusArrayIndex> OctopusArray::neighbours(OctopusArrayIndex idx) {
  std::vector<OctopusArrayIndex> result;
  result.reserve(8);
  for (int i2 = idx.i - 1; i2 <= idx.i + 1; i2++) {
    for (int j2 = idx.j - 1; j2 <= idx.j + 1; j2++) {
      if (i2 < 0 || j2 < 0)
        continue;
      if (i2 >= this->max_height || j2 >= this->max_width)
        continue;
      if (i2 == idx.i && j2 == idx.j)
        continue;
      result.push_back(OctopusArrayIndex { i2, j2 });
    }
  }
  return result;
}

void OctopusArray::display() {
  for (int i = 0; i < this->max_height; i++) {
    for (int j = 0; j < this->max_width; j++) {
      auto oct = this->get(OctopusArrayIndex { i, j });
      if (oct->has_flashed) {
        std::cout << '+';
      } else {
        std::cout << oct->energy_level;
      }
    }
    std::cout << "\n";
  }
  std::cout << "\n";
}
