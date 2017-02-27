using Optimize
using Plots
include("utils/plotting.jl")

# Replace this with whichever plotting backend you prefer
plotlyjs()

# Choose an example problem, see src/test_problems.jl
example = test_problems[:easom]
f, x_0 = example.f, example.x_initial

# Construct the search parameters
method = Rosenbrock()
prob = Problem(f, x_0)
opts = Options(store_trace = true)

# Run the search
result = optimize(method, prob, opts)

# Print the results
println(result)

# Plot the objective function contours and results
X, Y = example.x_range, example.y_range
plot_range(f, X, Y)
plot_points(result.trace.evaluations)
plot_points(result.trace.iterations, true)
plot!(xlims = X, ylims = Y)
gui()
