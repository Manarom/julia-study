mutable struct A
    a::Float64
end
using BenchmarkTools
a = [A(a) for a in zeros(10)]
@benchmark @async for i in 1:10
        a[i].a=a[i].a+ 1
end
a
a = [A(a) for a in zeros(10)]
@benchmark for i in 1:10
        a[i].a=a[i].a+ 1
end
a

a = [A(a) for a in zeros(10)]
@benchmark Threads.@spawn for i in 1:10
        a[i].a=a[i].a+ 1
end
a
 ⬚(a::Int...) = begin
    sum(length(string(i)) - 2*count("0",string(i)) for i in a) 
 end