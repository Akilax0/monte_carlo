from typing import Callable

from map import Map
import numpy as np
from random import random


class SimulatedAnnealing(object):
    """
    The implementation of the Simulated Annealing algorithm using the Boltzmann Distribution.

    Note: This implementation is specific to a Map optimization.

    Attributes
    ----------
    - `temp`: The temperature in the Boltzmann Distribution.
    - `__map`: The map object to be optimized.
        When getting with `map` property it returns the `__map.copy()`.
        Don't have a setter to it.
    - `__best`: The best map found. Is initialize equal to the given map.
        When getting with the `best` property it returns the `__best.copy()`.
        Don't have a setter to it.
    - `__best_value`: The `objective_function()` value for the best map found.
        Has the `best_value` property to get it but don't have a setter.
    - `__objective_function`: The objective function. Should never be accessed, see constructor for more details.
    """
    __map: Map
    temp: float
    __objective_function: Callable

    def __init__(self, map_: Map, objective_function: Callable, temperature=0.01, minimize=False):
        """
        Create an instance of the SimulatedAnnealing object. This object finds a Map object that maximizes the
        objective_function (or minimize it if `minimize=True`).

        :param map_: The Map to be optimized.
        :param objective_function: The objective function to be maximized (or minimized if `minimize=True`). The
         objective_function should be somehow attached to the Map object and must have *NO* required arguments.
        :param temperature: The Boltzmann Distribution temperature parameter, in this implementation is constant.
        :param minimize: A flag indication if the objective function should be minimized, default is to maximize it.
        """
        self.__map = map_
        if minimize:
            def f():
                return - objective_function()
            self.__objective_function = f
        else:
            self.__objective_function = objective_function

        self.__best_value = self.__objective_function()
        self.__best = self.__map.copy()
        self.temp = temperature

    def optimize(self, transitions: int = 1000, draw: bool = False) -> (np.array, np.array):
        """
        Do the Simulated Annealing optimization maximizing the objective_function or minimizing it if constructed that 
        way.
        
        :param transitions: Number of Simulated Annealing transitions, a rejected one doesn't increment it counter.
        :param draw: Flag indicating if should draw/save the map image for each transition.
        :return: A tuple with two numpy arrays of size transitions containing, respectively, the best measure found and
         number of rejections for each transition.
        """
        value_old = self.best_value
        best_plot, rejections_plot = np.zeros(transitions), np.zeros(transitions)
        best_plot[0], rejections_plot[0] = self.__best_value, 0
        total_rejections = 0
        for i in range(1, transitions):
            rejections = 0
            while True:
                array = self.__map.landmarks_coordinates
                luck = np.random.choice(range(array[0].size))
                black = (array[0][luck], array[1][luck])

                array = self.__map.no_landmarks_coordinates
                luck = np.random.choice(range(array[0].size))
                white = (array[0][luck], array[1][luck])
                self.__map.swap(white, black)
                value = self.__objective_function()
                if self.__best_value < value:
                    self.__best_value = value
                    self.__best = self.__map.copy()
                    value_old = value
                    break
                elif value > value_old or random() < np.exp((value - value_old) / self.temp):
                    value_old = value
                    break
                else:
                    self.__map.swap(white, black)
                    rejections += 1
                    if not(rejections % 10):
                        print("Rejeitou 10 vezes seguidas")
                        print("Taxa de rejeicao: ", total_rejections / (i-1))
                        print("Rodada: ", i)
                    if rejections == 100:
                        return best_plot, rejections_plot
            if draw:
                self.__map.get_image().save(str(i)+'.png')
            rejections_plot[i] = rejections
            best_plot[i] = self.__best_value
            total_rejections += rejections
        return best_plot, rejections_plot

    @property
    def map(self):
        return self.__map.copy()

    @property
    def best_value(self):
        return self.__best_value

    @property
    def best(self):
        return self.__best.copy()
