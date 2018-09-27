"""
	correctinterval!(datain,corrpar)
Correct time intervals either setting them to NaNs or interpolate value.
In addition, steps in input time series can by corrected.

**Input**
* datain: DataFrame where at least one column contains DateTime
* corrpar: DataFrame with correction parameters or name of a file containing these information
Should contain following parameters (keys):
column = number of a data column or name/key (if number & :datetime in first column: ++column)
id = type of correction: 1=step, 2=set interval to NaN, 3=set interval to interpolated values
5=set interval to given values (range between y1 and y2) (id=4 not yet implemented).
x1,x2 = starting,end time of the interval
y1,y2 = step correction: value at before at after step (id=1) | values used to replace interval (see id=5). If id=0 and y1==0.0 && isnan(y2), than difference is set to zero
* includetime: switch to either to apply correction to time including x1/x2 or just > & < (true: => & <=)

**Output**
* corrected DataFrames. Call the function without ! to get a corrected copy of the input dataframe

**Example**
```
datain = DataFrame(
		   datetime=collect(DateTime(2010,1,1,3):Dates.Minute(30):DateTime(2010,1,2,12)),
		   grav = zeros(Float64,67) .+ 9.8,
		   pres = zeros(Float64,67) .+ 1000.,
		   temp = zeros(Float64,67) .+ 27.);
corrfile = "f:/mikolaj/code/libraries/matlab_octave_library/test/input/correctTimeInterval_inputFile.txt"
dataout = correctinterval(datain,corrfile);
# Set parameters directly and overwrite the input dataframe
corrpar = DataFrame(column=[1,2,3], id = [3,2,1],
					x1 = [DateTime(2010,01,01,04,30,00),
						  DateTime(2010,01,01,08,00,00),
						  DateTime(2010,01,02,04,00,00)],
				  	x2 = [DateTime(2010,01,01,07,30,00),
						  DateTime(2010,01,01,09,30,09),
						  DateTime(2010,01,02,06,30,00)],
					y1 = [NaN,NaN,10.],y2 = [NaN,NaN,0.0]);
correctinterval!(datain,corrpar);
```
"""
function correctinterval!(datain::DataFrame,par::DataFrame;includetime::Bool=true)
	corrpar = deepcopy(par);
	if names(datain)[1] == :datetime && eltype(corrpar[:column]) != Symbol
		corrpar[:column] = corrpar[:column] .+ 1;
	end
	for (i,v) in enumerate(corrpar[:id])
		if eltype(corrpar[:column])!=Symbol ? corrpar[:column][i]<=size(datain,2) : haskey(datain,corrpar[:column][i])
			if v == 1
				correctinterval_step!(datain,corrpar,i,includetime);
			elseif v == 2
				correctinterval_nan!(datain,corrpar,i,includetime);
			elseif v == 3
				correctinterval_interp!(datain,corrpar,i,includetime);
			elseif v == 5
				correctinterval_replace!(datain,corrpar,i,includetime);
			end
		end
	end
	return datain
end
function correctinterval(datain::DataFrame,corrpar::DataFrame;includetime::Bool=true)
	correctinterval!(deepcopy(datain),corrpar,includetime=includetime)
end
function correctinterval(datain::DataFrame,corrfile::String;includetime::Bool=true)
	correctinterval!(deepcopy(datain),FileTools.readcorrpar(corrfile),includetime=includetime)
end
function correctinterval!(datain::DataFrame,corrfile::String;includetime::Bool=true)
	correctinterval!(datain,FileTools.readcorrpar(corrfile),includetime=includetime)
end

"""
Auxiliary function to correct step in time series
"""
function correctinterval_step!(datain,corrpar,i,includetime)
	# find points recorded after the step occur.
	r = includetime ? findall(x->x .>= corrpar[:x2][i], datain[:datetime]) :
					  findall(x->x .> corrpar[:x2][i], datain[:datetime]);
	# check if both values are given (if second not, then set diff. to 0)
	if !isnan(corrpar[:y1][i]) && isnan(corrpar[:y2][i])
		r1 = includetime ? findall(x->x .>= corrpar[:x1][i], datain[:datetime]) :
						  findall(x->x .> corrpar[:x1][i], datain[:datetime]);
		applyDiff = datain[corrpar[:column][i]][r[1]] -
						datain[corrpar[:column][i]][r1[1]] -
							corrpar[:y1][i];
	else
		applyDiff = corrpar[:y2][i] - corrpar[:y1][i];
	end
	for j in r # remove the step by SUBTRACTING the given difference.
        datain[corrpar[:column][i]][j] = datain[corrpar[:column][i]][j] -
						applyDiff;
    end
end

"""
Auxiliary function to set interval to NaNs
"""
function correctinterval_nan!(datain,corrpar,i,includetime)
	# find points recorded in-between given time epochs.
	r = findinterval(datain[:datetime],corrpar[:x1][i],corrpar[:x2][i],
						includetime=includetime)
	for j in r
		datain[corrpar[:column][i]][j] = NaN
	end
end

"""
Auxiliary function to set interval to linearly interpolated values
"""
function correctinterval_interp!(datain,corrpar,i,includetime)
	# find points recorded withing interval.
    r = includetime ? map(x->x .>= corrpar[:x1][i] && x .<= corrpar[:x2][i],datain[:datetime]) :
					  map(x->x .> corrpar[:x1][i] && x .< corrpar[:x2][i],datain[:datetime]);
    if any(r)
		# get values except affected interval and use it in interpolation
		ytemp = datain[corrpar[:column][i]][.!r];
		xtemp = Dates.value.(datain[:datetime][.!r]);
		datain[corrpar[:column][i]][r] = interp1(xtemp,ytemp,Dates.value.(datain[:datetime][r]));
    end
end

"""
Auxiliary function to replace interval using given value
"""
function correctinterval_replace!(datain,corrpar,i,includetime)
	# find points recorded in-between given time epochs.
	r = findinterval(datain[:datetime],corrpar[:x1][i],corrpar[:x2][i],
						includetime=includetime)
	rep_val = range(corrpar[:y1],stop=corrpar[:y2],length=length(r));
	for (j,v) in enumerate(r)
		datain[corrpar[:column][i]][v] = rep_val[j][1];
	end
end

"""
Auxiliary function to find interval between two points
"""
function findinterval(timein,x1,x2;includetime::Bool=true)
	r = includetime ? findall(x->x .>= x1 && x .<= x2,timein) :
					  findall(x->x .> x1 && x .< x2,timein);
end

"""
	prepcorrpar(datain,timein;min_gap,defcol,defid)

Function to prepare correction parameter used in 'correctinterval'.
Will find all blocks of NaNs and create formated DataFrame (that can be then
manually updated)

**Input**
* datain: input vector to be examined. Regular sampling is assumed! (use time2regular)
* timein: input DateTime vector corresponding to datain
* min_gap: minimum gap/time span of NaNs (in index, not time!). See example
* defcol: default column number or symbol (see correctinterval function)
* defid: default correction ID (see correctinterval function)

**Output**
* correction parameter DataFrame. Empty if no NaNs found.

**Example**
```
dfin = DataFrame(Temp = collect(0.:1.:12.),
	 datetime= collect(DateTime(2000,1,1):Dates.Hour(1):DateTime(2000,1,1,12)))
dfin[:Temp][[6,10,11]] .= NaN;
min_gap = 2; # corresponds to 2 hours (see datetime column)
corrpar = prepcorrpar(dfin[:Temp],dfin[:datetime],min_gap=min_gap,
					defcol=:Temp,defid=2);
```
"""
function prepcorrpar(datain,timein::Vector{DateTime};
						min_gap::Int=1,defcol=1,defid::Int=1)
	corrpar = DataFrame();
	nstart,nstop = ResampleAndFit.findnanblocks(datain);
	outlength = length(nstart);
	if !isempty(nstart)
		corrpar = DataFrame(column = repeat([defcol],outlength),
				id = repeat([defid],outlength),
				x1 = timein[nstart],
				x2 = timein[nstop],
				y1 = zeros(outlength).+NaN,
				y2 = zeros(outlength).+NaN;
				comment = repeat(["automatically_generated_using_preparecorrpar"],outlength));
		# remove rows where gap is too short
		deleterows!(corrpar,prepcorrpar_remrow(nstart,nstop,min_gap))
		corrpar = size(corrpar,1) == 0 ? DataFrame() : corrpar; # return empty if all columns deleted
	end
	return corrpar
end

"""
Auxiliary function to find indices where the gap is < as given value
"""
function prepcorrpar_remrow(nstart,nstop,min_gap)
	remrow = Vector{Int}();
	for i in 1:length(nstart)
		(nstop[i] - nstart[i] + 1) < min_gap ? push!(remrow,i) : nothing
	end
	return remrow
end
