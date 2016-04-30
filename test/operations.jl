A1d = TimeAxisArray(randn(10), collect(1.0:10.0))
A1d[5] = NaN
A2d = readtimeaxisarray("2dtest.csv", date())

@test isequal(dropif(any, x->x<=0, A1d), A1d[find((A1d .> 0) | isnan(A1d))])
@test dropif(any, x->x>0, A2d) == TimeAxisArray(zeros(0,3), Date[], A2d.axes[2])
@test isequal(dropif(any, x->x<0, A2d), A2d)

most(f::Function, x::AbstractArray) = sum(f(x)) > length(x)/2
@test dropnan(A1d) == A1d[[1:4;6:10]]
@test isequal(dropnan(A2d), A2d)
@test isequal(dropnan(A2d, all), A2d)
@test isequal(dropnan(A2d, most), A2d[[1:10;12:14], :])
@test dropnan(A2d, any) == A2d[[2:3;5:6;8:10;12;14], :]
