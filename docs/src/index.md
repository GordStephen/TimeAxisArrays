# TimeAxisArrays.jl
_A convenience wrapper around AxisArrays.jl for working with time series data_

TimeAxisArrays.jl augments [AxisArrays.jl](https://github.com/mbauman/AxisArrays.jl) with functionality for time series analysis. A `TimeAxisArray` is simply an `AxisArray` with the first axis constrained to be dimensional and labelled `:Timestamp`, and all remaining axes categorical. It inherits all `AxisArray` functionality such as indexing, merging and joining, and math and logic operations, while gaining additional functionality for common time series operations such as temporal downsampling, differencing, lead, and lag.

This package is currently a work-in-progress and so is unregistered - to install, first install [AxisArrays.jl](https://github.com/mbauman/AxisArrays.jl) (which is also unregistered) and run:

```julia
julia> Pkg.clone("https://github.com/GordStephen/TimeAxisArrays.jl")
```

## Contents

```@contents
Pages = [
    "man/getting-started.md",
    "man/combining.md",
    "man/downsampling.md",
	"man/other.md",
    "man/file-io.md"
]
Depth = 2
```
