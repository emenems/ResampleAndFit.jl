"""
	mergetimeseries(args...;timecol=:datetime)

Merge DataFrames with time series using DateTime column

**Input**
* args: DataFrames to be merged
* timecol: column containing DateTime. Default column name = :datetime
* kind: kind of mergind (see `?join`), default :outer = fill missing wiht NaNs

**Output**
* meged time series into one DataFrame

**Example**
```
data1 = DataFrame(Temp=[10.,20,30,40],
       datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
         DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
data2 = DataFrame(grav=[400.,300,200,100],
		        datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
		          DateTime(2010,1,1,2),DateTime(2010,1,1,3)]);
data3 = DataFrame(pres=[1000.,2000,3000,4000],
  		        datetime=[DateTime(2010,1,1,1),DateTime(2010,1,1,2),
  		          DateTime(2010,1,1,3),DateTime(2010,1,1,4)]);
dataout = mergetimeseries(data1,data2,data3,timecol=:datetime,kind=:outer);
```
"""
function mergetimeseries(args...;timecol=:datetime,kind=:outer)
	# use first as reference
	dataout,datestringcol = ResampleAndFit.addTimeString(args[1],Dates.Second(1),timecol);
	deletecols!(dataout,timecol); # can be deleted as the time infor is in datestringcol
	for i in 2:length(args)
		# add time string
		dfc,temp = ResampleAndFit.addTimeString(args[i],Dates.Second(1),timecol);
		# do not use datetime  (not supported)
		useonly = ResampleAndFit.allexcept(names(dfc),timecol);
		dataout = join(dataout,dfc[useonly],on=:datestringcol,kind=kind)
	end
	# convert datestring to datetime
	dataout[timecol] = DateTime.(dataout[:datestringcol],datestringcol)
	deletecols!(dataout,:datestringcol)
	na2nan!(dataout); # replace NAs
	return DataFrames.sort!(dataout, [order(:datetime)])
end
