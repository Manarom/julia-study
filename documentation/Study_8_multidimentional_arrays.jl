using BenchmarkTools
"""
# This module is for docs about multi-dimentional arrays


"""
a=rand(10)
typeof(eachindex(a))
for i in eachindex(a) # effective iterator along each index
    @show i
end

axes(rand(4,5,31)) # returns a tuple containing valid indices
12 in axes(a)[1]
# stride(a,k) returns distance (in indices) between adjacent elements of dimention k
stride(a,1)
stride(rand(10,10,10),3)
using LinearAlgebra
A = rand(10,10)
Q,R = qr(A)
svd(A)