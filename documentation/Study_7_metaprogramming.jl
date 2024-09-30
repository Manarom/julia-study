# Metaprogramming

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