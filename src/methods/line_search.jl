import Optim

function lineSearch(f::Function)
  # TODO: figure out how to automatically calculate these bounds
  result = Optim.optimize(f, -2.0, 2.0, Optim.GoldenSection())

  return (Optim.minimizer(result), Optim.minimum(result))
end
