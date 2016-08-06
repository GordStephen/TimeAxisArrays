# Getting Started

## Creating `TimeAxisArray`s

A simple one-dimensional`TimeAxisArray` can be created with as:

```julia
using TimeAxisArrays

tstamps = 1:10
data = randn(10)
TimeAxisArray(data, timestamps)
```

Timestamps can be any sortable type. For example, `Date`s or `DateTime`s are often useful as timestamps:

```julia
tstamps = Date(2000,1,1):Date(2000,1,10)
TimeAxisArray(data, timestamps)
```

In additional to a temporal dimension, `TimeAxisArray`s can store data across an arbitrary number of categorical dimensions as well. For example:

```julia
data = randn(10, 3, 2)
TimeAxisArray(data, timestamps, [:Red, :Green, :Blue], [:Apple, :Banana])
```

The first dimension (axis) is always called `Timestamp`. Subsequent axes are automatically assigned names, but can be given custom names as well:

```julia
a = TimeAxisArray(data, timestamps, Axis{:Color}([:Red, :Green, :Blue]), Axis{:Fruit}([:Apple, :Banana]))

```

## Indexing

Indexing is identical to `AxisArray`s. As with standard `Array`s, individual elements or ranges can be accessed by providing the relevant value along each axis:

```julia
a[Date(2000,1,3), :Green, :Banana]
a[Date(2000,1,3), [:Red, :Blue], :Banana]
a[Date(2000,1,3), :, :Banana]
```
In some cases it's preferable to only reference data according to a specific axis. In those cases the `Axis` constructor can be used:

```julia
a[Axis{:Fruit}(:Banana)]
```

Finally, all timestamps in a given interval can be selected with `..`:

```julia
a[Date(2000,1,3) .. Date(2000,1,7), :, :]
a[Date(2000,1,3) .. Date(2000,1,7), [:Red, :Blue], :Banana]
```
