abstract Method
abstract State

immutable Options{TCallback <: Union{Void, Function}}
  ϵ_f::Float64
  ϵ_x::Float64
  max_iterations::Int
  callback::TCallback
end

function Options(;
  ϵ_f = 1e-16,
  ϵ_x = 1e-16,
  max_iterations = 1000,
  callback = nothing)
  return Options{typeof(callback)}(
    ϵ_f,
    ϵ_x,
    max_iterations,
    callback
  )
end

immutable Problem{T}
  objective::Function
  x_initial::Array{T}
end

type FunctionCalls
  objective::Int
end

immutable Results{T}
  method_name::String
  x_initial::Array{T}
  minimizer::Array{T}
  minimum::T
  iterations::Int
  converged::Bool
  convergence_criteria::Float64
  function_calls::FunctionCalls
  elapsed_time::Real
end

function Base.show(io::IO, results::Results)
  @printf io "Optimization Results\n"
  @printf io " * Algorithm: %s\n" results.method_name
  @printf io " * Minimizer: [%s]\n" join(results.minimizer, ",")
  @printf io " * Minimum: %e\n" results.minimum
  @printf io " * Iterations: %d\n" results.iterations
  @printf io " * Converged: %s\n" results.converged ? "true" : "false"
  @printf io " * Objective Function Calls: %d\n" results.function_calls.objective
  @printf io " * Elapsed time: %f seconds" results.elapsed_time
  return
end
