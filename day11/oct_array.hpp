#ifndef OCTOPUS_ARRAY
#define OCTOPUS_ARRAY
#include <vector>
#include "octopus.hpp"
#define MAX_OCT_ARRAY_DIM 20

constexpr int ARRAY_LEN = MAX_OCT_ARRAY_DIM * sizeof(Octopus);

typedef struct OctopusArrayIndex {
  int i;
  int j;
} OctopusArrayIndex;

class OctopusArray {
  private:
    Octopus *arr;
  public:
    int max_width = 0;
    int max_height = 0;
    OctopusArray();
    ~OctopusArray();
    Octopus *get(OctopusArrayIndex idx);
    void set(OctopusArrayIndex idx, Octopus *oct);
    std::vector<OctopusArrayIndex> neighbours(OctopusArrayIndex idx);
    void display();
};
#endif
