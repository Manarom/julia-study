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
path_name = @__DIR__
@code_warntype # checks the function call for type stability
@which # macro returns gives dispatched nethod 