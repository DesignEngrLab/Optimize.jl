
function plot_range(f, x, y)
  X = repmat(x',length(y),1)
  Y = repmat(y,1,length(x))
  Z = map((x1, x2) -> f([x1, x2]),X,Y)
  p = contour(x,y,Z)
  plot(p)
end

function plot_coords(coords)
  plot!([(x[1], x[2]) for x in coords];
    # aspect_ratio=1,
    markershape=:circle,
    markersize=2,
    markerstrokecolor=nothing
  )
end
