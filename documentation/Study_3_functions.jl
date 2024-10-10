# function is an object that maps a tuple of arguments value to the return value
function  fun1(a,b)
    return a+b
end
fun1(2,3)
fun2(x,y) = x+y
fun2(10,11)
typeof(fun2)
typeof(fun1)
function fun1(a,b::Float64)
    return Float64(a) + b
end
fun1(1,0.2)
fun2(1,0.1)
# Function arguments "pass-by-sharing", values are not copyed but inside function there are
# new name bindings
function fun3(x::AbstractArray{Float64},y)
    length(x)>0 ? x[1] += 1.0 : nothing
    display(y)
end
x1 = rand(10) # returns vector of Float64
x2 = rand(1:1:10,10) # returns vector of Int64
fun3(x1,3)
x1[1]
try 
    fun3(x2,3)
catch ex
    showerror(stdout, ex)
   # println(ex.msg)
end
function fun4(x,y)::Float64 # this is not recommended since
    # best practice is to write type-stable code!
    x*y
end
typeof(fun4(1,2))
# problem to convert string result to Float64
try 
    typeof(fun4("A","c"))
catch e
    showerror(e)
end
# nothing is a singleton object of type nothing
nothing==nothing
nothing===nothing
typeof(nothing)
function fun5(x)
    println(x)
    # all this version are the same:
        #return nothing
        #return
        #nothing
end
a = fun5(1)
a==nothing
+(1,2,3)
# A[i] <=> getindex
# A[i] = x <=> setindex!
# A.n <=> getproperty
struct A
    n::Float64
    b
end
st1 = A(3.14,"ad")
getproperty(st1,:n)
getfield(st1,:n)
getfield(st1,1)
map(i->getfield(st1,i),[1 2])
# zero argument anonymoous function
f1 = ()->time()
f1()
typeof(f1)
# something about tuples (property destructuring)
# ignoring several elements when the right hand type is iterable
_,_,_,b = 1:10
_,_,_,b... = 1:10
b
a,b...="hello"
@show b
@show A
minimax(x,y) = (y<x) ? (y,x) : (x,y)
#=
    gap(min,max) = max - min # this implementation gives error because
    # minimax returns tuple 
    gap(minimax(2,3)) => error
=#
# Arguments destructuring:
gap((min,max)) = max - min
gap(minimax(3.4,15)) # this is OK necause input tuple should be passed
# ; preceeds optional arguments 
foo(;x=0,y=0) =x+y
foo()
foo(x=5,y=6)
foo(x=1)
# named tuple arguments
foo2((;x,y)) = x+y
foo2((x=3,y=5))# direct names tuple
struct A23
    x
    y
end
foo2(A23(3,4))# object of struct with appropriate fieldnames
# varargs functions
foo3(x,y...) = x,x + sum(y)
foo3(1,2,3,4,5,6)
foo3(1,[2,3,4,5,6]...) # the same as previous with the splat operator
foo3([23 4 5 6 7]...) # looks similar to matlab varargin{:} expanding of function arguments
foo4(x;y=1,z=3)=x+y+z
foo4(1)
# evaluation scope of default variables
foo5(x;a1 = 1, a2=a1+2) = x +a1 + a2
@show foo5(1, a1=15,a2=2)
# do syntax
map((x)->begin
        if x>0
            return 1
        else
            return 2
        end
    end,
    rand(range(-1,1,length=20),10))
map(rand(range(-1,1,length=20),10)) do x
    if x>0
        return 1
    else
        return 2
    end
end 
# Another example of do block
data = "Data for file"
open("myfile.txt","w") do io # Variant of open call which ensures 
    # file close after open(f::Function,varargs...), f - function to be called on data stream
    write(io,data)
end
# Function composition and piping
# h(x) = f(g(x)) <=> h = f∘g  ∘ = \circ
f1(x) = x^2 + 2
g1(x) = sin(x)
# Composed function:
h1 = f1∘g1
typeof(h1)
f1(g1(10))==h1(10)
(sqrt∘+)(3,6)
# piping
1:10 |>sum |>sqrt
# piping with broadcast
1:10 .|>sqrt|>sum
1:3 .|> (x -> x^2) |> sum |> sqrt
1:3 .|> x -> x^2 |> sum |> sqrt
# ⏬ is the same as ⏫ if there is no parentheses 
# the second and the third pipes assumed as a part of the anonnymous 
# function  
1:3 .|> x -> (x^2 |> sum |> sqrt)
A = [1.0, 2.0, 3.0]
f(ang,x) = sin(ang)*x
iob = IOBuffer();
try_fun(f::Function,args...) = begin
    is_ok_flag = false
    error_string = ""
    try
        angs = [0.1, 0.2, 0.3, 0.5]
        out = f.(angs,A)
        is_ok_flag = true
    catch er
        if ~@isdefined iob
            iob = IOBuffer();
        end
        showerror(iob,er)
        error_string = String(take!(iob))
        println(error_string)
        
    end   
    return is_ok_flag,error_string
end

rngd = range(0,π,length=100)
fun = (sin∘cos)
rngd_copy = deepcopy(collect(rngd))
    @benchmark rngd_copy.=[fun(x) for x in rngd]
    @benchmark copy!(rngd_copy,[fun(x) for x in rngd])
    @benchmark rngd_copy.= fun.(rngd)
    @benchmark rngd_copy.= @. fun(rngd)
    @benchmark @. rngd_copy=  fun(rngd)
    @benchmark rngd_copy.= @. sin(cos(rngd))
    @benchmark rngd_copy.=broadcast(fun,rngd)
    @benchmark map!(fun,collect(rngd),rngd_copy)


# using multiple dispatch to extract parameters from parametric types

second_par(::AbstractArray{T,N}) where {T,N}=N
# version of the same function with the use of internal
second_par2(T::DataType) = begin
    return length(T.parameters)>=2 ? T.parameters[2] : nothing
end
# the second version is faster but the former is safer 