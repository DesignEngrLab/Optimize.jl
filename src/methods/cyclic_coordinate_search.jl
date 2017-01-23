immutable CyclicCoordinateSearch <: Optimizer
  use_acceleration::Bool
end

function CyclicCoordinateSearch(; use_acceleration = true)
  return CyclicCoordinateSearch(use_acceleration)
end

type CyclicCoordinateSearchState{T}
  method_name::String
  n::Int
  n_k::Int
  x_k::Array{T}
  x_last::Array{T}
  x_acc::Array{T}
  dir::Array{T}
end

function initial_state{T}(method::CyclicCoordinateSearch, problem::Problem{T}, options::Options)
  n = length(problem.initial_x)
  return CyclicCoordinateSearchState(
    "Cyclic Coordinate Search",
    n,
    1,
    copy(problem.initial_x),
    Array{T}(n),
    Array{T}(n),
    Array{T}(n)
  )
end

function update_state!{T}(method::CyclicCoordinateSearch, problem::Problem{T}, options::Options, state::CyclicCoordinateSearchState)
  n, n_k = state.n, state.n_k
  x_k, x_last, x_acc, dir = state.x_k, state.x_last, state.x_acc, state.dir

  # Keep track of last iteration's coordinate
  copy!(x_last, x_k)

  # Determine the search direction: cycle through each coordinate direction
  # once, then use an "acceleration" direction constructed using the first
  # and last points in each cycle
  if (n_k <= n)
    # Keep track of the first coordinate in each cycle in order to
    # calculate the acceleration direction
    if (n_k == 1)
      copy!(x_acc, x_k)
    end

    for i = 1:n
      dir[i] = i == n_k ? 1.0 : 0.0
    end

    # If acceleration isn't used, reset the cycle
    if (!method.use_acceleration && n_k == n)
      state.n_k = 1
    else
      state.n_k += 1
    end
  else
    copy!(dir, x_k - x_acc)
    state.n_k = 1
  end

  # Find minimizing distance along search direction
  α_k = lineSearch(x -> problem.objective(x_k + x * dir))

  # Update the minimizer to the new minimum
  copy!(x_k, x_k + α_k * dir)

  # Check for convergence
  converged = norm(x_k - x_last) < options.ϵ_x

  return converged
end
