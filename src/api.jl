function instrument_problem{T}(problem::Problem{T}, calls::FunctionCalls)
  objective(x) = begin
    calls.objective += 1
    return problem.objective(x)
  end

  return Problem(
    objective,
    problem.x_initial
  )
end

function optimize{T}(method::Method, problem::Problem{T})
  return optimize(method, problem, Options())
end

function optimize{T}(method::Method, problem::Problem{T}, options::Options)
  iteration = 1
  converged = false
  x_cur, x_prev = copy(problem.x_initial), zeros(problem.x_initial)
  f_cur::T, f_prev::T = problem.objective(problem.x_initial), Inf

  if options.callback != nothing
    options.callback(0, copy(x_cur), f_cur)
  end

  # Set up automatic tallying of objective function calls
  call_state = FunctionCalls(0)
  problem = instrument_problem(problem, call_state)

  state = initial_state(method, problem)

  while true
    x_cur, f_cur = update_state!(method, problem, state)

    if options.callback != nothing
      options.callback(iteration, copy(x_cur), f_cur)
    end

    converged = has_converged(method, (x_prev, x_cur), (f_prev, f_cur), options, state)

    if (converged || iteration >= options.max_iterations)
      break
    end

    copy!(x_prev, x_cur)
    f_prev = f_cur
    iteration += 1
  end

  return Results(
    state.method_name,
    problem.x_initial,
    state.x_k,
    f(state.x_k),
    iteration,
    converged,
    options.ϵ_x,
    call_state
  )
end

function has_converged{T}(method::Method, x::Tuple{Array{T},Array{T}}, f::Tuple{T,T}, options::Options, state::State)
  return has_converged(x..., options) || has_converged(f..., options)
end

function has_converged{T}(f_cur::T, f_prev::T, options::Options)
  return f_cur - f_prev < options.ϵ_f
end

function has_converged{T}(x_cur::Array{T}, x_prev::Array{T}, options::Options)
  return norm(x_cur - x_prev) < options.ϵ_x
end
