import math


def rotate_point(point, origin, angle):
    """
    Rotate a point counterclockwise by a given angle around a given origin.
    """
    x, y = point
    ox, oy = origin

    qx = ox + math.cos(angle) * (x - ox) - math.sin(angle) * (y - oy)
    qy = oy + math.sin(angle) * (x - ox) + math.cos(angle) * (y - oy)

    return qx, qy


def distance(point1, point2):
    """
    Calculate the Euclidean distance between two points.
    """
    x1, y1 = point1
    x2, y2 = point2

    return math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
