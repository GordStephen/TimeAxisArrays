function Base.split(A::TimeAxisArray, f::Function)

    discriminants = map(f, timestamps(A))
    n = length(discriminants)

    clusterstart = 1
    splits = UnitRange{Int}[]
    for i in 2:n
        if discriminants[i] !== discriminants[i-1]
            push!(splits, clusterstart:i-1)
            clusterstart = i
        end #if
    end #for
    push!(splits, clusterstart:n)

    return map(s -> A[Axis{:Timestamp}(s)], splits)

end #split

# For use with do-notation
Base.split(f::Function, A::TimeAxisArray) = Base.split(A, f)

function Base.vcat(taas::TimeAxisArray...)
    ts = vcat(map(timestamps, taas)...)
    data = vcat(map(taa -> taa.data, taas)...)
    return TimeAxisArray(data, ts, taas[1].axes[2:end]...)
end #vcat

# TODO: Lift basic 1D->scalar reducer (rather than hope the supplied function does the right thing)
collapse{T,N}(A::TimeAxisArray{T,N}, tsreducer::Function, reducer::Function=tsreducer) =
    TimeAxisArray(reducer(A.data), [tsreducer(timestamps(A))], A.axes[2:end]...)

downsample{T,N}(A::TimeAxisArray{T,N}, splitter::Function, tsreducer::Function, reducer::Function=tsreducer) =
    vcat(map(a -> collapse(a, tsreducer, reducer), split(A, splitter))...)

moving(A::TimeAxisArray) = nothing

function lag(A::TimeAxisArray, k::Int=1)
    n = size(A,1)
    return TimeAxisArray(A[Axis{:Timestamp}(1:n-k)].data, timestamps(A)[1+k:n], A.axes[2:end]...)
end #lag

function lead(A::TimeAxisArray, k::Int=1)
    n = size(A,1)
    return TimeAxisArray(A[Axis{:Timestamp}(1+k:n)].data, timestamps(A)[1:n-k], A.axes[2:end]...)
end #lead

Base.diff(A::TimeAxisArray, k::Int=1) = if k == 1
    n = size(A,1)
    return TimeAxisArray(A[Axis{:Timestamp}(2:n)].data .- A[Axis{:Timestamp}(1:n-1)].data, timestamps(A)[2:n], A.axes[2:end]...)
else
    return diff(diff(A, k-1))
end #if

percentchange(A::TimeAxisArray; logresult::Bool=false) =
    logresult ? diff(map(log,A)) : map(expm1, percentchange(A, logresult=true))

function dropif(selector::Function, predicate::Function, A::TimeAxisArray)
    keepers = Int[]
    for i in 1:size(A,1)
        !selector(predicate, A[Axis{:Timestamp}(i)]) && push!(keepers, i)
    end #for
    return A[Axis{:Timestamp}(keepers)]
end #dropif

dropnan(A::TimeAxisArray, selector::Function=all) = dropif(selector, isnan, A)
