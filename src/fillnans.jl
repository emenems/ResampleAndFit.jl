"""
	fillnans(datavec,maxgap)

Find and (try to) remove all NaNs in the input data vector (`datavec`) via
linear interpolation

**Input:**
`datavec`: vector (DataArray) to be corrected for NaNs. It is assumed that this
	vector corresponds to equally sampled time vector! Use the `time2regular`
	function to ensure regular sampling, or check the sampling using `isregular`
	function.
`maxgap`: parameter controlling the maximum gap to be filled. Corresponds to
	index range.


**Output:**
corrected DataArray


**Example**
```
# NaN will be replaced by interpolated value
data = DataFrame(Temp=[10.,11.,12.,14.,NaN, 14.,],
	Grav=[1.,2.,NaN,NaN,NaN,6.],
	datetime=collect(DateTime(2010,1,1,1):Dates.Hour(1):DateTime(2010,1,1,6)));
out = fillnans(data[:Temp],2);

# To find indices corresponding to corrected values just search for difference
# `fillnans` was called:
corrindex = find(isnan.(data[:Temp]) .& !isnan.(out)); # will return [5]

# NaN will NOT be replaced as the missing window is too long (3>2)
data[:Grav] = fillnans(data[:Grav],2);
```
"""
function fillnans(datavec::DataArray{Float64},maxgap::Int)
   const nanlines = !isnan.(datavec);
   dataout = copy(datavec);
   for i in 2:length(datavec)-1
	   if nanlines[i]==false # only for NaNs
		   # Get maximum possible data range (the maxgap length will be checked inside lininterp fce)
		   starti = i <= maxgap ? 1 : i - maxgap
		   stopi  = i >= length(datavec)-maxgap ? length(datavec) : i + maxgap
		   # Interpolate only if valid data exist at both sides of the NaN
		   if any(nanlines[starti:i]) && any(nanlines[i:stopi])
			   dataout[i] = lininterp(datavec[starti:stopi],i-starti+1,maxgap);
		   end
	   end
   end
   return dataout
end

"""
	replacenans!(datain,replaceby)

Replace all NaNs by given value

**Input:**
`datain`: DataFrame to be corrected (all Float64 columns)
`replaceby`: replace NaNs by this value

**Output:**
corrected DataArray

**Example**
```
# NaN will be replaced by 0.0
datain = DataFrame(Temp=[10.,11.,12.,14.,NaN, 14.,],
	Grav=[1.,2.,NaN,NaN,NaN,6.],
	datetime=collect(DateTime(2010,1,1,1):Dates.Hour(1):DateTime(2010,1,1,6)));
out = replacenans!(datain,0.0);
```
"""
function replacenans!(datain::DataFrame,replaceby::Float64)
	for i in names(datain)
		if eltype(datain[i]) == Float64
			for j in 1:length(datain[i])
				if isnan(datain[i][j])
					datain[i][j] = replaceby;
				end
			end
		end
	end
end

"""
Function to convert NA to NaNs (if (el)type=Float64)
"""
function na2nan!(datain::DataFrame)
	for i in names(datain)
		if eltype(datain[i]) == Float64
			for j in 1:length(datain[i])
				if isna(datain[i][j])
					datain[i][j] = NaN;
				end
			end
		end
	end
end

"""
Auxiliary function for linear interpolation
"""
function lininterp(datain::DataArray{Float64,1},ind::Int,maxgap::Int)
	xl,xr,yl,yr = prepwindow(datain,ind);
	if xr - xl <= maxgap+1 # make sure the window is not too long
		return (yr-yl)/(xr-xl)*(ind-xl) + yl; # (slope)*distance + offset
	else
		return NaN;
	end
end
"""
Auxiliary function to prepare data for interpolation (remove NaNs and convert
	input to x,y coordinates)
"""
function prepwindow(datain::DataArray{Float64,1},ind::Int)
	li = datain[1:ind]; # values left of NaN
	ri = datain[ind:end]; # values right of NaN
	rl = !isnan.(li); # find all valid values on left
	rr = !isnan.(ri); # ------------------------ right
	xl = 1:ind |> x -> x[rl][end]; # get only left x coodinate closest to NaN
	xr = ind:length(datain) |> x -> x[rr][1];#right--------------------
	yl = li[rl][end]; # y coordinate on left
	yr = ri[rr][1];	  # ----------------right
	return xl,xr,yl,yr
end
