#ifndef QUEUE
#define QUEUE
#include <cstddef>
template <typename T>
class Queue {
  private:
    T *array;
    size_t initial;
    size_t terminal;
    size_t length;
  public:
    // It is the calling context's responsibility
    // to allocate and deallocate the array and verify
    // that its size is accurately represented.
    // Pass-by-value happens to be more efficient in this
    // problem than pass-by-reference.
    Queue(T *array, size_t length);
    void queue(T element);
    T dequeue();
};
#endif
