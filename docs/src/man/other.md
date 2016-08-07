# Other time series utilities

## Rolling reductions

`moving` applies a reduction function to a moving window of values and assigns the output value to the final timestamp in the window. For example, to take a 10-element moving average:

```julia
using TimeAxisArrays

a = TimeAxisArray(cumsum(ones(15)), Date(2000,1,1):Date(2000,1,15))
moving(a, mean, 10)
```

## Lead and lag

`lead` and `lag` shift all values forwards or backwards one timestamp:

```julia
lead(a)
```

## Absolute and percent differencing

`diff` subtracts the value at each timestamp from the value preceding it. By default differencing is only applied once, but optional higher order differencing is possible as well:

```julia
diff(a) # Difference of values
diff(a,2) # Difference of difference of values
```

`percentchange` performs a similar function, returning the percent difference between values at each timestamp and those immediately preceding them:

```julia
percentchange(a)
```

Setting the `logdiff` keyword to true provides the percent change as the difference of logged values:

```julia
percentchange(a, logdiff=true)
```
