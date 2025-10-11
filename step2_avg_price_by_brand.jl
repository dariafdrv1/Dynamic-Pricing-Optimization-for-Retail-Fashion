###############################################################
# STEP 2 — Avg Price by Brand (Menu + Loop)
# -------------------------------------------------------------
# Select Category & Season via menus, then plot a bar chart of
# average current price by brand for that slice. Optionally save
# each plot to a PNG. Repeats until you say "no".
#
### HOW TO RUN (macOS / Linux):
#   cd /Users/marcelasantos/Desktop/Project
#   julia --project step2_avg_price_by_brand.jl "fashion_boutique_dataset.csv" [/optional/output/dir]
#
### HOW TO RUN (Windows PowerShell):
#   cd "D:\path\to\Project"
#   julia --project step2_avg_price_by_brand.jl "fashion_boutique_dataset.csv" "D:\path\to\save"
#
### Notes:
#   - The CSV must have columns: brand, category, season, current_price
#   - If no output dir is provided, plots are NOT saved (only displayed).
#   - Use ↑/↓ and Enter to navigate the menus.
###############################################################

using CSV, DataFrames, Statistics, Plots
using REPL.TerminalMenus
gr()  # backend (same as Step 6)

# -------- inputs --------
inpath = length(ARGS) ≥ 1 ? ARGS[1] : "fashion_boutique_dataset.csv"
outdir = length(ARGS) ≥ 2 ? ARGS[2] : nothing

isfile(inpath) || error("CSV not found at: $inpath")
if outdir !== nothing
    isdir(outdir) || mkpath(outdir)
end

df = CSV.read(inpath, DataFrame)

# -------- guards & normalization --------
required = ["brand", "category", "season", "current_price"]
missing_cols = setdiff(required, String.(names(df)))
isempty(missing_cols) || error("CSV is missing required columns: " * join(missing_cols, ", "))

# normalize types used by menus & filtering
df."brand"    = String.(df."brand")
df."category" = String.(df."category")
df."season"   = String.(df."season")

# keep valid price rows only
df = df[.!ismissing.(df."current_price") .& (df."current_price" .> 0), :]
nrow(df) > 0 || error("No valid rows after cleaning (check 'current_price').")

# menu value sets
categories = sort!(unique(df."category"))
seasons    = sort!(unique(df."season"))

cmenu = RadioMenu(categories; pagesize = max(1, min(length(categories), 12)))
smenu = RadioMenu(seasons;    pagesize = max(1, min(length(seasons), 12)))

# helpers
safe_slug(s::AbstractString) = replace(replace(s, r"\s+" => "_"), r"[^A-Za-z0-9_]" => "")

fmean(x) = mean(skipmissing(x))

function plot_avg_price_by_brand!(base::DataFrame, category_sel::String, season_sel::String)
    # averages per brand
    avg = combine(groupby(base, "brand"), "current_price" => fmean => :avg_price)
    if nrow(avg) == 0
        println("\nNo price data to chart for ($category_sel, $season_sel).")
        return nothing
    end
    sort!(avg, :avg_price, rev=true)

    x = String.(avg."brand")
    y = Float64.(avg[!, :avg_price])

    p = bar(
        x, y;
        legend=false,
        xlabel="Brand", xrotation=30, bar_width=0.7,
        ylabel="Average current price",
        title="Avg price by brand — $(category_sel) / $(season_sel)",
        ylim=(0, maximum(y) * 1.25),
        series_annotations = text.(string.(round.(y; digits=2)), :center, 10, :black, 0, :bottom)
    )
    display(p)
    return p
end

println("\nUse ↑/↓ to move and Enter to select.\n")

while true
    # --- pick slice ---
    cidx = request("Select category:", cmenu)
    sidx = request("Select season:",  smenu)

    category_sel = categories[cidx]
    season_sel   = seasons[sidx]

    slice = df[(df."category" .== category_sel) .& (df."season" .== season_sel), :]
    if nrow(slice) < 1
        println("\nNo rows for $category_sel / $season_sel — try another.")
        print("\nMake another selection? (y/n): ")
        lowercase(chomp(readline())) in ("y","yes") || (println("\nAll set ✨"); break)
        continue
    end

    # summary before plotting
    mean_price   = mean(skipmissing(slice."current_price"))
    median_price = median(skipmissing(slice."current_price"))
    println("Summary — $(category_sel) / $(season_sel): n=$(nrow(slice)), mean=$(round(mean_price,digits=2)), median=$(round(median_price,digits=2))")

    # need at least 2 brands to make a meaningful bar chart
    brands_in_slice = unique(slice."brand")
    if length(brands_in_slice) < 2
        println("\nOnly one brand in $category_sel / $season_sel — try another selection.")
        print("\nMake another selection? (y/n): ")
        lowercase(chomp(readline())) in ("y","yes") || (println("\nAll set ✨"); break)
        continue
    end

    # --- plot ---
    p = plot_avg_price_by_brand!(slice, category_sel, season_sel)

    # --- optional save ---
    if p !== nothing && outdir !== nothing
        fname = "avg_price_by_brand_$(safe_slug(category_sel))_$(safe_slug(season_sel)).png"
        pngpath = joinpath(outdir, fname)
        try
            savefig(p, pngpath)
            # attempt to auto-open on macOS
            try run(`open $(pngpath)`) catch end
            println("✅ Saved plot to: $pngpath")
        catch e
            @warn "Plot could not be saved" error=e
            println("⚠️  Tried to save plot but hit an error. Path was: $pngpath")
        end
    end

    # --- again? ---
    print("\nMake another chart? (y/n): ")
    lowercase(chomp(readline())) in ("y","yes") || (println("\nAll set ✨"); break)
end