using TimeAxisArrays
using Base.Test
using Base.Dates

n = now()

data = randn(11)
A = RegularTimeAxisArray(data, n-Hour(2):Hour(1):n+Hour(8))
@test isa(A, RegularTimeAxisArray)
writemime(IOBuffer(),MIME("text/plain"),A)

data = randn(5,2)
A = RegularTimeAxisArray(data, n-Hour(2):Hour(1):n+Hour(2),
                         Axis{:Columns}([:A, :B]))
@test isa(A, RegularTimeAxisArray)
writemime(IOBuffer(),MIME("text/plain"),A)
A2 = RegularTimeAxisArray(data, n-Hour(2):Hour(1):n+Hour(2), [:A, :B])
@test A == A2

data = randn(49,2,3)
A = RegularTimeAxisArray(data, n-Day(1):Hour(1):n+Day(1),
              Axis{:Columns}([:A, :B]),
              Axis{:Pages}([:I, :II, :III]))
@test isa(A, RegularTimeAxisArray)
writemime(IOBuffer(),MIME("text/plain"),A)

data = randn(49,2,5,3)
A = RegularTimeAxisArray(data, n-Day(1):Hour(1):n+Day(1),
              Axis{:Columns}([:A, :B]),
              Axis{:Pages}([:I, :II, :III, :IV, :V]),
              Axis{:Superpages}([:one, :two, :three]))
@test isa(A, RegularTimeAxisArray)
writemime(IOBuffer(),MIME("text/plain"),A)
