#ifndef OCTOPUS_ARRAY
#include <vector>
#include <tuple>
#include "octopus.hpp"
#define OCTOPUS_ARRAY
#define MAX_OCT_ARRAY_DIM 20

constexpr size_t ARRAY_LEN = MAX_OCT_ARRAY_DIM * sizeof(Octopus);

std::vector<std::tuple<int, int>> neighbours(int i, int j);

class OctopusArray {
  private:
    Octopus *arr;
  public:
    OctopusArray();
    ~OctopusArray();
    Octopus *get(int i, int j);
    void set(int i, int j, Octopus *oct);
};
#endif
