#include <cstddef>
#include <cassert>
#include <iostream>
#include "queue.hpp"

// straightforward ringbuffer queue

template <typename T>
Queue<T>::Queue(T *array, size_t length) : array(array), length(length), initial(0), terminal(0)
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
  T *result = this->array[this->initial];
  this->initial++;
  if (this->initial == this->length) {
    this->initial = 0;
  }
  return result;
}
