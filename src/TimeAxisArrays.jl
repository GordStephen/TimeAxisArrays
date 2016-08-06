module TimeAxisArrays

using Reexport, Iterators
@reexport using AxisArrays

export TimeAxisArray, RegularTimeAxisArray,
timestamps, interval,
collapse, downsample, moving,
lead, lag, percentchange,
dropif, dropnan,
readtimeaxisarray, date, datetime

symbolize(x) = x |> string |> symbol
defaultaxisnames = map(symbolize, ["Timestamp"; "Column"; map(i -> "Axis$i", 3:10)])
defaultaxisvalues = map(symbolize, 'A':'Z')

# Typealiases

typealias Timestamp Union{Number,Dates.AbstractTime}
typealias AbstractTimeVector{T<:Timestamp} AbstractVector{T}
typealias CategoryVector Vector{Symbol}

typealias CategoricalAxis{T} Axis{T, CategoryVector}
typealias TimeAxis{T<:AbstractTimeVector} Axis{defaultaxisnames[1], T}
typealias RegularTimeAxis{T<:Range} Axis{defaultaxisnames[1], T}

typealias TimeAxisArray{T,N,D,Ax<:Tuple{TimeAxis,Vararg{CategoricalAxis}}} AxisArray{T,N,D,Ax}
typealias RegularTimeAxisArray{T,N,D,Ax<:Tuple{RegularTimeAxis,Vararg{CategoricalAxis}}} AxisArray{T,N,D,Ax}

# Helper functions

maketimeaxis(timestamps::AbstractTimeVector) =
    Axis{defaultaxisnames[1]}(timestamps)

makecategoricalaxes(axesvals) = #TODO: Precise typing
    map((n,vs) -> Axis{n}(vs), defaultaxisnames[2:length(axesvals)+1], axesvals)

# Constructors

## 1-D TimeAxisArray

call(::Type{TimeAxisArray}, data::AbstractArray, timestamps::AbstractTimeVector) =
    AxisArray(data, maketimeaxis(timestamps))

call(::Type{RegularTimeAxisArray}, data::AbstractArray, timestamps::Range) =
    TimeAxisArray(data, timestamps)

## Custom higher-axis values with automatic names

call(::Type{TimeAxisArray}, data::AbstractArray, timestamps::AbstractTimeVector, axesvals::CategoryVector...) =
    AxisArray(data, maketimeaxis(timestamps), makecategoricalaxes(axesvals)...)

call(::Type{RegularTimeAxisArray}, data::AbstractArray, timestamps::Range, axesvals::CategoryVector...) =
    TimeAxisArray(data, timestamps, axesvals...)

## Custom higher-axis values with custom higher-axis names

call(::Type{TimeAxisArray}, data::AbstractArray, timestamps::AbstractTimeVector, axes::CategoricalAxis...) =
    AxisArray(data, maketimeaxis(timestamps), axes...)

call(::Type{RegularTimeAxisArray}, data::AbstractArray, timestamps::Range, axes::CategoricalAxis...) =
    TimeAxisArray(data, timestamps, axes...)

include("operations.jl")
include("io.jl")
include("utilities.jl")

end # module
