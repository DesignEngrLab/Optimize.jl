

includePath = "src\\optimize.jl"
# the following line converts the relative path to absolute. This is to get around
# a bug in Julia-VSCode, but the fix is not likely far off (https://github.com/julia-vscode/julia-vscode/issues/1080)
includePath = joinpath(@__DIR__, includePath)
#####
include(includePath)
using .Optimize
using Plots, LinearAlgebra

function contour2D(testProblem::Optimize.TestProblem)
    x = range(testProblem.x_range[1],testProblem.x_range[2],length=101)
    y = range(testProblem.y_range[1],testProblem.y_range[2],length=101)
    f = testProblem.f
    p = contour(x, y, (x, y) -> f([x, y]), levels = 150)
  end
  
  function plot_points(points, show_line = false)
    plot!([tuple(pt[1]...) for pt in points ];
      # aspect_ratio = 1,
      markershape = :circle,
      markersize = 2,
      markerstrokecolor = nothing,
      linewidth = show_line ? 1 : 0,
      legend = false
    )
  end

# Replace this with whichever plotting backend you prefer
gr()

# Choose an example problem, see src/test_problems.jl
example = test_problems[:booth]
f, x_0 = example.f, example.x_initial
plot(contour2D(example))
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

plot_points(result.trace.evaluations)
plot_points(result.trace.iterations, true)
plot!(xlims = X, ylims = Y)
gui()
