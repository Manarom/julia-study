# missing values in statistical sense...
# singletone instance of type Missing
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
"a"*missing # gives missing
"a"+ missing # gives error
abs(missing)

# as far as mising 
# Singleton object implementation Base.Missing:
#                       struct Missing end
#                       const missing = Missing()
# ordinary struct with no fields

# there is a package Missings.jl
# which provides functions to work with missing
f(x) = "A"
using  Missings
f1=passmissing(f)
f(missing)
f1(missing)
f1(9)
#now function f1 returns missing if one of its arguments is missing

# missing follows three-value logic
true|missing
missing|true
false|missing
true&missing
false&missing
!missing
xor(missing)

# control flow operations doesnt support missing
if missing
    display("A")
end

# arrays of missing
zeros(Missing,5)
a = ones(Missing,5)
a[1] = 1
b = [missing 1 3.0]
typeof(b)
convert(Array{Float64},b)
b[1] = 9.0
typeof(b)
b = convert(Array{Float64},b)
typeof(b)

# scipping missing values

sum([2,3,missing])
sum(skipmissing([2,3,missing]))

a = [missing,9.0, missing,5,10,23]
as = skipmissing(a)
mapreduce(sqrt,+,a)
mapreduce(sqrt,+,as)
# object created using skipmissing 
# skipmissign arrays can be accesed by get index 
# this gives error
as[1]
#this is ok
as[2]
# no method setindex for missing values
as[1] = 20 

for i in as
    @show i
end
# iterators skip missing values in skipmissing objects
collect(as)
# returns non-missing 

[1,missing]==[2,missing]

[1,missing]==[1,missing]