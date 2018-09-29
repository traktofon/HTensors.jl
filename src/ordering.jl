preorder(node::T) where {T} = set_preorder!( T[], node )
postorder(node::T) where {T} = set_postorder!( T[], node )

function set_preorder!(order, node)
   push!(order, node)
   for child in node.children
      set_preorder!(order, child)
   end
   return order
end

function set_postorder!(order, node)
   for child in node.children
      set_postorder!(order, child)
   end
   push!(order, node)
   return order
end

