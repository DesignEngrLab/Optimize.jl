immutable HookeAndJeeves <: Optimizer
  initial_step_size::Float32
  step_reduction::Float32
end

function HookeAndJeeves(;
  initial_step_size = 0.5,
  step_reduction = 0.5)
  return HookeAndJeeves(initial_step_size, step_reduction)
end

type HookeAndJeevesState{T}
  method_name::String
  n::Int
  n_k::Int
  h_k::Float32
  f_k::T
  x_k::Array{T}
  x_b::Array{T}
end

function initial_state{T}(method::HookeAndJeeves, problem::Problem{T}, options::Options)
  return HookeAndJeevesState(
    "Hooke and Jeeves",
    length(problem.initial_x),
    1,
    method.initial_step_size,
    problem.objective(problem.initial_x),
    copy(problem.initial_x),
    copy(problem.initial_x)
  )
end

function update_state!{T}(method::HookeAndJeeves, problem::Problem{T}, options::Options, state::HookeAndJeevesState)
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
      return false
    end

    # Check the other direction
    copy!(x_k, x_k - state.h_k * d_k)
    state.f_k = f(x_k)

    # Use the point as long as it's not worse
    if (state.f_k <= f_last)
      return false
    end
  end

  # If the cardinal direction searches did not improve, reduce the
  # step size
  if (x_k == x_b)
    state.h_k *= method.step_reduction

    # Convergence is based on a minimum step
    if (state.h_k < options.ϵ_f)
      return true
    end
  end

  # Move in an acceleration based direction
  copy!(x_k, 2x_k - x_b)
  copy!(x_b, x_k)
  state.f_k = f(x_k)
  state.n_k = 1

  # If the point isn't an improvement don't use it, instead search
  # in the cardinal directions again
  return state.f_k <= f_last ? false : update_state!(method, problem, options, state)
end
