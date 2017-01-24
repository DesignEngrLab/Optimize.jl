using Optimize
using Plots
plotlyjs()

x_0 = [0.0,0.0]
f(x) = (x[2] - x[1]^2)^2 + (x[1] - 4)^2

x = -5:0.1:5
y = -5:0.1:20
X = repmat(x',length(y),1)
Y = repmat(y,1,length(x))
Z = map((x1, x2) -> f([x1, x2]),X,Y)
p = contour(x,y,Z)
plot(p)

points = [x_0]
add_point(i, state) = push!(points, copy(state.x_k))

method = CyclicCoordinateSearch(use_acceleration = false)
prob = Problem(f, x_0)
opts = Options(callback = add_point)

result = optimize(method, prob, opts)
println(result)

plot!([(x[1], x[2]) for x in points])
gui()
