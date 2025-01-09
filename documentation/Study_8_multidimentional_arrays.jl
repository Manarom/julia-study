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

using BenchmarkTools

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
d = Array{Float64}(undef,10,20,20)
ы=Vector{Float64}(undef,10)
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

#-------------------*Comprehentions*-----------------------------------------------------
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
@benchmark sum(i for i in $a) # sends generator to the sum function
@benchmark sum([i for i in $a]) # creates array and than sends it to the sum function
@which sum(i for i in a) # calls special version of sum function 
@which sum([i for i in a])# call array-inout version of sum function
@code_warntype sum(i for i in a)
mapreduce(identity,(t1,t2)->+(Float64(t1),Float64(t2)), i for i in a)

#-------------------------------*Indexing*----------------------------------------------
A = reshape(collect(1:16), (2, 2, 2, 2))
A[2,[1 2],1,[1 2]]

#-------------------------------*Indexing assignment*-----------------------------------
a= rand(5)
# assignment calls type convertion 
a[2:4]=[2 3 4] # here right - Int64, left - vector of Float64
a
A = rand(2,3)
for i in CartesianIndices(A)
    @show i
 end
typeof(CartesianIndices(A))
supertype(ans)
CartesianIndex{2}((2,2))
iter = CartesianIndices(A)
# CartesianIndices acts like an array of CartesianIndex elements (N-tuple of integers)
# there are several basic operations are applcable to the CartesianIndex
typeof(iter[1,2])
methodswith(CartesianIndex)
fieldnames(CartesianIndices)
iter.indices
i1 = iter[1,3]
i2=iter[2,1]
i2>i1
min(i2,i1)
# CartesianIndices usage example
function sum_dim(A::Array{T,K},dim) where {K, T}
    #summation along dim'th dimention
    # A - matrix [M,N,K]
    sz  = [size(A)...]
    sz[dim]=1
    B=Matrix{T}(undef,sz...) # matrix [M,1,K]
    Bmax = last(CartesianIndices(B)) #the same as CartesianIndex(size(B))
    for I in CartesianIndices(A)
        B[min(Bmax,I)] += A[I] # min(Bmax,I) - returns (m,1,k)
    end
    return B
end

sum_dim(rand(10,10,10),3)
@code_warntype sum_dim(rand(10,10,10),3) # this version of functions is type unstable
a=rand(3,4,5,6)
typeof(eachindex(a))
f_each(a) = begin 
    s = 0.0
    for i in eachindex(a) # effective iterator along each index
        s+=a[i]
    end
    return s
end
f_cart(a)=begin 
    s = 0.0
    for i in CartesianIndices(a)
        s+=a[i]
    end
    return s
end
f_direct_iter(a)=begin
    s = 0.0
    for i in a 
        s+=i
    end
    return s
end
using BenchmarkTools
@benchmark f_each($a)
@benchmark f_cart($a)
@benchmark  f_direct_iter($a)
# eachindex is faster than CartesianIndices, but direct iteration is faster
# the sum via the iterator is
@benchmark  sum(i for i in $a)
#has the same speed as direct iteration

#Logical Indexing
a=rand(100,200)

f_find(a)=begin # find indices and gather a elements
    return a[findall(a.>0.5)]
end
f_find(a)

f_direct(a)=begin #direct logical indexing
    return a[a.>0.5]
end
f_direct(a)

f_filter(a)=begin
    return filter(t->t>0.5,a)
end
f_filter(a)

f_push(a::AbstractArray{T}) where T =begin
    b=Vector{T}(undef,0)
    for i in a 
        if i>0.5
            push!(b,i)
        end
    end
    return b
end
f_push(a)

@btime f_find(a)
@btime f_direct(a)
@btime f_filter(a)
@btime f_push(a)
# boolean indexing has the same speed as filter, it is interesting that push! is actually
# faster than findall...
# vec - function 
# if dimention is one it index can be omitted if there is only one possible value for those omitted 
a = rand(1,5,5,1)
a[1,4,4]
# there also all index a[] - return all indices
a = rand()
a[]


#-----------------------*Array traits-------------------------
# if MyArray<:AbstractArray - self made type with AbstractArray superype
# the Base.IndexStyle if it is set to IndexLinear eachindex returns int64,
# otherwise it returns CartesianIndex
# Base.IndexStyle(::Type{<:MyArray}) = IndexLinear()
struct my_array_linear{T,N}<:AbstractArray{T,N} 
    a::Vector{T}
end
Base.IndexStyle(::Type{<:my_array_linear}) = IndexLinear() 
Base.size(::my_array_linear{T,N}) where {T,N}= N
struct my_array_cart{T,N}<:AbstractArray{T,N} 
    a::Vector{T}
end
Base.IndexStyle(::my_array_cart) = IndexCartesian()
Base.size(::my_array_cart{T,N}) where {T,N}= N

m_lin = my_array_linear{Float64,1}(rand(10))
typeof(eachindex(m_lin))
size(m_lin)
m_car = my_array_cart{Float64,1}(rand(10))
typeof(eachindex(m_car))
#----------------------*Iteration------------------------------
# recommended ways to iterate over the whole collection
# for i in eachindex(A) OR for a in A 

#-------*arrays and vectorized operators and functions-----------
a = rand(10,30,50)
f(x)=sin(cos(x))
b = copy(a)
c = copy(a)
f_bench(a,b,f)= @. b=f(a)
f_b2(a,b,f) = begin
    for i in eachindex(a)
        b[i] = f(a[i])
    end
    #return b
end
@benchmark f_bench($a,$b,$f)
@benchmark f_b2($a,$b,$f)
# the performance is practically the same (f_b2 is faster if no return is used)
a= reshape(1:20,(2,10))
b = [99,99]
b.*a
# broadcasting over common dimention
c = rand(2,2)
c.*a
# dot operations FUSE!
x = rand(1000)
# this calls are equal performance
@btime f.($x)
@btime sin.(cos.($x))
# stride returns distance between twoo adjacent elements ub dimention k
c = rand(10,20)
stride(c,2)
stride(rand(10,10,10),3)
using LinearAlgebra, MKL
A = rand(10,10)
Q,R = qr(A)
svd(A)
@benchmark svd($A)
strides(A)

# implementing AvstractArray abstract class
# immutable arrays should implement at least 
# size, getindex(A,i) and getindex(A,i1,...,iN)
# mutable arrays should implement setindex!(A,i)
