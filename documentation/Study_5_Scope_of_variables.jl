module NewMod
    a = "NewMod_foo"
    export a
    foo() = a
end
module Mod2
    #a="Mod2_foo"
    import Main.NewMOd
    foo() = a
end
a = 35
NewMod.foo() # if the module is imported using import 
Mod2.foo()
# using .NewMod  in REPL -brings foo function to the Main
# using .Mod2 in REPL after ⬆ does not brings it's version of foo 
# to the Main,  because both functions has the same name
# Each module introduces a new global scope, separate from 
# the global scope of all other modules—there is no 
# all-encompassing global scope. 

# include evaluates the contents of the file at global scope

# the usual pattern in 
# Julia is to structure packages something like the following:

#= MyModule.jl
module MyModule
export foo_functionality_one, foo_functionality_two, bar_functionality

include("foo_file.jl")
include("bar_file.jl")
end

# foo_file.jl
foo_functionality_one() = ...
foo_functionality_two() = ...
foo_functionality_private() = ...

# bar_file.jl
function bar_functionality()
    something = foo_functionality_private()
    ...
end
=#

module Num3 # module introduces new global scope
    using Plots # now everything from Plots Package is sitting inside this module
    include(raw"D:\mironov\current\Emissivity Unit\new work\program\julia project\JEmissivityUnit\Planck.jl") # include evaluates 
    # script in global scope this ⬆ file contains new module, now this module can be called from Num3 module using dot notation
    """
    This function calculates Planck spectrum for wavelengths @lam of a Blackbody source at temperature @T 

        # Examples
        ```jldoctest
        julia> f_ibb(573,2.5)
        53.000110568793524
        ```
    """
    f_ibb(T,lam) = begin
        Planck.ibb(lam,T) # calling module function from this module
    end
    a = "module_global" # global variable of this module
    f0() = begin
        println(a) # this function prints the value associated with module_global variable a 
    end
    f1() = begin
        println(a) # this gives an error because variable a is declared as local variable
        # declaration as a local somewhere inside the block with a local scope makes this name
        # local for this block 
        local a="function_local" # its doesn't matter where exactly the declaration 
    end
    f2() = begin
        a = "renewd" # now a  - is a local variable, because  -- begin ... end -- creates new local scope  
        println(a) # this returns local value of a, at the same time the global a introduced 
        # in the body of the module block doesnt change its value
        local a # it  is not necessary to declare variable as local because it was previously 
        # assigned inside the begin...end block : the first assignment to a at the top of f2 
        # causes a to be a new local variable!
    end
    f3() = begin
        a = "new_value"
    end
    f4()  = begin
        global a # this declares that a is a global variable
        a = "f4_value_changing"
    end
    s = 15
    f5() = begin
        @show s # here it sees global variable s 
        for i in 1:10
            t=s+i # here it does not sees the global variable s => gives error
            s=t # introduces new local variable
        end
        return s
    end
    check_cycle_fun() = begin
        #local 
        #i=0 
        flag = true
        while flag
            (@isdefined i) ? i+=1 : i=0
            flag = i<=10
        end
        @show @isdefined i
    end
    # @show i - 
end
Num3.a
@show Num3.f0()
lam = collect(0.1:0.1:25);
spec  = Num3.f_ibb.(573.0,lam)
Num3.plot(lam,spec)
# @show Num3.f1()
@show Num3.f2()
Num3.f3()
Num3.a
Num3.f4()
Num3.a