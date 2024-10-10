# @__MODULE__ - returns the name of a module where it is been running
@__MODULE__
module XMOD
    foo() = begin
        @__MODULE__
    end
end

# @show - shows variable value together with its name
@show XMOD.foo
# using BenchmarkTools ; @benchmark - benchmark 
# @btime average evaluation time (if is much faster than @becnhmark)
@btime XMOD.foo()
@benchmark XMOD.foo()
# @__DIR__ - returns current path as a string

# AllocCheck package gives @
using AllocCheck
@check_allocs # macro to check the allocations of a function
# @show - shows variable value together with its name
@show XMOD.foo
# using BenchmarkTools ; @benchmark - benchmark 
# @btime average evaluation time (if is much faster than @becnhmark)
@btime XMOD.foo()
@benchmark XMOD.foo()
@allocated XMOD.foo() # returns allocated memory
# @__DIR__ - returns current path as a string
path_name = @__DIR__
@which sin(pi) # prints which method of the function was used (this work if function doesn't call external function )
@code_warntype sin(3.12)#...- generates a representation of your code that can be helpful
@macroexpand sin(3.12) #... - shows code with expanded macros
using Revise
# includet("\\...\\File_Name.jl") # after including script in this way julia starts to monitor all changes in 
# @view VS view(...)
a = ones(Float64,10)
b = @view a[1]
fill!(b,23.1)
@macroexpand @view a[1] # now vector a has the value of b as a first element, thus @view macro makes it possible to create a reference to some part of the array
#thus in this case @view macro simplt calls view function, bt it supports special words
b1 = view(a,1)
b1==b
# b3 = view(a,3:end) this returns error when using view function
b3 = view(a,3:10) # this is OK
b4 = @view a[3:end] # for @view end word is OK
b3==b4 

# Base.@kwdef  - adds Constructor with keyword arguments and allows default values
@macroexpand Base.@kwdef struct TextStyle
    font_family
    font_size
    font_weight = "Normal"
    foreground_color = "black"
    background_color= "white"
    alignment = "center"
    rotation = 0
end

using Lazy: @forward

struct D
    d
end
f(x::D)="d"
struct D_wrapper
    d::D
end

@forward D_wrapper.d f # generates method f(x::CC) = f(x.d)
@which f(D_wrapper(D(10)))

