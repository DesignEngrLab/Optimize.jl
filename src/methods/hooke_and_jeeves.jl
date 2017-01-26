immutable HookeAndJeeves <: Method
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

type HookeAndJeevesState{T} <: State
  method_name::String
  n::Int
  n_k::Int
  h_k::Real
  f_k::T
  x_k::Array{T}
  x_b::Array{T}
end

function initial_state{T}(method::HookeAndJeeves, problem::Problem{T})
  return HookeAndJeevesState(
    "Hooke and Jeeves",
    length(problem.x_initial),
    1,
    method.initial_step_size,
    problem.objective(problem.x_initial),
    copy(problem.x_initial),
    copy(problem.x_initial)
  )
end

function update_state!{T}(method::HookeAndJeeves, problem::Problem{T}, state::HookeAndJeevesState)
  f, n = problem.objective, state.n
  x_k, x_b = state.x_k, state.x_b
  f_last = state.f_k

  # Evaluate a positive and a negative point in each cardinal direction
  # and update as soon as one is found
  while state.n_k <= n
    d_k = [i == state.n_k ? 1.0 : 0.0 for i in 1:n]
    state.n_k += 1

    # Arbitrarily choose the positive direction first
    copy!(x_k, x_k + state.h_k * d_k)
    state.f_k = f(x_k)

    # If the point is better, don't bother checking the other direction
    if (state.f_k <= f_last)
      return (x_k, state.f_k)
    end

    # Check the other direction
    copy!(x_k, x_k - state.h_k * d_k)
    state.f_k = f(x_k)

    # Use the point as long as it's not worse
    if (state.f_k <= f_last)
      return (x_k, state.f_k)
    end
  end

  # If the cardinal direction searches did not improve, reduce the
  # step size
  if (x_k == x_b)
    state.h_k *= method.step_reduction
  end

  # Move in an acceleration based direction
  copy!(x_k, 2x_k - x_b)
  copy!(x_b, x_k)
  state.f_k = f(x_k)
  state.n_k = 1

  # If the point is an improvement use it
  if state.f_k <= f_last
    return (x_k, state.f_k)
  end

  # Otherwise search in the cardinal directions again
  return update_state!(method, problem, state)
end

function has_converged{T}(method::HookeAndJeeves, x::Tuple{Array{T},Array{T}}, f::Tuple{T,T}, options::Options, state::HookeAndJeevesState)
  # Convergence is based on step size
  return state.h_k < method.ϵ_h
end
