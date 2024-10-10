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
