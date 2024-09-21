#includet("./Study_2_variable_scope.jl") #COPY-PASTE IN REPL TO MAKE REVISE WORK
# Study_2_variable_scope
function g0_error()
    # эта функция возвращает ошибку, так как циклы
    # имеют свой local scope
    for i in 1:4

    end
    @show i # ошибка при попытке обратиться к локальной дл цикла переменной
end
function g0_error2()
    # эта функция также выдает ошибку, так как переменная v на каждой итерации цикла 
    # инициализируется заново
    for i in 1:4
        if i==1
            v=15
        else
            @show i
            @show v # на второй итерации возникает ошибка
        end
    end
end

function g02()
    # вариант предыдущей функции, который не возвращает ошибку
    #local v если обявить переменную локальной, то даже если переменная с таким именем существует 
    # в РЕПЛе, то она не поменяется
    #global  v=13 # в данном случае в репле переменная меняется ()
    v=13 #есил мя есть в репле, то оно затемняется внутри функции the
    # the  first assignment to variable causes it to be a new local variable 
    # in the body of the function!
    # можно и просто инициализировать v=0, тогда так как мы находимся функции цикл 
    # не выдаст ошибку
    for i in 1:4
        
        if i==1
            v=10
        else
            @show i
            @show v # на второй итерации возникает ошибка
        end
    end
end
function g1()
    l = []
    j = 0
    for i in 0:3
        push!(l, () -> j)
        j += 1
    end
    return l
end
# пример из документации по иллюстрации local scopeing of the loop_body
# вариант  sum_to_def_closure работает намного медленнее на @benchmark так как 
# требует создания функции каждый
function sum_to_def_closure(n)
    function loop_body(i)
        t = s + i # new local `t`
        s = t # assign same local `s` as below
    end
    s = 0 # new local
    for i = 1:n
        loop_body(i)
    end
    return s, @isdefined(t)
end
function sum_to_def(n)
    s = 0 # new local
    for i = 1:n
        t = s + i # new local `t`
        s = t # assign existing local `s`
    end
    return s, @isdefined(t)
end
# вынесли функцию из локальной

function loop_body(i,s)
    t = s + i # new local `t`
    s = t # assign same local `s` as below
end
function sum_to_def_closure2(n,body_loop_function::Function)
    s = 0 # new local
    for i = 1:n
        body_loop_function(i,s)
    end
    return s, @isdefined(t)
end