function random_access(data::Vector{UInt}, N::Integer)
    #@show n = rand(UInt)
    @show n = rand(UInt)
    mask = length(data) - 1
    @inbounds for i in 1:N
        @show n
        @show n>>>7
        b1 = n&mask
        @show b1
        @show n & mask + 1
        n = (n >>> 7) ⊻ data[n & mask + 1]
    end
    return n
end

random_access(UInt.([1,2,3]),5)

GC.