###############################################################
# runtest_full.jl — alternative comprehensive test (non-interactive)
# This is a companion file to `runtest.jl` that runs steps 1-5
# without interactive menus. If you'd prefer, we can merge
# its contents back into `runtest.jl` later.
###############################################################

using CSV, DataFrames, Statistics, GLM, StatsModels

root = @__DIR__
csvpath = joinpath(root, "fashion_boutique_dataset.csv")
script3 = joinpath(root, "step3_simulate_timeseries_sales_aligned.jl")

function fail(msg)
    println("[FAIL] ", msg)
    exit(1)
end

function ok(msg)
    println("[ OK ] ", msg)
end

println("Running full program tests (runtest_full.jl)...\n")

# 1) CSV exists
isfile(csvpath) || fail("CSV not found at: $csvpath")
ok("Found dataset: $(basename(csvpath))")

# 2) CSV has required columns
required = ["brand", "category", "season", "current_price"]
cols = try String.(CSV.File(csvpath).header) catch; String.(names(CSV.read(csvpath, DataFrame))) end
missing_cols = setdiff(required, cols)
isempty(missing_cols) || fail("CSV is missing required columns: " * join(missing_cols, ", "))
ok("CSV has required columns: " * join(required, ", "))

# 3) Run step3 to produce a timeseries
isfile(script3) || fail("Missing file: $(script3)")
ok("Found script: $(basename(script3))")

timeseries_out = joinpath(root, "test_timeseries_sales.csv")
isfile(timeseries_out) && rm(timeseries_out)
try
    run(`julia --project $(script3) $(csvpath) $(timeseries_out)`)
catch e
    fail("Running step3 script failed: $(e)")
end

isfile(timeseries_out) || fail("step3 did not produce timeseries file: $(timeseries_out)")
ok("step3 produced timeseries file: $(basename(timeseries_out))")

# 4) Basic checks on timeseries
ts = try CSV.read(timeseries_out, DataFrame) catch e; fail("Could not read timeseries CSV: $(e)") end
required_ts = ["date", "brand", "category", "season", "sim_price", "sim_demand"]
cols_ts = String.(names(ts))
missing_ts = setdiff(required_ts, cols_ts)
isempty(missing_ts) || fail("Timeseries CSV missing columns: " * join(missing_ts, ", "))
ok("Timeseries CSV has expected columns")

# 5) Compute elasticities and run a sample regression
# prepare logs
ts.sim_price = Float64.(ts.sim_price)
ts.sim_demand = Float64.(ts.sim_demand)
ts.log_p = log.(ts.sim_price)
ts.log_q = log.(ts.sim_demand)

function fit_beta_r2(g)
    m = lm(@formula(log_q ~ log_p), g)
    return (coef(m)[2], GLM.r2(m))
end

groups = groupby(ts, [:brand, :category])
summary_rows = [(brand=String(g.brand[1]), category=String(g.category[1]), n=nrow(g), beta=fit_beta_r2(g)[1], r2=fit_beta_r2(g)[2]) for g in groups]
summ = DataFrame(summary_rows)
nrow(summ) > 0 || fail("Elasticity summary is empty")
ok("Computed elasticity summary with $(nrow(summ)) rows")

good = findfirst(g -> nrow(g) >= 3, groups)
good !== nothing || fail("No group in timeseries has >=3 rows to run regression for step5 test")
g = groups[good]

m = lm(@formula(log_q ~ log_p), g)
coef(m) !== nothing || fail("Regression failed for step5 test")
ok("Step5 core regression runs on a sample slice (n=$(nrow(g)))")

println("\nAll full-program checks passed.")
exit(0)
