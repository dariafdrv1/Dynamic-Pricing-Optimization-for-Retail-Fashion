# season_tables_dresses_current_price.jl
# For each season, produce a table:
# rows = ALL brands
# col  = avg_current_price_dress  (mean of current_price for items with category containing "dress" in that season)
#
# If needed the first time:
# import Pkg; Pkg.add(["CSV","DataFrames","Dates","Statistics"])

using CSV, DataFrames, Dates, Statistics

# ===== CONFIG =====
csv_path = "/Users/dfedorova/github/DashasCode/fashion_boutique_dataset.csv"  # <- set to your file
seasons_to_show = ["summer","autumn","winter","spring"]  # "fall" will be normalized to "autumn"
save_csv = true
outdir   = "season_tables_dresses"
# ==================

# --- helpers ---
normbrand(s) = begin
    if s === missing; return missing end
    t = lowercase(strip(String(s)))
    t2 = replace(t, "&" => "and", "." => "", "  " => " ")
    if occursin("zara", t2)
        "Zara"
    elseif occursin("h m", t2) || occursin("h and m", t2) || t2 == "hm" || occursin("h&m", t)
        "H&M"
    else
        join(titlecase.(split(strip(String(s)))), " ")
    end
end

cleancat(s) = begin
    if s === missing; return missing end
    t = String(s)
    t = replace(t, r"[-_]+" => " ")
    t = replace(t, r"\s+" => " ")
    strip(t)
end

function ensure_current_price(df::DataFrame)
    # we REQUIRE current_price per your definition
    haskey( Dict(Symbol.(names(df)) .=> 1), :current_price ) || error("Missing required column: current_price")
end

function load_and_normalize(path::AbstractString)
    df = CSV.read(path, DataFrame)
    # lowercase column names to Symbols
    rename!(df, Dict(n => Symbol(lowercase(String(n))) for n in names(df)))

    # required columns
    for req in [:brand, :category, :season]
        req in names(df) || error("Missing required column: $(req)")
    end
    ensure_current_price(df)

    # normalize fields
    df.brand    = normbrand.(df.brand)
    df.category = cleancat.(df.category)
    df.season   = lowercase.(strip.(string.(df.season)))
    df.season   = replace.(df.season, "fall" => "autumn")

    # (Optional) If you want to deduplicate to latest per product, uncomment block below.
    # For your definition, we simply average the values in the current_price column as-is.
    # date_col = first(filter(c -> c in names(df), [:date, :timestamp, :scraped_at, :last_updated]), nothing)
    # prod_id  = first(filter(c -> c in names(df), [:product_id, :sku, :id, :product_name, :name, :title]), nothing)
    # if date_col !== nothing && prod_id !== nothing
    #     try
    #         df[!, date_col] = DateTime.(string.(df[!, date_col]))
    #         sort!(df, [prod_id, date_col])
    #         df = unique(df, prod_id; keep = :last)
    #     catch
    #         @warn "Could not parse date column $(date_col); skipping latest-per-product reduction."
    #     end
    # end

    return df
end

# safe mean of possibly string-typed current_price
fmean_current(v) = begin
    vals = skipmissing(tryparse.(Float64, string.(v)))
    isempty(vals) ? missing : mean(collect(vals))
end

# Build one season table: ALL brands listed, column avg_current_price_dress
function table_one_season_dresses(df_all::DataFrame, season::String)
    # season filter (substring match, e.g., "summer 2024")
    ds = df_all[occursin.(season, df_all.season), :]

    # dress-only rows (category contains "dress")
    if :category in names(ds)
        ds = ds[occursin.("dress", lowercase.(string.(ds.category))), :]
    end

    # aggregate by brand over current_price
    if nrow(ds) == 0
        # no dress rows for this season; still list all brands with missing
        brands = sort(unique(df_all.brand))
        return DataFrame(brand = brands, avg_current_price_dress = Vector{Union{Missing,Float64}}(missing, length(brands)))
    end

    g   = groupby(ds, :brand)
    agg = combine(g, :current_price => fmean_current => :avg_current_price_dress)

    # enforce ALL brands appear
    all_brands = sort(unique(df_all.brand))
    wide = leftjoin(DataFrame(brand = all_brands), agg, on = :brand)

    return wide
end

# Build all season tables and optionally save CSVs
function build_season_tables_dresses(path::AbstractString;
        seasons::Vector{String} = ["summer","autumn","winter","spring"],
        save_csv::Bool = true,
        outdir::AbstractString = "season_tables_dresses")

    df = load_and_normalize(path)
    tables = Dict{String,DataFrame}()

    for s in seasons
        tbl = table_one_season_dresses(df, s)
        tables[s] = tbl

        println("\n===== $(uppercase(s)) =====")
        show(tbl, allrows=true, allcols=true); println()
    end

    if save_csv
        isdir(outdir) || mkpath(outdir)
        for (s, tbl) in tables
            CSV.write(joinpath(outdir, "avg_current_price_dress_$(s).csv"), tbl)
        end
        println("\nSaved CSVs to: $(outdir)")
    end

    return tables
end

# Run when executed
if abspath(PROGRAM_FILE) == @__FILE__
    build_season_tables_dresses(csv_path;
        seasons = seasons_to_show,
        save_csv = save_csv,
        outdir = outdir
    )
end
