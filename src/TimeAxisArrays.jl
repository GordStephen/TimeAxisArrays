module TimeAxisArrays

using Reexport, Iterators
@reexport using AxisArrays

export TimeAxisArray, RegularTimeAxisArray,
readtimeaxisarray, date, datetime

symbolize(x) = x |> string |> symbol
defaultaxisnames = map(symbolize, ["Timestamp"; "Column"; map(i -> "Axis$i", 3:10)])
defaultcolumnnames = map(symbolize, 'A':'Z')

typealias AbstractTimeVector{T<:Union{Number,Dates.AbstractTime}} AbstractVector{T}

typealias CategoricalAxis{T} Axis{T, Vector{Symbol}}
typealias TimeAxis{T<:AbstractTimeVector} Axis{defaultaxisnames[1], T}
typealias RegularTimeAxis{T<:Range} Axis{defaultaxisnames[1], T}

typealias TimeAxisArray{T,N,D,Ax<:Tuple{TimeAxis,Vararg{CategoricalAxis}}} AxisArray{T,N,D,Ax}
typealias RegularTimeAxisArray{T,N,D,Ax<:Tuple{RegularTimeAxis,Vararg{CategoricalAxis}}} AxisArray{T,N,D,Ax}

call(::Type{TimeAxisArray}, data::AbstractArray, timestamps::AbstractTimeVector, axes::CategoricalAxis...) =
    AxisArray(data, Axis{defaultaxisnames[1]}(timestamps), axes...)

call(::Type{TimeAxisArray}, data::AbstractMatrix, timestamps::AbstractTimeVector, columns::Vector{Symbol}) =
    TimeAxisArray(data, timestamps, Axis{defaultaxisnames[2]}(columns))

include("io.jl")
include("utilities.jl")

end # module
