# aggregate2: find minimum including NAs
function aggeregate2_test()
	dfi = DataFrame(Temp=@data([10,11,14,1,2,NA,4]),
	   		datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,6),
	         		  DateTime(2010,1,1,18),
	           		  DateTime(2010,1,2,0),DateTime(2010,1,2,6),
	           		  DateTime(2010,1,2,12),DateTime(2010,1,2,18),
					  ]);
	dfa = aggregate2(dfi,resol=Dates.Day(1),fce=minimum);
	@test dfa[1,1] == 10
	@test isna(dfa[2,1])
	# aggregate2: compute sum removing NAs
	dfa = aggregate2(dfi,resol=Dates.Day(1),fce=x->sum(dropna(x)))
	@test dfa[1,1] == 10+11+14
	@test dfa[2,1] == 1+2+4
end

# time2regular
function time2regular_test()
	dfi = DataFrame(Temp=@data([10,11,14,1,2,NA,4]),
	   		datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,6),
	         		  DateTime(2010,1,1,18),
	           		  DateTime(2010,1,2,0),DateTime(2010,1,2,6),
	           		  DateTime(2010,1,2,12),DateTime(2010,1,2,18),
					  ]);
	reg_sample = time2regular(dfi,timecol=:datetime,resol=Dates.Hour(6))
	@test size(reg_sample,1) == 8
	@test isna(reg_sample[3,1])
end

# isregular
function isregular_test()
	# Test irregular
	dfi = DataFrame(Temp=@data([10,11,14,1,2,NA,4]),
	   		datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,6),
	         		  DateTime(2010,1,1,18),
	           		  DateTime(2010,1,2,0),DateTime(2010,1,2,6),
	           		  DateTime(2010,1,2,12),DateTime(2010,1,2,18),
					  ]);
	@test isregular(dfi[:datetime]) == false

	# Test regular
	timevec = @data(collect(DateTime(2000,1,1):Dates.Hour(1):DateTime(2001,1,2,3,0,0)));
	@test isregular(timevec) == true
end

function cut2interval_test()
	datain = DataFrame(datetime=collect(DateTime(2000,1,1):Dates.Day(1):DateTime(2000,1,12)),
						 somevalues=collect(1:1:12))
	datatest = deepcopy(datain);
	# do not cut anything as the interval is outside given time vector
	starttime,endtime = DateTime(2000,2,2),DateTime(2000,2,11);
	cut2interval!(datatest,starttime,endtime,keepedges=(false,true))
	@test datatest == datain
	# cut, but keep starting point
	starttime,endtime = DateTime(2000,1,1),DateTime(2000,1,11);
	datatest = deepcopy(datain);
	cut2interval!(datatest,starttime,endtime,keepedges=(true,false))
	@test datatest[:datetime] == datain[:datetime][1:10]
	# cut, removing starting point and keeping end
	starttime,endtime = DateTime(2000,1,1),DateTime(2000,1,9);
	datatest = deepcopy(datain);
	cut2interval!(datatest,starttime,endtime,keepedges=(false,true))
	@test datatest[:datetime] == datain[:datetime][2:9]
	# Do not cut anything because of the specific setting (end time outside time
	# interval & keep first point)
	starttime,endtime = DateTime(2000,1,1),DateTime(2001,12,9);
	datatest = deepcopy(datain);
	cut2interval!(datatest,starttime,endtime,keepedges=(true,true))
	@test datatest == datain
end

aggeregate2_test();
time2regular_test();
isregular_test();
cut2interval_test()
