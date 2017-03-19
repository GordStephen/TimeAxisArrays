# Write to text (REPL)

maxstrwidth(x::AbstractVector, colname) = maximum(map(ts -> length(string(ts)), [x; colname]))

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

function paneltotext{T}(io::IO, A::TimeAxisArray{T,2})
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

function textrep{T}(io::IO, A::TimeAxisArray{T,1}, typealiasname::AbstractString)
    timestamps = A.axes[1].val
    n = length(timestamps)
    tsname = dimname(A.axes[1])
    tswidth = maxstrwidth(timestamps, tsname)
    valname = "Value"
    valwidth = maxstrwidth(A.data, valname)
    println(io, "$n-element $typealiasname{$T,1,...}:")
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

function textrep{T}(io::IO, A::TimeAxisArray{T,2}, typealiasname::AbstractString)
    println(io, "$(length(A.axes[1].val))x$(length(A.axes[2].val)) $typealiasname{$T,2,...}:")
    return paneltotext(io, A)
end #textrep 2D

function textrep{T,N}(io::IO, A::TimeAxisArray{T,N}, typealiasname::AbstractString)
    higherdimnames = Symbol[dimname(A.axes[i]) for i in 3:N]
    higherdimcategories = Vector{Symbol}[A.axes[i].val for i in 3:N]
    dimsizes = join(size(A), "x")
    println(io, "$dimsizes $typealiasname{$T,$N,...}:")
    for categoryset in product(higherdimcategories...)
        println(io, "\n", panellabeltotext(higherdimnames, collect(categoryset)))
        paneltotext(io, A[:,:,categoryset...])
    end #for
    return A.axes[1].val
end #textrep 3D+

function Base.show(io::IO, A::TimeAxisArray)
    timestamps = textrep(io, A, "TimeAxisArray")
    tsstart, tsend = timestamps[1], timestamps[end]
    print(io, "Spans $tsstart to $tsend")
    return nothing
end #show

function Base.show(io::IO, A::RegularTimeAxisArray)
    timestamps = textrep(io, A, "RegularTimeAxisArray")
    tsstart, tsend, tsinterval = timestamps[1], timestamps[end], step(timestamps)
    print(io, "Spans $tsstart to $tsend at intervals of $tsinterval")
    return nothing
end #show

# Read from disk

function readtimeaxisarray(f, timeparser::Function,
                           dataparser::Function=x->stringfallback(x, NaN);
                           timecol::Bool=true, header::Bool=true, namedaxes::Bool=false, defaultval=NaN,
                           headlines::Int=header?1:0, delim::Char=',', kwargs...)

    # Read in data
    rawdata = readdlm(f, delim, header=false; kwargs...)

    # Process array contents
    data = map(dataparser, rawdata[1+headlines:end,(1+timecol):end])

    # Process time axis
    timestamps = timecol ? map(timeparser, rawdata[1+headlines:end,1]) : map(timeparser, 1:size(data,1))
    timestamps = collect(promote(timestamps...))
    isregularspaced(timestamps) && (timestamps = timestamps[1]:(timestamps[2]-timestamps[1]):timestamps[end])

    # Process headers / higher dimension axes
    ndatacols = size(data,2)
    if ndatacols == 1
        A = TimeAxisArray(vec(data), timestamps)
    elseif !header
        A = TimeAxisArray(data, timestamps, [defaultcolumnnames[i] for i in 1:ndatacols])
    else
        headers = map(symbolize, rawdata[1:headlines, (1+timecol):end])
        dataaxisnames = (timecol && namedaxes) ?
            map(symbolize, rawdata[1:headlines,1]) : defaultaxisnames[2:headlines+1]
        axes = map(i -> Axis{dataaxisnames[i]}(unique(headers[i,:])), 1:headlines) |> reverse
        dims = tuple(length(timestamps), map(length, axes)...)
        A = TimeAxisArray(fill(defaultval, dims), timestamps, axes...)
        for col in 1:ndatacols
            A[:,reverse(vec(headers[:, col]))...] = data[:,col]
        end #for
    end #if

    return A

end #readdlm

# Write to disk

Base.writedlm{T}(f::AbstractString, A::TimeAxisArray{T,1}, delim::Char=',') = writedlm(f, Any[timestamps(A) A.data], delim)

function Base.writedlm{T,N}(f::AbstractString, A::TimeAxisArray{T,N}, delim::Char=',')

    fileArray = Matrix{Any}(size(A,1)+N-1,0)

    higherdimnames = Symbol[dimname(A.axes[i]) for i in 2:N]
    higherdimcategories = Vector{Symbol}[A.axes[i].val for i in 2:N]

    fileArray = [fileArray [reverse(higherdimnames); timestamps(A)]]

    for categoryset in product(higherdimcategories...)
        fileArray = [fileArray [reverse(collect(categoryset)); A[:,categoryset...].data]]
    end #for

    writedlm(f, fileArray, delim)

end #writedlm
