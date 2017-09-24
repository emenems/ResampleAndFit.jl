module ResampleAndFit

using DataFrames
include("fitdata.jl")
include("resampledata.jl")
include("interpdata.jl")
include("filtdata.jl")

export aggregate2, time2regular
export interpdf, interp1
export fitexp, evalexp, fitpoly, evalpoly
export mmconv, convindices, findblocks

end #module
