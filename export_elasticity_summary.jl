#to export elasticity summary
using CSV, DataFrames, GLM, StatsModels
ts = CSV.read("/Users/marcelasantos/Desktop/Project/timeseries_sales.csv", DataFrame)
ts.log_p = log.(ts.sim_price); ts.log_q = log.(ts.sim_demand)
using Statistics
function fit(g); m=lm(@formula(log_q~log_p),g); (coef(m)[2], r2(m)) end
summ = DataFrame([(b=String(g.brand[1]), c=String(g.category[1]), n=nrow(g), β=fit(g)[1], r2=fit(g)[2]) for g in groupby(ts, [:brand,:category])])
CSV.write("/Users/marcelasantos/Desktop/Project/elasticity_timeseries_summary.csv", summ)