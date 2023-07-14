import numpy as np


class Map:
    def __init__(self, size):
        self.size = size
        self.grid = np.zeros((size, size))

    def add_landmark(self, x, y):
        if self.is_valid_position(x, y):
            self.grid[x, y] = 1

    def is_landmark(self, x, y):
        if self.is_valid_position(x, y):
            return self.grid[x, y] == 1
        return False

    def is_valid_position(self, x, y):
        return 0 <= x < self.size and 0 <= y < self.size


# Example usage:
map_size = 10
map_obj = Map(map_size)

# Add landmarks
map_obj.add_landmark(2, 3)
map_obj.add_landmark(5, 7)

# Check if positions are landmarks
print(map_obj.is_landmark(2, 3))  # True
print(map_obj.is_landmark(5, 5))  # False
