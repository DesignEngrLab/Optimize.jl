immutable HookeAndJeeves <: Optimizer
  initial_step_size::Real
  step_reduction::Real
  ϵ_h::Real
end

function HookeAndJeeves(;
  initial_step_size = 0.5,
  step_reduction = 0.5,
  ϵ_h = 1e-8)
  return HookeAndJeeves(
    initial_step_size,
    step_reduction,
    ϵ_h
  )
end

type HookeAndJeevesState{T,N} <: State
  method_name::String
  n_k::Int
  h_k::Real
  f_k::T
  x_k::Array{T}
  x_b::Array{T}
  d_k::Array{T,N}
end

function initial_state{T}(method::HookeAndJeeves, problem::Problem{T})
  n = problem.dimensions
  return HookeAndJeevesState(
    "Hooke and Jeeves",
    1,
    method.initial_step_size,
    problem.objective(problem.x_initial),
    copy(problem.x_initial),
    copy(problem.x_initial),
    eye(n)
  )
end

function update_state!{T}(method::HookeAndJeeves, problem::Problem{T}, state::HookeAndJeevesState)
  f, n = problem.objective, problem.dimensions
  x_k, x_b = state.x_k, state.x_b

  # Evaluate a positive and a negative point in each cardinal direction
  # and update as soon as one is found
  while state.n_k <= n
    # Arbitrarily choose the positive direction first
    for dir in [1,-1]
      x_trial = x_k + dir * state.h_k * state.d_k[:,state.n_k]
      f_trial = f(x_trial)

      # If the point is better, immediately go there
      if (f_trial <= state.f_k)
        copy!(x_k, x_trial)
        state.f_k = f_trial
        state.n_k += 1
        return (x_k, state.f_k)
      end
    end

    state.n_k += 1
  end

  # If the cardinal direction searches did not improve, reduce the
  # step size
  if (x_k == x_b)
    state.h_k *= method.step_reduction
  end

  # Attempt to move in an acceleration based direction
  x_trial = 2x_k - x_b
  f_trial = f(x_trial)
  copy!(x_b, x_k)
  state.n_k = 1

  # If the point is an improvement use it
  if f_trial <= state.f_k
    copy!(x_k, x_trial)
    state.f_k = f_trial
    return (x_k, state.f_k)
  end

  # Otherwise search in the cardinal directions again
  return update_state!(method, problem, state)
end

function has_converged{T}(method::HookeAndJeeves, x::Tuple{Array{T},Array{T}}, f::Tuple{T,T}, options::Options, state::HookeAndJeevesState)
  # Convergence is based on step size
  return state.h_k < method.ϵ_h
end
