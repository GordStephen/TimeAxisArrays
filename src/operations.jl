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

# TODO: Lift basic 1D->scalar reducer (rather than hope the supplied function does the right thing)
collapse{T,N}(A::TimeAxisArray{T,N}, tsreducer::Function, reducer::Function=tsreducer) =
    TimeAxisArray(reducer(A.data), [tsreducer(timestamps(A))], A.axes[2:end]...)

downsample{T,N}(A::TimeAxisArray{T,N}, splitter::Function, tsreducer::Function, reducer::Function=tsreducer) =
    vcat(map(a -> collapse(a, tsreducer, reducer), split(A, splitter))...)
