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
# actually i dont see significant difference between const c and c_int 
