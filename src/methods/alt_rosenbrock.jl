immutable AltRosenbrock <: Method
  initial_step_size::Real
  forward_step_multiplier::Real
  backward_step_multiplier::Real
  ϵ_h::Real
end

function AltRosenbrock(;
  initial_step_size = 0.5,
  forward_step_multiplier = 5.0,
  backward_step_multiplier = 0.5,
  ϵ_h = 1e-8)
  return AltRosenbrock(
    initial_step_size,
    forward_step_multiplier,
    backward_step_multiplier,
    ϵ_h
  )
end

type AltRosenbrockState{T,N} <: State
  method_name::String
  n::Int                      # Number of design variables / search dimensions
  n_k::Int                    # Current iteration dimension
  x_k::Array{T,1}             # Current search coordinate
  f_k::T                      # Current coordinate's objective function value
  h_k::Array{T}               # Array of current step sizes for each dimension
  h_ave::T                    # Starting step size for the current stage
  d_k::Array{T,N}             # Array of current search directions
  a_k::Array{T,1}             # Array of distances traveled in each direction
  trial_results::BitArray{1}  # Record of success/failures in each direction
end

function initial_state{T}(method::AltRosenbrock, problem::Problem{T})
  n = length(problem.x_initial)
  return AltRosenbrockState(
    "Alternative Rosenbrock's Method",
    n,
    1,
    copy(problem.x_initial),
    problem.objective(problem.x_initial),
    fill(convert(T, method.initial_step_size), n),
    method.initial_step_size,
    eye(n),
    zeros(problem.x_initial),
    falses(n)
  )
end

function update_state!{T}(method::AltRosenbrock, problem::Problem{T}, state::AltRosenbrockState)
  f, n = problem.objective, state.n
  x_k, h_k, a_k, d_k = state.x_k, state.h_k, state.a_k, state.d_k
  trial_results = state.trial_results

  while state.n_k <= n
    while true
      x_trial = x_k + h_k[state.n_k] * d_k[:,state.n_k]
      f_trial = f(x_trial)

      if (f_trial <= state.f_k)
        # Objective improved, use the coordinate as the next x_k
        copy!(x_k, x_trial)
        state.f_k = f_trial

        # Store the distance traveled in order to update h_ave later
        a_k[state.n_k] += h_k[state.n_k]

        # Record a success in the positive direction
        trial_results[h_k[state.n_k] > 0 ? 1 : 2] = true

        # Take a larger step in the next trial for this direction
        h_k[state.n_k] *= method.forward_step_multiplier

        # If there's been both a positive and negative success, start searching next direction
        if (all(trial_results))
          fill!(trial_results, false)
          state.n_k += 1
        end

        return (x_k, state.f_k)
      else
        # Reduce the step size next iteration
        h_k[state.n_k] *= -method.backward_step_multiplier
      end
    end
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
  state.h_ave = 1/n * sum(abs(a_k))
  fill!(h_k, state.h_ave)
  fill!(a_k, 0)

  # Reset the success state to start next stage
  fill!(trial_results, false)
  state.n_k = 1

  # Start directional search again
  return update_state!(method, problem, state)
end

function has_converged{T}(method::AltRosenbrock, x::Tuple{Array{T},Array{T}}, f::Tuple{T,T}, options::Options, state::AltRosenbrockState)
  # Convergence is based on step size
  return state.h_ave < method.ϵ_h
end
