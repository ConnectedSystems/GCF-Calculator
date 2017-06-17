using BenchmarkTools

function get_gcf(func, params)
    sets = map(func, abs(params))
    temp = Set(reduce(intersect, sets))

    return max(temp...)
end

function naive_jl(val)
    factors = [1, val]
    for x in 2:(val - 1)
        for y in x:val
            if (x * y) == val
                append!(factors,[x,y])
            end
        end
    end
    return factors
end

function recursive(x1::Int, x2::Int)::Int
    if x2 == 0
        return x1
    end

    return recursive(x2, x1 % x2)
end

values = [1600, 1200, 800]

println("Julia is JIT compiled, so we will run the functions multiple times to get indicative timing")
println("Naive gcf with $(values)")
println(get_gcf(naive_jl, values))
t = @benchmark get_gcf($naive_jl, $values) samples=100 gcsample=true
println("Mean: ", mean(t), " Median: ", median(t))

search_vals = readdlm("../data/input.in", ' ', Int, skipstart=1)
println("Recursive approach with $(length(search_vals)) values...")
println(reduce(recursive, abs(search_vals)))
t = @benchmark reduce($recursive, abs($search_vals)) samples=100 gcsample=true
println("Mean: ", mean(t), " Median: ", median(t))
