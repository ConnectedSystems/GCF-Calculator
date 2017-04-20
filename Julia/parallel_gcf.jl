include("gcf.jl")  # Evaluate all code within specified file

println("Extending to parallel processing was very easy")
srand(100)  # seed the random number generator
extra = rand(100000:2500000, 2000000)

# Number of processors to use, should be 1 less than num of physical cores.
addprocs(3)

function parallel_get_gcf(params::Array{Int, 1})::Int

    params = abs(params)
    tmp::Int = Int(round(length(params) / 2))

    # @sync is important to include otherwise the loop is done asynchronously
    @sync res::Int = @parallel reduce for i in 1:2:tmp
        [recursive(params[i], params[i+1])]
    end

    return res
end

# Redefine example function with @everywhere macro to make the function available on all processes
@everywhere function hinted_modulo2(val::Int, limit=0::Int)::Array{Int, 1}
    factors::Array{Int,1} = []
    for x::Int in 1:val
        if limit != 0 && x > limit
            return factors
        end

        if (val % x) == 0
            push!(factors, x)
        end
    end
    return factors
end

@everywhere function recursive(x1::Int, x2::Int)::Int
    if x2 == 0
        return x1
    end

    return recursive(x2, x1 % x2)
end

array_size = size(extra)
println("Parallel GCF with array with ($array_size) elements")
println(parallel_get_gcf(extra))
@time parallel_get_gcf(extra)
@time parallel_get_gcf(extra)
@time parallel_get_gcf(extra)
