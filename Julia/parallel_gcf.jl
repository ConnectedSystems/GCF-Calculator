# Run this file with `julia -p 3 parallel_gcf.jl` to get timings for parallel example
# the number after 'p' should be one less than the total number of physical cores on the machine.

include("gcf.jl")  # Evaluate all code within specified file

println("Extending to parallel processing was very easy")
srand(100)  # seed the random number generator
extra = rand(16000:151296,10000)  # random number between 16000 to 151296, array of 1 by 10000

function parallel_get_gcf(func, params::Array{Int, 1})::Int
    params = sort(abs(params))
    m = size(params)[1]
    sets::Array{Any, 1} = []
    push!(sets, func(params[1]))
    limit::Int = max(sets[1]...)

    # @sync is important to include otherwise the loop is done asynchronously
    @sync sets = @parallel append! for i in params[2:m]
        [func(i, limit)]
    end

    temp::Set{Int} = Set(reduce(intersect, sets))
    return max(temp...)
end

# Redefine example function with @everywhere macro
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

array_size = size(extra)
println("Parallel GCF with array with ($array_size) elements")
println(parallel_get_gcf(hinted_modulo2, extra))
@time parallel_get_gcf(hinted_modulo2, extra)
@time parallel_get_gcf(hinted_modulo2, extra)
@time parallel_get_gcf(hinted_modulo2, extra)

println("For comparison - single thread type hinted GCF")
println(hinted_get_gcf(hinted_modulo, extra))
@time hinted_get_gcf(hinted_modulo, extra)
@time hinted_get_gcf(hinted_modulo, extra)
@time hinted_get_gcf(hinted_modulo, extra)
