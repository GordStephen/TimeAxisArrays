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
defaultcolumnnames = map(symbolize, 'A':'Z')

typealias Timestamp Union{Number,Dates.AbstractTime}
typealias AbstractTimeVector{T<:Timestamp} AbstractVector{T}

typealias CategoricalAxis{T} Axis{T, Vector{Symbol}}
typealias TimeAxis{T<:AbstractTimeVector} Axis{defaultaxisnames[1], T}
typealias RegularTimeAxis{T<:Range} Axis{defaultaxisnames[1], T}

typealias TimeAxisArray{T,N,D,Ax<:Tuple{TimeAxis,Vararg{CategoricalAxis}}} AxisArray{T,N,D,Ax}
typealias RegularTimeAxisArray{T,N,D,Ax<:Tuple{RegularTimeAxis,Vararg{CategoricalAxis}}} AxisArray{T,N,D,Ax}

call(::Type{TimeAxisArray}, data::AbstractArray, timestamps::AbstractTimeVector, axes::CategoricalAxis...) =
    AxisArray(data, Axis{defaultaxisnames[1]}(timestamps), axes...)

call(::Type{TimeAxisArray}, data::AbstractMatrix, timestamps::AbstractTimeVector, columns::Vector{Symbol}) =
    TimeAxisArray(data, timestamps, Axis{defaultaxisnames[2]}(columns))

call(::Type{TimeAxisArray}, data::AbstractArray, timestamp::Timestamp, axes::CategoricalAxis...) =
    TimeAxisArray(reshape(data, 1, size(data)...), [timestamp], axes...)

call(::Type{TimeAxisArray}, data, timestamp::Timestamp, axes::CategoricalAxis...) =
    TimeAxisArray([data], [timestamp], axes...)

call(::Type{RegularTimeAxisArray}, data::AbstractMatrix, timestamps::Range, columns::Vector{Symbol}) =
    TimeAxisArray(data, timestamps, columns)

call(::Type{RegularTimeAxisArray}, data::AbstractArray, timestamps::Range, axes::CategoricalAxis...) =
    TimeAxisArray(data, timestamps, axes...)

include("operations.jl")
include("io.jl")
include("utilities.jl")

end # module
