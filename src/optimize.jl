module Optimize
  include("types.jl")
  include("api.jl")

  include("methods/cyclic_coordinate_search.jl")
  include("methods/hooke_and_jeeves.jl")
  include("methods/line_search.jl")

  export
    optimize
    Problem
    Options
    CyclicCoordinateSearch
    HookeAndJeeves
end
