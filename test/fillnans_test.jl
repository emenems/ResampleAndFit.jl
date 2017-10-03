function fillnans_test()
	# NaN will be replaced by interpolated value
	data = DataFrame(Temp=[10.,11.,12.,14.,NaN, 14.,15.,16],
		Grav=[1.,2.,NaN,NaN,NaN,6.,NaN,8.],
		datetime=collect(DateTime(2010,1,1,1):Dates.Hour(1):DateTime(2010,1,1,8)));
	out = fillnans(data[:Temp],2);
	@test out[5] ≈ 14.
	@test all(!isnan.(out)) == true
	# To find indices corresponding to corrected values just search for difference
	# `fillnans` was called:
	corrindex = find(isnan.(data[:Temp]) .& !isnan.(out)); # will return [5]
	@test corrindex == [5]

	# NaNs will NOT be replaced as the missing window is too long (3>2), except
	# for the last NaN
	out2 = fillnans(data[:Grav],2);
	@test find(isnan.(data[:Grav]) .& !isnan.(out2)) == [7]
	@test out2[7] ≈ 7.0

	# NaNs will be replace as window is longer (or equal to missing gap)
	out3 = fillnans(data[:Grav],3);
	@test find(isnan.(data[:Grav]) .& !isnan.(out3)) == [3,4,5,7]
	@test sum(out3[[3,4,5,7]]) ≈ 3.+4.+5.+7.
end

# run
fillnans_test();
