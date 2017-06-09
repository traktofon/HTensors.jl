# non-allocating evaluation of an HTensor at a given multi-index

struct HTensorEvaluator{T}
   ht           :: HTensorNode{T}
   children     :: Vector{HTensorEvaluator{T}}
   child_inputs :: Vector{Vector{Int}}
   output       :: Vector{T}
end

isleaf(hte::HTensorEvaluator) = isempty(hte.children)

function HTensorEvaluator{T}( ht::HTensorNode{T}, nevalhint=0 )::HTensorEvaluator{T}
   if fulldim(ht) <= nevalhint
      ht = collapse_all(ht)
   end
   nchildren = length(ht.children)
   children = HTensorEvaluator{T}[ HTensorEvaluator(htch, nevalhint) for htch in ht.children ]
   child_inputs = Vector{Int}[ Array{Int}(ht.partition[i]) for i=1:nchildren ]
   output = Array{T}(ht.nbasis)
   return HTensorEvaluator(ht, children, child_inputs, output)
end

getelt(hte::HTensorEvaluator, idxs) = getelts(hte, idxs)[1]

function getelts(hte::HTensorEvaluator, idxs)
   ht = hte.ht
   if isleaf(hte)
      # get the slice of data corresponding to the idxs
      fill_output!(hte.output, ht.data, ht.subshape, idxs)
   else
      # prepare the idxs for the children
      split_indices!(hte.child_inputs, ht.partition, idxs)
      # ask children to evaluate their slices
      nchildren = length(hte.children)
      for i = 1:nchildren
         getelts(hte.children[i], hte.child_inputs[i])
      end
      # contract the core with the children's slices
      if nchildren == 2
         contract_core!(hte.output, ht.data, hte.children[1].output, hte.children[2].output)
      elseif nchildren == 3
         contract_core!(hte.output, ht.data, hte.children[1].output, hte.children[2].output, hte.children[3].output)
      elseif nchildren == 4
         contract_core!(hte.output, ht.data, hte.children[1].output, hte.children[2].output, hte.children[3].output, hte.children[4].output)
      else
         error("only supports 2, 3, or 4 children")
      end
   end
   return hte.output
end

function fill_output!(output, data, subshape, idxs)
   nbasis = length(output)
   @assert size(data,2) == nbasis
   @assert size(data,1) == prod(subshape)
   @assert length(idxs) == length(subshape)
   idx = linearindex(subshape, idxs)
   @inbounds for i=1:nbasis
      output[i] = data[idx,i]
   end
   return nothing
end

function split_indices!(inputs, partition, idxs)
   ninputs = length(inputs)
   @assert length(partition) == ninputs
   k = 1
   @inbounds for f=1:ninputs
      input = inputs[f]
      for i=1:partition[f]
         input[i] = idxs[k]
         k += 1
      end
   end
   return nothing
end

# output[i] = core[a,b,i] u1[a] u2[b]
# but core is stored as matrix of (a,b) x i 
function contract_core!(output, core, u1, u2)
   plen, nbasis = size(core)
   n1 = length(u1)
   n2 = length(u2)
   @assert n1*n2 == plen
   @assert length(output) == nbasis

   @inbounds for i=1:nbasis
      ab = 1
      out = zero(eltype(core))
      @inbounds for b=1:n2
         cu1_bi = zero(eltype(core))
         @inbounds for a=1:n1
            cu1_bi += core[ab,i] * u1[a]
            ab += 1
         end
         out += cu1_bi * u2[b]
      end
      output[i] = out
   end

   return nothing
end

# output[i] = core[a,b,c,i] u1[a] u2[b] u3[c]
# but core is stored as matrix of (a,b,c) x i 
function contract_core!(output, core, u1, u2, u3)
   plen, nbasis = size(core)
   n1 = length(u1)
   n2 = length(u2)
   n3 = length(u3)
   @assert n1*n2*n3 == plen
   @assert length(output) == nbasis

   @inbounds for i=1:nbasis
      abc = 1
      out = zero(eltype(core))
      @inbounds for c=1:n3
         cu1u2_ci = zero(eltype(core))
         @inbounds for b=1:n2
            cu1_bci = zero(eltype(core))
            @inbounds for a=1:n1
               cu1_bci += core[abc,i] * u1[a]
               abc += 1
            end
            cu1u2_ci += cu1_bci * u2[b]
         end
         out += cu1u2_ci * u3[c]
      end
      output[i] = out
   end

   return nothing
end

# output[i] = core[a,b,c,d,i] u1[a] u2[b] u3[c] u4[d]
# but core is stored as matrix of (a,b,c,d) x i 
function contract_core!(output, core, u1, u2, u3, u4)
   plen, nbasis = size(core)
   n1 = length(u1)
   n2 = length(u2)
   n3 = length(u3)
   n4 = length(u4)
   @assert n1*n2*n3*n4 == plen
   @assert length(output) == nbasis

   @inbounds for i=1:nbasis
      abcd = 1
      out = zero(eltype(core))
      @inbounds for d=1:n4
         cu1u2u3_di = zero(eltype(core))
         @inbounds for c=1:n3
            cu1u2_cdi = zero(eltype(core))
            @inbounds for b=1:n2
               cu1_bcdi = zero(eltype(core))
               @inbounds for a=1:n1
                  cu1_bcdi += core[abcd,i] * u1[a]
                  abcd += 1
               end
               cu1u2_cdi += cu1_bcdi * u2[b]
            end
            cu1u2u3_di += cu1u2_cdi * u3[c]
         end
         out += cu1u2u3_di * u4[d]
      end
      output[i] = out
   end

   return nothing
end

