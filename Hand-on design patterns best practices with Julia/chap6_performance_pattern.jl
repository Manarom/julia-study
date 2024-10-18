# CHAPTER 6 - PERFORMANCE PATTERN

#= Performance patterns
* Global constant
* Struct array
* Shared arrays
* Memorization
* Barrier function
=#

# Global constant patterns
# global must be const for Performance
module A
    c=5
    c_int::Int=5
    const c_const = Ref(5) # const dont need typisation?
    const c_const2::Base.RefValue{Int}=Ref(6) # a way to have a mutable object as a constant !
    using BenchmarkTools
    function f(f_::Function)
        b_c = @benchmark($f_(c))
        b_cint = @benchmark($f_(c_int))
        b_const = @benchmark($f_(c_const[]))
        b_const2 = @benchmark($f_(c_const2[]))
        return (b_c,b_cint,b_const,b_const2)
    end
    function f_mod(f_::Function) # version with modification modification of const is faster!
        f_mod() = begin 
            global c = 15
            return f_(c)
        end 
        f_mod_cint() = begin 
            global c_int = 15
            return f_(c_int)
        end  
        f_mod_const() = begin 
            global c_const[] = 15
            return f_(c_const[])
        end  
        f_mod_const2() = begin 
            global c_const2[] = 15
            return f_(c_const2[])
        end   
        b_c = @benchmark($f_mod())
        b_cint = @benchmark($f_mod_cint())
        b_const = @benchmark($f_mod_const())
        b_const2 = @benchmark($f_mod_const2())
        return (b_c,b_cint,b_const,b_const2)
    end
end
using BenchmarkTools
for bench in A.f_mod(cos)
    @show bench
end

var_glob = 10
function add_using_global_var(x)
    return x + var_glob
end
const global_const = 10
function add_using_global_const(x)
    return x+global_const
end
@benchmark add_using_global_var(90)
@benchmark add_using_global_const(10)

function modify_global_var()
    global var_glob+=1
    return var_glob
end
const var_gloab_ref = Ref(10)
function modify_global_ref()
    global var_gloab_ref[]+=1
    return var_gloab_ref[]
end
@benchmark modify_global_var()
@benchmark modify_global_ref()
# use reference const to modify global variable

# * STRUCT ARRAY PATTERN
module B
    using StructArrays,BenchmarkTools # creates struct-of-arrays - like behaviour from array of structs
    struct A
        a
        b
    end
    a = [A(i,i) for i in 1:100]
    @benchmark mean(a.a for a in a)
    st = StructVector(a)
    @benchmark StructVector(a)
    @benchmark mean(a.a for a in st) # little faster

    @benchmark [a.a for a in a ]
    @benchmark st.a # this is much faster!!
end
# Base.summarysize - calculates all memory consumed by obj
Base.summarysize(B.st)
Base.summarysize(B.a)
B.a = nothing
Base.summarysize(B.st)
Base.summarysize(B.a)
Base.summarysize(2)


# * SHARED ARRAY PATTERN