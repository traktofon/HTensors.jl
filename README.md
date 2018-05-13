HTensors.jl
===========

A Julia libray for dealing with Hierarchical Tensors.

**WORK IN PROGRESS**

Code and interface are still strongly in flux!


Current Features
----------------

- a type `HTensorNode` which holds the nodes of the tree-structured HTensor
- indexing and slicing (`getelts`)
- a type `HTensorEvaluator` for zero-allocation evaluation of individual elements of the HTensor (`getelt`)
- converting into a full multi-dimensional array (`array`)


Planned Features
----------------

Most importantly, methods for converting a full multi-dimensional array (e.g. stored in memory
as a Julia `Array`, or computed on the fly as a [`ComputedArray`](https://github.com/traktofon/ComputedArrays.jl), etc.)
into a Hierarchical Tensor.  This conversion will be lossy (i.e. only approximate) but should be controllable
either via an a-priori error threshold, or via an a-posteriori error estimate.

#### Hierarchical Singular Value Decomposition:

Based on the algorithms described in:

> L. Grasedyck,  
> Hierarchical Singular Value Decomposition of Tensors,  
> SIAM J. Matrix Anal. Appl. 31, 2029 (2010)  
> DOI: [10.1137/090764189](https://doi.org/10.1137/090764189)  

#### Randomized Hierarchical SVD

The original Hierarchical SVD needs access to all elements of the full tensor, which is
prohibitive for high tensor orders. If the tensor has regularity, it can be sufficient
to randomly (or not so randomly) sample from the full tensor. Initial ideas and results
are presented in:

> F. Otto, Y.-C. Chiang, and D. Peláez,  
> Accuracy of Potfit-based potential representations and its impact on the performance of (ML-)MCTDH.  
> Chem. Phys. (2017), in press  
> DOI: [10.1016/j.chemphys.2017.11.013](https://doi.org/10.1016/j.chemphys.2017.11.013)
> -- [arXiv preprint](https://arxiv.org/abs/1805.00395)


Further Reading
---------------

For the mathematical background on Hierarchical Tensors, see:

> W. Hackbusch and S. Kühn,  
> A new scheme for the tensor representation.  
> J. Fourier Anal. Appl. 15, 706 (2009)  
> DOI: [10.1007/s00041-009-9094-9](https://doi.org/10.1007/s00041-009-9094-9)  

Additional helpful literature:

> W. Hackbusch,  
> Tensor Spaces and Numerical Tensor Calculus.  
> Springer Series in Computational Mathematics 42 (2012), Springer, Heidelberg  
> DOI: [10.1007/978-3-642-28027-6](https://doi.org/10.1007/978-3-642-28027-6)

> L. Grasedyck, D. Kressner, and C. Tobler,  
> A literature survey of low-rank tensor approximation techniques.  
> GAMM-Mitteilungen, 36: 53-78 (2013)  
> DOI: [10.1002/gamm.201310004](https://doi.org/10.1002/gamm.201310004)  

