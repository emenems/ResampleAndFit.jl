module ResampleAndFit

using DataFrames
include("fitdata.jl")
include("resampledata.jl")
include("interpdata.jl")
include("filtdata.jl")

export aggregate2, time2regular, isregular
export interpdf, interp1
export fitexp, evalexp, fitpoly, evalpoly
export mmconv, findblocks, filtblocks

end #module
