using Optimize
using Plots
include("utils/plotting.jl")
include("utils/problems.jl")

# Replace this with whichever plotting backend you prefer
plotlyjs()

# Choose an example problem, see utils/problems.jl
example = example_problems[:rosenbrock]
x_initial = [-0.0,0.0]

# Plot the objective function contours
plot_range(example.f, example.x_range, example.y_range)

# Keep track of each iteration's search coordinates
coords = []
add_coord(k, x_k, f_k) = push!(coords, x_k)

# Construct the search parameters
prob = Problem(example.f, x_initial)
opts = Options(callback = add_coord)

# Run the first search
method = Rosenbrock()
result = optimize(method, prob, opts)
println(result)
plot_coords(copy(coords))

# Run the second search
empty!(coords)
method = AltRosenbrock()
result = optimize(method, prob, opts)
println(result)
plot_coords(copy(coords))

gui()
