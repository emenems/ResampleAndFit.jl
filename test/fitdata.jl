@testset "Fitting data" begin
	x = collect(1.:1:10*365)./365;
	y = 1869.9 .- 782.0 .* exp.(-0.085 .* x);
	par,er = fitexp(x,y);
	@test round(sum(par*10)) ≈ round(18699-7820-0.85)
	@test sum(er) < 1e-2
	
	@test evalexp([3.],[10.,0.5,0.05]) ≈ [10. + 0.5*exp(0.05*3.)]

	x = collect(1.:1:365);
	y = 10.0 .+ 0.1 .* x + rand(length(x))./20;
	par,er = fitpoly(x,y,deg=1);
	@test par[1] ≈ 0.1 atol=0.001
	@test par[2] ≈ 10. atol=0.1
	@test sum(er) < 1e-2

	@test evalpoly([10.],[0.01, 0.1, 1.0]) ≈ [1+0.1*10+0.01*10*10]
	
	@test evalpoly([DateTime(1,1,1,0,1)],[0.01, 0.1, 1.0]) ≈ [1+0.1*86460000+0.01*86460000.0^2]
	
	## Test model creation
	m = ResampleAndFit.getpolymodel(0)
	@test m([10.,20.],2.0) == [2.0, 2.0]
	m = ResampleAndFit.getpolymodel(3)
	@test m(1,[4.,3.,2.,1]) == sum([4.,3.,2.,1])
	m = ResampleAndFit.getpolymodel(4)
	@test m(1,[5.,4.,3.,2.,1]) == sum([5.,4.,3.,2.,1])
	@test isnan(ResampleAndFit.getpolymodel(10))
end
