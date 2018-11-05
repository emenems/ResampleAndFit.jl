"""
	mmconv(sig,imp)
Convolve two signals and cut the result to valid time interval only (cut out edges)
Cutting of edges is the only difference between Julias `conv` and this function

**Input:**
* sig: signal to be filtered (vector)
* imp: filter = impulse response (vector)
> length of `imp` must be an odd number

**Output**
* outsig: filtered 'valid' input signal, i.e., NaNs where filter/edge effect
  (same length as `sig`)

**Example**
```
t = collect(1:1:400.);
s = sin.(2*pi*1/50.*t) .+ randn(length(t))./6;
sf = mmconv(s,ones(7)./7);
```
"""
function mmconv(sig::Vector{Float64},imp::Vector{Float64})
	outsig = DSP.conv(sig,imp);
	return correctconv(outsig,length(imp));
end

"""
	correctconv(sig,impl)
Correct phase shift and edge effect (replace by NaNs)
**Input**
* sig: signal to be filtered (vector)
* impl: length of impulse response (=filter length)
> `impl` must be odd number

**Output**
* valid output signal

**Example**
```
sig = [1.,2.,3.,4.,3.,2.,1.,0.,-1];
imp = [1/3,1/3,1/3];
outsig = correctconv(sig,length(imp));
```
"""
function correctconv(sig::Vector{Float64},impl::Int)
	iseven(impl) ? error("Filter must have odd number of coefficients") : nothing
	temp = div(impl,2);
	# Remove phase shift
	out = sig[1+temp:end-temp];
	# Remove filter/edge effect
	out[1:temp] .= NaN; # left
	out[end-temp+1:end] .= NaN; # right
	return out;
end


"""
	findblocks(invec)
Find blocks without NaNs

**Input**
* invec: input vector to be examined. Regular sampling is assumed! (use time2regular)

**Output**
* start,stop indices of blocks without NaNs

**Example**
```
invec = collect(1.:1:17.);
invec[[6,10,11,12,14,17]] .= NaN;
istart,istop = findblocks(invec);
```
"""
function findblocks(invec::Vector{Float64})
	idall = findall(isnan.(invec));
	findblocks_decide(idall,length(invec));
end

function findblocks_decide(idall::Vector{Int},length_invec::Int)
	if !isempty(idall)
		return findblocks_main(idall,length_invec);
	else
		return [1],[length_invec]
	end
end
function findblocks_main(idall::Vector{Int},length_invec::Int)
	idstart = Vector{Int}();
	idstop = Vector{Int}();
	for i in 1:length(idall)
		if i == 1 && i != idall[1]
			push!(idstart,1);
			push!(idstop,idall[1]-1);
		elseif i == 1
			continue;
		elseif idall[i]-idall[i-1] != 1
			push!(idstart,idall[i-1]+1)
			push!(idstop,idall[i]-1)
		end
	end
	if idall[end] != length_invec
		push!(idstart,idall[end]+1);
		push!(idstop,length_invec);
	end
	return idstart,idstop
end

"""
	findnanblocks(invec)
Find blocks of NaNs

**Input**
* invec: input vector to be examined. Regular sampling is assumed! (use time2regular)

**Output**
* start,stop indices of blocks of NaNs

**Example**
```
invec = collect(1.:1:17.);
invec[[6,10,11,12,14,17]] .= NaN;
nstart,nstop = findnanblocks(invec);
```
"""
function findnanblocks(invec)
	inans = map(isnan,invec);
	ostart,ostop = Vector{Int64}(), Vector{Int64}();
	if any(inans)
		istart,istop = findblocks(invec);
		ostart = istop[1:end-1] .+ 1;
		ostop = istart[2:end] .- 1;
		if istart[1] != 1
			ostart = vcat(1,ostart);
			ostop = vcat(istart[1]-1,ostop);
		end
		if istop[end] != length(invec)
			ostart = vcat(ostart,istop[end]+1);
			ostop = vcat(ostop,length(invec));
		end
	end
	return ostart,ostop
end


"""
	filtblocks(sig,imp)
Filter signal assuming input time series contains NaNs. Thus, piecewise filtering
of the input singal will be applied (`mmconv` will be utilized).

See `mmconv` help for **Input** and **Output**

**Example**
```
t = collect(1:1:100.);
s = sin.(2*pi*1/20.*t) .+ randn(length(t))./6;
s[40:49] .= NaN;
sf = filtblocks(s,ones(5)./5);
```
"""
function filtblocks(sig::Vector{Float64},imp::Vector{Float64})
	id1,id2 = findblocks(sig);
	out = Vector{Float64}(undef,length(sig)) .+ NaN;
	for i in 1:1:length(id1)
		if id2[i]-id1[i] > length(imp)*2.
			out[id1[i]:id2[i]] = mmconv(sig[id1[i]:id2[i]],imp);
		end
	end
	return out
end

"""
	demean(sig)
subtract mean value from input Vector

**Input:**
* sig: data to be reduced (can contain NaNs)

**Output**
* outsig: data after subtraction of mean value

**Example**
```
s = [-1.,NaN,0.,1.] .+ 1.234
sf = demean(s);
```
"""
function demean(sig::Vector{Float64})::Vector{Float64}
	c = 0;s = 0.;
	for i in sig
		if !isnan(i)
			c += 1;
			s += i;
		end
	end
	return sig .- s/c
end

"""
	detrend(x,y;deg)
subtract polynomial from input Vector

**Input:**
* x: x coordinates
* y: y coordinates
* deg: polynomial degree to be subtracted (0=mean,1=linear,etc)

**Output**
* outsig: data after subtraction of given polynomial

**Example**
```
x = collect(1.:1:10);
y = ones(length(x));
out = detrend(x,y,deg=1)
```
"""
function detrend(x,y;deg::Int=1)
	if deg==0
		return demean(y)
	else
		xc,yc = copy(x),copy(y);
		# remove NaNs
		xc = xc[.!isnan.(y)];
		yc = yc[.!isnan.(y)];
		# fit
		fit,err = ResampleAndFit.fitpoly(xc,yc,deg=deg);
		return y - ResampleAndFit.evalpoly(x,fit);
	end
end

"""
	defirst(sig)
subtract first not NaN value from input Vector

**Input:**
* sig: data to be reduced (can contain NaNs)

**Output**
* outsig: data after subtraction of fist not NaN value

**Example**
```
s = [-1.,NaN,0.,1.];
sf = defirst(s);
```
"""
function defirst(sig::Vector{Float64})::Vector{Float64}
	s = 0.;
	for i in sig
		if !isnan(i)
			s = i;
			break;
		end
	end
	return sig .- s
end
