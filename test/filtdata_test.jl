function mmconv_test()
	sig = ones(15);
	imp = ones(5)./5;
	filtsig = mmconv(sig,imp);
	@test sum(filter(!isnan,filtsig)) ≈ 11.
	for i in [1,2,14,15]
		@test isnan(filtsig[i])
	end
	@test length(filtsig) == 15
end

function findblocks_test()
	invec = collect(1.:1:17.);
	invec[[6,10,11,12,14,17]] .= NaN;
	start1,stop1 = findblocks(invec);
	@test start1 == [1,7,13,15];
	@test stop1 == [5,9,13,16];
	# Add NaN to the first position
	invec[1] = NaN;
	invec = vcat(invec,[18]);
	start2,stop2 = findblocks(invec);
	@test start2 == [2,7,13,15,18];
	@test stop2 == [5,9,13,16,18];
	# Test Vector input without NaNs
	start3,stop3 = findblocks([1.,2.,3.,4.,5.]);
	@test start3 == [1];
	@test stop3 == [5]
end

function findnanblocks_test()
	invec = collect(1.:1:17.);
	invec[[6,10,11,12,14,17]] .= NaN;
	start1,stop1 = findnanblocks(invec);
	@test start1 == [6,10,14,17];
	@test stop1 == [6,12,14,17];
	# Add NaN to the first & remove from last position
	invec[1] = NaN;
	invec = vcat(invec,[18]);
	start2,stop2 = findnanblocks(invec);
	@test start2 == [1,6,10,14,17];
	@test stop2 == [1,6,12,14,17];
	# Test Vector input without NaNs
	start3,stop3 = findnanblocks([1.,2.,3.,4.,5.]);
	@test isempty(start3)
	@test isempty(stop3)
end

function filtblocks_test()
	sig = vcat(ones(10),NaN,ones(12) .+ 1);
	out = filtblocks(sig,ones(3)./3);
	for i in [1,10,11,12,length(sig)]
		@test isnan(out[i])
	end
	@test sum(filter(!isnan,out)) ≈ 8+10*2.0
end

function demean_test()
	o = [-1.,NaN,0.,1.];
	s = o .+ 1.234
	sf = demean(s)
	for (i,v) in enumerate(sf)
		if i != 2
			@test v ≈ o[i]
		else
			@test isnan(v)
		end
	end
end

function detrend_test()
	x = collect(1.:1:10);
	y = ones(length(x));
	yc0 = detrend(x,y,deg=0);
	@test isapprox(sum(yc0),0.0)

	yc1 = detrend(x,x .* 0.5,deg=1);
	@test isapprox(sum(yc1),0.0,atol=1e-10)
end

# run
mmconv_test();
findblocks_test();
filtblocks_test();
demean_test();
findnanblocks_test();
detrend_test();
