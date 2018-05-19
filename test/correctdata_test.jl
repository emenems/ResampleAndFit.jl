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
	dataout = correctinterval(datain,corrfile,includetime=false);
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
	correctinterval!(datain,corrpar,includetime=false);
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
	# Replace values within interval including x1/x2 time
	corrpar = DataFrame(column=[2], id = [5],
						x1 = [DateTime(2010,01,01,03)],
					  	x2 = [DateTime(2010,01,01,04,30)],
						y1 = [0.0],y2 = [1.0]);
	correctinterval!(datain,corrpar);
	@test datain[:pres][1:4] == collect(linspace(0.,1.,4));
end

function correctdata_test2()
	datain = DataFrame(
			   datetime=collect(DateTime(2010,1,1,3):Dates.Minute(60):DateTime(2010,1,2,12)),
			   grav = zeros(Float64,34)+9.8,
			   pres = zeros(Float64,34)+1000.,
			   temp = zeros(Float64,34)+27.);
    datain[:temp][5:end] += 3;
	datain[:temp][33:end] += 1;
	corrfile = joinpath(pwd(),"test/input/correctTimeInterval_inputFile2.txt");
	dataout = correctinterval(datain,corrfile,includetime=true);
	@test sum(dataout[:temp]) == 27.0*length(dataout[:temp])+2.
	# all others are unchanged
	for i in [:grav,:pres,:datetime]
		@test dataout[i] == datain[i]
	end
end

function prepcorrpar_test()
	dfin = DataFrame(Temp = collect(0.:1.:12.),
		 datetime= collect(DateTime(2000,1,1):Dates.Hour(1):DateTime(2000,1,1,12)))
	dfin[:Temp][[6,10,11]] = NaN;
	corrpar = prepcorrpar(dfin[:Temp],dfin[:datetime],min_gap=2,defcol=:Temp,defid=2)
	@test size(corrpar) == (1,7)
	@test corrpar[:x1][1] == dfin[:datetime][10]
	@test corrpar[:x2][1] == dfin[:datetime][11]
	@test corrpar[:column][1] == :Temp
	@test corrpar[:id][1] == 2
end
# run
corrinterval_test();
correctdata_test2();
prepcorrpar_test();
