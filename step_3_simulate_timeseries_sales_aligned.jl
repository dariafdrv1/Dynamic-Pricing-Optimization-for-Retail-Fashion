# simulate_timeseries_sales_aligned.jl
# Uses: /Users/marcelasantos/Desktop/Project/fashion_boutique_dataset.csv

using CSV, DataFrames, Dates, Random, Statistics

const CSV_PATH = "/Users/marcelasantos/Desktop/Project/fashion_boutique_dataset.csv"

# Inputs (CLI overrides CSV_PATH)
inpath  = length(ARGS) ≥ 1 ? ARGS[1] : CSV_PATH
outpath = length(ARGS) ≥ 2 ? ARGS[2] : "timeseries_sales.csv"

println("Input:  " * inpath)
println("Output: " * outpath)

if !isfile(inpath)
    error("CSV not found at: " * inpath)
end

# --- Load ---
df = CSV.read(inpath, DataFrame)

# --- Normalize headers lightly (remove BOM, trim, lower, spaces->underscores)
normalize_name(s) = Symbol(replace(lowercase(strip(string(s))) |> x -> replace(x, '\uFEFF' => ""),
                           r"[\s\-\/]+" => "_"))
rename!(df, Dict(names(df) .=> normalize_name.(names(df))))

# Show columns for sanity
println("Detected columns: " * join(string.(names(df)), ", "))

# --- Robust required-column check
required = [:brand, :category, :current_price]
cols     = Set(Symbol.(names(df)))       # force Symbols, use a Set for O(1) membership
missing  = [c for c in required if !(c in cols)]

if !isempty(missing)
    println("Missing required columns: " * join(string.(missing), ", "))
    error("Required columns not found. Please check the CSV headers.")
end

# Ensure numeric price
df.current_price = tryparse.(Float64, string.(df.current_price))
df = dropmissing(df, :current_price)
df = df[df.current_price .> 0, :]

# Unique values
brands     = sort(unique(string.(df.brand)))
categories = sort(unique(string.(df.category)))
dates      = collect(Date(2024,1,1):Week(1):Date(2024,12,31))

Random.seed!(42)

# Popularity factors
brand_pop = Dict(b => 1.0 + 0.15*randn() for b in brands)
cat_pop   = Dict(c => 1.0 + 0.10*randn() for c in categories)

season_of(d::Date) = month(d) in 3:5  ? "Spring" :
                     month(d) in 6:8  ? "Summer" :
                     month(d) in 9:11 ? "Fall"   : "Winter"

season_mult = Dict("Spring"=>1.05, "Summer"=>1.15, "Fall"=>1.00, "Winter"=>0.90)

# Base price per (brand, category)
base_price = Dict{Tuple{String,String},Float64}()
for b in brands, c in categories
    slice = df[(string.(df.brand).==b) .& (string.(df.category).==c), :]
    base_price[(b,c)] = nrow(slice) > 0 ? median(skipmissing(slice.current_price)) : 30 + rand()*70
end

# Simulation params
elasticity       = 1.15
price_vol        = 0.04
demand_noise_sd  = 0.08

# Simulate weekly prices and demands
rows = NamedTuple[]
for b in brands, c in categories
    p0 = base_price[(b,c)]
    price = p0
    for d in dates
        seas = season_of(d)
        drift = 0.15*(p0 - price)/p0
        shock = randn()*price_vol
        price = max(1.0, price * (1 + drift + shock))
        level = 1200 * brand_pop[b] * cat_pop[c] * season_mult[seas]
        mean_demand = level * (price^(-elasticity))
        demand = max(0.0, mean_demand * exp(randn()*demand_noise_sd))
        push!(rows, (date=d, brand=b, category=c, season=seas,
                     sim_price=price, sim_demand=demand))
    end
end

out = DataFrame(rows)
out.sim_price  = round.(out.sim_price;  digits=2)
out.sim_demand = round.(out.sim_demand; digits=2)

CSV.write(outpath, out)
println("✅ Wrote " * string(nrow(out)) * " rows to " * outpath)
