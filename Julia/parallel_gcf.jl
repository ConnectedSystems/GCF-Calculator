# Run this file with `julia -p 3 parallel_gcf.jl` to get timings for parallel example
# the number after 'p' should be one less than the total number of physical cores on the machine.

include("gcf.jl")  # Evaluate all code within specified file

println("Extending to parallel processing was very easy")
srand(100)  # seed the random number generator
extra = rand(100000:2500000, 2000000)

function parallel_get_gcf(params::Array{Int, 1})::Array{Int, 1}

    res_arr::Array{Int, 1} = params[1:Int(round(length(params) / 2))]

    # @sync is important to include otherwise the loop is done asynchronously
    @sync res_arr = @parallel append! for i in 1:2:length(res_arr)
        [recursive(params[i], params[i+1])]
    end

    if length(res_arr) > 1
        res_arr = parallel_get_gcf(res_arr)
    end

    return res_arr
end

addprocs(3)

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
# println(parallel_get_gcf(recursive, extra))
@time parallel_get_gcf(extra)
@time parallel_get_gcf(extra)
@time parallel_get_gcf(extra)

# println("For comparison - single thread type hinted GCF")
# println(hinted_get_gcf(recursive, extra))
# @time hinted_get_gcf(recursive, extra)
# @time hinted_get_gcf(recursive, extra)
# @time hinted_get_gcf(recursive, extra)
