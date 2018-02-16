module ResampleAndFit

using DataFrames
include("fitdata.jl")
include("resampledata.jl")
include("interpdata.jl")
include("filtdata.jl")
include("fillnans.jl")
include("correctdata.jl")

export aggregate2, time2regular, isregular, getresolution
export interpdf, interp1, meshgrid, mesh2vec, interp2
export fitexp, evalexp, fitpoly, evalpoly
export mmconv, findblocks, filtblocks, demean
export fillnans
export correctinterval, correctinterval!

end #module
