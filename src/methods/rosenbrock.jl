immutable Rosenbrock <: Optimizer
  initial_step_size::Float32
  forward_step_multiplier::Float32
  backward_step_multiplier::Float32
end

function Rosenbrock(;
  initial_step_size = 0.5,
  forward_step_multiplier = 5.0,
  backward_step_multiplier = 0.5)
  return Rosenbrock(
    initial_step_size,
    forward_step_multiplier,
    backward_step_multiplier
  )
end

type RosenbrockState{T,N}
  method_name::String
  n::Int                      # Number of design variables / search dimensions
  n_k::Int                    # Current iteration dimension
  x_k::Array{T,1}             # Current search coordinate
  f_k::T                      # Current coordinate's objective function value
  h_k::Array{T}               # Array of current step sizes for each dimension
  d_k::Array{T,N}             # Array of current search directions
  a_k::Array{T,1}             # Array of distances traveled in each direction
  trial_results::BitArray{2}  # Record of success/failures in each direction
end

function initial_state{T}(method::Rosenbrock, problem::Problem{T}, options::Options)
  n = length(problem.initial_x)
  return RosenbrockState(
    "Rosenbrock's Method",
    n,
    1,
    copy(problem.initial_x),
    problem.objective(problem.initial_x),
    fill(convert(T, method.initial_step_size), n),
    eye(n),
    zeros(problem.initial_x),
    falses(2, n)
  )
end

function update_state!{T}(method::Rosenbrock, problem::Problem{T}, options::Options, state::RosenbrockState)
  f, n = problem.objective, state.n
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

      return false
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
  h_ave = 1/n * sum(abs(a_k))
  fill!(h_k, h_ave)
  fill!(a_k, 0)

  # Convergence is based on step size
  if (h_ave < options.ϵ_f)
    return true
  end

  # Reset the success/failure state to start next stage
  fill!(trial_results, false)

  # Start directional search again
  return update_state!(method, problem, options, state)
end
