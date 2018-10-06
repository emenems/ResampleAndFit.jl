@testset "Interpolate 1D" begin
	df = DataFrame(Temp=[10,11,12,14],Humi=[40.,NaN,50,60],
	      datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
	      DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
	dfi = interpdf(df,[DateTime(2010,1,1,0,30,0),DateTime(2010,1,1,12,0,0)]);
	@test dfi[:Temp][1] ≈ 10.5
	@test isnan(dfi[:Humi][1])
	@test isnan(dfi[:Humi][2])
	@test isnan(dfi[:Temp][2])
	@test interp1([1,2,3,4],[10,20,30,40],[1.5]) ≈ [15.]
end

@testset "Interpolate 2D" begin
	# meshgrid
	x = [1,2,3,4];
	y = [10,20,30,40];
	xi,yi = meshgrid(x,y)
	@test xi[2,3] == 3.0
	@test yi[2,3] == 20.0

	# mesh2vec
	xi = [1 2 3 4; 1 2 3 4; 1 2 3 4; 1 2 3 4];
	yi = [10 10 10 10; 20 20 20 20; 30 30 30 30; 40 40 40 40];
	x,y = mesh2vec(xi,yi);
	@test x[end] == 4
	@test y[1] == 10

	# interp2
	x = [1.,2.,3.,4.,5.,];
	y = [2.,3.,4.,5.,6.,7.,8.];
	z = ones(Float64,(length(y),length(x)));
	z[2,3] = 2.;
	xi = [4.1,3.0,3.0,3.5,5.0,5.01]
	yi = [2.1,3.0,3.5,3.5,2.0,3.30]
	zi = interp2(x,y,z,xi,yi);
	zi_true = [1.0,2.0,1.5,1.25,1.0,NaN]
	for (i,v) in enumerate(zi_true)
		if isnan(v)
			@test isnan(zi[i])
		else
			@test zi[i] ≈ v;
		end
	end

	# scalar input
	@test isnan(interp2(x,y,z,xi,yi)[end])

	# meshgrid input
	xi,yi = meshgrid([1.,2.],[2.,3.])
	zi = interp2(x,y,z,xi,yi);
	@test zi ≈ [1.0 1.0; 1.0 1.0];
end
