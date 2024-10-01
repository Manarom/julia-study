# Metaprogramming
using BenchmarkTools,TreeView
# All programs are first parsed as expressions
# expressions can be constructed manually:

(ex1=Expr(:call,:+,1,1)) |>eval
ex1.head
[ex1.args...]
ex2 = quote
    if a>b
        return a
    else
        return b
    end
end
ex2 |> dump
a=5
b=15
ex2|>eval
a=25
b=1
ex2|>eval

# what is the difference between colon and quote?

ex_col = :(begin
    sin(a)
    end
)

ex_col2 = quote
    sin(a)
end

f1()=begin 
    a=pi
    return eval(ex_col), eval(ex_col2)
end
f1() #- incorrect answer because the eval function evaluates expression in the global scope!

# quote ... end is the same as :(begin ... end)... from docs Unlike the other means of quoting, :( ... ), this form introduces QuoteNode elements to the expression tree, which must be considered when
# directly manipulating the tree

Meta.show_sexpr(ex_col2) # another way to show expressions

#splatting interpolation

x = [:x,:y,:z]
ex3=:(f(1,$(x...)))

x=:(1+2)
ex1 = :(:($x))
eval(ex1) |>typeof
ex2 = :(:($$x))
eval(ex2) |>typeof


#QuoteNode

Meta.parse(":x")|>dump
# the parser automatically add QuoteNode for :a to mark it as a symbol
(ex1 = :(:x)) |> dump
g = :x
(ex2 = :($g)) |> dump # this return just Symbol 
ex1==ex2
(ex2 = :(QuoteNode($g))) |> dump 
(ex2 = quote QuoteNode($g) end) |> dump


# Eval function
# eval(Expr)  - evaluates expression in the global scope! Each module has its own eval function
module f_eval
    function add_var(varname,varvalue) # this function add variable to the global scope of the module
        eval(:($varname=$varvalue))
    end
    function eval_exp(exp::Expr)
        @assert exp.head==:call
        return eval(exp)
    end
    macro eval_exp(exp)
        quote
            $exp
        end 
    end
    function f()
        return a
    end
end
f_eval.add_var(:a,5)
f_eval.add_var(:b,3)
f_eval.eval_exp(:(sin(a+b)))
f_eval.@eval_exp :(sin(a+b))
f_eval.@eval_exp(:(if a>b 
                 a
else
    b
end    ))
# MACROS

# Macros provide a mechanism to include generated code in the final
# body of a program. A macro maps a tuple of arguments to a returned 
# expression, and the resulting expression is compiled directly rather 
# than requiring a runtime eval call. Macro arguments may include 
# expressions, literal values, and symbols.
ex1 = @macroexpand @show a
@macroexpand @which sin(pi)
macro sayhello()
           return :( println("Hello, world!") )
end
@sayhello
@macroexpand @sayhello

macro simple_assert(cond)
    @show  cond
    :(
       
        $cond ? nothing : throw(AssertionError("Error: "*$(string(cond))))
    )
end
@simple_assert 1==3
ex3 = :(begin
    struct B
        a::Int
        b::Float64
    end
end)
ex3|>dump
eval(ex3)
B(3,4.5)
eval(ex3)

Macros
# Macros provide a mechanism to include generated code in the final body of a program. 
# A macro maps a tuple of arguments to a returned expression, and the resulting expression 
# is compiled directly rather than requiring a runtime eval call. Macro arguments may 
# include expressions, literal values, and symbols.
macro mody_type(ex) # macro to change the name of type
    @show ex
    dump(ex)
    if ex.head == :struct
        ex.args[2]=Symbol("modified"*String(ex.args[2]))
    end 
    return ex
end
@mody_type struct A
        b::Int
        c::Float64
end
@tree :(
    function f(x::Int)
        return x*x
    end
)