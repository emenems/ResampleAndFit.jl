module ResampleAndFit

using DataFrames
include("fitdata.jl")
include("resampledata.jl")
include("interpdata.jl")
include("filtdata.jl")
include("fillnans.jl")
include("correctdata.jl")
include("mergedata.jl")

export aggregate2, time2regular, isregular, getresolution
export interpdf, interp1, meshgrid, mesh2vec, interp2
export fitexp, evalexp, fitpoly, evalpoly
export mmconv, findblocks, filtblocks, demean
export fillnans, replacenans!, na2nan!
export correctinterval, correctinterval!
export mergetimeseries

end #module
