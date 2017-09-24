# interpdf
function interpdf_test()
	df = DataFrame(Temp=[10,11,12,14],Humi=@data([40.,NaN,50,60]),
	      datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
	      DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
	dfi = interpdf(df,@data([DateTime(2010,1,1,0,30,0),DateTime(2010,1,1,12,0,0)]));
	@test dfi[:Temp][1] ≈ 10.5
	@test isnan(dfi[:Humi][1])
	@test isnan(dfi[:Humi][2])
	@test isnan(dfi[:Temp][2])
end

# interp1
function interp1_test()
	@test interp1(@data([1,2,3,4]),@data([10,20,30,40]),@data([1.5])) ≈ @data([15.])
end
interpdf_test()
interp1_test()
