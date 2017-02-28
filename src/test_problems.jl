# See: https://en.wikipedia.org/wiki/Test_functions_for_optimization
# See: http://infinity77.net/global_optimization/test_functions.html
# See: http://al-roomi.org/benchmarks/unconstrained/n-dimensions/
test_problems = Dict(
  :rosenbrock => TestProblem(
    x -> (x[2] - x[1]^2)^2 + (x[1] - 4)^2,
    [-2.0,15.0],
    (-5,5),
    (-5,20)
  ),
  :beal => TestProblem(
    (x) -> (1.5 - x[1] + x[1]*x[2])^2 + (2.25 - x[1] + x[1]*x[2]^2)^2 + (2.625 - x[1] + x[1]*x[2]^3)^2,
    [-8.0,-8.0],
    (-10,10),
    (-10,10)
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
  )
)
