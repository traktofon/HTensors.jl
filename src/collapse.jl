# eliminate children
function collapse(ht::HTensorNode{T}) where {T}
   if isleaf(ht); return ht; end
   core = coreshape(ht)
   nchildren = length(ht.children)
   newsubshape = Int[]
   newchildren = HTensorNode{T}[]
   for i in 1:nchildren
      child = ht.children[i]
      core = tensordot(core, child.data, i)
      append!(newsubshape, child.subshape)
      append!(newchildren, child.children)
   end
  #println(STDERR, "!!! collapse: $(ht.subshape) -> $(newsubshape)")
   core = reshape(core, newsubshape..., ht.nbasis)
   HTensorNode(core, newchildren)
end

# eliminate children recursively
function collapse_all(ht::HTensorNode)
   if isleaf(ht); return ht; end
   newchildren = map(collapse_all, ht.children)
   collapse(HTensorNode(ht.data, newchildren))
end
