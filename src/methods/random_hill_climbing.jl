immutable RandomHillClimbing <: Optimizer
  step_sizes::Array{Real,1}
  max_failed_neighbors::Int
end

function RandomHillClimbing(;
  step_sizes = [0.1],
  max_failed_neighbors = 1e10)
  return RandomHillClimbing(
    step_sizes,
    max_failed_neighbors
  )
end

type RandomHillClimbingState{T} <: State
  method_name::String
  x_k::Array{T,1}                # Current search coordinate
  f_k::T                         # Current coordinate's objective function value
  x_n::Array{T,1}                # Trial point
  failed_neighbors::Array{Int,1} # List of attempted neighbor coords
  max_failed_neighbors::Int      # Maximum number of failed neighbors before search stops
  last_neighbor::Int             # Last neighbor visited
end

function initial_state{T}(method::RandomHillClimbing, problem::Problem{T})
  return RandomHillClimbingState(
    "Random Hill Climbing",
    copy(problem.x_initial),
    problem.objective(problem.x_initial),
    zeros(problem.x_initial),
    zeros(Int, 1),
    min(method.max_failed_neighbors, 2*problem.dimensions*length(method.step_sizes) - 1),
    -1
  )
end

function update_state!{T}(method::RandomHillClimbing, problem::Problem{T}, iteration::Int, state::RandomHillClimbingState)
  f, n = problem.objective, problem.dimensions
  @fields x_k, x_n, f_k = state
  @fields failed_neighbors, max_failed_neighbors, last_neighbor = state
  step_sizes = method.step_sizes
  n_steps = length(step_sizes)

  # Reverse the direction of the last neighbor
  last_neighbor += iseven(last_neighbor) ? 1 : -1

  empty!(failed_neighbors)

  while length(failed_neighbors) < max_failed_neighbors
    # Choose a random number representing dimension, step size, and direction
    neighbor = rand(0:2*n*n_steps-1)

    # Don't re-try a neighbor, or the last coord
    if neighbor == last_neighbor || neighbor ∈ failed_neighbors
      continue
    end

    # Move the trial coord's selected dimension
    copy!(x_n, x_k)
    dim = div(neighbor, 2n_steps) + 1
    dir = iseven(neighbor) ? 1 : -1
    step = mod(div(neighbor, 2), n_steps) + 1
    x_n[dim] += dir*step_sizes[step]

    # Evaluate the trial point
    f_n = f(x_n)

    # If the point is better, use the point
    if f_n < f_k
      copy!(x_k, x_n)
      state.f_k = f_n
      state.last_neighbor = neighbor
      break
    else
      push!(failed_neighbors, neighbor)
    end
  end

  return (x_k, state.f_k)
end

function has_converged{T}(method::RandomHillClimbing, x::Tuple{Array{T},Array{T}}, f::Tuple{T,T}, options::Options, state::RandomHillClimbingState)
  # Convergence is simply when the max number of attempted neighboring
  # coordinates is reached
  return length(state.failed_neighbors) == state.max_failed_neighbors
end
