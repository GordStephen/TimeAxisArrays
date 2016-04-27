using TimeAxisArrays
using Base.Test
using Base.Dates

n = now()
testwritemime(A::TimeAxisArray) = writemime(IOBuffer(),MIME("text/plain"),A)

data = randn(11)
A = TimeAxisArray(data, n-Hour(2):Hour(1):n+Hour(8))
@test isa(A, RegularTimeAxisArray)
testwritemime(A)
A2 = TimeAxisArray(randn(5), n-Hour(2):Hour(1):n+Hour(2))
testwritemime(A2)

data = randn(5,2)
A = TimeAxisArray(data, n-Hour(2):Hour(1):n+Hour(2),
                         Axis{:Columns}([:A, :B]))
@test isa(A, RegularTimeAxisArray)
testwritemime(A)
A2 = TimeAxisArray(data, n-Hour(2):Hour(1):n+Hour(2), [:A, :B])
@test A == A2

data = randn(7,2,3)
A = TimeAxisArray(data, n-Day(1):Hour(8):n+Day(1),
              Axis{:Columns}([:A, :B]),
              Axis{:Pages}([:I, :II, :III]))
@test isa(A, RegularTimeAxisArray)
testwritemime(A)

data = randn(49,2,5,3)
A = TimeAxisArray(data, n-Day(1):Hour(1):n+Day(1),
              Axis{:Columns}([:A, :B]),
              Axis{:Pages}([:I, :II, :III, :IV, :V]),
              Axis{:Superpages}([:one, :two, :three]))
@test isa(A, RegularTimeAxisArray)
testwritemime(A)
