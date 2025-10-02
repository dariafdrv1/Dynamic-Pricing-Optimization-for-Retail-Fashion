# step0_normalize.jl
# Step 0: Normalize minimal things for later steps.
# - Keeps BRAND, CATEGORY, SEASON values as they are (only trims spaces).
# - Ensures current_price is Float64 (numbers only, per your note).
# - Leaves all other columns unchanged and order preserved after the key columns.

# If needed once:
# import Pkg; Pkg.add(["CSV","DataFrames"])

using CSV, DataFrames

# ---------- config ----------
input_path  = "/Users/dfedorova/github/DashasCode/fashion_boutique_dataset.csv"
output_path = "/Users/dfedorova/github/DashasCode/normalized.csv"
# ----------------------------

# ---------- helpers ----------
trimstr(x) = x === missing ? missing : strip(String(x))

tofloat(x) = x === missing ? missing : try
    Float64(x)
catch
    try
        parse(Float64, String(x))
    catch
        missing
    end
end

# ---------- run ----------
df = CSV.read(input_path, DataFrame)

# lowercase column names to be consistent when referencing
rename!(df, Dict(n => Symbol(lowercase(String(n))) for n in names(df)))

# required columns
for req in (:brand, :category, :season, :current_price)
    req in names(df) || error("Missing required column: $(req)")
end

# keep values as-is (only trim)
df.brand         = trimstr.(df.brand)
df.category      = trimstr.(df.category)
df.season        = trimstr.(df.season)

# ensure numeric current_price
df.current_price = tofloat.(df.current_price)

# reorder: keys first, then original columns (excluding duplicates)
key_order = [:brand, :category, :season, :current_price]
others = [c for c in names(df) if c ∉ key_order]
select!(df, vcat(key_order, others))

# quick summary
println("Rows: ", nrow(df),
        " | Brands: ", length(unique(skipmissing(df.brand))),
        " | Categories: ", length(unique(skipmissing(df.category))),
        " | Seasons: ", length(unique(skipmissing(df.season))),
        " | current_price missing: ", count(ismissing, df.current_price))

CSV.write(output_path, df)
println("Wrote normalized file to: ", output_path)