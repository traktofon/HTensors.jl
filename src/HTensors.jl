module HTensors

abstract type AbstractTensor{T} end

export HTensorNode, HTensorEvaluator
export isleaf, nmode, ncoeffs, shape, fulldim, array, getelt, getelts
export collapse
export preorder, postorder

include("ops.jl")
include("indexing.jl")
include("htensor.jl")
include("collapse.jl")
include("evaluator.jl")
include("ordering.jl")

end
