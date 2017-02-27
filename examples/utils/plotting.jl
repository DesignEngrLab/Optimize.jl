function plot_range(f, x, y, step_size = 0.1)
  x = x[1]:step_size:x[2]
  y = y[1]:step_size:y[2]
  X = repmat(x', length(y), 1)
  Y = repmat(y, 1, length(x))
  Z = map((x1, x2) -> f([x1, x2]),X,Y)
  p = contour(x,y,Z)
  plot!(p)
end

function plot_points(points, show_line = false)
  plot!([tuple(pt[1]...) for pt in points ];
    # aspect_ratio = 1,
    markershape = :circle,
    markersize = 2,
    markerstrokecolor = nothing,
    linewidth = show_line ? 1 : 0
  )
end
