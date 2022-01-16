from dataclasses import dataclass
from enum import Enum, auto
import sys

class FlashState(Enum):
    NO_FLASH = auto()
    MUST_FLASH = auto()
    HAS_FLASHED = auto()

def vals_around(minimum, maximum, val):
    result = list()
    if val > minimum:
        result.append(val - 1)
    result.append(val)
    if val < maximum:
        result.append(val + 1)
    return result

@dataclass
class Octopus:
    energy_level: int
    flash_state: FlashState

class OctopusArray:
    def __init__(self, input_str):
        self.octopi = list()
        max_height = 0
        for line in input_str.split('\n'):
            row = list()
            max_width = 0
            for char in row:
                octopus = Octopus(int(char), False)
                row.append(octopus)
                max_width += 1
            max_height += 1
        self.max_height = max_height
        self.max_width = max_width

    def get(height, width):
        return self.octopi[height][width]

    def set(height, width, octopus):
        self.octopi[height][width] = octopus

    def neighbours(height, width):
        heights = vals_around(0, self.max_height, height)
        widths = vals_around(0, self.max_width, width)
        result = list()
        for i in heights:
            for j in widths:
                result.append((i, j))
        return result

def step1(oct_array):
    for i in range(oct_array.max_height):
        for j in range(oct_array.max_width):
            octopus = octopus.get(i, j)
            new_level = current_level + 1
            octopus.energy_level = new_level
            if new_level > 9:
                octopus.flash_state = FlashState.MUST_FLASH

def step2(oct_array):
    num_flashed = 0
    promoted_no_octopi = False
    while not promoted_no_octopi:
        promoted_no_octopi = True
        for i in range(oct_array.max_height):
            for j in range(oct_array.max_width):
                octopus = octopus.get(i, j)
                if octopus.flash_state == FlashState.MUST_FLASH:
                    for neighbour_indices in oct_array.neighbours(i, j):
                        i2, j2 = neighbour
                        neighbour_octopus = oct_array.get(i2, j2)
                        neighbour_octopus.energy_level += 1
                        if neighbour_octopus.flash_state == FlashState.NO_FLASH:
                            neighbour_octopus.flash_state = FlashState.MUST_FLASH
                            promoted_no_octopi = False
                    octopus.flash_state = FlashState.HAS_FLASHED
                    num_flashed += 1
    return num_flashed

def step3(oct_array):
    for i in range(oct_array.max_height):
        for j in range(oct_array.max_width):
            octopus = octopus.get(i, j)
            if octopus.flash_state == FlashState.MUST_FLASH:
                raise ValueError('Octopi which must flash left over for step 3')
            elif octopus.flash_state == FlashState.HAS_FLASHED:
                octopus.flash_state = FlashState.NO_FLASH
                octopus.energy_level = 0

def main():
    if len(sys.argv) != 2:
        sys.exit(1)
    with open(sys.argv[1], 'r') as f:
        data = f.read()
    oct_array = OctopusArray(data)
    flashes = 0
    for i in range(100):
        step1(oct_array)
        flashes += step2(oct_array)
        step3(oct_array)
    print(f'flashes: {flashes}')

if __name__ == '__main__':
    main()
