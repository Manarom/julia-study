#interesting packages

# PkgTemplate - package to make templates for new package (generates directory structure)

# TreeView - drows syntax trees from expressions 

# Lazy - package with @forward  - macros to reimplement substructure methods

# CSV.jl - package to read files 

#Memoize :@memoize  - cashes function evaluation
using Memoize
@memoize foo(x)=("value"*string(x),x)
foo2(x)=("value"*string(x),x)
@benchmark foo(3)
@benchmark foo2(3)
@benchmark foo.(rand(30))
@benchmark foo2.(rand(30))
memoize_cache(foo)