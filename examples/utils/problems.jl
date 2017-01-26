# See: https://en.wikipedia.org/wiki/Test_functions_for_optimization
example_problems = Dict(
  :rosenbrock => ExampleProblem(
    x -> (x[2] - x[1]^2)^2 + (x[1] - 4)^2,
    [-2.0,15.0],
    -5:0.1:5,
    -5:0.1:20
  ),
  :beal => ExampleProblem(
    (x) -> (1.5 - x[1] + x[1]*x[2])^2 + (2.25 - x[1] + x[1]*x[2]^2)^2 + (2.625 - x[1] + x[1]*x[2]^3)^2,
    [-8.0,-8.0],
    -10:0.1:10,
    -10:0.1:10
  ),
  :booth => ExampleProblem(
    x -> (x[1] + 2x[2] - 7)^2 + (2x[1] + x[2] - 5)^2,
    [-8.0,-8.0],
    -10:0.1:10,
    -10:0.1:10
  ),
  :easom => ExampleProblem(
    x -> -cos(x[1])*cos(x[2])*exp(-((x[1] - π)^2 + (x[2] - π)^2)),
    [-3.5,-8.0],
    -10:0.1:10,
    -10:0.1:10
  )
)
