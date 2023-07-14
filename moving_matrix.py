import numpy as np


class MovingMatrix(object):
    def __init__(self, matrix):
        self.zero = np.array([0, 0])
        self.matrix = matrix

    def __getitem__(self, ind):
        return self.matrix[tuple((ind + self.zero) % self.matrix.shape)]

    def __add__(self, mat):
        if (self.zero == mat.zero).all():
            return self.matrix + mat.matrix
        else:
            raise (ValueError, "I am tired to implement sum of different zero points")

    def __mul__(self, mat):
        if (self.zero == mat.zero).all():
            return self.matrix.dot(mat.matrix)
        elif (mat.zero == (0, 0)).all():
            tam0 = self.matrix.shape[0]
            tam1 = self.matrix.shape[1]
            sub1 = self.matrix[:self.zero[0], :self.zero[1]] * (
            mat.matrix[(tam0 - self.zero[0]):, (tam1 - self.zero[1]):])
            sub2 = self.matrix[:self.zero[0], self.zero[1]:] * (
            mat.matrix[(tam0 - self.zero[0]):, :(tam1 - self.zero[1])])
            sub3 = self.matrix[self.zero[0]:, :self.zero[1]] * (
            mat.matrix[:(tam0 - self.zero[0]), (tam1 - self.zero[1]):])
            sub4 = self.matrix[self.zero[0]:, self.zero[1]:] * (
            mat.matrix[:(tam0 - self.zero[0]), :(tam1 - self.zero[1])])
            return np.block([[sub1, sub2], [sub3, sub4]])

    def move(self, cmd):
        if cmd == 3:  # Move pra baixo
            self.zero[0] = (self.zero[0] + 1) % self.matrix.shape[0]
        elif cmd == 2:  # Move pra cima
            self.zero[0] = (self.zero[0] - 1) % self.matrix.shape[0]
        elif cmd == 1:  # Move pra direita
            self.zero[1] = (self.zero[1] + 1) % self.matrix.shape[1]
        elif cmd == 0:  # Move pra esquerda
            self.zero[1] = (self.zero[1] - 1) % self.matrix.shape[1]
