module Opt
  import Optim

  max_iterations = 10000

  type MaximumIterationsExceededException <: Exception end

  function cyclicCoordinateSearch(f::Function, x_0::Array{Float64}, ϵ::Float64 = 0.0005; use_acceleration = true)
    iteration = 1
    n = length(x_0)
    n_k = 1
    x_k = x_0
    dir = zeros(Float64, n)

    while true
      x_last = x_k

      # Determine the search direction: cycle through each coordinate direction
      # once, then use an "acceleration" direction constructed using the first
      # and last points in each cycle
      if (n_k <= n)
        # Keep track of the first coordinate in each cycle in order to
        # calculate the acceleration direction
        if (n_k == 1)
          x_acc = x_k
        end

        for i = 1:n
          dir[i] = i == n_k ? 1.0 : 0.0
        end

        n_k += 1
      else
        dir = x_k - x_acc
        n_k = 1

        if (!use_acceleration)
          continue
        end
      end

      # Find minimizing distance along search direction
      α_k = lineSearch(x -> f(x_k + x * dir))

      # Update the minimizer to the new minimum
      x_k = x_k + α_k * dir

      # Check for convergence
      if (norm(x_k - x_last) < ϵ)
        break
      end

      if (iteration >= max_iterations)
        throw(MaximumIterationsExceededException())
      end

      iteration += 1
    end

    return x_k
  end

  function lineSearch(f::Function)
    result = Optim.optimize(f, -10.0, 10.0)

    return Optim.minimizer(result)
  end
end
