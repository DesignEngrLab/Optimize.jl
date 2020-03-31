function plot_range(f, x, y, n = 100, l = 50)
  x = range(y[1], y[2], length = n)
  p = contour(x, y, (x, y) -> f([x, y]); levels = l)
  plot!(p)
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
