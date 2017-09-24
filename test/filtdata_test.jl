function test_mmconv()
	sig = ones(15);
	imp = ones(5)./5;
	filtsig = mmconv(sig,imp);
	@test sum(filtsig) ≈ 15.-5*2+1.
	@test length(filtsig) == 6
end

function test_convindices()
	ii = convindices(15,5);
	@test ii == 3:1:13
	ii = convindices(15,5,cutto="valid");
	@test ii == 5:1:10
end

function test_findblocks()
	invec = collect(1.:1:17.);
	invec[[6,10,11,12,14,17]] = NaN;
	start,stop = findblocks(invec);
	@test start == [1,7,13,15];
	@test stop == [5,9,13,16];
	invec[1] = NaN;
	invec = vcat(invec,[18]);
	start2,stop2 = findblocks(invec);
	@test start2 == [2,7,13,15,18];
	@test stop2 == [5,9,13,16,18];
end

# run
test_mmconv();
test_convindices();
test_findblocks();
