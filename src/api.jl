function instrument_problem{T}(problem::Problem{T}, calls::FunctionCalls)
  objective(x) = begin
    calls.objective += 1
    return problem.objective(x)
  end

  return Problem(
    objective,
    problem.initial_x
  )
end

function optimize{T}(method::Optimizer, problem::Problem{T})
  return optimize(method, problem, Options())
end

function optimize{T}(method::Optimizer, problem::Problem{T}, options::Options)
  iteration = 1
  converged = false
  call_state = FunctionCalls(0)
  problem = instrument_problem(problem, call_state)

  state = initial_state(method, problem, options)

  if options.callback != nothing
    options.callback(iteration, state)
  end

  while true
    converged = update_state!(method, problem, options, state)

    if options.callback != nothing
      options.callback(iteration, state)
    end

    if (converged || iteration >= options.max_iterations)
      break
    end

    iteration += 1
  end

  return Results(
    state.method_name,
    problem.initial_x,
    state.x_k,
    f(state.x_k),
    iteration,
    converged,
    options.ϵ_x,
    call_state
  )
end
