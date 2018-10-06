using ResampleAndFit, Test, DataFrames, Dates
import FileTools
using Test

tests = ["filtdata.jl",
		 "resampledata.jl",
		 "interpdata.jl",
		 "fitdata.jl",
		 "fillnans.jl",
		 "correctdata.jl",
		 "mergedata.jl"];
# Run all tests in the list
for i in tests
	include(i)
end
