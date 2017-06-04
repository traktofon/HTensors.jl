function linearindex(shape, idxs)
   stride = 1
   idx = 1
   @inbounds for d in 1:min(length(shape), length(idxs))
      i = idxs[d]
      n = shape[d]
      @assert 1<=i<=n
      idx += stride*(i-1)
      stride *= n
   end
   return idx
end
