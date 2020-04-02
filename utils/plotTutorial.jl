println("plotting")

using Plots
gr()
p=plot(rand(10))
display(p)
plot!(p, rand(10))
gui()
println("completed")
sleep(10)
