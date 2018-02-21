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
5=set interval to given values (linspace between y1 and y2) (id=4 not yet implemented).
x1,x2 = starting,end time of the interval (if id=1 only x1 used)
y1,y1 = step correction: value at before at after step (id=1) | values used to replace interval (see id=5)

**Output**
* corrected DataFrames. Call the function without ! to get a corrected copy of the input dataframe

**Example**
```
datain = DataFrame(
		   datetime=collect(DateTime(2010,1,1,3):Dates.Minute(30):DateTime(2010,1,2,12)),
		   grav = zeros(Float64,67)+9.8,
		   pres = zeros(Float64,67)+1000.,
		   temp = zeros(Float64,67)+27.);
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
function correctinterval!(datain::DataFrame,par::DataFrame)
	corrpar = deepcopy(par);
	if names(datain)[1] == :datetime
		corrpar[:column] = corrpar[:column] .+ 1;
	end
	for (i,v) in enumerate(corrpar[:id])
		if corrpar[:column][i] <= size(datain,2) # haskey(datain,i)
			if v == 1
				correctinterval_step!(datain,corrpar,i);
			elseif v == 2
				correctinterval_nan!(datain,corrpar,i);
			elseif v == 3
				correctinterval_interp!(datain,corrpar,i);
			elseif v == 5
				correctinterval_replace!(datain,corrpar,i);
			end
		end
	end
	return datain
end
function correctinterval(datain::DataFrame,corrpar::DataFrame)
	correctinterval!(deepcopy(datain),corrpar)
end
function correctinterval(datain::DataFrame,corrfile::String)
	correctinterval!(deepcopy(datain),correctinterval_file(corrfile))
end
function correctinterval!(datain::DataFrame,corrfile::String)
	correctinterval!(datain,correctinterval_file(corrfile))
end

"""
Auxiliary function to correct step in time series
"""
function correctinterval_step!(datain,corrpar,i)
	# find points recorded after the step occur.
    r = find(x->x .> corrpar[:x2][i], datain[:datetime]);
	for j in r # remove the step by SUBTRACTING the given difference.
        datain[corrpar[:column][i]][j] = datain[corrpar[:column][i]][j] .-
						(corrpar[:y2][i] - corrpar[:y1][i]);
    end
end

"""
Auxiliary function to set interval to NaNs
"""
function correctinterval_nan!(datain,corrpar,i)
	# find points recorded in-between given time epochs.
    r = find(x->x .> corrpar[:x1][i] && x .< corrpar[:x2][i],datain[:datetime]);
	for j in r
		datain[corrpar[:column][i]][j] = NaN
	end
end

"""
Auxiliary function to set interval to linearly interpolated values
"""
function correctinterval_interp!(datain,corrpar,i)
	# find points recorded withing interval.
    r = map(x->x .> corrpar[:x1][i] && x .< corrpar[:x2][i],datain[:datetime]);
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
function correctinterval_replace!(datain,corrpar,i)
	# find points recorded in-between given time epochs.
	r = find(x->x .> corrpar[:x1][i] && x .< corrpar[:x2][i],datain[:datetime]);
	rep_val = linspace(corrpar[:y1],corrpar[:y2],length(r));
	for (j,v) in enumerate(r)
		datain[corrpar[:column][i]][v] = rep_val[j][1];
	end
end

"""
Function to read correction parameters used in 'corrinterval' function
"""
function correctinterval_file(corrfile::String)
	temp = readdlm(corrfile,comments=true,comment_char='%');
	corrpar = DataFrame(column=trunc.(Int,temp[:,2]),
						id = trunc.(Int,temp[:,1]),
						x1 = DateTime.(temp[:,3],temp[:,4],temp[:,5],temp[:,6],temp[:,7],temp[:,8]),
						x2 = DateTime.(temp[:,9],temp[:,10],temp[:,11],temp[:,12],temp[:,13],temp[:,14]),
						y1 = convert.(Float64,temp[:,15]),
						y2 = convert.(Float64,temp[:,16]),
						comment = temp[:,17]);
end
