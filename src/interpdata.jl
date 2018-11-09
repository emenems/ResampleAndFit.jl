import Interpolations
"""
	interpdf(data,timecol,timvec)

Re-sample dataframe applying linear interpolation to all columns

**Input**
* data: DataFrame where at least one column contains DateTime
* timevec: output time vector (=Vector{DateTime,1})
* timecol: column containing DateTime (default value = :datetime)

**Output**
* dataframe containing all re-sampled columns + timevec

**Example**
```
data = DataFrame(Temp=[10,11,12,14],
			datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
			DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
datai = interpdf(data,[DateTime(2010,1,1,12,0,0)]);

```
"""
function interpdf(data::DataFrame,timevec::Vector{DateTime};timecol=:datetime)
	# prepare input time vector for interpolation
	x,xi = preptime(data[timecol],timevec);
	# run for all input columns except for DateTime (x vector) and Types not
	# suitable for interpolation
	dfi = DataFrame(datetime=timevec);
	for i in names(data)
		if (i != timecol) && (eltype(data[i]) <: Real)
			dfi[i] = interp1(x,data[i],xi);
		end
	end
    return dfi
end

"""
	interp1(x,y,xi)
Interpolate 1D data

**Input**
* x: x coordinate vector
* y: y values (vector)
* xi: x coordinate to be interpolated

**Output**
* yi: interpolated value

**Example**
```
yi = interp1([1,2,3,4],[10,20,30,40],1.5);
```
"""
function interp1(x,y,xi)
	# Declare output vector
	out = zeros(length(xi));
	# Create interpolation object
    itp = Interpolations.interpolate((x,),y,
            Interpolations.Gridded(Interpolations.Linear()));
	# exclude (set to NA) extrapolated values
	maxx = maximum(x);minx = minimum(x);
	for i = 1:length(out)
        if (xi[i] <= maxx) && (xi[i] >= minx)
            out[i] = itp(xi[i]);
		else
			out[i] = NaN;
        end
    end
    return out;
end

function interp1(x::Vector{DateTime},y::Vector{Float64},xi::Vector{DateTime})
	t1,t2 = preptime(x,xi);
	return interp1(t1,y,t2)
end
"""
	preptime(dft,timevec)

Auxiliary function to prepare time in DateTime format for interpolation
Will convert DateTime to Number/Int and declare/create output (length) dataframe

"""
function preptime(dft::Vector{DateTime},timevec::Vector{DateTime})
	x = Dates.value.(dft);
	xi = Dates.value.(timevec);
	return x, xi
end

"""
	meshgrid(x,y)

Function to create meshgrid, i.e. returns the same as 2D Matlab meshgrid [function](https://de.mathworks.com/help/matlab/ref/meshgrid.html).

**Input**
* x: vector or range (Int or Float)
* y: vector or range (Int or Float)

**Output**
* xi: matrix with x coordinates  (Int or Float)
* yi: matrix with y coordinates  (Int or Float)

**Example**

```
xi,yi = meshgrid(0:1:10,100:1:110);

```

"""
function meshgrid(x,y)
    xi = [j for i in y, j in x];
    yi = [i for i in y, j in x];
    return xi, yi;
end

"""
	mesh2vec(xi,yi)

Convert meshgrid back to vector


**Input**
* xi: matrix of x coordinates (in mesghrid format)
* yi: matrix of y coordinates (in mesghrid format)

**Output**
* x: vector of x coordinates
* y: vector of x coordinates

**Example**

```
xi = [0 1 2;0 1 2;0 1 2];
yi = [10 10 10;11 11 11;12 12 12];
x,y = mesh2vec(xi,yi);

```
"""
function mesh2vec(x,y)
    return x[1,:], y[:,1]
end

"""
	interp2(x,y,z,xi,yi)

Re-sample 2D data using linear interpolation

**Input**
* x: vector with x coordinates
* y: vector with y coordinates
* z: matrix with (x,y)-dependent values (meshgrid-like)
* xi: new x coordinates
* yi: new y coordinates

**Output**
* zi: interpolated values

**Example**
```
# Prepare input
x = [1.,2.,3.,4.,5.,];
y = [2.,3.,4.,5.,6.,7.,8.];
z = ones(Float64,(length(y),length(x)));
z[2,3] = 2.;
xi = [4.1,3.0,3.0,3.5,5.0,5.01]
yi = [2.1,3.0,3.5,3.5,2.0,3.30]
# compute
zi = interp2(x,y,z,xi,yi)
```
"""
function interp2(x::Vector{Float64},y::Vector{Float64},z::Matrix{Float64},
				 xi::Vector{Float64},yi::Vector{Float64})
	minx,miny,maxx,maxy,itp = prep2interp(x,y,z);
	# declare output
	zi = zeros(Float64,size(xi));
	for i in 1:length(xi[:])
		# do not extrapolate!
		if (xi[i] >= minx && yi[i] >= miny) && (xi[i] <= maxx && yi[i] <= maxy)
		   zi[i] = itp(yi[i],xi[i]) # use yi,xi order as matlab sorts masgrid in different order
		else
		   zi[i] = NaN;
		end
	end
	return zi
end
function interp2(x::Vector{Float64},y::Vector{Float64},z::Matrix{Float64},
				 xi::Matrix{Float64},yi::Matrix{Float64})
	zi = interp2(x,y,z,xi[:],yi[:]);
	return reshape(zi,size(xi));
end
function interp2(x::Matrix{Float64},y::Matrix{Float64},z::Matrix{Float64},
				 xi::Matrix{Float64},yi::Matrix{Float64})
	xm,ym = mesh2vec(x,y);
	return interp2(xm,ym,z,xi,yi);
end
function interp2(x::Matrix{Float64},y::Matrix{Float64},z::Matrix{Float64},
				 xi::Float64,yi::Float64)
	xm,ym = mesh2vec(x,y);
	return interp2(xm,ym,z,xi,yi);
end
function interp2(x::Vector{Float64},y::Vector{Float64},z::Matrix{Float64},
				 xi::Float64,yi::Float64)
	return interp2(x,y,z,[xi],[yi])[1]
end

"""
	Auxilliary function for determination of min and max values of input vectors
"""
function prep2interp(x::Vector{Float64},y::Vector{Float64},z::Matrix{Float64})
    # Need to switch x <--> y as matlab meshgrid uses transposed matrix
    itp = Interpolations.interpolate((y,x),z,
            Interpolations.Gridded(Interpolations.Linear()));
    return minimum(x), minimum(y), maximum(x), maximum(y), itp;
end
