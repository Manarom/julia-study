# chapter 4 Metaprogramming
# Meta.pase function parses string as an expression
# dump funciton expands the expression 
Meta.parse("2+3")
Meta.parse("sin(pi)")|>typeof
dump(Meta.parse("sin(pi)"))
Meta.parse("sin(cos(pi))") |> dump

# the expression can be constructed manually:
e1 = Expr(:call,:sin,:pi)
eval(e1)
Meta.parse("sin(π)") |> eval
a = "f(x::Float64) = begin 
    x+=10 
    return x^2 
end"
Meta.parse(a) |> dump
b = :(f(x::Float64) = begin 
    x+=10 
    return x^2 
end)
dump(b)

:(a>b ? "true" : nothing) |> dump
:(if a>b "true" else nothing end) |>dump
:(eval(:(sin(pi)))) |> dump
# eval function evaluates the expression
eval(:(y=15))
y
function f_eval1()
    eval(:(c=13)) # eval evaluates expression in the global scope!
end
f_eval1()
c # variable c is available outside the f_eval1 function local scope
module eval_check2
    function f_eval1()
        eval(:(c2=13)) # eval evaluates expression in the global scope!
    end
    f_eval1()
    c2
end
c2 # it is undefined
eval_check2.f_eval1()
c2 # still undefined

# Expressions can be creates via the interpolation

c3 = :pi

:(sin($c3)) |> eval
# interpolating symbol
f(a)=:(a=$a)
f(:hello) |> eval #this gives error because the symbol :hello interpolated as a part of the expression like "hello" variable 
f(QuoteNode(:hello)) |> eval # this is ok becaouse the symbol is enclosed in QuoteNode
a

v=QuoteNode(:pi)
:(:(x=$v)) |>dump
:(:(x=$v)) |>eval|>eval|>sin # this returns error, double evaluation assignes :pi (Symbol) to x
:(:(x=$($v))) |>dump
:(:(x=$($v))) |>eval|>eval |> sin # this works well as far as double "v" variable exit interpolates the value of pi to the final expression, thus the value of pi is assigned to the x variable
x

Meta.@lower @show pi
# WRITING MACROS, macro must return expressions
macro sin_(x)
    return quote
        sin($x)
    end
end
@sin_(pi)
Meta.@lower @sin_(pi)
# arguments to macro a transfered as an expression
macro showme(x)
    @show x
end

a=5
@showme a

function f_plus(x,y)
    return +(x,y)
end

@macroexpand @showme f_plus(2,3)

macro squared(x)
    return :($(x) * $(x))
end

@squared 2
x=5

function foo(x)
    return @squared x
end
foo(2) # this returns incorrect answer as far as @squared refers to the global variable x!!
# 
@code_lowered foo(2) # this shows that "x" in macro refers to the global "x"
macro squared_local(x)
    return :($(esc(x)) * $(esc(x))) # esc function places variable right in the context tree without letting the compiler resolve it
    # in practice this means that the variable now is taken from the context of macros calling
end
function foo2(x)
    return @squared_local x
end
foo2(5)
@code_lowered foo2(5)


macro compose_twise(ex)
    @assert ex.head==:call
    @assert length(ex.args)==2
    ex.args[2]=copy(ex)
    return ex
end
@compose_twise sin(2)
@macroexpand @compose_twise sin(2)
:(sin(sin(2)))|> dump


# Macros hygiene

macro ntimes(n,ex)
    
    quote
        times=$(esc(n))
        for i in 1:times
            $(esc(ex))
        end
    end
end
@macroexpand @ntimes 4 println("a")


# developing non-standart string literals
macro nbp_str(s)
    l,r=Base.parse.(Int,split(s,":"))
    return [i for i in l:r]
end
@code_lowered nbp"1:4"



#Using generated funcitons

@generated function doubled(x)
    @show x
    return :(2*x)
end
doubled(2)

foo3(x)=begin
    return doubled(x)
end
foo3(45)
x=55
doubled(6.0)
 