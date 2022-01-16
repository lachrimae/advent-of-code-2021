#include "oct_array.hpp"

OctopusArray::OctopusArray() {
  this->arr = (Octopus*)(new char[ARRAY_LEN*ARRAY_LEN]);
}

OctopusArray::~OctopusArray() {
  delete this->arr;
}

Octopus *OctopusArray::get(int i, int j) {
  return &this->arr[i * ARRAY_LEN + j];
}

void OctopusArray::set(int i, int j, Octopus *oct) {
  this->arr[i * ARRAY_LEN + j] = *oct;
}

std::vector<std::tuple<int, int>> neighbours(int i, int j) {
  std::vector<std::tuple<int, int>> result;
  result.reserve(8);
  for (int i2 = i - 1; i <= i + 1; i++) {
    for (int j2 = j - 1; j <= j + 1; j++) {
      if (i2 < 0 || j2 < 0)
        continue;
      if (i2 >= ARRAY_LEN || j2 >= ARRAY_LEN)
        continue;
      if (i2 == i && j2 == j)
        continue;
      std::tuple<int, int> pair = std::make_tuple(i2, j2);
      result.push_back(pair);
    }
  }
  return result;
}
