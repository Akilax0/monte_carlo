# Virtual Chess Rook

The Virtual Chess Rook is a simulated robot (virtual) that moves north, 
south, east, and west on a grid just like a Chess Rook! 

This project is a result of the Junior Scientific Research Program
(Iniciação Científica in portuguese) made by [Henrique Ferreira Jr.](https://gitlab.com/henriquejsfj)
and advisored by [Ph.D. Daniel R. Figueiredo](https://scholar.google.com/citations?user=j4YbANwAAAAJ&hl=pt-BR&oi=ao).
The objective here is to use a simple model and maps to perform many
simulations efficiently. Then, with these simulations results we do the
analyses and propose new methods.

This README file is divided by the articles published. At each article
section has the paper abstract, its link to where was published, and
indicates the folder with codes and results presented in the paper.

Please visit [The Monte Carlo Robots Docs](https://the-monte-carlo-robots.readthedocs.io/)
for more information and complete documentation.

Note: This repository is being refactored, I mean, the code is becoming
more organized and documented. Also the documentation is being developed.
Thus, some code that import others may be deprecated and not working at all.


## Influence of Location and Number of Landmarks on the Monte Carlo Localization Problem

**Abstract:**
> An important problem in robotics is to determine and maintain the position of a robot that moves through a previously known environment with reference points that are indistinguishable, which is made difficult due to the inherent noise in robot movement and identification of reference pints. Monte Carlo Localization (MCL) is a frequently used technique to solve this problem and its performance intuitively depends on reference points. In this paper we evaluate the performance of MCL as a function of the number of reference points and their positioning in the environment. In particular, we show that performance is not monotonic in the number of reference points and that a random positioning of the reference points is close to optimal. 

The first [article](https://doi.org/10.5753/eniac.2018.4435) published.
It was published on the ENIAC 2018. In the 
[ENIAC 2018 directory](ENIAC%202018) you find the Jupyter Notebook with 
the codes to generate the paper plots.


## Improving Monte Carlo Localization Performance Using Strategic Navigation Policies

**Abstract:**
> An important problem in robotics is to determine and maintain the position of a robot that moves through a known environment with indistinguishable reference points. This problem is made difficult due to the inherent noise in robot movement and sensor readings. Monte Carlo Localization (MCL) is a frequently used technique to solve this problem and its performance intuitively depends on how the robot explores the map. In this paper, we evaluate the performance of MCL under different navigation policies. In particular, we propose a novel navigation policy that aims in reducing the uncertainty in the robot’s location by making a greedy movement at every step. We show that this navigation policy can significantly outperform random movements.

This article was published on the ENIAC 2019. In the 
[ENIAC 2019 directory](ENIAC%202019) you find the ~~Jupyter Notebook~~ 
(by now is just a code) with the codes to generate the paper plots.

## Improving Monte Carlo Localization with StrategicNavigation Policies and Optimal Landmark Placement

**Abstract:**
> An important problem in robotics is to determine and maintain the position of a robot that moves through a known environment with indistinguishable landmarks. This problem is made difficult due to the inherent noise in robot movement and sensor readings. Monte Carlo Localization (MCL) is a frequently used technique to solve this problem, and its performance intuitively depends on how the robot explores the environment and the position of the landmarks. In this paper, we propose a navigation policy to reduce the number of steps required by the robot to find its location together with the optimal landmark placement for this policy. This proposal is evaluated and compared against other policies using two specific metrics that indicate its superiority.

Under review, not yet accepted. In the [CTIC 2020 directory](CTIC%202020)
you find the ~~Jupyter Notebook~~ (by now is just ~~a code~~ some misc codes)
with the codes to generate the paper plots.