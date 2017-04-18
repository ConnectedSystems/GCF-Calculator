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

function mod_get_gcf(func, params)
    params = sort(abs(params))
    sets = [func(params[1])]
    limit = max(sets[1]...)

    append!(sets, [func(val, limit) for val in params[2:end]])
    temp = Set(reduce(intersect, sets))

    return max(temp...)
end

function improved_modulo(val, limit=0)
    factors = [1, val]
    for x in 2:(val - 1)
        if limit != 0 && x > limit
            return factors
        end

        if (val % x) == 0
            push!(factors, x)
        end
    end
    return factors
end

function hinted_get_gcf(func, params::Array{Int, 1})::Int
    params = sort(abs(params))
    sets::Array{} = [func(params[1])]
    limit::Int = max(sets[1]...)

    append!(sets, func(val, limit) for val::Int in params[2:end])
    temp::Set{Int} = Set(reduce(intersect, sets))

    return max(temp...)
end

function hinted_modulo(val::Int, limit=0::Int)::Array{Int, 1}
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

function recursive(x1::Int, x2::Int)
    if x2 == 0
        return x1
    end

    return recursive(x2, x1 % x2)
end

values = [1600, 1200, 800]

println("Julia is JIT compiled, so we will run the functions multiple times")
println("Naive gcf with $(values)")
println(get_gcf(naive_jl, values))
@time get_gcf(naive_jl, values)
@time get_gcf(naive_jl, values)
@time get_gcf(naive_jl, values)

expanded = [1600, 1200, 800, 8000, 7260, 9800, 6520]
println("Naive gcf with $(expanded)")
println(get_gcf(naive_jl, expanded))
@time get_gcf(naive_jl, expanded)
@time get_gcf(naive_jl, expanded)
@time get_gcf(naive_jl, expanded)

println("Improved gcf with $(values)")
println(mod_get_gcf(improved_modulo, values))
@time mod_get_gcf(improved_modulo, values)
@time mod_get_gcf(improved_modulo, values)
@time mod_get_gcf(improved_modulo, values)

println("Improved gcf with $(expanded)")
println(mod_get_gcf(improved_modulo, expanded))
@time mod_get_gcf(improved_modulo, expanded)
@time mod_get_gcf(improved_modulo, expanded)
@time mod_get_gcf(improved_modulo, expanded)

println("Type hinted gcf, using $(expanded)")
println(hinted_get_gcf(hinted_modulo, expanded))
@time hinted_get_gcf(hinted_modulo, expanded)
@time hinted_get_gcf(hinted_modulo, expanded)
@time hinted_get_gcf(hinted_modulo, expanded)

println("Recursive approach")
println(reduce(recursive, abs(expanded)))
@time reduce(recursive, abs(expanded))
@time reduce(recursive, abs(expanded))
@time reduce(recursive, abs(expanded))
