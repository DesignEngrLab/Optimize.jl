using Optimize
using Plots
include("utils/plotting.jl")
include("utils/problems.jl")

# Replace this with whichever plotting backend you prefer
plotlyjs()

# Choose an example problem, see utils/problems.jl
example = example_problems[:easom]

# Plot the objective function contours
plot_range(example.f, example.x_range, example.y_range)

# Keep track of each iteration's search coordinates
coords = []
add_coord(k, x_k, f_k) = push!(coords, x_k)

# Construct the search parameters
method = Rosenbrock()
prob = Problem(example.f, example.x_initial)
opts = Options(callback = add_coord)

# Run the search
result = optimize(method, prob, opts)

# Print the results
println(result)

# Plot the results
plot_coords(coords)
gui()
