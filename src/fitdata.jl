import LsqFit

"""
	fitexp(x,y)
Fit exponential curve with offset assuming following function:
y = p[1] + p[2]\*exp.(p[3].\*x)

**Input: Vectors**
* x: x coordinate DataArray
* y: y coordinate DataArray
**Input: DataFrame**
* df: DataFrame where at least one column contains DateTime
* fitcol: ONE column containing data for fitting
* timecol: column containing DateTime. Default column name = :datetime

**Output**
* out[1]: fitted parameters p[1-3]
* out[2]: 95% confidence error bars

**Example**
```
x = @data(collect(1.:1:10*365)./365);
y = 1869.9 - 782.*exp.(-0.085.*x) + rand(length(x))*20;
par,er = fitexp(x,y);
```
"""
function fitexp(x::DataArray{Float64,1},y::DataArray{Float64,1})
	x,y = fitprep(x,y);
	function fitexp_guess()
		# First guess based on: https://math.stackexchange.com/questions/1337601/fit-exponential-with-constant
		s = Vector{Float64}(length(y));
		s[1] = 0;
		for i = 2:length(y)
			s[i] = s[i-1] + 0.5*(y[i]+y[i-1])*(x[i]-x[i-1]);
		end
		mat1 = [sum((x-x[1]).^2) sum((x-x[1]).*s);
				sum((x-x[1]).*s) sum(s.^2)];
		mat2 = [sum((y-y[1]).*(x-x[1]));
				sum((y-y[1]).*s)];
		ac = mat1\mat2;
		psi = exp.(ac[2]*x);
		mat3 = [length(y) sum(psi);
				sum(psi) sum(psi.^2)];
		mat4 = [sum(y);
				sum(y.*psi)];
		ab = mat3\mat4;
		return ab[1],ab[2],ac[2];
	end
	a,b,c = fitexp_guess();
	# Estimate using Least square fit
	fit = LsqFit.curve_fit(evalexp,x,y,[a,b,c])
	# Return estimated parameters
	return fit.param,LsqFit.estimate_errors(fit, 0.95)
end
function fitexp(x::DataArray{DateTime,1},y::DataArray{Float64,1})
	x = convert.(Float64,Dates.value.(x));
	return fitexp(x,y);
end
"""
	evalexp(par,x)
Evaluate/compute exponential function using given parameters and x coordinate

**Input**
* x: x coordinate DataArray
* par: vector with 3 parameters: par[1] + par[2]\*exp.(x.\*par[3])
* par: vector with 2 parameters: par[1]\*exp.(x.\*par[2])

**Output**
* evaluated values for given parameters (=y)

**Example**
```
x = @data(collect(1.:1:10*365)./365);
y = evalexp(x,[1869.9,-782.,-0.085]);
```
"""
function evalexp(x,par)
	if length(par) == 3
		return par[1] + par[2].*exp.(x.*par[3])
	else
		return par[1].*exp.(x.*par[2])
	end
end

"""
	fitprep(x,y)
Prepare data for fitting, i.e. remove NaNs,...

**Input Vectors**
* x,y: x and y vectors
**Input DataFrame**
* df: DataFrame where at least one column contains DateTime
* fitcol: ONE column containing data for fitting
* timecol: column containing DateTime. Default column name = :datetime

**Ouput**
* tuple with corrected vectors

**Example**
```
x = [1,2,3,4];
y = [10,NaN,30,40];
x0,y0 = fitprep(x,y);
```

"""
function fitprep(x::DataArray{Float64,1},y::DataArray{Float64,1})
	x0 = ResampleData.prepdata(x,to="vector");
	y0 = ResampleData.prepdata(y,to="vector");
	r = find(isnan,x0+y0);
	deleteat!(x0,r);
	deleteat!(y0,r);
	return x0,y0;
end
