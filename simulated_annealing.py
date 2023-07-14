import math
import random


def simulated_annealing(cost_function, initial_solution, temperature=1.0, cooling_rate=0.95, num_iterations=1000):
    current_solution = initial_solution[:]
    best_solution = initial_solution[:]
    current_cost = cost_function(current_solution)
    best_cost = current_cost

    for _ in range(num_iterations):
        new_solution = current_solution[:]
        random_index = random.randint(0, len(new_solution) - 1)
        new_solution[random_index] += random.uniform(-1, 1)

        new_cost = cost_function(new_solution)
        delta_cost = new_cost - current_cost

        if delta_cost < 0 or random.random() < math.exp(-delta_cost / temperature):
            current_solution = new_solution[:]
            current_cost = new_cost

        if current_cost < best_cost:
            best_solution = current_solution[:]
            best_cost = current_cost

        temperature *= cooling_rate

    return best_solution, best_cost
