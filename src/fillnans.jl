"""
	fillnans(datavec,maxgap)

Find and (try to) remove all NaNs in the input data vector (`datavec`) via
linear interpolation

**Input:**
`datavec`: vector to be corrected for NaNs. It is assumed that this
	vector corresponds to equally sampled time vector! Use the `time2regular`
	function to ensure regular sampling, or check the sampling using `isregular`
	function.
`maxgap`: parameter controlling the maximum gap to be filled. Corresponds to
	index range.


**Output:**
corrected vector


**Example**
```
# NaN will be replaced by interpolated value
data = DataFrame(Temp=[10.,11.,12.,14.,NaN, 14.,],
	Grav=[1.,2.,NaN,NaN,NaN,6.],
	datetime=collect(DateTime(2010,1,1,1):Dates.Hour(1):DateTime(2010,1,1,6)));
out = fillnans(data[:Temp],2);

# To find indices corresponding to corrected values just search for difference
# `fillnans` was called:
corrindex = findall(isnan.(data[:Temp]) .& !isnan.(out)); # will return [5]

# NaN will NOT be replaced as the missing window is too long (3>2)
data[:Grav] = fillnans(data[:Grav],2);
```
"""
function fillnans(datavec::Vector{Float64},maxgap::Int)
   nanlines = .!isnan.(datavec);
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
corrected vector

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
		if eltype(datain[i]) == Union{Float64, Missings.Missing}
			datain[i] = collect(Missings.replace(datain[i],NaN))
		end
	end
end

"""
	missing2nan(datain)

Convert vector or DataFrame of type missing to Float64 or DateTime (missing replaced by NaNs)

**Input:**
`datain`: Vector/DataFrame to be converted to Float64 or DateTime Vector/DataFrame


**Output:**
corrected Vector/DataFrame


**Example**
```
df = DataFrame(datetime=[DateTime(2000),DateTime(2001)],
			datetime2 = [DateTime(2002),missing],
			grav=[missing,3.],
			pres=[1,missing],
			temp=[missing,missing]);
df[:datetime3] = convert(Array{Union{Missing, DateTime},1},df[:datetime])

@test missing2nan(df[:datetime]) == [DateTime(2000),DateTime(2001)]
@test missing2nan(df[:datetime3]) == [DateTime(2000),DateTime(2001)]
@test missing2nan(df[:datetime2])[1] == DateTime(2002)
@test ismissing(missing2nan(df[:datetime2])[2])
@test missing2nan(df[:grav])[2] == 3.
@test missing2nan(df[:pres])[1] == 1.
@test isnan(missing2nan(df[:grav])[1])
@test isnan(missing2nan(df[:pres])[2])
@test isnan(missing2nan(df[:temp])[1])
@test isnan(missing2nan(df[:temp])[1])

# input should stay unchanged
@test ismissing(df[:grav][1])
@test df[:pres][1] == 1
@test eltype(typeof(df[:temp])) == Missing

# test for dataframe input
dfout = missing2nan(df)

@test missing2nan(dfout[:datetime]) == [DateTime(2000),DateTime(2001)]
@test missing2nan(dfout[:datetime3]) == [DateTime(2000),DateTime(2001)]
@test missing2nan(dfout[:datetime2])[1] == DateTime(2002)
@test ismissing(missing2nan(dfout[:datetime2])[2])
@test missing2nan(dfout[:grav])[2] == 3.
@test missing2nan(dfout[:pres])[1] == 1.
@test isnan(missing2nan(dfout[:grav])[1])
@test isnan(missing2nan(dfout[:pres])[2])
@test isnan(missing2nan(dfout[:temp])[1])
@test isnan(missing2nan(dfout[:temp])[1])

# input should stay unchanged
@test ismissing(df[:grav][1])
@test df[:pres][1] == 1
@test eltype(typeof(df[:temp])) == Missing
```
"""
function missing2nan(datain::Vector)::Vector
	outtype = eltype(typeof(datain));
	if outtype == DateTime || outtype == Int || 
		outtype == Float64 || outtype == String  || outtype == Symbol
		return datain
	elseif outtype == Missing
		return zeros(Float64,length(datain)).+NaN
	elseif !any(ismissing.(datain))
		return convert(Vector{outtype.b},datain)	
	elseif outtype.b == DateTime
		return datain # cannot convert DateTime
	else 
		out = zeros(Float64,length(datain)).+NaN;
		for i in 1:length(datain)
			if !ismissing(datain[i])
				out[i] = datain[i];
			end
		end
		return out
	end
end
function missing2nan(datain::DataFrame)::DataFrame
	dataout = copy(datain);
	for i in names(datain)
		dataout[i] = missing2nan(datain[i]);
	end
	return dataout
end

"""
Auxiliary function for linear interpolation
"""
function lininterp(datain::Vector{Float64},ind::Int,maxgap::Int)
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
function prepwindow(datain::Vector{Float64},ind::Int)
	li = datain[1:ind]; # values left of NaN
	ri = datain[ind:end]; # values right of NaN
	rl = .!isnan.(li); # find all valid values on left
	rr = .!isnan.(ri); # ------------------------ right
	xl = 1:ind |> x -> x[rl][end]; # get only left x coodinate closest to NaN
	xr = ind:length(datain) |> x -> x[rr][1];#right--------------------
	yl = li[rl][end]; # y coordinate on left
	yr = ri[rr][1];	  # ----------------right
	return xl,xr,yl,yr
end
