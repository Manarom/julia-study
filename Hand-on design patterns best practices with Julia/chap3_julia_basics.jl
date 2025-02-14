

# chapter 3 (julia basics designing functions and interfaces)

#do syntax for functions accepting other function as the first argument

fire(do_fun,obj) = return typeof(obj)==String ? do_fun(obj) : println("no obj") 
#
fire(o->*("fire ",o)," obj")
# do syntax
fire("ff") do s
    *("fire ",s)
end

# both are equal!

# do is useful for open file function
"""
```julia
open(jdx.file_name) do io_file # io_file - file header
    x_point=0.0
    for ln in eachline(io_file)
   # do some stuff
    end

end # when using do syntax we dont need to care about the closing file!
````
"""
function do_style_open_file end


# extracting type iformation using multiple dispatch
# this works as typeof()
get_type(x::T) where T = T
# this works as eltype
get_eltype(x::AbstractArray{T}) where T=T
function power_on end
# this module is an interface
module i_sum

export plus_
"""
This function `must` be impemented
    This function is applied to the left argument of the summation 
"""
function leftarg(_) end # abstract functions declared but having no methods, in the docstring there should be details of this implementation
"""
This function `must` be impemented
    It is applied to the right argument of the summation
"""
function rightarg(_) end # abstract function declared but having no methods
# as far as all functions should be impemented for plus_ to work 
# this this type of interface is called `hard constract`
function plus_(a,b)
    return +(leftarg(a),rightarg(b))
end
function plus_(a::Int,b::Int)
    return nplus_(leftarg(a),rightarg(b))
end
function nplus_(a::NTuple{T,N},b::NTuple{T,N}) where {T, N}
    return a .+b
end

end
# before using the plus_ function we should implement the abstract methods for particular types
Main.i_sum.leftarg(a)=NTuple{a,Float64}(rand(a))
Main.i_sum.rightarg(a)=NTuple{a,Float64}(rand(a))
c= Main.i_sum.plus_(2,2)