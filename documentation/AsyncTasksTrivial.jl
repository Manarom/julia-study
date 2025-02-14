mutable struct A
    a::Float64
end
using BenchmarkTools
a = [A(a) for a in zeros(10)]
@benchmark for i in 1:10
    @async begin
        a[i].a=a[i].a+ i
    end
end
a
@benchmark for i in 1:10
    begin
        a[i].a=a[i].a+ i
    end
end
@benchmark Threads.@spawn for i in 1:10
    begin
        a[i].a=a[i].a+ i
    end
end

 ⬚(a::Int...) = begin
    sum(length(string(i)) - 2*count("0",string(i)) for i in a) 
 end