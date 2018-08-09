using Base.Test
using HTensors
using BenchmarkTools

include("make.jl")

u1 = rand(10,4)
u2 = rand(9,6)
u3 = rand(8,3)
u4 = rand(11,4)
u12 = rand(4,6,7)
u34 = rand(3,4,5)
u1234 = rand(7,5,1)

t1234 = make4(u1,u2,u3,u4,u12,u34,u1234)
@test nmode(t1234) == 4
@test shape(t1234) == [10,9,8,11]

a1234 = array(t1234)
@test size(a1234) == (10,9,8,11,1)

te1234 = HTensorEvaluator(t1234)
te1234c = HTensorEvaluator(t1234,1e6)

idxs = [2, 3, 5, 8]
@test a1234[idxs..., :] == getelts(t1234, idxs)
@test a1234[idxs..., :] ≈ getelts(te1234, idxs)
@test a1234[idxs..., :] ≈ getelts(te1234c, idxs)

bm = @benchmark getelts($te1234, $idxs)
@test memory(bm) == 0
bm = @benchmark getelts($te1234c, $idxs)
@test memory(bm) == 0

idxs = [3:8, 2, :, [3,5,7]]
@test a1234[idxs..., :] == getelts(t1234, idxs)

