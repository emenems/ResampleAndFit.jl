using ResampleAndFit, Base.Test, DataFrames, DataArrays
import FileTools

# List of test files. Run the test from ResampleAndFit.jl folder
tests = ["filtdata_test.jl",
		 "resampledata_test.jl",
		 "interpdata_test.jl",
		 "fitdata_test.jl",
		 "fillnans_test.jl",
		 "correctdata_test.jl",
		 "mergedata_test.jl"];
# Run all tests in the list
for i in tests
	include(i)
end
println("End test!")
