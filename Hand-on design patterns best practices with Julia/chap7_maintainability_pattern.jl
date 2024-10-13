#Maintainability Patterns

#=
*Sub-module pattern
*Keyword definition pattern
*Code generation pattern
*Domain-specific language pattern
=#
#-------------------------submodule patter-------------------------------------

# efferent coupling of component A - number of components the A is using 
# afferent coupling of component A - number of components which use A

# The main target is to reduce the number of couplings!

# 1.removing bidirectional coupling

# 1.2 Passing data as function arguments - the idea is to move constant to the parent module 
# and transfer it as a named function argument

# 1.3 Factoring common code as a new submodule
# the idea is when to modules A and B are mutually dependent
# move the dependent part to another module D to make two modules A and B 
# dependent on D

#=mutually dependent modules
module B
    using .A:f2 
    f1() = f2()
    f3()= 3
end

module A
using .B:f3
    f2()=2
    f4()=f3()
end
=#
module D # module with functions which both A and B depend on 
    f3()= 3
    f2()=2
end
module B
    using Main.D: f2 
    f1() = f2()
end

module A
    using Main.D: f3
    f4()=f3()
end

A.f4()
B.f1()




#-----------------Key-word definition pattern------------------------
# Base.@kwdef  - adds Constructor with keyword arguments and allows default values

Base.@kwdef struct TextStyle
    font_family
    font_size
    font_weight = "Normal"
    foreground_color = "black"
    background_color= "white"
    alignment = "center"
    rotation = 0
end
o=TextStyle(font_family="Arial",font_size=5, alignment="left")
o.font_weight
# default constructor is still available
o2 = TextStyle(
"ghjg",
6, "Normal", "black", "white", "center",0)


#--------------------Code----generation------pattern--------------
# when several functions has practically the same code, they can be generated using @eval macros
fnames = (:A,:B,:C)

for fn in fnames
    @eval function $fn()
        return string($fn)
    end
end
A()
B()
@macroexpand @eval function $fn()
    return string($fn)
end

methods(C)


# Domain Specific language pattern

# Exaple L-specific language for a Lindenmayer System (L-system)
# the main idea is to impement simple rules for the symbol sequence
# each iteration change the sequence by replacing symbols accoding to:
# Axion: A
#   Rule: A->AB 
#   Rule: B->A 
# First five iterations: A -> AB -> ABA -> ABAAB-> ABAABABA
# The target is to make a simple syntax like:
#= model = @lsys begin
    axiom: A
    rule: A->AB 
    rule: B->A
end
=#
module LSYNTAX
    using Lazy
    struct LModel{T<:AbstractString}
        axiom::AbstractVector{T}
        rules::Dict{T,Vector{T}}
        LModel(axiom)=new{typeof(axiom)}([axiom],Dict()) # adding constructor
        LModel(axiom::T,rules::Pair{T,T}...) where {T<:AbstractString} = begin
            lm=new{typeof(axiom)}([axiom],Dict())
            for p in rules
                add_rule!(lm,p[1],p[2])
            end
            return lm
        end  
    end 


    function add_rule!(model::LModel{T},left::T,right::T) where {T<:AbstractString}
        model.rules[left]=split(right,"")
    end
    function Base.show(io::IO, model::LModel)
        println(io, "LModel:")
        println(io, " Axiom: ", join(model.axiom))
        for k in sort(collect(keys(model.rules)))
            println(io, " Rule: ", k, " → ", join(model.rules[k]))
        end
    end
    function apply_rules!(res::Vector{T},l::LModel{T}) where {T<:AbstractString}
        res_ = Vector{T}()
        for r in res
            append!(res_,get(l.rules,r,r))
        end
        copy!(res,res_)
        return res
    end
    struct LState{T<:AbstractString}
        model::LModel{T}
        current_iteration::Int
        counter::Int
        result::Vector{T}
    end
    LState(m::LModel{T},counter::Int=10) where {T<:AbstractString}=
    LState{T}(m,0,counter,copy(m.axiom))

    apply_rules!(ls::LState) = apply_rules!(ls.result,ls.model)

    function Base.iterate(l_state::LState,state::Int=1)
        if state>l_state.counter
            return nothing
        end
        apply_rules!(l_state)
        return (l_state,state+1)
    end
    function Base.getindex(ls::LState,ind::Int)
        copy!(ls.result,ls.model.axiom)
        for _ in 1:ind
            iterate(ls,ind)
        end
        return ls
    end
    function Base.show(io::IO, ls::LState)
        #println(io, ls.model)
        println(io, " result: ", join(ls.result))   
    end
    function Base.lastindex(ls::LState)
        return ls.counter
    end
    macro lsys(ex)
        if ex.head != :block 
            error("Wrong syntax")
        end
        local ex_args = filter( e->e.head==:call,filter(arg->isa(arg,Expr),ex.args))
        local axiom = string(filter(e-> e.args[2]==:axiom, ex_args)[1].args[3])
        local counter = Int(filter(e-> e.args[2]==:counter, ex_args)[1].args[3])
        local rules = Vector{Pair{String,String}}()
        for r in filter(e-> e.args[2]==:rule, ex_args)
            a = string(r.args[3].args[1])
            b = string(r.args[3].args[2].args[2])
            push!(rules,a => b)
        end
        @show axiom
        @show rules
        return :(LState(LModel($axiom,$rules...),$counter))
    end
end


begin

lm2 = LSYNTAX.LModel("A","A"=>"AB","B"=>"A")
 
ls = LSYNTAX.LState(lm2,10)
ls[end]

end

model= LSYNTAX.@lsys begin
    axiom: A
    rule: A->AB 
    rule: B->A
    counter: 10
end
model[5]