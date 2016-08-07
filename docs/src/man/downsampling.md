# Splitting, collapsing, and downsampling on timestamps

## Splitting

`split` partitions a `TimeAxisArray` into subgroups of array elements according to sequential timestamps that return the same value for some function. For example, to split apart a `TimeAxisArray` into multiple parts corresponding to different weeks:

```julia
using TimeAxisArrays

a = TimeAxisArray(randn(10), Date(2000,1,1):Date(2000,1,14))
split(a, Dates.week)
```

## Collapsing

`collapse` reduces a `TimeAxisArray` to a single timestamp and corresponding values in each higher dimension. For example, to take the first timestamp of the input and the first value timewise in each other axis:

```julia
b = TimeAxisArray(randn(5,3), Date(2000,1,1):Date(2000,1,:5), [:A, :B, :C])
collapse(a, first)
```

The value reduction function can optionally be specified separately from the timestamp reducer:

```julia
collapse(b, first, sum)
```

## Downsampling

`downsample` combines `split` and `collapse` to group clusters of values in time, and then reduce the clusters to single values. For example, to downsample observations to a weekly average labelled by the first day of the week:

```julia
downsample(a, Dates.week, first, mean)
```
