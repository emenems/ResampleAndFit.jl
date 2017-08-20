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
