library(microbenchmark)

naive <- function(val) {

  factors <- c(1, val)

  for (x in seq(2:val - 1)) {
    for (y in seq(x:val - 1)){
      if ( (x * y) == val) {
        factors <- c(factors, c(y))
      }
    }
  }

  return(factors)
}

improved <- function(val, limit=0) {
  factors <- c(1)

  for (x in seq(2:val - 1)) {
    if (limit > 0 && x > limit) {
      return(factors)
    }

    if ( (val %% x) == 0) {
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
  params <- lapply(params, abs)
  params <- unlist(params)
  sets <- func(params[1])
  limit <- max(sets)

  sets <- lapply(tail(params, length(params) - 1), func, limit)

  temp <- Reduce(intersect, sets)
  return(max(temp))
}

recursive <- function(x1, x2) {
    if (x2 == 0) {
        return(x1)
    }

    return(recursive(x2, x1 %% x2))
}

vals <- c(1600, 1200, 800)

# microbenchmark(get_gcf(naive, vals))
# ~1.4 seconds

microbenchmark(mod_get_gcf(improved, vals))
# 1.8765 milliseconds = 1876.5 microseconds

expanded <- c(1600, 1200, 800, 8000, 7260, 9800, 6520, 1020, 10220, 16420)
microbenchmark(mod_get_gcf(improved, expanded))
# 3.92 milliseconds = 3920 microseconds

microbenchmark(Reduce(recursive, abs(expanded)))
# 49 microseconds

cat("With JIT compilation...")
cat("importing 2 million values...")
expanded <- scan("../data/input.in", skip = 1, what = integer())

library(compiler)
enableJIT(3)

# microbenchmark(mod_get_gcf(improved, expanded))

microbenchmark(Reduce(recursive, abs(expanded)))
