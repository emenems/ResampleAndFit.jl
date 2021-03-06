module ResampleAndFit

using DataFrames
using Dates
using Statistics
import FileTools
import LsqFit
import DSP

include("fitdata.jl")
include("resampledata.jl")
include("interpdata.jl")
include("filtdata.jl")
include("fillnans.jl")
include("correctdata.jl")
include("mergedata.jl")

export aggregate2, time2regular, isregular, getresolution, cut2interval!
export interpdf, interp1, meshgrid, mesh2vec, interp2
export fitexp, evalexp, fitpoly, evalpoly
export mmconv, findblocks, filtblocks, demean, findnanblocks, detrend, defirst
export fillnans, replacenans!, na2nan!, missing2nan
export correctinterval, correctinterval!, prepcorrpar
export mergetimeseries

end #module
