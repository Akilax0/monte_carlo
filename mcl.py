import random
import math


class MonteCarloLocalization:
    def __init__(self, num_particles, map_size):
        self.num_particles = num_particles
        self.map_size = map_size
        self.particles = []

    def initialize_particles(self):
        for _ in range(self.num_particles):
            x = random.uniform(0, self.map_size)
            y = random.uniform(0, self.map_size)
            theta = random.uniform(0, 2 * math.pi)
            self.particles.append([x, y, theta])

    def motion_update(self, delta_x, delta_y, delta_theta):
        for i in range(self.num_particles):
            self.particles[i][0] += delta_x
            self.particles[i][1] += delta_y
            self.particles[i][2] += delta_theta

    def measurement_update(self, measurements, sigma):
        weights = []
        for particle in self.particles:
            x, y, theta = particle
            weight = 1.0
            for measurement in measurements:
                landmark_x, landmark_y = measurement
                distance = math.sqrt((x - landmark_x) ** 2 + (y - landmark_y) ** 2)
                weight *= self.gaussian(distance, sigma)
            weights.append(weight)

        sum_weights = sum(weights)
        normalized_weights = [weight / sum_weights for weight in weights]
        self.particles = random.choices(self.particles, normalized_weights, k=self.num_particles)

    @staticmethod
    def gaussian(x, sigma):
        coefficient = 1 / (sigma * math.sqrt(2 * math.pi))
        exponent = -0.5 * ((x / sigma) ** 2)
        return coefficient * math.exp(exponent)


# Example usage:
num_particles = 100
map_size = 10.0
mcl = MonteCarloLocalization(num_particles, map_size)

# Initialize particles
mcl.initialize_particles()

# Perform motion update
delta_x = 1.0
delta_y = 0.5
delta_theta = math.pi / 4
mcl.motion_update(delta_x, delta_y, delta_theta)

# Perform measurement update
measurements = [(2.0, 3.0), (5.0, 7.0)]
sigma = 0.1
mcl.measurement_update(measurements, sigma)
