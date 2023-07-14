from typing import Callable

import numpy as np
from PIL import Image, ImageDraw
from copy import deepcopy


class Map(object):
    """
    The bi-dimensional grid map implementation for Monte Carlo Localization.

    Each place in the map can contain or not a landmark. Each place is an element at the `Map.matrix` attribute and
    the presence of a landmark is denoted by 1 and the absence by 0. In the image representation returned by
    `Map.get_image()` landmarks are denoted by black squares.

    Attributes
    ----------

    - `__matrix`: The map squared matrix representation.
    - `__size`: The size of the map, i.e. the matrix dimension (since is a square matrix is just a number).
    - `__border`: A Boolean flag indicating if the map has border or not.
    - `update_cb`: A function to be called when the matrix change.
    """
    update_cb: Callable
    __border: bool
    __size: int
    __matrix: np.array

    def __init__(self, matrix: np.array, border: bool = False, update_cb: Callable = None):
        """
        Creates an instance of the Map object.

        :param matrix: The squared binary matrix to represent the map, 1 represents the landmark.
        :param border: A flag indicating if the map has border or not.
        :param update_cb: The callback function called when the matrix change. Although optional, the function
        `Map.shuffle()` and `Map.swap(e1, e2)` just work if the `Map.update_cb` is filled.
        """
        assert len(matrix.shape) == 2
        assert matrix.shape[0] == matrix.shape[1]
        self.__size = matrix.shape[0]
        self.__matrix = matrix
        self.__border = border
        self.update_cb = update_cb

    @classmethod
    def striped(cls, size: int, border=False):
        """
        Generate a Map with matrix of shape (size, size) with horizontal stripes. The first row has landmarks.

        :param size: The map size/dimension.
        :param border: A flag indicating if the map has border or not.
        :return: The generated striped Map instance.
        """
        matrix = np.zeros(size * size, np.uint8)
        matrix.shape = size, size
        for i in range(0, size, 2):
            matrix[i, :] = np.ones(size)
        return cls(matrix, border)

    @classmethod
    def random(cls, size: int, number_of_landmarks: int, border=False):
        """
        Generate a random Map with matrix of shape (size, size) with a specific number of landmarks.

        :param size: The map size/dimension.
        :param number_of_landmarks: The number of landmarks.
        :param border: A flag indicating if the map has border or not.
        :return: A randomly generated Map instance.
        """
        matrix = np.zeros(size * size, dtype=np.float)
        matrix[:number_of_landmarks] = np.ones(number_of_landmarks, dtype=np.float)
        np.random.shuffle(matrix)
        matrix.shape = size, size
        return cls(matrix, border)

    def shuffle(self):
        """
        Shuffle the Map matrix, this means randomly place the landmarks.
        Also call the update callback indicating that change.
        """
        np.random.shuffle(self.__matrix)
        self.update_cb()

    def swap(self, e1, e2):
        """
        Swap the landmarks location. And call the update callback indicating a change in the matrix.

        :param e1: Coordinate of the landmark.
        :param e2: Coordinate of the landmark.
        """
        self.__matrix[e1], self.__matrix[e2] = self.__matrix[e2], self.__matrix[e1]
        self.update_cb()

    @property
    def border(self):
        """
        :return: True if this Map has border, False otherwise.
        """
        return self.__border

    def __getitem__(self, item):
        """
        :return: The item at the matrix. Same as `matrix[item]`
        """
        return self.__matrix[item]

    @property
    def matrix(self):
        """
        :return: The matrix representation of the map. This is NOT a copy, and NEVER change it.
        """
        return self.__matrix

    @property
    def landmarks_coordinates(self):
        """
        :return: The coordinates of places with landmarks (black at image representation).
        """
        return np.nonzero(self.__matrix)

    @property
    def no_landmarks_coordinates(self):
        """
        :return: The coordinates of places without landmarks (white at image representation).
        """
        return np.nonzero(1 - self.__matrix)

    @property
    def size(self) -> int:
        """
        :return: The map dimension/size.
        """
        return self.__size

    def get_image(self) -> Image:
        """
        Generate the Image object of the actual map.
        Black represents the landmarks (ones in the matrix) and white the absence of landmarks (zeros in the matrix).

        :return: The generated image.
        """
        pixel_width = 400
        image = Image.new("L", (pixel_width, pixel_width))
        draw_square = ImageDraw.Draw(image).rectangle

        def mat2box(x):
            return x * pixel_width / self.__size

        ind = np.nonzero(1 - self.__matrix)
        for i in range(ind[0].size):
            box = [(mat2box(ind[1][i]), mat2box(ind[0][i])), (mat2box(ind[1][i] + 1) - 1, mat2box(ind[0][i] + 1) - 1)]
            draw_square(box, fill='white')
        return image

    def copy(self):
        """
        :return: The deepcopy of this object.
        """
        return deepcopy(self)
