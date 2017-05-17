using TensorOperations

function tensordot(A,B,n)
   @assert size(A,n) == size(B,2)
   T = eltype(A)
   d = length(size(A))
   szC = ntuple(i -> (i==n)?size(B,1):size(A,i), d)
   C = Array{T}(szC)
   tensordot!(C,A,B,n)
end

function tensordot!(C,A,B,n)
   d = length(size(A))
   T = eltype(C)
   @assert 1<=n<=d
   idA = ntuple(identity, d)
   idB = (0, n)
   idC = ntuple(i -> (i==n)?0:i, d)
   tensorcontract!(one(T), A, idA, 'N', B, idB, 'N', zero(T), C, idC)
end