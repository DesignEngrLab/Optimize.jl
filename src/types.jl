abstract type Optimizer end
abstract type State end

struct Options
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

struct Problem{T}
  objective::Function
  x_initial::Array{T}
  dimensions::Int
end

function Problem(objective::Function, x_initial::Array{T}) where {T<:Number}
   Problem(objective, x_initial, length(x_initial))
 end

function Problem(objective::Function, dimensions::Int)
   Problem(objective, zeros(dimensions), dimensions)
 end

struct SearchTrace
  evaluations::Array{Tuple}
  iterations::Array{Tuple}
end

function SearchTrace()
  SearchTrace([], [])
end

struct Results{T} 
  method_name::String
  x_initial::Array{T}
  minimizer::Array{T}
  minimum::T
  iterations::Int
  converged::Bool
  convergence_criteria::Float64
  elapsed_time::Real
  trace::Union{Nothing, SearchTrace}
end

struct TestProblem{T} 
  f::Function
  x_initial::Array{T}
  x_range::Tuple{Real, Real}
  y_range::Tuple{Real, Real}
end

function Base.show(io::IO, results::Results)
  @show io "Optimization Results\n"
  @show io " * Algorithm: %s\n" results.method_name
  @show io " * Minimizer: [%s]\n" join(results.minimizer, ",")
  @show io " * Minimum: %e\n" results.minimum
  @show io " * Iterations: %d\n" results.iterations
  @show io " * Converged: %s\n" results.converged ? "true" : "false"
  @show io " * Elapsed time: %f seconds" results.elapsed_time
  if results.trace != nothing
    @show io "\n * Objective Function Calls: %d" length(results.trace.evaluations)
  end
  return
end
