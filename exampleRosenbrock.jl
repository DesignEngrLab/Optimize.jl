includePath = "src\\optimize.jl"
# the following line converts the relative path to absolute. This is to get around
# a bug in Julia-VSCode, but the fix is not likely far off (https://github.com/julia-vscode/julia-vscode/issues/1080)
includePath = joinpath(@__DIR__, includePath)
#####
include(includePath)
using .Optimize
using Plots, LinearAlgebra
includePath = "utils\\plotting.jl"
#### again, temp fix
includePath = joinpath(@__DIR__, includePath)
#####
include(includePath)

# Replace this with whichever plotting backend you prefer
#plotlyjs()

# Choose an example problem, see src/test_problems.jl
example = test_problems[:easom]
f, x_0 = example.f, example.x_initial

# Construct the search parameters
method = Rosenbrock()
prob = Problem(f, x_0)
opts = Options(store_trace = true)

# Run the search
result = optimize(method, prob, opts)

# Print the result
println(result)

# Plot the objective function contours and results
X, Y = example.x_range, example.y_range
plot_range(f, X, Y)
plot_points(result.trace.evaluations)
plot_points(result.trace.iterations, true)
plot!(xlims = X, ylims = Y)
gui()
