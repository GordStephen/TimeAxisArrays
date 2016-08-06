# Combing multiple TimeAxisArrays

`TimeAxisArray` combination methods are identical to those in `AxisArray`, but are documented here for convenience.

## Combining on existing axes

Multiple `TimeAxisArray`s can be joined together along an existing axis with `merge` - this can be thought of as an axis-aware form of concatenation:

```julia
a = TimeAxisArray(ones(5), 7:11)
b = TimeAxisArray(zeros(5), 1:5)
merge(a,b)
```

`merge` works along any number of axes. If an axis coordinate appears more than once in the `TimeAxisArray`s to be merged, the value in the last provided input is kept.

```julia
a = TimeAxisArray(ones(5,2), 1:5, [:A, :B])
b = TimeAxisArray(zeros(5,2), 3:7, [:B, :C])
merge(a,b)
```

As shown above, in some cases new array elements that were not defined in any of the inputs to the merge will be created. By default these values are zero, but they can be set to any arbitrary value with the `fillvalue` keyword:

```julia
merge(a,b, fillvalue=NaN)
```

## Combining into a new axis

`TimeAxisArrays` can also be combined so as to preserve elements at repeated axis coordinates by combining the inputs along a newly created axis with the `join` method:

```julia
join(a,b)
```

The name and values of the new axis can be specified using the `newaxis` keyword, and `fillvalue` can be provided as with `merge`:

```julia
join(a,b, newaxis=Axis{:Order}([:First, :Second]), fillvalue=NaN)
```

Inner, left, right, and outer join methods are supported, with outer used by default:

```julia
join(a, b, method=:outer) # same as join(a,b)
join(a, b, method=:left)
join(a, b, method=:right)
join(a, b, method=:inner)
```
