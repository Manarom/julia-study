# Strings 
# String type supports full unicode
S1 = "WTF,world?😐"
S1[end]
S1[1:end]
S1[2]
Int(S1[1])
Char(87)
S2 = """Sick"Sad"world"""
S2[begin]
lastindex(S2)
S2[end÷2]
S2[2:end÷2]
#= indexing with one value returns Char, multyvalue indexing like
using Range: (1:3:2) returns substring =#
S2[rand(1:14,10)]
try 
    S2[14*rand(10).>0.5]
catch ex
    println(ex)
end # logical indexing of strings is not supported! (logical indexing of arrays is OK)
s = "\u2200 x \u2203 y"
#all indices are bitewise
try 
    s[8]
catch Ex
    display(Ex)
end
length(s),lastindex(s),length(s)==lastindex(s)
lastindex("∃")
length("∃")
lastindex("🍬")
display(try s[1] catch Ex Ex end)
s[1:4]
for c in s
    println(c)
end
codeunits(s)
iterate(s,2)
# Interpolation
"1 + 2 = $(1 + 2)"; # works fine in REPL but gives error in VSCode
"this is $s"
# Triple quoted strings (preserves new line characters)
str1 = """ 
Hello,
world.
"""
print(str1)
"1 + 2 = 3" == "1 + 2 = $(1 + 2)" # it is strange that this works
"1 + 2 = $(1 + 2)"
# Special string literals
    # Version string v"...."
    typeof(v"0.2")
    v"0.2alfa"<v"0.2beta"
    "0.2alfa"<"0.2beta"
    VERSION 
    typeof(VERSION)
    # VERSION  - constant giving the current Julia VERSION
    v"1.4"<VERSION<v"1.9"
    # Regexp literals
    rg2 = r"^\s*(?:)"
    typeof(rg2)
    match_result = match(r"^\s*(?:#|$)", "# a comment")
    propertynames(match_result)
    match_result.match
    match_result.captures
    # raw"..." - resulting string contains all escaping symbols
    print("ghjk \n ghjgjhg")
    print(raw"ghjk \n ghjgjhg")
    println("\"")
