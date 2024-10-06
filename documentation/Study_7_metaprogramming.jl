# Metaprogramming
using BenchmarkTools
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


#QuoteNode - A quoted piece of code, that does not support interpolation

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
        Bool($cond) ? nothing : throw(AssertionError("Error: "*$(string(cond))))
    )
end
ex4 = @macroexpand @simple_assert 1==3
ex3 = :(begin
    struct B
        a::Int
        b::Float64
    end
end)
ex4 = Base.remove_linenums!(copy(ex3)) # removes linenumber nodes!



ex3|>dump
ex4|>dump

# Macros
# Macros provide a mechanism to include generated code in the final body of a program. 
# A macro maps a tuple of arguments to a returned expression, and the resulting expression 
# is compiled directly rather than requiring a runtime eval call. Macro arguments may 
# include expressions, literal values, and symbols.

# Macros are necessary because they execute when code is parsed, therefore, macros allow 
# the programmer to generate and include fragments of customized code before the full program is run.
# Напишем по-русски, чтобы лучше запомнить, тело макроса разворачивается при парсинге, во что
# оно разворачивается можно посмотреть при помощи @macroexpand, при этом, @macroexpan возвращает 
# то, что возращает сам макрос

macro twostep(arg)
    println("I execute at parse time. The argument is: ", arg)
    return :(println("I execute at runtime. The argument is: ", $arg))
end
exx1 = @macroexpand @twostep(1+35);
exx1

# We need macros because the functions don't know the names of variables (only values) 
macro mody_type(ex) # macro to change the name of type
    @show ex
    dump(ex)
    @show __source__
    if ex.head == :struct
        ex.args[2]=Symbol("modified"*String(ex.args[2]))
    end 
    return ex
end


@macroexpand @mody_type struct A
        b::Int
        c::Float64
end

module m1
    f(a::Number) = sin(a)
    
end



# hygiene. The main idea of julia hygiene is to prevent macros local variables names shadowing the gloabl variables 
# of the module where macro is expanded

macro time_test1(ex)
    return quote
        local t0 = time_ns() # adding local to quote automatically uses gensym for t0 variable
        local val = $ex
        local t1 = time_ns()
        println("elapsed time: ", (t1-t0)/1e9, " seconds")
        val
    end
end # this macro works well till the input ex does not contain any variables of functions with the same names as 
# of the variables marked local inside the macro 
macro time_test2(ex)
    return quote
        local t0 = time_ns() # adding local to quote automatically uses gensym for t0 variable
        local val = $(esc(ex)) # using esc function allows to use local variables inside expression
        # revents the macro hygiene pass from turning embedded variables into gensym variables.   

        local t1 = time_ns()
        println("elapsed time: ", (t1-t0)/1e9, " seconds")
        val
    end
end
# the difference between this two macros is illustrated inside the module mod2
module mod2
    import Main.@time_test1 # importing both macros
    import Main.@time_test2 
    ex1 = @macroexpand @time_test1 rand(1000)
    ex2 = @macroexpand @time_test2 rand(1000)
    @show ex1
    @show ex2
    time_ns()=15.1 # we define self-made function with the same name as use locally in macros
    ex3 = @macroexpand @time_test1 time_ns() # this macro the mod2 version of the function time_ns() is replaced with the Main.time_ns() 
    ex4 = @macroexpand @time_test2 time_ns()
    @show ex3
    @show ex4
    # the difference between ex3 and ex4 is that the first one replaced 
    # time_ns() with the one from the module where this macro was created (Main module)
    # thus when the variable is evaluated is returns incorrect results
    @time_test1 time_ns() # this returns incorrect result
    @time_test2 time_ns() # this returns correct result for time_ns function (local for this module) because of the `esc` function
end

# the following illustrates different ways of creating local variable inside 
# macros consistent with the julia hygiene idea
macro mac1_test() # this version uses local to call the gensym implisitly
    return quote
         local t=rand(1) # here we mark variable t as local for thic macro, thus 
         t
    end
end
macro mac2_test() # this version of macros uses gensym() explicitly to get a new name of the local variable
    t = gensym() # this function generates the simbol not matching any variables within the scope
    return quote
         $t=rand(1) # here we mark variable t as local for thic macro, thus 
         $t
    end
end
macro mac2_a_test()
    @gensym t
    return quote
        $t=rand(1)
        $t
    end
end
@macroexpand @mac1_test # both of this macros are practically the same, but the first one uses local variable inside the quote
@macroexpand @mac2_test # this macro uses gensym function to generate a consistent name for the local variable
@macroexpand @mac2_a_test
@mac1_test
@mac2_test
@mac2_a_test
# Macros and dispatch
macro mac3_test end # macro with 0 methods
macro mac3_test(ex::Int)
    :(println("Integer input"))
end

@mac3_test(3)
x=3
@mac3_test x # this returns error because the macro dispatches at the parse time not the runtime
# thus the input is :(x) macros doesnt know about the type of the input!

#CODE GENERATION
# using eval function we can generate functions for any particular type
struct C
    x::Float64
end

generate_C_methods()=begin
    for i in [:sin,:cos]
        eval(:(
            
        Base.$i(c::C)=Base.$i(c.x)
        ))
    end
end

generate_C_methods() # generating several function for C type struct
sin(C(pi)) # this functions are available now
cos(C(10.0))
generate_C_methods2()=begin # this function can be rewritten using @eval macros
    for i in [:sin,:cos]
        @eval $i(c::C)=Base.$i(c.x)
    end
end
generate_C_methods2()
sin(C(0))


# NON-STANDARD STRING LITERALS
# String literals are expanded at a compil tyme thus they are more efficient
macro SelfLiteral_str(s::String)
    l,r=Base.parse.(Int,split(s,":"))
    return [i for i in l:r]
end
@macroexpand SelfLiteral"1:10"


fun1()=begin
    s=0.0
    for i in SelfLiteral"1:10"
        s+=i
    end
    return s
end

fun2()=begin
    s=0.0
    for i in 1:10
        s+=i
    end
    return s
end
fun2()
fun1()
@benchmark fun2()
@benchmark fun1()

# this part is not clear 
macro SL_str(s::String,flag)
    l,r=Base.parse.(Int,split(s,":"))
    @show flag
    if Base.parse(Bool,flag)
        return [i for i in l:r]
    else
        return range(l,r)
    end
end
flag="true"
@macroexpand SL"1:10""true"
SL"1:10"flag
Base.parse(Bool,"true")


# GENERATED functions

#= While macros work with expressions at parse time and cannot access 
the types of their inputs, a generated function gets expanded at a time 
when the types of the arguments are known, but the function is not yet compiled.

Distinction of generated function from common functions: 

* abbreviation with @generated
* generated functions know only types of variables not values
* return quoted expressions like macros
* may call functions defined before the generated function (where, in code?)
* must not mutate or observe any global non-contant state (???)
=#
@generated function foo(x)
        Core.println(x) # function body returned only when the foo() is called on the argument of 
        # a new type, after that the compiled version of funciton is used
        if x==Int
            return :(println("an int"))
        else
            return :(println("not int"))
        end
end
@code_warntype foo("")
@code_warntype foo(90)
foo("a")
# Note that there is no printout of Int64. We can see that the
# body of the generated function was only executed once here, for 
# the specific set of argument types, and the result was cached.
# still i dont know when the generated function is better than multiple dispatch....

# Generated function are useful when all needed information is in the type of the argument
# thus all runtime execution can be done at a compile time!! (see docs example 
# for multidimentional array index to linear index conversion)

# Generated functions can be optionally generated in this case the syntax is the following:

#=
function optionally_generated(args)
    #do smthng  - this part will be done always on runtime
    if @generated
        return :(....) # branch when generated fintion is used
    else # run-time branch of the function
        return normal_value
    end
end
=#
# in the case of optionally generated function compiler desides 
# by itself which brecnh should be used