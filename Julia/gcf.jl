function get_gcf(func, params)
    sets = map(func, map(abs, params))
    temp = Set(reduce((x, y) -> intersect(x, y), sets ))
    
    return max(temp...)
end

function naive_jl(val)
    factors = []
    for x in 1:val
        for y in x:val
            if (x * y) == val
                append!(factors,[x,y])
            end
        end
    end
    return factors
end

function mod_get_gcf(func, params)
    params = sort(map(abs, params))
    sets = []
    push!(sets, func(params[1]))
    limit = max(sets[1]...)
    
    append!(sets, [func(val, limit) for val in params[2:end]])
    temp = Set(reduce((x, y) -> intersect(x,y), sets))
    
    return max(temp...)
end

function improved_modulo(val, limit=0)
    factors = []
    for x in 1:val
        if limit != 0 && x > limit
            return factors
        end
        
        if (val % x) == 0
            push!(factors, x)
        end
    end
    return factors
end

function hinted_get_gcf(func, params::Array{Int64, 1})::Int64
    params = sort(map(abs, params))
    sets = []
    push!(sets, func(params[1]))
    limit = max(sets[1]...)
    
    append!(sets, [func(val, limit) for val in params[2:end]])
    temp = Set(reduce((x, y) -> intersect(x,y), sets))
    
    return max(temp...)
end

function hinted_modulo(val, limit=0::Int)::Array{Int64, 1}
    factors = []
    for x in 1:val
        if limit != 0 && x > limit
            return factors
        end
        
        if (val % x) == 0
            push!(factors, x)
        end
    end
    return factors
end

values = [1600, 1200, 800]

println("Julia is JIT compiled, so we will run the functions multiple times")
println("Naive gcf with $(values)")
@time get_gcf(naive_jl, values)
@time get_gcf(naive_jl, values)
@time get_gcf(naive_jl, values)

expanded = [1600, 1200, 800, 8000, 7260, 9800, 6520]
println("Naive gcf with $(expanded)")
@time get_gcf(naive_jl, expanded)
@time get_gcf(naive_jl, expanded)
@time get_gcf(naive_jl, expanded)

println("Improved gcf with $(values)")
@time mod_get_gcf(improved_modulo, values)
@time mod_get_gcf(improved_modulo, values)
@time mod_get_gcf(improved_modulo, values)

println("Improved gcf with $(expanded)")
@time mod_get_gcf(improved_modulo, expanded)
@time mod_get_gcf(improved_modulo, expanded)
@time mod_get_gcf(improved_modulo, expanded)

println("Type hinted gcf, using $(expanded)")
@time hinted_get_gcf(hinted_modulo, expanded)
@time hinted_get_gcf(hinted_modulo, expanded)
@time hinted_get_gcf(hinted_modulo, expanded)