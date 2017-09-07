import Interpolations
"""
	interpdf(df,timecol,timvec)

Re-sample dataframe applying linear interpolation to all columns

**Input**
* df: DataFrame where at least one column contains DateTime
* timevec: output DateTime vector
* timecol: column containing DateTime (default value = :datetime)

**Output**
* dataframe containing all re-sampled columns + timevec

**Example**
```
df = DataFrame(Temp=[10,11,12,14],
			datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
			DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
dfi = interpdf(df,[DateTime(2010,1,1,12,0,0)]);

```
"""
function interpdf(df::DataFrame,timevec::Vector{DateTime};timecol=:datetime)
	# prepare input time vector for interpolation
	x,xi,dfi = preptime(df[timecol],timevec);
	# run for all input columns except for DateTime (x vector) and Types not
	# suitable for interpolation
	for i in names(df)
		if i != timecol
			y = prepdata(df[i]);
			dfi[i] = interp1(x,y,xi);
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
function preptime(dft::DataArray{DateTime},timevec::Vector{DateTime})
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
function prepdata(y)
	# Interpolation output must be Float64 regardless of input type
	out = @data(Vector{Float64}(length(y)));
	if eltype(y) == Float64
		# Replace NA before interpolation (only if present)
		if sum(isna.(y)) > 0
			out = convert(Array,y,NaN);
		else
			out = df[i];
		end
	elseif eltype(y) == Int64
		# Conversion from Int using 'convert' fce would return Error as NaN is
		# a Float64
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
