abstract Optimizer
abstract State

immutable Options
  ϵ_f::Float64
  ϵ_x::Float64
  max_iterations::Int
  store_trace::Bool
end

function Options(;
  ϵ_f = 1e-16,
  ϵ_x = 1e-16,
  max_iterations = 1000,
  store_trace = false)
  return Options(
    ϵ_f,
    ϵ_x,
    max_iterations,
    store_trace
  )
end

immutable Problem{T}
  objective::Function
  x_initial::Array{T}
  dimensions::Int
end

function Problem{T}(objective::Function, x_initial::Array{T})
   Problem(objective, x_initial, length(x_initial))
 end

function Problem(objective::Function, dimensions::Int)
   Problem(objective, zeros(dimensions), dimensions)
 end

immutable SearchTrace
  evaluations::Array{Tuple}
  iterations::Array{Tuple}
end

function SearchTrace()
  SearchTrace([], [])
end

immutable Results{T}
  method_name::String
  x_initial::Array{T}
  minimizer::Array{T}
  minimum::T
  iterations::Int
  converged::Bool
  convergence_criteria::Float64
  elapsed_time::Real
  trace::Union{Void, SearchTrace}
end

immutable TestProblem{T}
  f::Function
  x_initial::Array{T}
  x_range::Tuple{Real, Real}
  y_range::Tuple{Real, Real}
end

function Base.show(io::IO, results::Results)
  @printf io "Optimization Results\n"
  @printf io " * Algorithm: %s\n" results.method_name
  @printf io " * Minimizer: [%s]\n" join(results.minimizer, ",")
  @printf io " * Minimum: %e\n" results.minimum
  @printf io " * Iterations: %d\n" results.iterations
  @printf io " * Converged: %s\n" results.converged ? "true" : "false"
  @printf io " * Elapsed time: %f seconds" results.elapsed_time
  if results.trace != nothing
    @printf io "\n * Objective Function Calls: %d" length(results.trace.evaluations)
  end
  return
end
