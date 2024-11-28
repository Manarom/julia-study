
# distributed computing script

# to run this script one should:
# start julia processed using command line `julia -p 6` , 6 is the number of julia processes
# nworkers() - returns the number of workers
# using SharedArrays, Distributed arrays
# include(this_script) - inside the script there are 

# further run this code in the REPL


#load_data!(nfiles, valuation)

# after that we have 

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
@everywhere using Statistics:std
function  std_var(dest)
    rasult_
end
nfiles = 100
nstates = 10_000
nattr = 3
valuation = SharedArray{Float64}(nstates, nattr, nfiles)
#load_data!(nfiles, valuation)
