function Base.filter(f::Function, A::TimeAxisArray)

    n = size(A,1)
    predresults = Array{Bool}(n)
    tstamps = timestamp(A)

    for i in 1:n
        ts = tstamps[i]
        predvals[i] = f(ts, A[Axis{:Timestamp}(ts)])
    end #for

    return A[Axis{:Timestamp}(predvals)]
end #filter

filtertimestamps(f::Function, A::TimeAxisArray) = filter((ts,v)->f(ts), A)
filtervalues(f::Function, A::TimeAxisArray) = filter((ts,v)->f(v), A)

"""
    split(A::TimeAxisArray, f::Function)

Returns an array containing sequential fragments of `A`, split according to clusters of values in the mapping of `f` over the timestamps of `A`. `split(f, A)` is also defined so as to support do-notation.
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

applytimewise(f::Function, A::AbstractArray) = if ndims(A) == 1
    return [f(A)]
else
    higherdimsizes = size(A)[2:end]
    result = Array{typeof(f(A[1]))}(1, higherdimsizes...)
    for inds in product(map(n->1:n, higherdimsizes)...)
        result[1, inds...] = f(A[:, inds...])
    end #for
    return result
end #applytimewise

"""
    collapse(A::TimeAxisArray, tsreducer::Function, reducer::Function=tsreducer)

Collapses the timestamps of `A` to a single observation in the time dimension using `tsreducer`. Data is collapsed in the time dimension using `reducer`, which defaults to `tsreducer`.
"""
collapse(A::TimeAxisArray, tsreducer::Function, reducer::Function=tsreducer; lift::Bool=true) = lift ?
    TimeAxisArray(applytimewise(reducer, A.data), [tsreducer(timestamps(A))], A.axes[2:end]...) :
    TimeAxisArray(reducer(A.data), [tsreducer(timestamps(A))], A.axes[2:end]...)

"""
    downsample(A::TimeAxisArray, splitter::Function, tsreducer::Function, reducer::Function=tsreducer)

Combines `split`, `collapse`, and `vcat` to partition `A` according to sequential values in the mapping of `splitter` over the timestamps of `A`, then collapses each of the split TimeAxisArrays according to `tsreducer` (for timestamps) and `reducer` (for data), before recombining the collapsed values.
"""
downsample(A::TimeAxisArray, splitter::Function, tsreducer::Function, reducer::Function=tsreducer; lift::Bool=true) =
    cat(1, map(a -> collapse(a, tsreducer, reducer, lift=lift), split(A, splitter))...)

# # TODO: Allow for time-based interval selection (rather than fixed integer range window)
"""
    moving(A::TimeAxisArray, reducer::Function, n::Int)

Applies a time-wise reduction specified by `reducer` to a moving window of `n` observations, storing the result at the last timestamp in the window.
"""
function moving{T}(A::TimeAxisArray{T}, reducer::Function, window::Int; lift::Bool=true)
    if lift
        data = applytimewise(reducer, A[Axis{:Timestamp}(1:window)].data)
        for i in 2:(size(A,1)+1-window)
            data = vcat(data, applytimewise(reducer, A[Axis{:Timestamp}(i:i+window-1)].data))
        end #for
    else
        data = reducer(A[Axis{:Timestamp}(1:window)].data)
        for i in 2:(size(A,1)+1-window)
            data = vcat(data, reducer(A[Axis{:Timestamp}(i:i+window-1)].data))
        end #for
    end #if
    return TimeAxisArray(data, timestamps(A)[window:end], A.axes[2:end]...)
end #moving

"""
    lag(A::TimeAxisArray, k::Int=1)

Shifts all observations in `A` later in time by `k` timestamps.
"""
function lag(A::TimeAxisArray, k::Int=1)
    n = size(A,1)
    return TimeAxisArray(A[Axis{:Timestamp}(1:n-k)].data, timestamps(A)[1+k:n], A.axes[2:end]...)
end #lag

"""
    lead(A::TimeAxisArray, k::Int=1)

Shifts all observations in `A` earlier in time by `k` timestamps.
"""
function lead(A::TimeAxisArray, k::Int=1)
    n = size(A,1)
    return TimeAxisArray(A[Axis{:Timestamp}(1+k:n)].data, timestamps(A)[1:n-k], A.axes[2:end]...)
end #lead

"""
    diff(A::TimeAxisArray, k::Int=1)

Perform `k`th order differencing across time observations in `A`.
"""
Base.diff(A::TimeAxisArray, k::Int=1) = if k == 1
    n = size(A,1)
    return TimeAxisArray(A[Axis{:Timestamp}(2:n)].data .- A[Axis{:Timestamp}(1:n-1)].data, timestamps(A)[2:n], A.axes[2:end]...)
else
    return diff(diff(A, k-1))
end #if

"""
    percentchange(A::TimeAxisArray; logdiff::Bool=false)

Computes the percent change between observations in time in `A`. If `logdiff` is true, returns the difference of log-transformed values.
"""
function percentchange(A::TimeAxisArray; logdiff::Bool=false)
    n = size(A,1)
    return logdiff ? diff(map(log,A)) : TimeAxisArray(A[Axis{:Timestamp}(2:n)] ./  A[Axis{:Timestamp}(1:n-1)] .- 1, timestamps(A)[2:end], A.axes[2:end]...)
end #percentchange

"""
    dropif(selector::Function, predicate::Function, A::TimeAxisArray)

Drops observations at timestamps where `selector` (e.g. `any`, `all`) data values statisfy `predicate`.
"""
function dropif(selector::Function, predicate::Function, A::TimeAxisArray)
    keepers = Int[]
    for i in 1:size(A,1)
        !selector(predicate, A[Axis{:Timestamp}(i)]) && push!(keepers, i)
    end #for
    return A[Axis{:Timestamp}(keepers)]
end #dropif

"""
    dropnan(selector::Function, A::TimeAxisArray)

Drops observations at timestamps where `selector` (e.g. `any`, `all`) data values are NaN. Equivalent to `dropif(selector, isnan, A)`
"""
dropnan(A::TimeAxisArray, selector::Function=all) = dropif(selector, isnan, A)
