
# distributed computing script

# to run this script one should:
# start julia processed using command line `julia -p 6` , 6 is the number of julia processes
# nworkers() - returns the number of workers
# using SharedArrays, Distributed arrays
# include(this_script) - inside the script there are 

# further run this code in the REPL


#load_data!(nfiles, valuation)

# after that we have 
using SharedArrays,DistributedArrays
@everywhere wdir="D:/temp/" # every worker knows this variable
@everywhere function read_val_file!(index, dest) # here index is the number of page of the shared array
    filename = locate_file(index) # generate the full path by file index
    (nstates, nattrs) = size(dest)[1:2] # we need the size of one page of the shared array to obtain the the number of double to be 
    # read from the file 
    open(filename) do io
        nbytes = nstates * nattrs * 8 # each variable has equght bited (64 bits)
        buffer = read(io, nbytes) # returns an array of  bites 
        A = reinterpret(Float64, buffer) # reinterprets memory region to another format
        dest[:, :, index] = A # writing the matrix A to the specified page of the array
    end
end
@everywhere function locate_file(i)
    id = i - 1
    dir = joinpath(wdir,string(id % 10)) # ten files in each directory
    joinpath(dir, "sec$(id).dat")
end
function load_data!(nfiles, dest)
    @sync @distributed for i in 1:nfiles # @distributed evalautes each iteration on specified worker
        read_val_file!(i, dest)
    end 
end
@everywhere using Statistics: std, mean, median
@everywhere using StatsBase: skewness, kurtosis

function  std_var(dest)
    rasult_
end
nfiles = 100
nstates = 10_000
nattr = 3
valuation = SharedArray{Float64}(nstates, nattr, nfiles)
#load_data!(nfiles, valuation)
function std_direct(input_array) 
    # this function evaluates directly
    (nstates,nattr,n)=size(input_array)
    result=zeros(n,nattr)
    
    for i in 1:n
        for j in 1:nattr
            result[i,j]=std(input_array[:,j,i])
        end
    end
    return result
end

@everywhere function std_everywhere(input_array) 
    # this function evaluates everuwhere
    (nstates,nattr,n)=size(input_array)
    result=SharedArray{Float64}(n,nattr)
    @sync @distributed for i in 1:n
        for j in 1:nattr
            result[i,j]=std(input_array[:,j,i])
        end
    end
    return result
end
function stats_by_security(valuation, funcs)
    (nstates, nattr, n) = size(valuation)
    result = zeros(n, nattr, length(funcs))
    for i in 1:n
        for j in 1:nattr
            for (k, f) in enumerate(funcs)    
                result[i, j, k] = f(valuation[:, j, i])
            end
        end
    end
    return result
end
function stats_by_security2(valuation, funcs)
    (nstates, nattr, n) = size(valuation)
    result = SharedArray{Float64}((n, nattr, length(funcs)))
    @sync @distributed    for i in 1:n
         for j in 1:nattr   
            for (k, f) in enumerate(funcs)
                result[i, j, k] = f(valuation[:, j, i])
            end
        end
    end
    return result
end
funcs = (std,skewness,kurtosis)