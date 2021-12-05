struct Position {
  int x;
  int y;
};

// The following three struct templates may look like types, but
// in fact they are "metafunctions" which will be executed at
// compile-time to help write our program.


template<int n, Position p>
struct up {
  static constexpr struct Position value = {
    p.x,
    p.y - n,
  };
};

template<int n, Position p>
struct down {
  static constexpr struct Position value = {
    p.x,
    p.y + n,
  };
};

template<int n, Position p>
struct forward {
  static constexpr struct Position value = {
    p.x + n,
    p.y,
  };
};

static constexpr struct Position initial = {
  0,
  0,
};
