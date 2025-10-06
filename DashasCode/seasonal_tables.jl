# season_tables_all_brands.jl
# Prints 4 tables (Summer/Autumn/Winter/Spring):
# rows = ALL brands from the dataset (always listed)
# cols = Dress / Pants / Tops
# cells = average *current* price; missing if no data for that (brand, season, category)

# If needed the first time:
# import Pkg; Pkg.add(["CSV","DataFrames","Dates","Statistics"])

using CSV, DataFrames, Dates, Statistics

# --------- CONFIG ----------
csv_path = "/Users/dfedorova/github/DashasCode/fashion_boutique_dataset.csv"  # <— set path
categories_to_show = ["dress","pants","tops"]                # output columns (lowercase)
seasons_to_show    = ["summer","autumn","winter","spring"]   # "fall" → "autumn"
save_csv           = true
outdir             = "season_tables"
# ---------------------------

# --------- helpers ---------
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

# collapse messy category labels to our 3 buckets
function normcategory(s)
    if s === missing; return missing end
    t = lowercase(strip(String(s)))
    t = replace(t, r"[-_/]" => " ")
    if occursin("dress", t)
        "dress"
    elseif occursin("pant", t) || occursin("trouser", t)
        "pants"
    elseif occursin("top", t) || occursin("tee", t) || occursin("t shirt", t) || occursin("shirt", t) || occursin("blouse", t)
        "tops"
    else
        t # other categories kept as-is
    end
end

function pick_price_col(df::DataFrame)
    for c in (:current_price, :price, :sale_price, :list_price)
        if c in names(df); return c end
    end
    error("No price column found. Expected one of: current_price, price, sale_price, list_price.")
end

function pick_date_col(df::DataFrame)
    for c in (:date, :timestamp, :scraped_at, :last_updated)
        if c in names(df); return c end
    end
    return nothing
end

function pick_product_id(df::DataFrame)
    for c in (:product_id, :sku, :id, :product_name, :name, :title)
        if c in names(df); return c end
    end
    return nothing
end

fmean(v) = begin
    vals = skipmissing(tryparse.(Float64, string.(v)))
    isempty(vals) ? missing : mean(collect(vals))
end

# --------- load & normalize ---------
function load_and_normalize(path::AbstractString)
    df = CSV.read(path, DataFrame)
    # lowercase col names
    rename!(df, Dict(n => Symbol(lowercase(String(n))) for n in names(df)))

    for req in [:brand, :category, :season]
        req in names(df) || error("Missing required column: $(req)")
    end

    df.brand    = normbrand.(df.brand)
    df.category = normcategory.(df.category)
    df.season   = lowercase.(strip.(string.(df.season)))
    df.season   = replace.(df.season, "fall" => "autumn")

    price_col = pick_price_col(df)
    date_col  = pick_date_col(df)
    prod_id   = pick_product_id(df)

    # Keep the most recent entry per product as "current" if dates exist
    if date_col !== nothing
        try
            df[!, date_col] = DateTime.(string.(df[!, date_col]))
        catch
            @warn "Could not parse date column $(date_col); falling back to lexical order."
        end
        if prod_id !== nothing
            sort!(df, [prod_id, date_col])
            df = unique(df, prod_id; keep = :last)
        else
            # overall latest date
            if eltype(df[!, date_col]) <: Union{Missing,DateTime}
                latest = maximum(skipmissing(df[!, date_col]))
                df = df[df[!, date_col] .== latest, :]
            else
                latest = maximum(skipmissing(string.(df[!, date_col])))
                df = df[string.(df[!, date_col]) .== latest, :]
            end
        end
    end

    return df, price_col
end

# --------- pivot for one season, enforcing ALL brands ---------
function pivot_one_season_allbrands(df_all::DataFrame, df_season::DataFrame, price_col::Symbol; categories::Vector{String})
    # aggregate by brand+category for the season subset
    if nrow(df_season) == 0
        wide = DataFrame(brand = unique(df_all.brand))
        sort!(wide, :brand)
        for c in categories
            wide[!, Symbol(c)] = missing
        end
        return wide
    end

    g = groupby(df_season, [:brand, :category])
    agg = combine(g, price_col => fmean => :avg_price)
    wide = unstack(agg, :brand, :category, :avg_price)

    # ensure chosen category columns exist
    for c in categories
        sc = Symbol(c)
        if !(sc in names(wide))
            wide[!, sc] = missing
        end
    end

    # enforce ALL brands from the full dataset
    all_brands = sort(unique(df_all.brand))
    wide = leftjoin(DataFrame(brand = all_brands), wide, on = :brand)

    # keep brand + chosen categories in order
    select!(wide, vcat(:brand, Symbol.(categories)))
    return wide
end

# --------- build & save all tables (all brands listed) ---------
function build_season_tables(path::AbstractString;
        categories::Vector{String} = ["dress","pants","tops"],
        seasons::Vector{String}    = ["summer","autumn","winter","spring"],
        save_csv::Bool = true,
        outdir::AbstractString = "season_tables")

    df, price_col = load_and_normalize(path)
    tables = Dict{String,DataFrame}()

    for s in seasons
        ds = df[occursin.(s, df.season), :]
        tbl = pivot_one_season_allbrands(df, ds, price_col; categories=categories)
        tables[s] = tbl

        println("\n===== $(uppercase(s)) =====")
        show(tbl, allrows=true, allcols=true); println()
    end

    if save_csv
        isdir(outdir) || mkpath(outdir)
        for (s, tbl) in tables
            CSV.write(joinpath(outdir, "avg_prices_$(s).csv"), tbl)
        end
        println("\nSaved CSVs to: $(outdir)")
    end

    return tables
end

# --------- run when executed ---------
if abspath(PROGRAM_FILE) == @__FILE__
    build_season_tables(csv_path;
        categories = categories_to_show,
        seasons    = seasons_to_show,
        save_csv   = save_csv,
        outdir     = outdir
    )
end
