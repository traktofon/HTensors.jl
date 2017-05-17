module HTensors

abstract type AbstractTensor{T} end

export HTensorNode
export isleaf, nmode, shape, array

include("ops.jl")
include("indexing.jl")
include("htensor.jl")

end
