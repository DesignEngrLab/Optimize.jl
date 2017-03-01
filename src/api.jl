function optimize{T}(method::Optimizer, problem::Problem{T})
  return optimize(method, problem, Options())
end

function optimize{T}(method::Optimizer, problem::Problem{T}, options::Options)
  iteration = 1
  converged = false
  trace = nothing
  x_cur, x_prev = copy(problem.x_initial), zeros(problem.x_initial)
  f_cur::T, f_prev::T = problem.objective(problem.x_initial), Inf

  if options.store_trace
    # Set up automatic tracking of objective function evaluations
    trace = create_trace(method)
    problem = setup_trace(problem, trace)
    trace!(trace, 0, x_cur, f_cur)
  end

  # Start timing now
  tic()

  state = initial_state(method, problem)

  while true
    x_cur, f_cur = update_state!(method, problem, iteration, state)

    if options.store_trace
      trace!(method, trace, iteration, x_cur, f_cur, options, state)
    end

    converged = has_converged(method, (x_prev, x_cur), (f_prev, f_cur), options, state)

    if (converged || iteration >= options.max_iterations)
      break
    end

    copy!(x_prev, x_cur)
    f_prev = f_cur
    iteration += 1
  end

  elapsed_time = toq()

  return Results(
    state.method_name,
    problem.x_initial,
    x_cur,
    f_cur,
    iteration,
    converged,
    options.ϵ_x,
    elapsed_time,
    trace
  )
end

function create_trace(method::Optimizer)
  SearchTrace()
end

function setup_trace(problem::Problem, trace::SearchTrace)
  objective(x) = begin
    value = problem.objective(x)
    push!(trace.evaluations, (copy(x), value))
    return value
  end

  return Problem(objective, problem.x_initial)
end

function trace!{T}(method::Optimizer, trace::SearchTrace, i::Int, x::Array{T}, f::T, options::Options, state::State)
  trace!(trace, i, x, f)
end

function trace!{T}(trace::SearchTrace, i::Int, x::Array{T}, f::T)
  push!(trace.iterations, (copy(x), f))
end

function has_converged{T}(method::Optimizer, x::Tuple{Array{T},Array{T}}, f::Tuple{T,T}, options::Options, state::State)
  return has_converged(x..., options) || has_converged(f..., options)
end

function has_converged{T}(f_cur::T, f_prev::T, options::Options)
  return f_cur - f_prev < options.ϵ_f
end

function has_converged{T}(x_cur::Array{T}, x_prev::Array{T}, options::Options)
  return norm(x_cur - x_prev) < options.ϵ_x
end
