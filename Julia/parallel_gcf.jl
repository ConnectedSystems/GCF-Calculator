using BenchmarkTools

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

@everywhere function recursive(x1::Int, x2::Int)::Int
    if x2 == 0
        return x1
    end

    return recursive(x2, x1 % x2)
end

println("Extending to parallel processing was very easy")

search_vals = vec(readdlm("input.in", ' ', Int, skipstart=1))
println("Parallel GCF with array with ($length(search_vals)) elements")
println(parallel_get_gcf(search_vals))
t = @benchmark parallel_get_gcf($search_vals) samples=5 gcsample=true
println(mean(t))
