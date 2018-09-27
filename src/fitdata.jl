"""
	fitexp(x,y)
Fit exponential curve with offset assuming following function:
y = p[1] + p[2]*exp.(p[3].*x)

**Input: Vectors**
* x: x coordinate vector (Float64 or DateTime)
* y: y coordinate vector (Float64)

**Output**
* (fitted parameters p[1-3], 95% confidence error bars)

**Example**
```
x = collect(1.:1:10*365)./365;
y = 1869.9 .- 782.0 .* exp.(-0.085.*x) .+ rand(length(x)).*20;
par,er = fitexp(x,y);
```
"""
function fitexp(x::Vector{Float64},y::Vector{Float64})
	x,y = fitprep(x,y);
	function fitexp_guess()
		# First guess based on: https://math.stackexchange.com/questions/1337601/fit-exponential-with-constant
		s = Vector{Float64}(undef,length(y));
		s[1] = 0;
		for i = 2:length(y)
			s[i] = s[i-1] + 0.5*(y[i]+y[i-1])*(x[i]-x[i-1]);
		end
		mat1 = [sum((x.-x[1]).^2) sum((x.-x[1]).*s);
				sum((x.-x[1]).*s) sum(s.^2)];
		mat2 = [sum((y.-y[1]).*(x.-x[1]));
				sum((y.-y[1]).*s)];
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
	# Return estimated parameters
	return fitmodel(evalexp,x,y,[a,b,c])
end
function fitexp(x::Vector{DateTime},y::Vector{Float64})
	x = convert.(Float64,Dates.value.(x));
	return fitexp(x,y);
end

"""
	evalexp(x,par)
Evaluate/compute exponential function using given parameters and x coordinate

**Input**
* x: x coordinate Vector{DateTime or Float64} or Vector{Float64}
* par: vector with 3 parameters: par[1] + par[2]*exp.(x.*par[3])
* par: vector with 2 parameters: par[1]*exp.(x.*par[2])

**Output**
* evaluated values for given parameters (=y)

**Example**
```
x = collect(1.:1:10*365)./365;
y = evalexp(x,[1869.9,-782.,-0.085]);
```
"""
function evalexp(x::Vector{Float64},par::Vector{Float64})
	if length(par) == 3
		return par[1] .+ par[2].*exp.(x.*par[3])
	else
		return par[1].*exp.(x.*par[2])
	end
end
function evalexp(x::Vector{DateTime},par::Vector{Float64})
	x = convert.(Float64,Dates.value.(x));
	return evalexp(x,par);
end

"""
	fitprep(x,y)
Prepare data for fitting, i.e. remove NaNs,...

**Input**
* x,y: x and y Vector

**Output**
* tuple with corrected vectors (Float64)

**Example**
```
x = [1.,2,3,4];
y = [10.,NaN,30,40];
x0,y0 = fitprep(x,y);
```

"""
function fitprep(x::Vector{Float64},y::Vector{Float64})
	x0,y0 = copy(x),copy(y);
	r = findall(isnan,x+y);
	deleteat!(x0,r);
	deleteat!(y0,r);
	return x0,y0;
end


"""
	fitpoly(x,y,deg)
Polynomial fitting based on LsqFit while removing NA values prior fitting

**Input**
* x: x coordinate Vector (Float64 or DateTime)
* y: y coordinate Vector (Float64)
* deg: degree of the polynomial between 0 and 4 (default=0 ==> constant)

**Output**
* (fitted parameters, 95% confidence error bars)

**Example**
```
x = collect(1.:1:365);
y = 10. + 0.1 .* x .+ rand(length(x))./2;
par,er = fitpoly(x,y,deg=1);
```
"""
function fitpoly(x::Vector{Float64},y::Vector{Float64};deg::Int64=0)
	# First guess
	function fitpoly_guess()
		if deg == 0
			return mean(y);
		elseif deg == 1
			return [0.,mean(y)];
		elseif deg == 2
			return [0.,0.,mean(y)];
		elseif deg == 3
			return [0.,0.,0.,mean(y)];
		elseif deg == 4
			return [0.,0.,0.,0.,mean(y)];
		else
			return NaN;
		end
	end
	x,y = fitprep(x,y);
	mod = getpolymodel(deg);
	approx_val = fitpoly_guess();
	if deg == 0
		return mean(y), std(y)*2; # 1=>68%, 2=>95%,...
	elseif (deg >= 1) && (deg <= 4)
		return fitmodel(mod,x,y,approx_val);
	else
		return NaN, NaN
	end
end
function fitpoly(x::Vector{DateTime},y::Vector{Float64};deg::Int64=0)
	x = convert.(Float64,Dates.value.(x));
	return fitpoly(x,y,deg=deg);
end

"""
	fitmodel(model,x,y,approx_val;confid=0.95)
Fit data to input model using approximated values as initial guess of estimated
parameters

**Input**
model: function to be fitted
x: x coordinates vector (not Vector)
y: y values (vector). NA values on input will not be corrected!
approx_val: approximated values of the model parameters
conifd: alfa for confidence interval (default = 0.05)

**Output**
* (estimated parameters, error bars at requested confidence)

**Example**
```
x = collect(1.:1:365);
y = 10.0 .+ 0.1 .* x .+ rand(length(x))./2;
par,er = fitmodel((x,p)-> p[1] + p[2].*x,x,y,[0.1, 1]);

```
"""
function fitmodel(model::Function,x::Vector{Float64},y::Vector{Float64},
					approx_val::Vector{Float64};confid::Float64=0.05)
	fit = LsqFit.curve_fit(model,x,y,approx_val);
	return fit.param, LsqFit.margin_error(fit, 1 - confid)
end

"""
	getpolymodel(deg)
Auxiliary function to create polynomial model
"""
function getpolymodel(deg::Int64=1)
	if deg == 0
		return model0(x,p) = p*ones(length(x));
	elseif deg == 1
		return model1(x,p) = p[1].*x .+ p[2];
	elseif deg == 2
		return model2(x,p) = p[1].*x.^2 .+ p[2].*x .+ p[3];
	elseif deg == 3
		return model3(x,p) = p[1].*x.^3 .+ p[2].*x.^2 .+ p[3].*x .+ p[4];
	elseif deg == 4
		return model4(x,p) = p[1].*x.^4 .+ p[2].*x.^3 .+ p[3].*x.^2 .+ p[4].*x .+ p[5];
	else
		return NaN;
	end
end


"""
	evalpoly(par,x)
Evaluate/compute polynomial function using given parameters and x coordinate

**Input**
* x: x coordinate Vector{DateTime or Float64} or Vector{Float64}
* par: vector with n parameters (polynomial degree = n-1)

**Output**
* evaluated values for given parameters (=y)

**Example**
```
x = collect(1.:1:10*365);
y = evalpoly(x,[0.01, 10.]);
```
"""
function evalpoly(x::Vector{Float64},par::Vector{Float64})::Vector{Float64}
	mod = getpolymodel(length(par)-1);
	return mod(x,par);
end
function evalpoly(x::Vector{DateTime},par::Vector{Float64})::Vector{Float64}
	x = convert.(Float64,Dates.value.(x));
	return evalpoly(x,par);
end
