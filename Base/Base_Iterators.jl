# Iterators implements several useful functions for lazy computations

f(x) = sin(x)

a = rand(10)

# classical version of map and filter etc returns the object of the same type as an input
map(f,a)

map(f,(0.1, 0.3, 0))
#this gives an error 
map(i->Float64(i),"skjfl")
map(i->i,"skjfl")

filter(i->i>0.5,a)

filter(i->i>0.5,map(f,a))

typeof(Iterators.map(f,a))
Iterators.filter(i->i>0.5,Iterators.map(f,a)) # this return  filter object without iterating

using BenchmarkTools
flt_obj = Iterators.filter(i->i>0.5,Iterators.map(f,a))
@benchmark collect($flt_obj)
filter_fun(i)=i>0.5
@benchmark filter(filter_fun,map(f,a))

# upper version is much faster and less allocating 

# Iterators.Stateful - turns iterator into statefull channel-like object which 'remembers' its state
# Just a wrapper around the standard iterator 
iterate(a,1)
iterate(a,2)
# in standard iterate function iterator state should be provided externally 
itr = Iterators.Stateful(a)
iterate(itr,2)
begin 
    itr = Iterators.Stateful(a)
    for (n,i) in enumerate(itr)# enumerate returns counter, not index
        @show n,i
    end
    @show iterate(itr) # returns nothing
    Iterators.reset!(itr) # resets iterator state
    @show iterate(itr) # returns first elements (again)
    @show iterate(itr) # returns first elements (again)
end

begin
    a = Iterators.Stateful([1,2,3,4,5,6])
    b = Iterators.Stateful([1,2,3,4])
    for (i1,i2) in zip(a,b)
        @show i1,i2
    end
    @show iterate(a) # returns first elements (again)
    @show iterate(b) # returns first elements (again)
    for (i1,i2) in zip([1,2,3,4,5,6],[1,2,3,4])
        @show i1,i2
    end

end

begin 
    a = [1,2,3,4,5,6]
    state_a = Iterators.Stateful(a)

    rest_a = Iterators.rest(a,3)# reurns an iterator over last n from `state` elements (3:end for this case)
    collect(rest_a)
    @show typeof(Iterators.countfrom(5,5))
    for i in Iterators.countfrom(5,5)
        @show i
        i<=15 || break
    end

   @show itr = Iterators.take(a, 3) # teks first 3 elements from a
   for i in itr
    @show i 
   end
   @show itr = Iterators.take(state_a, 3) # teks first 3 elements from a
   for i in itr
    @show i 
   end
   collect(state_a)
@show "dff"
   for i in Iterators.takewhile(i->i<5,a) # takes while first function returns true
        @show i
   end
   sum=0
   for i in Iterators.cycle(a) # takes elements cyclically 
    @show i
    @show    sum+=i 
        sum<=12 || break
   end
   b=[22,33]
   for i in Iterators.product(a,b)
        @show i
   end
   collect(Iterators.product(a,b))
   collect(Iterators.flatten((a,b))) # <= concatenates iteraors (input rgument  - tuple of iterators)
end

