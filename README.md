# Optimize.jl

Optimization methods implemented in [Julia](http://julialang.org/). Architecture heavily inspired by the [Optim.jl package](https://github.com/JuliaOpt/Optim.jl).

Currently 4 direct search methods are implemented:
- [Cyclic Coordinate Search](https://en.wikipedia.org/wiki/Coordinate_descent)
- Hooke and Jeeves
- [Rosenbrock's Method](http://www.applied-mathematics.net/optimization/rosenbrock.html)
- Exhaustive Search

## Installation

This package is not published, since it is a learning project and doesn't provide anything that doesn't already exist in the plethora of [Julia packages](http://pkg.julialang.org/). To use these methdods, clone the git repository:

```sh
> git clone git@github.com:slindberg/Optimize.jl.git
```

Currently the library's only dependency is the `Optim` package, used for line search. In the Juila REPL:

```sh
> Pkg.add("Optim")
```

## Usage

The only public method is `optimize` which accepts two structs:

```julia
function optimize(method::Method, problem::Problem)
```

The `Problem` struct defines the optimization problem:

```julia

# Initial coordinate, defines the problem's dimensionality
x_0 = [0.0,0.0]

# The problem's objective function, accepts a single indexable
# object and returns the objective's value at that coordinate
f(x) = (x[2] - x[1]^2)^2 + (x[1] - 4)^2

problem = Problem(f, x_0)
```

The `Method` struct identifies the method to use to solve the optimization problem. Each method has a set of configuration arguments:

- Cyclic Coordinate Search

  ```julia
  method = CyclicCoordinateSearch(
    use_acceleration = false        # Whether or not to use an 'acceleration' direction
  )
  ```

- Hooke and Jeeves
  ```julia
  method = HookeAndJeeves(
    initial_step_size = 0.5,        # Initial distance to travel in each coordinate direction
    step_reduction = 0.5,           # Factor by which to reduce the step size
    ϵ_h = 1e-8                      # Minimum step size, used to determine convergence
  )
  ```

- Rosenbrock's Method
  ```julia
  method = Rosenbrock(
    initial_step_size = 0.5,        # Initial distance to travel in each direction
    forward_step_multiplier = 5.0,  # Step size expansion factor, should be > 1
    backward_step_multiplier = 0.5, # Step size reduction factor, should be > 0 and < 1
    ϵ_h = 1e-8                      # Minimum step size, used to determine convergence
  )
  ```

- Exhaustive Search
  ```julia
  method = ExhaustiveSearch(
    search_space = 0:0.1:1          # Single range or array of ranges defining search grid
  )
  ```

An optional argument to `optimize` provides global search options:

```julia
function optimize(method::Method, problem::Problem, options::Options)
```

The `Options` struct takes

```julia
options = Options(
  ϵ_f = 1e-16,            # Objective function convergence criteria
  ϵ_x = 1e-16,            # Minimizer convergence criteria
  max_iterations = 1000,  # Maximum number of iterations before search is stopped
  callback = nothing      # Optional callback that is invoked every search iteration
)
```

The optional callback is invoked with three parameters:

```julia
function callback(iteration, x_current, f_current)
  # ...
end
```

## Examples

The [`examples/` directory](https://github.com/slindberg/Optimize.jl/tree/master/examples) has examples showing how to use this package and plot results. Plotting uses the [`Plots` package](https://juliaplots.github.io), which you will need to install in addition to whichever plotting backend you choose.

## Tests

Nope, this is a quick and dirty learning project.
