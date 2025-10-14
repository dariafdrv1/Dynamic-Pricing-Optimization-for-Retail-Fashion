# Merged full runtest (final)
using CSV, DataFrames, Dates, Statistics, GLM, StatsModels

root = @__DIR__
csvpath = joinpath(root, "fashion_boutique_dataset.csv")
f1 = joinpath(root, "step1_compare_two_brands.jl")
f2 = joinpath(root, "step2_avg_price_by_brand.jl")
script3 = joinpath(root, "step3_simulate_timeseries_sales_aligned.jl")

function fail(msg)
    println("[FAIL] ", msg)
    exit(1)
end

function ok(msg)
    println("[ OK ] ", msg)
end

println("Running merged full program tests...\n")

# 1) CSV exists
isfile(csvpath) || fail("CSV not found at: $csvpath")
ok("Found dataset: $(basename(csvpath))")

# 2) CSV has required columns
required = ["brand", "category", "season", "current_price"]
cols = try String.(CSV.File(csvpath).header) catch; String.(names(CSV.read(csvpath, DataFrame))) end
missing_cols = setdiff(required, cols)
isempty(missing_cols) || fail("CSV is missing required columns: " * join(missing_cols, ", "))
ok("CSV has required columns: " * join(required, ", "))

# 3) step1 & step2 static checks
isfile(f1) || fail("Missing file: $(f1)")
isfile(f2) || fail("Missing file: $(f2)")
ok("Found script files: $(basename(f1)), $(basename(f2))")

txt1 = read(f1, String)
txt2 = read(f2, String)

if occursin("brand", lowercase(txt1)) && occursin("current_price", lowercase(txt1))
    ok("step1 contains expected keywords (brand, current_price)")
else
    fail("step1_compare_two_brands.jl looks missing expected keywords (brand, current_price)")
end

if occursin("function plot_avg_price_by_brand!", txt2)
    ok("step2 defines plot_avg_price_by_brand!()")
else
    fail("step2_avg_price_by_brand.jl missing function plot_avg_price_by_brand!()")
end

if occursin("safe_slug", txt2) && occursin("current_price", txt2)
    ok("step2 contains safe_slug and references current_price")
else
    fail("step2_avg_price_by_brand.jl missing safe_slug or current_price references")
end

# Step3: run simulation script in-process
isfile(script3) || fail("Missing file: $(script3)")
ok("Found script: $(basename(script3))")

timeseries_out = joinpath(root, "test_timeseries_sales.csv")
isfile(timeseries_out) && rm(timeseries_out)

orig_args = copy(ARGS)
try
    println("[DBG] include step3 with ARGS -> (inpath, outpath)")
    empty!(ARGS)
    push!(ARGS, csvpath)
    push!(ARGS, timeseries_out)
    include(script3)
    println("[DBG] step3 included successfully")
catch e
    empty!(ARGS)
    append!(ARGS, orig_args)
    fail("Including step3 failed: $(e)")
end
empty!(ARGS); append!(ARGS, orig_args)

isfile(timeseries_out) || fail("step3 did not produce timeseries file: $(timeseries_out)")
ok("step3 produced timeseries file: $(basename(timeseries_out))")

# basic checks on timeseries columns
ts = try CSV.read(timeseries_out, DataFrame) catch e; fail("Could not read timeseries CSV: $(e)") end
required_ts = ["date", "brand", "category", "season", "sim_price", "sim_demand"]
cols_ts = String.(names(ts))
missing_ts = setdiff(required_ts, cols_ts)
isempty(missing_ts) || fail("Timeseries CSV missing columns: " * join(missing_ts, ", "))
ok("Timeseries CSV has expected columns")

# Step4: compute elasticity summary
try
    ts.sim_price = Float64.(ts.sim_price)
    ts.sim_demand = Float64.(ts.sim_demand)
catch e
    fail("Could not coerce numeric columns in timeseries: $(e)")
end

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

for c in (:brand, :category, :n, :beta, :r2)
    hasproperty(summ, c) || fail("Elasticity summary missing column: $(c)")
end

# Step5: regression on a sample group
good = findfirst(g -> nrow(g) >= 3, groups)
good !== nothing || fail("No group in timeseries has >=3 rows to run regression for step5 test")
g = groups[good]

m = lm(@formula(log_q ~ log_p), g)
coef(m) !== nothing || fail("Regression failed for step5 test")
ok("Step5 core regression runs on a sample slice (n=$(nrow(g)))")

println("\nAll merged checks passed.")
exit(0)
