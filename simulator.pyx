from random import random
from numpy import unravel_index
from numpy.random import randint

from map import Map


class Simulator:
    """
    The robot model simulator. It simulates the robot position, movements and sensor readings.

    This implementation was not done to be general, is specific to our robot model. See more details in
    [Virtual Chess Rook docs](https://the-monte-carlo-robots.readthedocs.io/projects/virtual-chess-rook/).

    The noises are Simulator class attributes and are initialized with it default values:

     - `Simulator.p_hit = 0.9`: The probability of the measurement to be right.
     - `Simulator.p_miss = 0.1`: The probability of the measurement to be wrong.
     - `Simulator.p_exact = 0.8`: The probability of the robot perform an exact motion.
     - `Simulator.p_overshoot = 0.1`: The probability of the robot perform more than desired motion.
     - `Simulator.p_undershoot = 0.1`: The probability of the robot perform less than desired motion.

    It also has class attributes to help dealing with movements commands. They are not Enum or other stuff to improve
    code speed:

     - `left_cmd = 0`
     - `right_cmd = 1`
     - `up_cmd = 2`
     - `down_cmd = 3`
    """

    p_hit = 0.9  # The probability of the measurement to be right.
    p_miss = 0.1  # The probability of the measurement to be wrong.
    p_exact = 0.8  # Probability of the robot perform an exact motion.
    p_overshoot = 0.1  # Probability of the robot perform more than desired motion.
    p_undershoot = 0.1  # Probability of the robot perform less than desired motion.

    left_cmd = 0
    right_cmd = 1
    up_cmd = 2
    down_cmd = 3

    def __init__(self, map_: Map):
        self._map = map_ #change it
        self.real_position = None

    @property
    def map(self):
        """
        :return: The map attribute (is not a copy).
        """
        return self._map

    @map.setter
    def map(self, x: Map):
        """
        Set the map with the new one (isn't a copy).

        :param x: The new map.
        """
        self._map = x

    def simulate_movement(self, cmd: int):
        """
        Do the simulation movement of the robot considering movement noises.
        It updates the `Simulator.real_position` with the new place.

        :param cmd: The desired robot movement
        """
        real = random()
        if real <= Simulator.p_exact:
            self.__real_position = self.__neighbors(self.__real_position)[cmd]
        elif real <= Simulator.p_exact + Simulator.p_overshoot:
            self.__real_position = self.__neighbors(self.__neighbors(self.__real_position)[cmd])[cmd]

    def simulate_sensor(self) -> bool:
        """
        Do the sensor measurement simulation considering sensor noises.
        Number 1 or `True` represents landmark reading (black on the image representation).

        :return: The measurement/sense.
        """
        sens = self._map[self.__real_position]  # 1 represents landmark reading (black on the image representation)
        real = random()
        if real > Simulator.p_hit:
            sens = not sens
        return sens

    @property
    def real_position(self) -> (int, int):
        """
        :return: The simulated (real) position of the robot
        """
        return self.__real_position

    @real_position.setter
    def real_position(self, x):
        """
        Set the new robot real position. It accepts an absolute number meaning the sum of row and column coordinates.
        Also accept a tuple in form (row, column). Or if you just want to set it to a random position set it to None.

        Note: This is due to the simulation part

        Examples
        -----
        >>> Simulator.real_position = (5, 5)
        set to (5,5) coordinate in a 6x6 map

        >>> Simulator.real_position = 35
        set to (5,5) coordinate in a 6x6 map

        >>> Simulator.real_position = None
        set to a random place

        :param x: The robot real position coordinate.
        """
        if type(x) == int:
            self.__real_position = unravel_index(x, (self._map.size, self._map.size))
        elif type(x) == tuple and 2 == len(x):
            self.__real_position = x
        elif x is None:
            self.__real_position = (randint(0, self._map.size), randint(0, self._map.size))
            
    def __neighbors(self, coordinate) -> tuple:
        """
        Calculates the possibles targets the robot can move into from a given coordinate. It considers that the robot
        can only move left, right, up and down. If the map has border and the movement run into the border the origin
        coordinate will be returned in place.

        :param coordinate: The 2D-coordinate (row, column)
        :return: The coordinates of the possibles targets the robot can move into in tuple of points, like:
        (left, right, up, down)
        """
        i, j = coordinate
        if self._map.border:
            column = [((j - 1) % self._map.size) % (self._map.size - 1), int((j + 1) < self._map.size) + j]
            row = [((i - 1) % self._map.size) % (self._map.size - 1), int((i + 1) < self._map.size) + i]
        else:
            column = [(j - 1) % self._map.size, (j + 1) % self._map.size]
            row = [(i - 1) % self._map.size, (i + 1) % self._map.size]
        return (i, column[0]), (i, column[1]), (row[0], j), (row[1], j)
