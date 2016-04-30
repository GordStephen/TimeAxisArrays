A1d3 = readtimeaxisarray("1dtest.csv", date(), header=false)
A1d = TimeAxisArray(randn(10), collect(1.0:10.0))
A1d[5] = NaN
A2d = readtimeaxisarray("2dtest.csv", date())
A4d1 = readtimeaxisarray("4dtest.csv", date(), headlines=3)
nA4d1 = size(A4d1, 1)

# split
@test map(size, split(A1d3, week)) == [(3,), (7,), (4,)]
@test map(size, split(A2d, week)) == [(3,3), (7,3), (4,3)]

# collapse
@test collapse(A1d1, first, mean) == TimeAxisArray(mean(A1d1.data), timestamps(A1d1)[1])
@test collapse(A2d1, last, x->std(x,1)) == TimeAxisArray(std(A2d1.data, 1), [timestamps(A2d1)[end]], A2d1.axes[2])

# downsample
@test downsample(A1d3, week, first) == TimeAxisArray(A1d3.data[[1,4,11]], timestamps(A1d3)[[1,4,11]])
@test downsample(A2d, week, last, x->maximum(x,1)) == TimeAxisArray([A2d.data[[2,4,13],1] A2d.data[[2,4,11],2] A2d.data[[1,7,13],3]], timestamps(A2d)[[3,10,14]], A2d.axes[2])

# moving

# lead
@test lead(A1d1) == TimeAxisArray(A1d1.data[2:end], timestamps(A1d1)[1:end-1])
@test lead(A1d1) == lead(A1d1, 1)
@test lead(A1d1, 3) == TimeAxisArray(A1d1.data[4:end], timestamps(A1d1)[1:end-3])
@test lead(A4d1) == TimeAxisArray(A4d1[Axis{:Timestamp}(2:nA4d1)].data, timestamps(A4d1)[1:end-1], A4d1.axes[2:end]...)
@test lead(A4d1) == lead(A4d1, 1)
@test lead(A4d1, 2) == TimeAxisArray(A4d1[Axis{:Timestamp}(3:nA4d1)].data, timestamps(A4d1)[1:end-2], A4d1.axes[2:end]...)

# lag
@test lag(A1d1) == TimeAxisArray(A1d1.data[1:end-1], timestamps(A1d1)[2:end])
@test lag(A1d1) == lag(A1d1, 1)
@test lag(A1d1, 3) == TimeAxisArray(A1d1.data[1:end-3], timestamps(A1d1)[4:end])
@test lag(A4d1) == TimeAxisArray(A4d1[Axis{:Timestamp}(1:nA4d1-1)].data, timestamps(A4d1)[2:end], A4d1.axes[2:end]...)
@test lag(A4d1) == lag(A4d1, 1)
@test lag(A4d1, 2) == TimeAxisArray(A4d1[Axis{:Timestamp}(1:nA4d1-2)].data, timestamps(A4d1)[3:end], A4d1.axes[2:end]...)

# diff

# percentchange

# dropif
@test isequal(dropif(any, x->x<=0, A1d), A1d[find((A1d .> 0) | isnan(A1d))])
@test dropif(any, x->x>0, A2d) == TimeAxisArray(zeros(0,3), Date[], A2d.axes[2])
@test isequal(dropif(any, x->x<0, A2d), A2d)

# dropnan
most(f::Function, x::AbstractArray) = sum(f(x)) > length(x)/2
@test dropnan(A1d) == A1d[[1:4;6:10]]
@test isequal(dropnan(A2d), A2d)
@test isequal(dropnan(A2d, all), A2d)
@test isequal(dropnan(A2d, most), A2d[[1:10;12:14], :])
@test dropnan(A2d, any) == A2d[[2:3;5:6;8:10;12;14], :]
