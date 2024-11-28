# to run this script one should:
# start julia processed using command line `julia -p 6` , 6 is the number of julia processes
# nworkers() - returns the number of workers
# using SharedArrays, Distributed arrays
# @everywhere include(this_script)

# distributed computing script

nfiled=100;
wdir=pwd();
@everywhere function read_val_file!(index, dest)
    filename = locate_file(index)
    (nstates, nattrs) = size(dest)[1:2]
    open(filename) do io
        nbytes = nstates * nattrs * 8
        buffer = read(io, nbytes)
        A = reinterpret(Float64, buffer)
        dest[:, :, index] = A
    end
end
function locate_file(i)
    id = i - 1
    dir = joinpath(wdir,string(id % 10)) # ten files in each directory
    joinpath(dir, "sec$(id).dat")
end
function load_data!(nfiles, dest)
    @sync @distributed for i in 1:nfiles
        read_val_file!(i, dest)
    end
end

#nfiles = 100
#nstates = 10_000
#nattr = 3
#valuation = SharedArray{Float64}(nstates, nattr, nfiles)
#load_data!(nfiles, valuation)