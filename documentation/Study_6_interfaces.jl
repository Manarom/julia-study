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
prev_state = 2 # previous state of iterator
@show iterate(a,prev_state) # returns the value of the tuple of (first element,  state )
# state - next iteration index
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
        @show item
        next=iterate(a,state) # next is a tuple or nothing
    end
end

f3(a::Vector{Float64}) = begin
    next= iterate(a) 
    while next!== nothing
        
        (_,state) = next
        #@show state
        next=iterate(a,state)
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
# it is interesting that if eltype function is not implemented than collect returns vector of Any ?!
#   collect(element_type, collection) - uses elfype function to obtain the element type of the collection
collect(A(2,3))
# after adding the element type this two benchmarks give the same timing
@benchmark [i for i in A(10,3)]
@benchmark collect(A(10,3))
# sum function can be used with iterators without memory allocation for th eintermediate vector
# first is fater than the second one, the third has the same speed as the first one and uses generator sintax
@benchmark sum(A(10,3))
@benchmark sum(collect(A(10,3)))
@benchmark sum(i for i in A(10,3))

end
@code_warntype sum(i for i in study_interf_iteration.A(10,3))
@code_warntype sum(study_interf_iteration.A(10,3))

module study_interf_indexing
using BenchmarkTools
struct A
    counter::Int
    pow::Float64
end
Base.iterate(a::A,state=1) = state > a.counter ? nothing : (state^a.pow,state+1)
Base.eltype(::A)=Float64 # this adds type to the first element of the iterate return tuple
Base.length(a::A)=a.counter

#= to implement collection-like behaviour several methods should be implemented for a particular type

        getindex(X, i)	X[i], indexed element access
        setindex!(X, v, i)	X[i] = v, indexed assignment
        firstindex(X)	The first index, used in X[begin]
        lastindex(X)	The last index, used in X[end]
=#
Base.getindex(a::A,i) = iterate(a,i)[1] # this version is without out of bounds check
A(4,6)[2]
struct B
    counter::Int
    pow::Float64
end
Base.getindex(a::B,i) = i<=a.counter ? i^a.pow : error("out of bounds")
B(4,6)[2]

@benchmark A(4,6)[2]
@benchmark B(4,6)[2]
# adding first and last index allows to get elements using [begin] [end] sintax
Base.lastindex(a::B) = a.counter
Base.firstindex(::B) = 1
B(4,6)[end]
end
# This module implements AbstractArray abstract class
module study_abstract_array
using BenchmarkTools
struct A <:AbstractArray{Float64,1}
    counter::Int
    pow::Float64
end
Base.size(a::A) = (a.counter,)
Base.getindex(a::A,i::Int) = i<=a.counter ? i^a.pow : error("index mismatch")
Base.getindex(a::A,i::Number) = a[convert(Int, i)] # adding possibility to have non-integer indexing
Base.eltype(::A)=Float64 # element type
a = A(5,3.0) # vector of five lements 
a.*a
A(4,2.0)[2:4]
for a in A(4,2.0)
    @show a
end
sin.(a)
similar(A(4,3))
similar(A(4,3),ComplexF64)
@benchmark A(4,2.0)[2:4]
#Base.getindex(a::A,I) = [a[i] for i in I]
Base.IndexStyle(::A) = IndexLinear()
A(5,1.0)[A(5,1.0).>3]
filter(i->isless(i,3.0),A(5,1.0))
copy(A(5,2.0))
A(5,1.0)[A(3,1.0)] #this works because we added non-integer indexing 
Base.one(::A) = A(1,1)
end