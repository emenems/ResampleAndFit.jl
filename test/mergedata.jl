@testset "Merge time series" begin
	data1 = DataFrame(Temp=[10.,20,30,40],
	       datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
	         DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
	data2 = DataFrame(grav=[400.,300,200,100],
			        datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
			          DateTime(2010,1,1,2),DateTime(2010,1,1,3)]);
	data3 = DataFrame(pres=[1000.,2000,3000,4000],
	  		        datetime=[DateTime(2010,1,1,1),DateTime(2010,1,1,2),
	  		          DateTime(2010,1,1,3),DateTime(2010,1,1,4)]);
	dataout = mergetimeseries(data1,data2,data3,timecol=:datetime,kind=:outer)

	@test size(dataout) == (5,4)
	@test Dates.value.(dataout[:datetime]) == Dates.value.(
				collect(DateTime(2010,1,1,0):Dates.Hour(1):DateTime(2010,1,1,4)))

	@test dataout[:Temp][[1,2,3,5]] == data1[:Temp]
	@test isnan(dataout[:Temp][4])

	@test dataout[:grav][[1,2,3,4]] == data2[:grav]
	@test isnan(dataout[:grav][end])

	@test dataout[:pres][[2,3,4,5]] == data3[:pres]
	@test isnan(dataout[:pres][1])
end
