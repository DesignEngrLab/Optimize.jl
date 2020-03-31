using LinearAlgebra

struct Rosenbrock <: Optimizer
  initial_step_size::Real
  forward_step_multiplier::Real
  backward_step_multiplier::Real
  ϵ_h::Real
end

function Rosenbrock(;
  initial_step_size = 0.5,
  forward_step_multiplier = 5.0,
  backward_step_multiplier = 0.5,
  ϵ_h = 1e-8)
  return Rosenbrock(
    initial_step_size,
    forward_step_multiplier,
    backward_step_multiplier,
    ϵ_h
  )
end

mutable struct RosenbrockState{T,N} <: State where{T<:Number, N<:Integer}
  method_name::String
  n_k::Int                    # Current iteration dimension
  x_k::Array{T,1}             # Current search coordinate
  f_k::T                      # Current coordinate's objective function value
  h_k::Array{T}               # Array of current step sizes for each dimension
  h_ave::T                    # Starting step size for the current stage
  d_k::Array{T,N}             # Array of current search directions
  a_k::Array{T,1}             # Array of distances traveled in each direction
  trial_results::BitArray{2}  # Record of success/failures in each direction
end

function initial_state(method::Rosenbrock, problem::Problem{T}) where {T<:Number}
  n = problem.dimensions
  return RosenbrockState(
    "Rosenbrock's Method",
    1,
    copy(problem.x_initial),
    problem.objective(problem.x_initial),
    fill(convert(T, method.initial_step_size), n),
    method.initial_step_size,
    Matrix{T}(I,n,n),
    zeros(T, size(problem.x_initial)),
    falses(2, n)
  )
end

function update_state!(method::Rosenbrock, problem::Problem{T}, iteration::Int, state::RosenbrockState) where{T<:Number}
  f, n = problem.objective, problem.dimensions
  x_k, h_k, a_k, d_k = state.x_k, state.h_k, state.a_k, state.d_k
  trial_results = state.trial_results
  
  while !all(trial_results)
    x_trial = x_k + h_k[state.n_k] * d_k[:,state.n_k]
    f_trial = f(x_trial)

    if (f_trial <= state.f_k)
      # Objective improved, use the coordinate as the next x_k
      copy!(x_k, x_trial)
      state.f_k = f_trial

      # Store the distance traveled in order to update h_ave later
      a_k[state.n_k] += h_k[state.n_k]

      # Record a success in the current direction
      trial_results[1, state.n_k] = true

      # Take a larger step in the next trial for this direction
      h_k[state.n_k] *= method.forward_step_multiplier

      return (x_k, state.f_k)
    else
      # Record a failure in the current direction
      trial_results[2, state.n_k] = true

      # Reduce the step size next iteration
      h_k[state.n_k] *= -method.backward_step_multiplier
    end

    # Start next trial in the next direction
    state.n_k = state.n_k == n ? 1 : state.n_k + 1
  end

  # Update the direction vectors to align with the average distance travelled
  for i = 1:n
    d_k[:,i] = sum(a_k[j] * d_k[:,j] for j in i:n)
  end

  # Orthogonalize the direction vectors using the Gram-Schmidt process
  for i = 1:n
    d_k[:,i] /= norm(d_k[:,i])
    for j = (i+1):n
      d_k[:,j] -= dot(d_k[:,j], d_k[:,i]) * d_k[:,i]
    end
  end

  # Start the next stage with a step size based on the last distance travelled
  state.h_ave = 1/n * sum(abs.(a_k))
  fill!(h_k, state.h_ave)
  fill!(a_k, 0)

  # Reset the success/failure state to start next stage
  fill!(trial_results, false)

  # Start directional search again
  return update_state!(method, problem, iteration, state)
end

function has_converged(method::Rosenbrock, x::Tuple{Array{T},Array{T}}, f::Tuple{T,T}, options::Options, state::RosenbrockState) where {T<:Number}
  # Convergence is based on step size
  return state.h_ave < method.ϵ_h
end
