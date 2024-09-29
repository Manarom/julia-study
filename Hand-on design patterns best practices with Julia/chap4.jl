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