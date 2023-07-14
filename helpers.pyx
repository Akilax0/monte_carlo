import numpy as np
from PIL import ImageDraw, Image


# TODO: Draw the probability with proportional size.
def draw_prob(image: Image, map_size: int, prob_distribution: np.array):
    """
    Draw the "probability distribution" at the given map image.
    The result is an image with gray squares drawn at the states with nonzero probability.
    All the squares are drawn with the same size.

    :param image: The map image to receive the drawings.
    :param map_size: The map size.
    :param prob_distribution: The Monte Carlo Localization (MCL) probability distribution
    """
    pixel_width = image.size[0]
    draw_square = ImageDraw.Draw(image).rectangle

    def mat2box(x):
        return x * pixel_width / map_size

    ind = np.nonzero(prob_distribution)
    for i in range(ind[0].size):
        box = [(mat2box(ind[1][i]) + 10, mat2box(ind[0][i]) + 10),
               (mat2box(ind[1][i] + 1) - 11, mat2box(ind[0][i] + 1) - 11)]
        draw_square(box, fill=125)


def draw_mov(image: Image, map_size: int, mov: int, position: tuple):
    """
    Draw the robot desired movement at the given map image, in the form:
    - Move left: <=
    - Move right: =>
    - Move up: /\\
    - Move down: \\/

    Call it between `MCL.move()` and `MCL.simulate_movement()` to draw it at the robot correct position.

    :param image: The map image to receive the drawings.
    :param map_size: The map size.
    :param mov: The desired movement.
    :param position: The robot actual position, square where the mov string will be draw.
    """
    pixel_width = int(image.size[0] / map_size)
    if mov == 0:
        text = '<='
    elif mov == 1:
        text = '=>'
    elif mov == 2:
        text = '/\\'
    elif mov == 3:
        text = '\\/'
    else:
        raise ValueError('Movement must be 0, 1, 2 or 3')
    ImageDraw.Draw(image).text((position[1] * pixel_width, position[0] * pixel_width), text, fill=125)

def avg_hit_rate(mcl, r=2000, samples=100) -> float:
    """
    Compute the average hit rate ($E_G(r)$ in the articles).

    :param r: The r in the articles. The number of steps (sensor measurement followed by movement) made by the robot
     in the map. Default is 2000, same used at the articles.
    :param samples: Number of hit rate samples to compute the measure.
    :return: The average hit rate.
    """
    hit_rate = 0
    for i in range(samples):
        mcl.real_position = None
        mcl.reset_distribution()
        hits = 0
        for j in range(r):
            mcl.sense(mcl.simulate_sensor())
            mcl.simulate_movement(mcl.move())
            if mcl.real_position == mcl.estimated_position:
                hits += 1
        hit_rate += hits / r
    return hit_rate / samples
