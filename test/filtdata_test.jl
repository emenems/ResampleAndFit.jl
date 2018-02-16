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
	invec[[6,10,11,12,14,17]] = NaN;
	start,stop = findblocks(invec);
	@test start == [1,7,13,15];
	@test stop == [5,9,13,16];
	# Add NaN to the first position
	invec[1] = NaN;
	invec = vcat(invec,[18]);
	start2,stop2 = findblocks(invec);
	@test start2 == [2,7,13,15,18];
	@test stop2 == [5,9,13,16,18];
	# Test DataArray input without NaNs
	start3,stop3 = findblocks(@data([1.,2.,3.,4.,5.]));
	@test start3 == [1];
	@test stop3 == [5]
end

function filtblocks_test()
	sig = vcat(ones(10),NaN,ones(12).+1);
	out = filtblocks(sig,ones(3)./3);
	for i in [1,10,11,12,length(sig)]
		@test isnan(out[i])
	end
	@test sum(filter(!isnan,out)) ≈ 8.+10.*2.
end

function demean_test()
	o = [-1.,NaN,0.,1.];
	s = @data(o+1.234)
	sf = demean(s)
	for (i,v) in enumerate(sf)
		if i != 2
			@test v ≈ o[i]
		else
			@test isnan(v)
		end
	end
end
# run
mmconv_test();
findblocks_test();
filtblocks_test();
demean_test();
