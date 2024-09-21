# Control flow study
# begin...end
using Random
z = begin
    x=1
    y=2
    x+y
end
z = (x=1;y=2;x+y)
function foo1(N::Int64)
    flag = fill(false,N)
    rand_mat  = zeros(N)
    #rand!(rand_mat)  
    for i in 1:N
       rand!(rand_mat)     
       #rand_mat.=rand(N)
       #randperm!(rand_mat)
        @. flag|= 0.1<=rand_mat>0.5
        if all(flag)
            return i
        end
    end
    return N
end
func2(x)=(a=1;b=2;a*x+b)
# last senetence in short-circuit logical operator can return non-logical
fun3(a) = a>3 && "its_ok"
# zip(collection_one, collection_two) - creates the iterator over common 
# dimentions of two collections; iteration over matrices goes column-wise (like MATLAB)
zip_test1 = [1 2 3; 4 5 6]
zip_test2 = [11 22 33 44;55 66 77 88;99 111 222 333]
fun_ziptest(t1,t2)= begin
    for (jjj,kkk) in zip(t1,t2)
        @show jjj,kkk
    end
end
@assert fun_ziptest(zip_test1,zip_test2)==fun_ziptest(zip_test1[:],zip_test2[:])
# try...catch
# try
# catch er
# else if there were no errors
# finally executed anyway
# end  
# Each block of the try...catch has its own scope

fun1(x)=begin
    try 
        a=15
        out = sqrt(x)
    catch er # this statement executed when there was an error
        println("Error catched")
    else# this statement executed when no errors
        println(a)# this gives an error because 
        # each block has its own scope (inspite of variable
        # a is assigned to the value before the error is taking place block  in else 
        # dont know about a variable of try block )
        println("Else reached")
    finally# this statement executed anyway
        println("Finally reached")
    end

end
fun1(-1)
fun1(10)
