# See: https://en.wikipedia.org/wiki/Test_functions_for_optimization
# See: http://infinity77.net/global_optimization/test_functions.html
# See: http://al-roomi.org/benchmarks/unconstrained/n-dimensions/
test_problems = Dict(
  :beal => TestProblem(
    (x) -> (1.5 - x[1] + x[1]*x[2])^2 + (2.25 - x[1] + x[1]*x[2]^2)^2 + (2.625 - x[1] + x[1]*x[2]^3)^2,
    [-8.0,-8.0],
    (-10,10),
    (-10,10)
  ),
  :bird => TestProblem(
    x -> (x[1] - x[2])^2 + exp((1 - sin(x[1]))^2)*cos(x[2]) + exp((1 - cos(x[2]))^2)*sin(x[1]),
    [-4.0,4.0],
    (-2π,2π),
    (-2π,2π)
  ),
  :booth => TestProblem(
    x -> (x[1] + 2x[2] - 7)^2 + (2x[1] + x[2] - 5)^2,
    [-8.0,-8.0],
    (-10,10),
    (-10,10)
  ),
  :easom => TestProblem(
    x -> -cos(x[1])*cos(x[2])*exp(-((x[1] - π)^2 + (x[2] - π)^2)),
    [-3.5,-8.0],
    (-10,10),
    (-10,10)
  ),
  :quing => TestProblem(
    x -> sum((x[i]^2 - i)^2 for i in 1:length(x)),
    [-0.5,-1.8],
    (-2,2),
    (-2,2)
  ),
  :rosenbrock => TestProblem(
    x -> (x[2] - x[1]^2)^2 + (x[1] - 4)^2,
    [-2.0,15.0],
    (-5,5),
    (-5,20)
  ),
  :rosenbrockmodified => TestProblem(
    x -> 74 + 100*(x[2] - x[1]^2)^2 + (1 - x[1])^2 - 400*exp(-((x[1] + 1)^2 + (x[2] + 1)^2)/0.1),
    [-0.2,-0.8],
    (-2,2),
    (-2,2)
  ),
  :schwefel26 => TestProblem(
    x -> 418.9829*length(x) - sum(x_i * sin(sqrt(abs(x_i))) for x_i in x),
    [0.0,0.0],
    (-500,500),
    (-500,500)
  ),
  :sixhumpcamel => TestProblem(
    x -> 4x[1]^2 + x[1]*x[2] - 4x[2]^2 - 2.1x[1]^4 + 4x[2]^4 + x[1]^6/3,
    [1.0,0.5],
    (-3,3),
    (-3,3)
  ),
  :styblinskitang => TestProblem(
    x -> sum(x_i^4 - 16x_i^2 + 5x_i for x_i in x),
    [0.156731,0.156731],
    (-5,5),
    (-5,5)
  )
)
