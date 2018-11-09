"""
	aggregate2

Aggregate data to yearly, monthly, daily, hourly or ONE minute samples.
Simple aggregation = sum, mean, maximum or minimum can be applied during re-sampling.
Missing (NaN) data can be either kept or replaced during re-sampling.

**Input**
* data: DataFrame where at least one column contains DateTime
* timecol: column containing DateTime. Default column name = :datetime
* resol: output (date)time resolution, e.g. Dates.Hour(1) (default).
> Dates.Hour(2) is not allowed (only ONE hour|minute|...)

* fce: function to by applied = sum (default)| mean | maximum | minimum
> To remove NaNs use `x->sum(filter(!isnan,x))` function

**Output**
* resampled dataframe with all input columns
> **Warning** the output dataframe can be re-arranged!

**Example**
```
data = DataFrame(Temp=[10,11,12,14],
       datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
         DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
dataa = aggregate2(data,resol=Dates.Day(1),fce=x->minimum(collect(skipmissing(x))));
```
"""
function aggregate2(data::DataFrame;
					timecol=:datetime,resol=Dates.Hour(1),
					fce=sum,rename=false)
	dfc,datestringcol = addTimeString(data,resol,timecol);
	# do not use datetime for aggregation (not supported)
	useonly = allexcept(names(dfc),timecol);
	dfc = aggregate(dfc[useonly],:datestringcol,fce)
	# Add back back datetime and remove date-string used for aggregation
	dfc[timecol] = DateTime.(dfc[:datestringcol],datestringcol);
	# make suree that type is DateTime
	if eltype(dfc[timecol]) != DateTime
		dfc[timecol] = convert(Vector{DateTime},dfc[timecol]);
	end
	delete!(dfc,:datestringcol);
	if rename==true
		for i in names(dfc)
			temp = string(i) |> x-> findlast("_",x);
			if typeof(temp)!=Nothing
				rename!(dfc,i=>Symbol(string(i)[1:collect(temp)[1]-1]));
			end
		end
	end
	return dfc
end

"""
	time2pattern(resol)

Convert DateTime hour, minute,... to string pattern, e.g. "yyyymmhh" or "yyyymmddhhmm"

**Input**
* resol: output (date)time resolution, e.g. Dates.Hour(1). (Dates.Hour(2) is not allowed)

**Output**
* datetime string

**Example**
```
s = time2pattern(Dates.Hour(1));
```
"""
function time2pattern(resol)
	if resol==Dates.Second(1)
		return "yyyymmddHHMMSS"
	elseif resol==Dates.Minute(1)
		return "yyyymmddHHMM"
	elseif resol==Dates.Hour(1)
		return "yyyymmddHH"
	elseif resol==Dates.Day(1)
		return "yyyymmdd"
	elseif resol=="month";#Dates.Month(1)
		return "yyyymm"
	elseif resol=="year"#Dates.Year(1)
		return "yyyy"
	end
end

"""
	time2regular(data,timecol,resol)

Resample data to regular time sampling (missing filled with NA values)

**Input**
* data: DataFrame where at least one column contains DateTime
* timecol: column containing DateTime. Default column name = :datetime
* resol: output (date)time resolution, e.g. Dates.Hour(1)

**Output**
* resampled dataframe with all input columns

**Example**
```
data = DataFrame(Temp=[10,11,12,14],
			datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
			DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
reg_sample = time2regular(data,timecol=:datetime,resol=Dates.Hour(1))

```
"""
function time2regular(data::DataFrame;timecol=:datetime,resol=Dates.Hour(1))
	# create dataframe with regular sampling
	dfr = DataFrame(datetime=collect(data[timecol][1]:resol:data[timecol][end]));
	# joint original and regular sampled dataframe
	reg_sample = join(data,dfr,on=timecol,kind=:right);
	# Sort accoring to time
	return sort!(reg_sample, timecol);
end

"""
	isregular(timevec)

Check if the data/time vector is regularly sampled

**Input**
`timevec`: Vector with DateTime

**Output**
`true` for regularly sampled data

**Example**
```
timevec = [DateTime(2010,1,1,1,0,0),
				 DateTime(2010,1,1,2,0,0),
				 DateTime(2010,1,1,3,0,0),
				 DateTime(2010,1,1,5,0,0),# fourth hour is missing =>not regular
				 DateTime(2010,1,1,6,0,0)];
out = isregular(timevec); # will return false
```
"""
function isregular(timevec::Vector{DateTime})
	timediff = diff(Dates.value.(timevec));
	if all(timediff[1] .== timediff)
		return true;
	else
		return false;
	end
end

"""
	getresolution(timevec;timecol)
Get time resolution in `Dates` format
NOT tested yet.

**Input:**
`timevec`: vector with DateTime values

**Output:**
time resolution in `Dates` format. Will return one of following:
Dates.Millisecond(X) | Dates.Second(X) | Dates.Minute(X) | Dates.Hour(X) |
Dates.Day(X),  where X <0,10>

**Example:**
```
timevec = [DateTime(2010,1,1,1,0,0),
				 DateTime(2010,1,1,2,0,0),
				 DateTime(2010,1,1,3,0,0)];
resol = getresolution(timevec); # should return Dates.Hour(1);
```
"""
function getresolution(timevec::Vector{DateTime})
	dt = timevec[2]-timevec[1];
	if dt < Dates.Millisecond(1000) # millisecond
		return dt;
	elseif dt < Dates.Millisecond(60*1000) # seconds
		return Dates.Second(dt)
	elseif dt < Dates.Millisecond(60*60*1000) # minute
		return Dates.Minute(dt)
	elseif dt < Dates.Millisecond(24*60*60*1000) # hour
		return Dates.Hour(dt)
	elseif dt < Dates.Millisecond(24*60*60*60*1000) # day
		return Dates.Day(1)
	else
		return dt;
	end
end


"""
	allexept(name)

Auxiliary function to return all column numbers except for input name

**Input**
* head: names collection (=names(dataframe))
* name: name/key to be excluded

**Output**
* list of indices
"""
function allexcept(head,name)
	index = Vector{Int64}();
	for (i,val) in enumerate(head)
		if val != name
			push!(index,i)
		end
	end
	return index;
end

"""
Auxiliary function to prepare dataframe for aggregate2 and timejoin
"""
function addTimeString(data,resol,timecol)
	# Create a copy of the DateFrame for manipulation
	dfc = deepcopy(data);
	# Convert input resolution to string pattern + apply
	datestringcol = time2pattern(resol);
	# Append column with string date/time
	dfc[:datestringcol] = Dates.format.(data[timecol],datestringcol);
	return dfc,datestringcol
end

"""
	cut2interval!(datain,timestart,timeend;)
Cut input dataframe to set time interval

**Input**
* datain: input dataframe containing :datetime (DateTime)
* timestart: starting time (DateTime)
* timeend: end time (DateTime)
* keepedges: either keep (true) or remove (false) the time epoch at (timestart,timeend)

> nothing will be deleted if start and end point are outside of input time

**Example**
```
datatest = DataFrame(datetime=collect(DateTime(2000,1,1):Dates.Day(1):DateTime(2000,1,12)),
					 somevalues=collect(1:1:12))
timestart,timeend = DateTime(2000,1,2),DateTime(2000,1,11);
cut2interval!(datatest,starttime,endtime,keepedges=(false,true))
```
"""
function cut2interval!(datain::DataFrame,timestart::DateTime,timeend::DateTime;
						keepedges::Tuple{Bool,Bool}=(true,true))
	rf = ResampleAndFit.findinterval(datain[:datetime],timestart,timeend,
									includetime=true);
	if length(rf) > 0 # at least 1 point must be found to delete rows
		r1 = keepedges[1] ? collect(1:rf[1]-1) : collect(1:rf[1]);
		r2 = keepedges[2] ? collect(rf[end]+1:size(datain,1)) : collect(rf[end]:size(datain,1));
		if length(r1) > 0 || length(r2) > 0
			deleterows!(datain,vcat(r1,r2));
		end
	end
end
