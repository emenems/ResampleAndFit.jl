# fitexp
function fitexp_test()
	x = collect(1.:1:10*365)./365;
	y = 1869.9 .- 782.0 .* exp.(-0.085 .* x);
	par,er = fitexp(x,y);
	@test round(sum(par*10)) ≈ round(18699-7820-0.85)
	@test sum(er) < 1e-2
end

# evalexp
function evalexp_test()
	@test evalexp([3.],[10.,0.5,0.05]) ≈ [10. + 0.5*exp(0.05*3.)]
end

# fitpoly
function fitpoly_test()
	x = collect(1.:1:365);
	y = 10.0 .+ 0.1 .* x + rand(length(x))./20;
	par,er = fitpoly(x,y,deg=1);
	@test par[1] ≈ 0.1 atol=0.001
	@test par[2] ≈ 10. atol=0.1
	@test sum(er) < 1e-2
end

# evalpoly
function evalpoly_test()
	@test evalpoly([10.],[0.01, 0.1, 1.0]) ≈ [1+0.1*10+0.01*10*10]
end

# run functions
fitexp_test()
evalexp_test()
fitpoly_test()
evalpoly_test()
