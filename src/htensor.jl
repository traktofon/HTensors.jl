mutable struct HTensorNode{T} <: AbstractTensor{T}
   data      :: Array{T,2}
   subshape  :: Vector{Int}
   nbasis    :: Int
   children  :: Vector{HTensorNode{T}}
   partition :: Vector{Int}
end

reshape2D{T}(a::Array{T,1}) = reshape(a, 1, length(a))
reshape2D{T,N}(a::Array{T,N}) = reshape(a, prod(size(a,i) for i=1:N-1), size(a,N))
coreshape(t::HTensorNode) = reshape(t.data, t.subshape..., t.nbasis)

function HTensorNode{T,N}(data::Array{T,N}, children = HTensorNode{T}[])
   nbasis = size(data,N)
   subshape = [size(data,i) for i=1:N-1]
   data2D = reshape2D(data)
   if !isempty(children)
      @assert length(children) == N-1
      for i=1:N-1
         @assert subshape[i] == children[i].nbasis
      end
   end
   partition = Int[ nmode(c) for c in children ]
   HTensorNode(data2D, subshape, nbasis, children, partition)
end

isleaf(t::HTensorNode) = isempty(t.children)
nmode(t::HTensorNode)  = isleaf(t) ? length(t.subshape) : sum(nmode(c) for c in t.children)

function ncoeffs(ht::HTensorNode)
   n = length(ht.data)
   for child in ht.children
      n += ncoeffs(child)
   end
   return n
end

function shape(t::HTensorNode)
   if isleaf(t)
      return t.subshape
   else
      shp = Array{Int}(sum(t.partition))
      f = 0
      for i = 1:length(t.children)
         nm = t.partition[i]
         ch = t.children[i]
         shp[f+1:f+nm] = shape(ch)
         f += nm
      end
      return shp
   end
end

function array(t::HTensorNode)
   core = coreshape(t)
   if isleaf(t)
      return core
   else
      nchildren = length(t.children)
      newshape  = Int[]
      for i in 1:nchildren
         child = t.children[i]
         charr = array(child)
         core  = tensordot(core, reshape2D(charr), i)
         append!(newshape, size(charr)[1:end-1])
      end
      reshape(core, newshape..., t.nbasis)
   end
end

function getelts(t::HTensorNode, idxs)
   core = coreshape(t)
   if isleaf(t)
      return core[idxs..., :]
   else
      f = 0
      nchildren = length(t.children)
      newshape  = Int[]
      for i in 1:nchildren
         ch_nmode = t.partition[i]
         ch_idxs  = idxs[f+1 : f+ch_nmode]
         ch_elts  = getelts(t.children[i], ch_idxs)
         core = tensordot(core, reshape2D(ch_elts), i)
         append!(newshape, size(ch_elts)[1:end-1])
         f += ch_nmode
      end
      reshape(core, newshape..., t.nbasis)
   end
end

