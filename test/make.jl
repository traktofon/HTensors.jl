using TensorOperations


function make4(a1,a2,a3,a4,a12,a34,a1234)
   t1 = HTensorNode(a1)
   t2 = HTensorNode(a2)
   t3 = HTensorNode(a3)
   t4 = HTensorNode(a4)
   t12 = HTensorNode(a12, [t1,t2])
   t34 = HTensorNode(a34, [t3,t4])
   t1234 = HTensorNode(a1234, [t12,t34])
   return t1234
end


# B[i,j,k] = A[a,b,k] U[i,a] V[j,b]
function AxUV(A, U, V)
   T = eltype(A)
   na, nb, nk = size(A)
   ni = size(U,1)
   nj = size(V,1)
   @assert size(U,2) == na
   @assert size(V,2) == nb
   tmp = Array{T}(ni, nb)
   B = zeros(T, ni, nj, nk)
   for k=1:nk
      fill!(tmp, zero(T))
      for b=1:nb, a=1:na, i=1:ni
         tmp[i,b] += A[a,b,k] * U[i,a]
      end
      for b=1:nb, j=1:nj, i=1:ni
         B[i,j,k] += tmp[i,b] * V[j,b]
      end
   end
   return B
end
   
function cost(u1,u2,u3,u4,u12,u34,u1234,target)
   a12 = AxUV(u12, u1, u2)
   a34 = AxUV(u34, u3, u4)
   n1, n2, n12 = size(a12)
   n3, n4, n34 = size(a34)
   a1234 = AxUV( u1234, reshape(a12, n1*n2, n12), reshape(a34, n3*n4, n34))
   guess = reshape(a1234, n1, n2, n3, n4, 1)
   return sum(abs2, guess-target)
end

