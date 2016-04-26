module TimeAxisArrays

using AxisArrays
using Iterators

export RegularTimeAxisArray

typealias CategoricalAxis{S} Axis{S, Vector{Symbol}}
typealias RegularTimeAxis{R<:Range} Axis{:Timestamp, R}
typealias RegularTimeAxisArray{T,N,D,Ax<:Tuple{RegularTimeAxis,Vararg{CategoricalAxis}}} AxisArray{T,N,D,Ax}

call(::Type{RegularTimeAxisArray}, data::AbstractArray, timestamps::Range, axes::Axis...) =
    AxisArray(data, Axis{:Timestamp}(timestamps), axes...)

maxstrwidth(x::AbstractVector, colname) = maximum(map(ts -> length(string(ts)), [x; colname]))

dimname{N}(a::Axis{N}) = N

function padval(val, maxlength::Int, center::Bool)
    paddingrequired = max(0, maxlength - length(string(val)))
    strval = string(val)
    center ?
    repeat(" ", floor(Int,paddingrequired/2)) * strval * repeat(" ", ceil(Int,paddingrequired/2)) :
    strval * repeat(" ", paddingrequired)
end #padval

showline(io, ts, tswidth::Int, val, valwidth::Int; center::Bool=false) =
    println(io, "┃ $(padval(ts,tswidth,center)) ┃ $(padval(val,valwidth,center)) ┃")

showline(io, ts, tswidth::Int, vals::AbstractArray, valwidths::Vector{Int}; center::Bool=false) =
    showline(io, ts, tswidth, vec(vals), valwidths, center=center)

showline(io, ts, tswidth::Int, vals::AbstractVector, valwidths::Vector{Int}; center::Bool=false) =
    println(io, "┃ $(padval(ts, tswidth, center)) ┃ $(showinnerline(vals, valwidths, center)) ┃")

showinnerline(colvals::AbstractVector, colwidths::Vector{Int}, center::Bool=false) =
    join(map((colval, colwidth) -> padval(colval, colwidth, center), colvals, colwidths), " │ ")

hline(colwidths::Vector{Int}, line::AbstractString, joiner::AbstractString) =
    join(map(colwidth -> repeat(line, colwidth+2), colwidths), joiner)

function paneltotext{T}(io::IO, A::RegularTimeAxisArray{T,2})
    timestamps, colnames = A.axes[1].val, A.axes[2].val
    n, m = length(timestamps), length(colnames)
    tsname = "$(dimname(A.axes[1])) \\ $(dimname(A.axes[2]))"
    tswidth = maxstrwidth(timestamps, tsname)
    colwidths = map(colname -> maxstrwidth(A[:,colname].data, string(colname)), colnames)
    totalcolswidth = sum(colwidths) + 3(length(colnames)-1 - 2)
    println(io, "┏",repeat("━", tswidth + 2), "┳", hline(colwidths, "━", "┯"), "┓")
    showline(io, tsname, tswidth, colnames, colwidths, center=true)
    println(io, "┠",repeat("─", tswidth + 2), "╂", hline(colwidths, "─", "┼"),"┨")
    if n < 9
        [showline(io, timestamps[i], tswidth, A[i,:].data, colwidths) for i in eachindex(timestamps)]
    else
        [showline(io, timestamps[i], tswidth, A[i,:].data, colwidths) for i in 1:4]
        showline(io, "⋮", tswidth, repmat(["⋮"], m), colwidths, center=true)
        [showline(io, timestamps[i], tswidth, A[i,:].data, colwidths) for i in n-3:n]
    end
    println(io, "┗",repeat("━", tswidth + 2), "┻", hline(colwidths, "━", "┷"), "┛")
    return timestamps
end #paneltotext

panellabeltotext(ns::Vector{Symbol}, cs::Vector{Symbol}) = join(map((n,c) -> "$n: $c", ns, cs), ", ")

function textrep{T}(io::IO, A::RegularTimeAxisArray{T,1})
    timestamps = A.axes[1].val
    n = length(timestamps)
    tsname = dimname(A.axes[1])
    tswidth = maxstrwidth(timestamps, tsname)
    valname = "Value"
    valwidth = maxstrwidth(A.data, valname)
    println(io, "$n-element RegularTimeAxisArray{$T,1,...}:")
    println(io, "┏",repeat("━", tswidth + 2), "┳", repeat("━", valwidth + 2),"┓")
    showline(io, tsname, tswidth, valname, valwidth, center=true)
    println(io, "┠",repeat("─", tswidth + 2), "╂", repeat("─", valwidth + 2),"┨")
    if n < 9
        [showline(io, timestamps[i], tswidth, A.data[i], valwidth) for i in eachindex(timestamps)]
    else
        [showline(io, timestamps[i], tswidth, A.data[i], valwidth) for i in 1:4]
        showline(io, "⋮", tswidth, "⋮", valwidth, center=true)
        [showline(io, timestamps[i], tswidth, A.data[i], valwidth) for i in n-3:n]
    end
    println(io, "┗",repeat("━", tswidth + 2), "┻", repeat("━", valwidth + 2),"┛")
    return timestamps
end #textrep 1D

function textrep{T}(io::IO, A::RegularTimeAxisArray{T,2})
    println(io, "$(length(A.axes[1].val))x$(length(A.axes[2].val)) RegularTimeAxisArray{$T,2,...}:")
    return paneltotext(io, A)
end #textrep 2D

function textrep{T,N}(io::IO, A::RegularTimeAxisArray{T,N})
    higherdimnames = Symbol[dimname(A.axes[i]) for i in 3:N]
    higherdimcategories = Vector{Symbol}[A.axes[i].val for i in 3:N]
    dimsizes = join(size(A), "x")
    println(io, "$dimsizes RegularTimeAxisArray{$T,$N,...}:")
    for categoryset in product(higherdimcategories...)
        println(io, "\n", panellabeltotext(higherdimnames, collect(categoryset)))
        paneltotext(io, A[:,:,categoryset...])
    end #for
    return A.axes[1].val
end #textrep 3D+

function Base.writemime(io::IO, m::MIME"text/plain", A::RegularTimeAxisArray)
    timestamps = textrep(io, A)
    tsstart, tsend, tsinterval = timestamps[1], timestamps[end], step(timestamps)
    print(io, "Spans $tsstart to $tsend at intervals of $tsinterval")
    return nothing
end #writemime

end # module
