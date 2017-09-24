import Interpolations
"""
	interpdf(data,timecol,timvec)

Re-sample dataframe applying linear interpolation to all columns

**Input**
* data: DataFrame where at least one column contains DateTime
* timevec: output time vector (=DataArray{DateTime,1})
* timecol: column containing DateTime (default value = :datetime)

**Output**
* dataframe containing all re-sampled columns + timevec

**Example**
```
data = DataFrame(Temp=[10,11,12,14],
			datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
			DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
datai = interpdf(data,[DateTime(2010,1,1,12,0,0)]);

```
"""
function interpdf(data::DataFrame,timevec::DataArray{DateTime,1};timecol=:datetime)
	# prepare input time vector for interpolation
	x,xi,dfi = preptime(data[timecol],timevec);
	# run for all input columns except for DateTime (x vector) and Types not
	# suitable for interpolation
	for i in names(data)
		if (i != timecol) && (eltype(data[i]) <: Real)
			dfi[i] = interp1(x,prepdata(data[i]),xi);
		end
	end
    return dfi
end

"""
	interp1(x,y,xi)
Interpolate 1D data

**Input**
* x: x coordinate vector
* y: y values (vector)
* xi: x coordinate to be interpolated

**Output**
* yi: interpolated value

**Example**
```
yi = interp1([1,2,3,4],[10,20,30,40],1.5);
```
"""
function interp1(x,y,xi)
	# Declare output vector
	out = @data(zeros(length(xi)));
	# Create interpolation object
    itp = Interpolations.interpolate((x,),y,
            Interpolations.Gridded(Interpolations.Linear()));
	# exclude (set to NA) extrapolated values
	maxx = maximum(x);minx = minimum(x);
	for i = 1:length(out)
        if (xi[i] <= maxx) && (xi[i] >= minx)
            out[i] = itp[xi[i]];
			if isnan(out[i])
				out[i] = NA;
			end
		else
			out[i] = NA;
        end
    end
    return out;
end

"""
	preptime(dft,timevec)

Auxiliary function to prepare time in DateTime format for interpolation
Will convert DateTime to Number/Int and declare/create output (length) dataframe

"""
function preptime(dft::DataArray{DateTime,1},timevec::DataArray{DateTime,1})
	x = Dates.value.(dft);
	xi = Dates.value.(timevec);
	dfi = DataFrame(datetime=timevec);
	return x, xi, dfi
end

"""
	prepdata(y)

Auxiliary function to prepare input vector (as DataArray) for interpolation,
i.e. will convert to Float64 (DataArray) and replace NAs with NaN

"""
function prepdata(y;to="da")
	# Interpolation output must be Float64 regardless of input type
	if to == "da" # "da" = dataarray
		out = @data(Vector{Float64}(length(y)));
	else # otherwise just vector (array)
		out = Vector{Float64}(length(y));
	end
	if eltype(y) <: Real
		# Replace NA before interpolation (only if present)
		for (i,v) in enumerate(y)
			if isna(v)
				out[i] = NaN;
			else
				out[i] = v;
			end
		end
	end
	return out
end
