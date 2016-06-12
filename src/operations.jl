"""
    split(A::TimeAxisArray, f::Function)

Returns an array containing sequential fragments of `A`, split according to clusters of values in the mapping of `f` over the timestamps of `A`.
"""
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

# TODO: For collapse and moving, include option (default?) to lift basic 1D->scalar reducer
#       (rather than hope the supplied function does the right thing and work along the first dimension)
"""
    collapse(A::TimeAxisArray, tsreducer::Function, reducer::Function=tsreducer)

Collapses the timestamps of `A` to a single observation in the time dimension using `tsreducer`. Data is collapsed in the time dimension using `reducer`, which defaults to `tsreducer`.
"""
collapse(A::TimeAxisArray, tsreducer::Function, reducer::Function=tsreducer) =
    TimeAxisArray(reducer(A.data), tsreducer(timestamps(A)), A.axes[2:end]...)

"""
    downsample(A::TimeAxisArray, splitter::Function, tsreducer::Function, reducer::Function=tsreducer)

Combines `split`, `collapse`, and `vcat` to partition `A` according to sequential values in the mapping of `splitter` over the timestamps of `A`, then collapses each of the split TimeAxisArrays according to `tsreducer` (for timestamps) and `reducer` (for data), before recombining the collapsed values.
"""
downsample(A::TimeAxisArray, splitter::Function, tsreducer::Function, reducer::Function=tsreducer) =
    vcat(map(a -> collapse(a, tsreducer, reducer), split(A, splitter))...)

# # TODO: Allow for time-based interval selection (rather than fixed integer range window)
function moving{T}(A::TimeAxisArray{T}, reducer::Function, window::Int)
    data = reducer(A[Axis{:Timestamp}(1:window)].data)
    for i in 2:(size(A,1)+1-window)
        data = vcat(data, reducer(A[Axis{:Timestamp}(i:i+window-1)].data))
    end #for
    return TimeAxisArray(data, timestamps(A)[window:end], A.axes[2:end]...)
end #moving

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

function percentchange(A::TimeAxisArray; logdiff::Bool=false)
    n = size(A,1)
    return logdiff ? diff(map(log,A)) : TimeAxisArray(A[Axis{:Timestamp}(2:n)] ./  A[Axis{:Timestamp}(1:n-1)] .- 1, timestamps(A)[2:end], A.axes[2:end]...)
end #percentchange

function dropif(selector::Function, predicate::Function, A::TimeAxisArray)
    keepers = Int[]
    for i in 1:size(A,1)
        !selector(predicate, A[Axis{:Timestamp}(i)]) && push!(keepers, i)
    end #for
    return A[Axis{:Timestamp}(keepers)]
end #dropif

dropnan(A::TimeAxisArray, selector::Function=all) = dropif(selector, isnan, A)
