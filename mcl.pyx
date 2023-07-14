from random import choice
import numpy as np

from simulator import Simulator
from map import Map


@np.vectorize
def make_sense_black(x):
    return (Simulator.p_hit - Simulator.p_miss) * x + Simulator.p_miss


@np.vectorize
def make_sense_white(x):
    return (Simulator.p_miss - Simulator.p_hit) * x + Simulator.p_hit


# TODO: Maybe is better to save the uniform distribution
class MCL(Simulator):
    """
    The Monte Carlo Localization algorithm implementation. Inherits the Simulator.

    This implementation was not done to be general, is specific to a bi-dimensional squared grid map.

    The noises are Simulator class attributes and are initialized with it default values. If you want to change the
    noises values change it using the `Simulator` and not `MCL`. Also, be sure to set a new map to trigger the
    pre-processing steps which uses the noise values. The default values:

     - `Simulator.p_hit = 0.9`: The probability of the measurement to be right.
     - `Simulator.p_miss = 0.1`: The probability of the measurement to be wrong.
     - `Simulator.p_exact = 0.8`: The probability of the robot perform an exact motion.
     - `Simulator.p_overshoot = 0.1`: The probability of the robot perform more than desired motion.
     - `Simulator.p_undershoot = 0.1`: The probability of the robot perform less than desired motion.

    See also the `Simulator` docs for more details.
    """

    __map: Map
    __move_up: np.array
    __move_down: np.array
    __move_left: np.array
    __move_right: np.array
    __sense_white: np.array
    __sense_black: np.array
    __prob_distribution: np.array

    def __init__(self, map_: Map):
        """
        Construct the MCL object.
        It starts an uniform probability distribution and randomly set the robot simulated position.
        Also, do the pre-processing to build the sense and movement matrices.

        :param map_: The map required by the Monte Carlo Localization.
        """
        # Set the map and set the Map update callback to update the sense matrices
        super().__init__(map_)
        # self._map = map_
        self._map.update_cb = self.__update_sense

        # Initialize the probability distribution as uniform
        self.reset_distribution()

        # Initialize the matrices to store the sense operation
        self.__update_sense()

        # Initialize the move matrices and the update it
        self.__update_move_matrix()

    @classmethod
    def deprecated(cls, size, map_=50, border=False):
        if type(map_) == int or type(map_) == np.int8:
            temp_map = Map.random(size, map_, border)
            mcl = cls(temp_map)
            temp_map.update_cb = mcl.__update_sense
            return mcl
        elif map_.shape == (size, size):
            return cls(Map(map_))
        else:
            raise TypeError('You should pass a %dx%d numpy array' % (size, size))

    def __update_sense(self):
        """
        Construct/Update the sensor matrices used to sense black or white (landmark or no).
        This is a pre-processing step to improve code speed.
        """
        self.__sense_black = make_sense_black(self._map.matrix)
        self.__sense_white = make_sense_white(self._map.matrix)
        self.reset_distribution()

    def __update_move_matrix(self):
        """
        Construct/Update the shift matrices are used to move the probability distribution.
        This is a pre-processing step to improve code speed.
        
        See also: https://en.wikipedia.org/wiki/Shift_matrix
        """
        identity = np.identity(self._map.size)
        self.__move_down = Simulator.p_undershoot * identity + \
                           Simulator.p_exact * np.roll(identity, 1, axis=0) + \
                           Simulator.p_overshoot * np.roll(identity, 2, axis=0)
        self.__move_left = self.__move_down.copy()
        self.__move_up = Simulator.p_undershoot * identity + \
                         Simulator.p_exact * np.roll(identity, -1, axis=0) + \
                         Simulator.p_overshoot * np.roll(identity, -2, axis=0)
        self.__move_right = self.__move_up.copy()
        if self._map.border:
            self.__move_left[:, 0] += self.__move_left[:, -1]
            self.__move_left[:, -1] = np.zeros(self._map.size)
            self.__move_down[-1, :] += self.__move_down[0, :]
            self.__move_down[0, :] = np.zeros(self._map.size)
            self.__move_right[:, -1] += self.__move_right[:, 0]
            self.__move_right[:, 0] = np.zeros(self._map.size)
            self.__move_up[0, :] += self.__move_up[-1, :]
            self.__move_up[-1, :] = np.zeros(self._map.size)

    def move(self, cmd=-1) -> int:
        """
        Do the movement operation at Monte Carlo Localization. 
        It can receive an external command (cmd) in the form:
        
        - 0: Move left. Prefer to use `Simulator.left_cmd`.
        - 1: Move right. Prefer to use `Simulator.right_cmd`.
        - 2: Move up. Prefer to use `Simulator.up_cmd`.
        - 3: Move down. Prefer to use `Simulator.down_cmd`.
        
        Or if the number is negative use a navigation policy:
        
        - -1: Random movements (default)
        - -2: Minimize the probability difference between places with and without landmarks (see articles).
        - -3: Minimize the expected quadratic sum. Not in the articles but also a good one (see project docs).
        
        :param cmd: The desired movement command.
        :return: The desired movement command.
        """
        # If use navigation policy
        if cmd < 0:
            if cmd < -1:
                mat_mov = np.array([np.matmul(self.__prob_distribution, self.__move_left),
                                    np.matmul(self.__prob_distribution, self.__move_right),
                                    np.matmul(self.__move_up, self.__prob_distribution),
                                    np.matmul(self.__move_down, self.__prob_distribution)])
                min_ = self._map.size * self._map.size
                if cmd == -3:  # Minimize quadratic sum
                    for c in range(4):
                        prob_black = np.multiply(self._map.matrix, mat_mov[c])
                        prob_white = np.multiply((1 - self._map.matrix), mat_mov[c])
                        var = np.sum(prob_black) * np.sum(np.multiply(prob_black, prob_black)) + \
                              np.sum(prob_white) * np.sum(np.multiply(prob_white, prob_white))
                        if var < min_:
                            min_ = var
                            cmd = [c]
                        elif var == min_:
                            cmd.append(c)
                elif cmd == -2:  # Divide the probability between black and white
                    for c in range(4):
                        dif = np.abs(0.5 - np.sum(np.multiply(self._map.matrix, mat_mov[c])))
                        if dif < min_:
                            min_ = dif
                            cmd = [c]
                        elif dif == min_:
                            cmd.append(c)
                cmd = choice(cmd)
                self.__prob_distribution = mat_mov[cmd]
                return cmd

            else:
                cmd = choice((0, 1, 2, 3))

        # Receiving command from world
        if cmd == Simulator.down_cmd:  # Move down
            np.matmul(self.__move_down, self.__prob_distribution, out=self.__prob_distribution)
        elif cmd == Simulator.up_cmd:  # Move up
            np.matmul(self.__move_up, self.__prob_distribution, out=self.__prob_distribution)
        elif cmd == Simulator.right_cmd:  # Move right
            np.matmul(self.__prob_distribution, self.__move_right, out=self.__prob_distribution)
        elif cmd == Simulator.left_cmd:  # Move left
            np.matmul(self.__prob_distribution, self.__move_left, out=self.__prob_distribution)
        return cmd

    def sense(self, sens: bool):
        """
        Do the Monte Carlo Localization measurement update. Also, it normalize the probability distribution.
        :param sens: The sensor reading.
        """
        # Receiving sensor readings from world or simulator
        if sens:
            np.multiply(self.__sense_black, self.__prob_distribution, out=self.__prob_distribution)
        else:
            np.multiply(self.__sense_white, self.__prob_distribution, out=self.__prob_distribution)
        np.multiply(1 / self.__prob_distribution.sum(), self.__prob_distribution, out=self.__prob_distribution)

    @property
    def estimated_position(self):
        """
        :return: The Monte Carlo Localization estimated position. None if there aren't one yet.
        """
        if np.sum(np.max(self.__prob_distribution) == self.__prob_distribution) > 1:
            return None
        return np.unravel_index(np.argmax(self.__prob_distribution), self.__prob_distribution.shape)

    @property
    def prob_distribution(self):
        """
        :return: A copy of the probability distribution.
        """
        return self.__prob_distribution.copy()

    @prob_distribution.setter
    def prob_distribution(self, x):
        """
        Set the probability distribution with a copy of the new one.

        :param x: New probability distribution.
        """
        self.__prob_distribution = x.copy()

    @property
    def map(self):
        """
        :return: A copy of the map.
        """
        return self._map.copy()

    @map.setter
    def map(self, x: Map):
        """
        Set the map with the new one (isn't a copy).
        Also, updates the sensor and movement matrices.
        Finally, set the real position to a random one.

        :param x: The new map.
        """
        old = self._map
        self._map = x
        self._map.update_cb = self.__update_sense
        if self._map.size != old.size or self._map.border != old.border:
            self.__update_move_matrix()
        self.__update_sense()
        self.real_position = None

    @property
    def uniform_distribution(self) -> np.array:
        """
        :return: The uniform probability distribution of the actual map
        """
        return np.full((self._map.size, self._map.size), 1 / (self._map.size * self._map.size), dtype=np.float)

    def reset_distribution(self):
        """
        Reset the probability distribution to the uniform one. Automatically called when changing or setting the `map`.

        Should be called after setting the `real_position` unless you want to analyse the kidnapped robot problem.
        """
        self.__prob_distribution = np.full((self._map.size, self._map.size), 1 / (self._map.size * self._map.size),
                                           np.float)
