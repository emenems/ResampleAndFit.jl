ResampleAndFit
============
This repository contains functions related to (time) **re-sampling** of DataFrames, simple curve **fitting**, and **filtering** of time series.

## Re-sampling options:
* `aggregate2`: aggregate data, i.e. compute sum, mean or other function, to a required time sampling. The input DataFrame is re-sampled and new DataFrame with required time resolution is created  
* `interpdf`: linearly interpolate values in DataFrame to a new time resolutin (=new DataFrame)
* `time2regular`: re-sample data in such a way that the output DataFrame contains values with constant (regular) sampling (missing values are filled with NaNs)  
* `fillnans`: replace NaN values by linearly interpolated values as long as the missing interval is shorter than given (input) maximum gap
* `interp2`: use [Matlab-like](https://www.mathworks.com/help/matlab/ref/interp2.html) 2D interpolation

_Auxiliary functions_:  
* `interp1`: linearly interpolate DataArray to a required time (datetime) vector (DataArray)
* `isregular`: check if the input time vector (data) is regularly sampled
* `meshgrid`: use Matlab-like [meshgrid](https://www.mathworks.com/help/matlab/ref/meshgrid.html) matrices
* `mesh2vec`: convert meshgrid matrices to vectors

## Fitting options:
* `fitexp`: fit exponential curve with an offset (a + b\*exp(c\*t))
* `evalexp`: compute exponential curve with offset giving its parameters (a,b,c)
* `fitpoly`: fit polynomials just like in _Matlab/polyfit_
* `evalpoly`: compute polynomial using input parameters
> use `LsqFit.curve_fit` for other fitting curves

## Filter options:
`filtblocks`: apply `mmconv` for filtering of input signal that contains NaNs (=piecewise filtering)  
> Assuming input singal is regularly sampled (use `time2regular` function)

_Auxiliary functions_:  
* `findblocks`: find time intervals (block) without NaNs (e.g. to allow for piecewise filtering)
* `mmconv`: convolution + setting edges affected by filter to NaN values

## Usage
* Check the function help for instructions and example usage
