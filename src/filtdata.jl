"""
	mmconv(sig,imp)
Convolve two signals and cut the result to valid time interval only (cut out edges)
Cutting of edges is the only difference between Julias `conv` and this function

**Input:**
* sig: signal to be filtered (vector)
* imp: filter = impulse response (vector)

**Output**
* outsig: filtered 'valid' input signal, i.e., not effected by filter edge effect
* outind: valid indices (can be used to cut, for example, time vector that is not
		on input)

**Example**
```
t = collect(1:1:400.);
s = sin.(2*pi*1/50.*t) + randn(length(t))./6;
sf = mmconv(s,ones(7)./7);
ii = convindices(length(s),7);
#using PyPlot;plot(t,s,t[ii],sf)
```
"""
function mmconv(sig::Vector{Float64},imp::Vector{Float64})
	outsig = conv(sig,imp);
	outind = convindices(length(sig),length(imp),cutto="valid");
	return outsig[outind];
end
function mmconv(sig::DataArray,imp::Vector{Float64})
	mmconv(convert(Vector{Float64},sig,NaN),imp);
end

"""
Returns indices for convolved signal for cutting vector to output signal without
phase shift or without phase shift and values affected by filter edge effect
**Input**
* sigl: length of input signal
* impl: length of impulse response (=filter length)
* cutto: switch to eithe return indices without "phase" shift (default) or
  without "phase" + filter edge effect (="valid")

**Output**
* valid indices range

**Example**
```
sig = [1.,2.,3.,4.,3.,2.,1.,0.,-1];
imp = [1/3,1/3,1/3];
outind = convindices(length(sig),length(imp));
```
"""
function convindices(sigl::Int,impl::Int;cutto::String="phase")
	if cutto == "valid"
		return impl:1:sigl-impl;
	elseif cutto == "phase"
		return 1+round(Int,(impl-1)/2):1:sigl-round(Int,(impl-1)/2);
	else
		return 1:1:sigl;
	end
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
invec[[6,10,11,12,14,17]] = NaN;
istart,istop = findblocks(invec);
```
"""
function findblocks(invec::Vector{Float64})
	idall = find(isnan.(invec));
	findblocks_decide(idall,length(invec));
end
function findblocks(invec::DataArray)
	idall = find(isna.(invec));
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
	idstart = Vector{Int}(0);
	idstop = Vector{Int}(0);
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
