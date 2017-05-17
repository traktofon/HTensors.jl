module HTensors

abstract type AbstractTensor{T} end

export HTensorNode
export isleaf, nmode, shape, array, get

include("ops.jl")
include("indexing.jl")
include("htensor.jl")

end
