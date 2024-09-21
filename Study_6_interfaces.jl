using BenchmarkTools
"""
# This module is for docs about interfaces

Why do we need interfaces:

 - one need to imlement just several functions to obtain the functionality of the collections

"""
module study_interf_iteration
using BenchmarkTools
#=
The state object will be passed back to the iterate function on the next 
iteration and is generally considered an implementation detail private to 
the iterable object
=#
const a = rand(10)
typeof(iterate(a))
@show iterate(a) # returns the value of the tuple of (first element,  state )
iterate(a,3)
 f1()=begin
    for i in a
        @show i
    end
 end
# for cycle is equivalent to the while cycle:
f2() = begin
    next= iterate(a) #next - tuple
    while next!== nothing
        (item,state) = next 
        #@show state
        next=iterate(a)
    end
end

f3(a::Vector{Float64}) = begin
    next= iterate(a) 
    while next!== nothing
        
        (item,state) = next
        #@show state
        next=iterate(a)
    end
end
# some functions accept the iterator obj as an input
typeof(i.^2 for i in a if i>0.1)
struct A
    counter::Int
    pow::Float64
end
# overriding iterate method 
Base.iterate(a::A,state=1) = state > a.counter ? nothing : (state^a.pow,state+1)
Base.eltype(::A)=Float64 # this adds type to the first element of the iterate return tuple
# it is importent for performance
for i in A(3,2) @show i end
# to use in comprehentions we need length method
Base.length(a::A)=a.counter
b=[i for i in A(10,3)]
collect(A(2,3))
# after adding the element type this two benchmarks give the same timing
@benchmark [i for i in A(10,3)]
@benchmark collect(A(10,3))
sum(A(10,3))
end