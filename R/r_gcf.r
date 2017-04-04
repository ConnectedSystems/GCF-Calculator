naive <- function(val) {
  
  factors <- c(1, val)
  
  for(x in seq(2:val-1)) {
    for(y in seq(x:val-1)){
      if((x * y) == val) {
        factors <- c(factors, c(y))
      }
    }
  }
  
  return(factors)
}

improved <- function(val, limit=0) {
  factors <- c(1)
  
  for(x in seq(2:val-1)) {
    if (limit > 0 && x > limit) {
      return(factors)
    }
    
    if ((val %% x) == 0) {
      factors <- c(factors, x)
    }  
  }
  
  return(factors)
}

get_gcf <- function(func, params) {
  sets <- lapply(lapply(params, abs), func)
  temp <- Reduce(intersect, sets)
  return(max(temp))
}

mod_get_gcf <- function(func, params) {
  params <- lapply(sort(params), abs)
  params <- unlist(params)
  sets <- func(params[1])
  limit <- max(sets)
  
  sets <- lapply(tail(params, length(params)-1), func, limit)
  
  temp <- Reduce(intersect, sets)
  return(max(temp))
}

vals <- c(1600, 1200, 800)

# Average of n runs...
n = 100
mean(replicate(n, system.time(get_gcf(naive, vals))[3]) )
# ~1.4 seconds

mean(replicate(n, system.time(mod_get_gcf(improved, vals))[3]) )
# 0.002 seconds = 2 milliseconds = 2000 microseconds

expanded <- c(1600, 1200, 800, 8000, 7260, 9800, 6520)
mean(replicate(n, system.time(mod_get_gcf(improved, expanded))[3]) )
# 0.006 seconds = 6 milliseconds = 6000 microseconds

