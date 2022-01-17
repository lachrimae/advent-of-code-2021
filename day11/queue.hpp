#ifndef QUEUE
#define QUEUE
#include <cstddef>

// straightforward ringbuffer queue

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
    bool empty();
};

// these templates need to live in this header file
// since they cannot be compiled into object file data

template <typename T>
Queue<T>::Queue(T *array, size_t length) : array(array), initial(0), terminal(0), length(length)
{}

template <typename T>
void Queue<T>::queue(T element) {
  this->array[this->terminal] = element;
  this->terminal++;
  if (this->terminal == this->length) {
    this->terminal = 0;
  }
}

template <typename T>
T Queue<T>::dequeue() {
  T result = this->array[this->initial];
  this->initial++;
  if (this->initial == this->length) {
    this->initial = 0;
  }
  return result;
}

template <typename T>
bool Queue<T>::empty() {
  return this->initial == this->terminal;
}
#endif
