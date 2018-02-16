function corrinterval_test()
	datain = DataFrame(
			   datetime=collect(DateTime(2010,1,1,3):Dates.Minute(30):DateTime(2010,1,2,12)),
			   grav = zeros(Float64,67)+9.8,
			   pres = zeros(Float64,67)+1000.,
			   temp = zeros(Float64,67)+27.);
    inan = [5,6];
    datain[:grav][inan] = NaN;
	datain[:pres][inan] = NaN;
	corrfile = joinpath(pwd(),"test/input/correctTimeInterval_inputFile.txt");
	dataout = correctinterval(datain,corrfile);
	## Interpolated values
	# check if only :grav column was corrected
	for i in inan
		@test isnan(dataout[:pres][i])
		@test isnan(datain[:grav][i]) # should stay NaN as called without !
		@test dataout[:grav][i] ≈ 9.8
	end
	# Inserted NaNs
	r = find(x-> x .== DateTime(2010,01,01,08,30,00),datain[:datetime])
	for i = r[1]:r[1]+2
		@test isnan(dataout[:pres][i])
		@test !isnan(datain[:pres][i])
	end
	# Remove step
	r = find(x-> x .== DateTime(2010,01,02,04),datain[:datetime])
	@test dataout[:temp][r] == datain[:temp][r]
	for i in r[1]+1:size(dataout,1)
		@test dataout[:temp][i] ≈ datain[:temp][i]+10.
		@test dataout[:grav][i] == datain[:grav][i];
	end
	# Set parameters directly and overwrite the input dataframe
	corrpar = DataFrame(column=[1,2,3], id = [3,2,1],
						x1 = [DateTime(2010,01,01,04,30,00),
							  DateTime(2010,01,01,08,00,00),
							  DateTime(2010,01,02,04,00,00)],
					  	x2 = [DateTime(2010,01,01,07,00,00),
							  DateTime(2010,01,01,09,30,09),
							  DateTime(2010,01,02,04,00,00)],
						y1 = [NaN,NaN,10.],y2 = [NaN,NaN,0.0]);
	correctinterval!(datain,corrpar);
	for k in names(datain)
		for i in 1:size(datain,1)
			if typeof(datain[k][i]) != DateTime
				if !isnan(datain[k][i])
					@test datain[k][i] == dataout[k][i];
				else
					isnan(dataout[k][i])
				end
			end
		end
	end
end

# run
corrinterval_test();
