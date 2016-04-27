dimname{N}(a::Axis{N}) = N

timestamps(A::TimeAxisArray) = A.axes[1].val
interval(A::RegularTimeAxisArray) = A |> timestamps |> step

function isregularspaced(x::AbstractTimeVector)
    spacing = x[2:end] - x[1:end-1]
    i = 1
    regularspaced = true
    while regularspaced && i < length(spacing) 
        regularspaced = spacing[i] == spacing[i+1]
        i += 1
    end #while
    return regularspaced
end #isregularspaced

stringfallback(x, fallback) = x
stringfallback(x::AbstractString, fallback) = fallback

date(format::AbstractString="yyyy-mm-dd"; locale="english") = x -> Date(x, format, locale=locale)
datetime(format::AbstractString="yyyy-mm-ddTHH:MM:SS"; locale="english") = x -> DateTime(x, format, locale=locale)
