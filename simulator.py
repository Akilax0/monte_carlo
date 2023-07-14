import math
from helpers import rotate_point, distance
from map import Map


class RobotSimulator:
    def __init__(self, map_size, landmark_positions, start_pose):
        self.map_size = map_size
        self.landmark_positions = landmark_positions
        self.pose = start_pose

    def move(self, dx, dy, dtheta):
        self.pose[0] += dx
        self.pose[1] += dy
        self.pose[2] += dtheta

    def sense(self):
        measurements = []
        for landmark in self.landmark_positions:
            landmark_x, landmark_y = landmark
            rotated_landmark = rotate_point((landmark_x, landmark_y), self.pose[:2], -self.pose[2])
            measurements.append(rotated_landmark)
        return measurements


class MonteCarloSimulator:
    def __init__(self, map_size, landmark_positions, num_particles, start_pose):
        self.map = Map(map_size)
        self.map_size = map_size
        self.landmark_positions = landmark_positions
        self.num_particles = num_particles
        self.particles = []
        self.initialize_particles(start_pose)

    def initialize_particles(self, start_pose):
        for _ in range(self.num_particles):
            x = random.uniform(0, self.map_size)
            y = random.uniform(0, self.map_size)
            theta = random.uniform(0, 2 * math.pi)
            self.particles.append([x, y, theta])

    def motion_update(self, dx, dy, dtheta):
        for particle in self.particles:
            robot = RobotSimulator(self.map_size, self.landmark_positions, particle)
            robot.move(dx, dy, dtheta)
            particle[0], particle[1], particle[2] = robot.pose

    def measurement_update(self, measurements, sigma):
        weights = []
        for particle in self.particles:
            robot = RobotSimulator(self.map_size, self.landmark_positions, particle)
            predicted_measurements = robot.sense()
            weight = 1.0
            for i in range(len(measurements)):
                distance_error = distance(measurements[i], predicted_measurements[i])
                weight *= gaussian(distance_error, sigma)
            weights.append(weight)
        weights_sum = sum(weights)
        normalized_weights = [weight / weights_sum for weight in weights]
        self.particles = random.choices(self.particles, normalized_weights, k=self.num_particles)


def gaussian(x, sigma):
    coefficient = 1 / (sigma * math.sqrt(2 * math.pi))
    exponent = -0.5 * ((x / sigma) ** 2)
    return coefficient * math.exp(exponent)
