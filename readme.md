ResampleAndFit
============
This repository contains functions related to (time) re-sampling of DataFrames and simple curve fitting.

## Re-sampling options:
* `aggregate2`: aggregate data, i.e. compute sum, mean or other function, to a required time sampling. The input DataFrame is re-sampled and new DataFrame with required time resolution is created  
* `interpdf`: linearly interpolate values in DataFrame to a new time resolutin (=new DataFrame)
* `time2regular`: re-sample data in such a way that the output DataFrame contains values with constant (regular) sampling (missing values are filled with NAs)  

Auxiliary functions are available allowing to:  
* `interp1`: linearly interpolate DataArray to a required time (datetime) vector (DataArray)

## Fitting options:
* `fitexp`: fit exponential curve with an offset (a + b\*exp(c\*t))
* `evalexp`: compute exponential curve with offset giving its parameters (a,b,c)
* `fitpoly`: fit polynomials just like in _Matlab/polyfit_
* `evalpoly`: compute polynomial using input parameters
> use `LsqFit.curve_fit` for other fitting curves


## Usage
* Check the function help for instructions and example usage
