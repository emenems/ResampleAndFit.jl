using ResampleData, Base.Test, DataFrames

# aggregate2: find minimum including NAs
df = DataFrame(Temp=@data([10,11,14,1,2,NA,4]),
   		datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,6),
         		  DateTime(2010,1,1,18),
           		  DateTime(2010,1,2,0),DateTime(2010,1,2,6),
           		  DateTime(2010,1,2,12),DateTime(2010,1,2,18),
				  ]);
dfa = aggregate2(df,resol=Dates.Day(1),fce=minimum);
@test dfa[1,1] == 10
@test isna(dfa[2,1])
# aggregate2: compute sum removing NAs
dfa = aggregate2(df,resol=Dates.Day(1),fce=x->sum(dropna(x)))
@test dfa[1,1] == 10+11+14
@test dfa[2,1] == 1+2+4

# time2regular
reg_sample = time2regular(df,timecol=:datetime,resol=Dates.Hour(6))
@test size(reg_sample,1) == 8
@test isna(reg_sample[3,1])

# interpdf
df = DataFrame(Temp=[10,11,12,14],Humi=@data([40.,NA,50,60]),
      datetime=[DateTime(2010,1,1,0),DateTime(2010,1,1,1),
      DateTime(2010,1,1,2),DateTime(2010,1,1,4)]);
dfi = interpdf(df,[DateTime(2010,1,1,0,30,0),DateTime(2010,1,1,12,0,0)]);
@test dfi[:Temp][1] ≈ 10.5
@test isna(dfi[:Humi][1])
@test isna(dfi[:Humi][2])
@test isna(dfi[:Temp][2])

# interp1
@test interp1([1,2,3,4],[10,20,30,40],1.5) ≈ @data([15.])

# fitexp
x = @data(collect(1.:1:10*365)./365);
y = 1869.9 -782.*exp.(-0.085.*x);
par,er = fitexp(x,y);
@test round(sum(par*10)) ≈ round(18699-7820-0.85)
@test sum(er) < 1e-2

# fiteval
@test evalexp(@data([3.]),[10.,0.5,0.05]) ≈ @data([10. + 0.5*exp(0.05*3.)])


println("End test");
