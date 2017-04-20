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
srand(100)
params = rand(100000:2500000, 2000000)

println("Julia is JIT compiled, so we will run the functions multiple times")
println("Naive gcf with $(values)")
println(get_gcf(naive_jl, values))
@time get_gcf(naive_jl, values)
@time get_gcf(naive_jl, values)
@time get_gcf(naive_jl, values)

println("Recursive approach with $(params[1:10])...")
println(reduce(recursive, abs(params)))
@time reduce(recursive, abs(params))
@time reduce(recursive, abs(params))
@time reduce(recursive, abs(params))
