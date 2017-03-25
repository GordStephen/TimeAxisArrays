# Write to text / REPL
testshow(A::TimeAxisArray) = show(IOBuffer(),MIME("text/plain"),A)
map(testshow, TimeAxisArray[A1d1, A1d2, A2d1, A3d, A4d])

# Read to / write from file

testfile = "test.csv"

writedlm(testfile, A1d1)
@test A1d1 == readtimeaxisarray(testfile, datetime(), header=false)

writedlm(testfile, A2d1)
@test A2d1 == readtimeaxisarray(testfile, datetime(), namedaxes=true)

writedlm(testfile, A4d)
@test A4d == readtimeaxisarray(testfile, datetime(), namedaxes=true, headlines=3)

rm(testfile)
