ResampleAndFit
============
[![Build Status](https://travis-ci.org/emenems/ResampleAndFit.jl.svg?branch=master)](https://travis-ci.org/emenems/ResampleAndFit.jl)
[![codecov](https://codecov.io/gh/emenems/ResampleAndFit.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/emenems/ResampleAndFit.jl)
[![Coverage Status](https://coveralls.io/repos/github/emenems/ResampleAndFit.jl/badge.svg?branch=master)](https://coveralls.io/github/emenems/ResampleAndFit.jl?branch=master)

This repository contains functions related to **re-sampling**, simple curve **fitting**, and **filtering** of time series/DataFrames.  

## Re-sampling options:
* `aggregate2`: aggregate data, i.e. compute sum, mean or other function, to a required time sampling. The input DataFrame is re-sampled and new DataFrame with required time resolution is created  
* `interpdf`: linearly interpolate values in DataFrame to a new time resolutin (=new DataFrame)
* `time2regular`: re-sample data in such a way that the output DataFrame contains values with constant (regular) sampling (missing values are filled with NaNs)  
* `fillnans`: replace NaN values by linearly interpolated values as long as the missing interval is shorter than given (input) maximum gap
* `replacenans`: replace all NaNs with given value (for Float64 type only)
* `na2nan`: convert NAs in DataFrame to NaNs (for Float64 type only)
* `missing2nan`: convert input Vector (or DataFrame) of type Array{Missing,x} to Array{x}
* `interp2`: use [Matlab-like](https://www.mathworks.com/help/matlab/ref/interp2.html) 2D interpolation

_Auxiliary functions_:  
* `interp1`: linearly interpolate DataArray to a required time (datetime) vector (DataArray)
* `isregular`: check if the input time vector (data) is regularly sampled
* `meshgrid`: use Matlab-like [meshgrid](https://www.mathworks.com/help/matlab/ref/meshgrid.html) matrices
* `mesh2vec`: convert meshgrid matrices to vectors
* `cut2interval!`: cut the input dataframe to required time interval

## Fitting options:
* `fitexp`: fit exponential curve with an offset (a + b\*exp(c\*t))
* `evalexp`: compute exponential curve with offset giving its parameters (a,b,c)
* `fitpoly`: fit polynomials just like in _Matlab/polyfit_
* `evalpoly`: compute polynomial using input parameters
> use `LsqFit.curve_fit` for other fitting curves

## Filter options:
* `filtblocks`: apply `mmconv` for filtering of input signal that may contain NaNs (=piecewise filtering)
* `demean`: subtract mean value from input data
* `detrend`: subtract polynomial fit from input data
* `defirst`: subtract first not NaN value from imput data

_Auxiliary functions_:  
* `findblocks`: find time intervals (blocks) without NaNs (e.g. to allow for piecewise filtering)
* `findnanblocks`: return blocks of NaNs in the input vector (opposite to `findblocks`)
* `mmconv`: convolution + setting edges affected by filter to NaN values

## Correct time series:
* `correctinterval`: apply step correction, interpolation or replace time interval specified in input parameters
* `prepcorrpar`: prepare correction parameter needed for `correctinterval` (find blocks of NaNs and format the output)

## Merge data:
* `mergetimeseries`: merge DataFrames with DateTime

## Usage
* Check the function help for instructions and example usage, e.g., `?aggregate2`

> Check the REQUIRE file for package dependency
