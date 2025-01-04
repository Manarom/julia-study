using BenchmarkTools
"""
# This module is for docs about multi-dimentional arrays

* Basic functions
* Construction and initialization
* Array literals
* Comperhensions
* Generator expressions
* Indexing
* Indexed assignment
* Supported index types
* Iteration
* Array traits
* Array and vectorized operations and functions
* Broadcasting 
* Implementation

"""


# ---------------------------------*Basic functions*------------------------------------------
a=rand(10,10) # 
eltype(a) # element type
axes(a) # returns a tuple containing valid indices
7 in axes(a)[1]
stride(a,2) # stride(a,k) returns distance (in indices) between adjacent elements of dimention k
b = copy(a) # copies all elements
## copy vs deepcopy
# to illustrate the difference let construct the vector of vectors (not numbers)
c= [ rand(1) for _ in 1:10]
# now c is the vector of vectors
# copy just copies each element (in this case references to the vectors)
b = copy(c)
b[1][1]
# changing c element changes b element also
c[1][1]=10
b[1][1]
# deepcopy copies recursively, now elements of b are copyes of data in references
b2 = deepcopy(c)
# changing c doesnt changes b2
c[1][1]=100.0
b2[1][1] # doesnt changed because 

## -------------------------*Construction and initialization*---------------------------
# zeros, ones, trues, falses
a = zeros(Union{Missing,T} where T<:Real,10)
a[2]=10.0
a[1]=missing
reshape(a,(5,2)) # reshaping
b = reinterpret(Float64,[1 2 3])
c = similar(a)
c[1] # similar returns uninitialized copy
c[1]=missing
# difference between undef, missing and nothing
@show typeof(missing) typeof(nothing) typeof(undef)
begin
    @show undef==undef
    @show undef===undef
    @show missing==missing
    @show missing===missing
    @show nothing==nothing
    @show nothing===nothing
end # they all are singletones, == with missing returns missing
@show 3*missing # gives missing 
3*nothing # gives error
3*undef # gives error
## missing propagates without error through the operations

# ranges
r =range(1,10)
o=Base.OneTo(10)
@benchmark [i for i in o]
@benchmark [i for i in r]

#filling
a= zeros(10)
fill!(a,1.0) # fills with the same values in-place
b = fill(10.0,2,4) # creates array filled with the same values

#--------------------------------*Array literals*--------------------------
# during the creation all types are automatically promoted to the common type
a = ["a",1,1//2]
b = [] # creates vector of any
size(b)
push!(b,1)
map!(identity,b,b)
identity.(b) # way to convert the vector of any to the vector of types
identity.(a)
# vector literals can be annotated with the type! T[....] where T
c = Float64[1, 3.0,1//3]
d = Any[1, 3.0,1//3]
# Concatenation
[1:2,2:5]
[1:2;2:5]
# dimention to concatenate can be settled by the number of ";"'s
# along the first dimention (row):
[rand(2,3);rand(2,3)]
# along the second dimention (column):
[rand(2,3);;rand(2,3)]
# along the third dimention (pages):
[rand(2,3);;;rand(2,3)]
[1:2; 4;; 1; 3:4]

#---------------------------------*Comprehentions*-------------------------------------
# A = [ F(x, y, ...) for x=rx, y=ry, ... ] - general syntax
a = 1:1000
@benchmark [i for i in $a]
@benchmark collect($a)
# comprehentions can eb used with type annotation
[i for i in a]
Float64[i for i in a]

#----------------------*Generator expressions*------------------------------------------
# comprehentions without literals
a = 1:1000
@benchmark sum(i for i in $a)
@benchmark sum([i for i in $a])
@which sum(i for i in a)
@which sum([i for i in a])
@code_warntype sum(i for i in a)

stride(c,2)
stride(rand(10,10,10),3)
using LinearAlgebra
A = rand(10,10)
Q,R = qr(A)
svd(A)

typeof(eachindex(a))
for i in eachindex(a) # effective iterator along each index
    @show i
end