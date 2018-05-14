function fillnans_test()
	# NaN will be replaced by interpolated value
	data = DataFrame(Temp=[10.,11.,12.,14.,NaN, 14.,15.,16],
		Grav=[1.,2.,NaN,NaN,NaN,6.,NaN,8.],
		datetime=collect(DateTime(2010,1,1,1):Dates.Hour(1):DateTime(2010,1,1,8)));
	out = fillnans(data[:Temp],2);
	@test out[5] ≈ 14.
	@test all(.!isnan.(out)) == true
	# To find indices corresponding to corrected values just search for difference
	# `fillnans` was called:
	corrindex = find(isnan.(data[:Temp]) .& .!isnan.(out)); # will return [5]
	@test corrindex == [5]

	# NaNs will NOT be replaced as the missing window is too long (3>2), except
	# for the last NaN
	out2 = fillnans(data[:Grav],2);
	@test find(isnan.(data[:Grav]) .& .!isnan.(out2)) == [7]
	@test out2[7] ≈ 7.0

	# NaNs will be replace as window is longer (or equal to missing gap)
	out3 = fillnans(data[:Grav],3);
	@test find(isnan.(data[:Grav]) .& .!isnan.(out3)) == [3,4,5,7]
	@test sum(out3[[3,4,5,7]]) ≈ 3.+4.+5.+7.
end

function replacenans_test()
	data1 = DataFrame(Temp=[10.,NaN,30.,40.],
					  pres=[1.0,2.0,NaN,4.0],
		   	datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
			 DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
 	replacenans!(data1,0.0)
	@test data1[:Temp] == [10.,0.0,30.,40.]
	@test data1[:pres] == [1.0,2.0,0.0,4.0]
end

function na2nan_test()
	data1 = DataFrame(Temp=[10,missing,30,40],
					  pres=[1.0,2.0,NaN,4.0],
		   	datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
			 DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
 	na2nan!(data1)
	@test data1[:Temp][[1,3,4]] == [10,30,40]
	@test ismissing(data1[:Temp][2])
	@test data1[:pres][[1,2,4]] == [1.,2.,4.]
	@test !ismissing(data1[:pres][3])
	@test isnan(data1[:pres][3])
end
# run
fillnans_test();
na2nan_test();
replacenans_test();
