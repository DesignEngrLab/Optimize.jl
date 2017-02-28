immutable ExhaustiveSearch <: Optimizer
  search_space::Union{FloatRange,Array{FloatRange,1}}
end

function ExhaustiveSearch(;
  search_space = 0:0.1:1)
  return ExhaustiveSearch(search_space)
end

type ExhaustiveSearchState{T} <: State
  method_name::String
  grid::Array{FloatRange{T},1}  # Search grid, array of ranges for each dim
  x_k::Array{T,1}               # Current search coordinate
  x_best::Array{T,1}            # Current best coord
  f_best::T                     # Value at best coord
  is_complete::Bool             # Whether every gridpoint has been evaluated
end

function initial_state{T}(method::ExhaustiveSearch, problem::Problem{T})
  n = problem.dimensions
  grid = if isa(method.search_space, Range)
    fill(method.search_space, n)
  else
    method.search_space
  end

  return ExhaustiveSearchState(
    "Exhaustive Search",
    grid,
    map(first, grid),
    zeros(n),
    Inf,
    false,
  )
end

function update_state!{T}(method::ExhaustiveSearch, problem::Problem{T}, state::ExhaustiveSearchState)
  f, n = problem.objective, problem.dimensions
  x_k = state.x_k
  grid = state.grid

  f_k = f(x_k)

  if f_k < state.f_best
    state.f_best = f_k
    copy!(state.x_best, x_k)
  end

  for i = 1:n
    if x_k[i] < last(grid[i])
      x_k[i] += step(grid[i])
      break;
    elseif i == n
      state.is_complete = true
    else
      for j = 1:i
        x_k[j] = first(grid[j])
      end
    end
  end

  return (state.x_best, state.f_best)
end

function has_converged{T}(method::ExhaustiveSearch, x::Tuple{Array{T},Array{T}}, f::Tuple{T,T}, options::Options, state::ExhaustiveSearchState)
  # There is no true 'convergence', just stop when all points
  # in the grid have been evaluated
  return state.is_complete
end