#=
 There are several types in Julia:
 - Abstract 
 - primitive
 - Composide
=#

# Lets create abstract types
abstract type MyAbstractType end
abstract type MyAbstractSubtype<:MyAbstractType end
abstract type MySecondAbstractSubtype<:MyAbstractType end
primitive type  MyPrimitiveType<:MyAbstractSubtype 128 end

"""
    Base.:+(a::MyPrimitiveType,b::MyPrimitiveType)
Create method for the summation of two self-made primitive type

TBW
"""
function Base.:+(a::MyPrimitiveType,b::MyPrimitiveType)
    UInt128(a)+UInt128(b)
end

"""
    MyPrimitiveType(x::UInt128)
Constructor for primitive type
TBW
"""
function MyPrimitiveType(x::UInt128)
    reinterpret(MyPrimitiveType, x::UInt128)
end;
"""
    UInt128(x::MyPrimitiveType)
Convertre from primitive type 
TBW
"""
function UInt128(x::MyPrimitiveType)
    reinterpret(UInt128, x)
    # reinterpret(::OutType,x::InputType) - this function reinterprets bit-wise representation of x::InputType
    # reinterpret(Float16,(0xA,0x2)) => Float16(3.11e-5)
end;
a = MyPrimitiveType(UInt128(24));
b = MyPrimitiveType(UInt128(27));
a+b
typeof(a)
sizeof(a)
typeof(MyPrimitiveType)
#the size of this type is 16*8=128 bits

## COMPOSITE types

struct MyCompositeType
    f1::Any
    f2::Number
    f3::Float64
    MyCompositeType(f1,f2,f3)=new(f1,f2,f3)#default Constructor
    MyCompositeType(f1::Float64,f2::Number)=new(f1,f2,f1)# Constructor overloading (for multiple dispatch)
end
#Constructor
mct=MyCompositeType("dfg",UInt8(9),2.34);#creating object
try
    mct.f1=23
catch ex
    display(ex)
end
# ^ all fields are immutable
mct2=MyCompositeType(rand(10),UInt8(9),2.34);#creating object rand(10) returns vector of Float64
mct2.f1[2]
mct2.f1[2]=10.1
mct2.f1
fieldnames(MyCompositeType)
methods(MyCompositeType)# returns methods 
methodswith(MyCompositeType)# shows methods apllicable to the particular object
isa(UInt8(8),Number)# check if is of specified type
mct isa MyCompositeType
mct3=MyCompositeType(nothing,23,2.4)# nothing is a special type (null)
mct3.f1
mct4 = MyCompositeType(nothing,23,π)
#struct with default values
#=@kwargs struct def_str
    a =24
    b=35.2
end
=#
# Structure with mutable fields
mutable struct MuSt
    a
    b
end
must = MuSt(2,3)
must.a=rand(10)
#TYPE UNION
IntOrString=Union{Integer,String}
23::IntOrString# this works like type assert
a=UInt8(5)
a::IntOrString
typeof(a)
a isa Integer
a isa Number

#PARAMETRIC TYPES
struct PaSt{T<:Number}
    a::T
    b::T
end

pst1 = PaSt{Float64}(2,3)
typeof(pst1.a)
try 
    pst2 = PaSt{String}("aas","sdg");
catch ex_p
    typeof(ex_p)
    #fieldnames(ex_p)
    display(ex_p)
end
typeof(PaSt{Real})
PaSt{Integer}<:PaSt{Number}
PaSt{Real}<:PaSt# Concrete type is a subtype of abstract supertype
fieldnames(typeof(pst1))# returns tuple of structure field properties as Exp fieldnames of struct
getfield(pst1,:a)#getfield is the same as pst1.a
pst1.:a
getfield(pst1,(fieldnames(typeof(pst1))[1]))
getproperty(pst1,:a)
function Base.getproperty(x::PaSt,prop::Symbol)#overriding getproperty returns 
    if any(i->i===prop,fieldnames(PaSt))
        return Base.getfield(x,prop)# getfield returns value
    elseif prop===:m #the property symbol can be also :m in this case return muliplication of structure properties
        return x.a*x.b
    end
end
# pst1.a === getproperty(pst1,:a)
#Compat.TypeUtils.isabstract(Integer)
@show Base.getproperty(pst1,:a)
@show pst1.m
# -----------------------------------TUPLES-------------
tupl1=(1,2,3)
tupl1[3]
fun(x::Tuple{Number,Number,Number})=mapreduce((x)->x,+,x)
fun(tupl1)
tuple_type = NamedTuple{(:a, :b), Tuple{Int64, String}}
typeof(tuple_type)
# В отличии от структуры  Tuple types are covariant in their parameters:
PaSt{Integer}<:PaSt{Number}# false- PaSt - Parametrized structure 
PaSt{Real}<:PaSt# true Concrete type is a subtype of abstract supertype
Tuple{Int64, String}<:Tuple{Number, AbstractString} # это true
isa((a=2,b="dg"),tuple_type)
tuple_type2=@NamedTuple begin
    a::Integer
    b::String
end
tuple_type2<:tuple_type
tuple_type2<:NamedTuple{(:a, :b), Tuple{Number, AbstractString}} # не понимаю почему это не тру
tuple_type_vararg =Tuple{AbstractString,Vararg{Any}}
primitive type Ptr{T} 32 end
typeof(Ptr)
type_ar_bounded = Array{T} where Integer<:T<:Number
isa(zeros(Float64, 2,3) , type_ar_bounded)
Array{Float64}<:type_ar_bounded
struct D{T} 
    n::T
    v::Array{T} 
  end
  methods(D)
  st1 = D{Int64}(34,[1;2;3])

  #SINGLETONE TYPES
  # Immutable composite types with no fields are called singletons
  struct NoFields{T}
  end
  Base.issingletontype(NoFields)
  Base.issingletontype(NoFields{Int64})
  # 
  struct Val{x}
  end
  vjk = Val{true}()
  fun(x::Val{true})="true"
  fun(vjk)
  vjk2=Val{false}() # calling the constructor
 try
    fun(vjk2)
 catch ex_p
    display(ex_p)
 end 
 # Таким образом, можно делать малтипл диспэтч не только по типам, но и по значениям параметров
 fun2(x::Val{3}) = "3"
 vjk3 = Val{3}()
 fun2(vjk3)