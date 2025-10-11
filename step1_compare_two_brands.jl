###############################################################
# STEP 1 — Compare Two Brands (Menu Version)
# -------------------------------------------------------------
# This script compares the average current prices of two brands
# within a selected category and season.
#
### HOW TO RUN (macOS / Linux):
#   1. Open your terminal and navigate to the folder you have saved it on:
#        cd /Users/marcelasantos/Desktop/Project #example
#
#   2. Run the script with:
#        julia --project step1_compare_two_brands.jl "fashion_boutique_dataset.csv"
#
### HOW TO RUN (Windows PowerShell):
#        cd "D:\path\to\your\Project"
#        julia --project step1_compare_two_brands.jl "fashion_boutique_dataset.csv"
#
### For users on another computer or folder:
#   - Replace the path in quotes with the correct CSV location.
#   - Example:
#       julia --project step1_compare_two_brands.jl "/path/to/fashion_boutique_dataset.csv"
#
### Notes:
#   - The CSV file must contain the columns:
#         brand, category, season, current_price
#   - The menus will guide you step-by-step through the selections.
#   - Press ↑/↓ to move and Enter to select.
###############################################################

using CSV, DataFrames, Statistics
using REPL.TerminalMenus

# -------- inputs & guards --------
inpath = length(ARGS) ≥ 1 ? ARGS[1] : "fashion_boutique_dataset.csv"
isfile(inpath) || error("CSV not found at: $inpath")

df = CSV.read(inpath, DataFrame)

# Required columns (treat names as Strings to match your CSV)
required = ["brand", "category", "season", "current_price"]
missing_cols = setdiff(required, String.(names(df)))
isempty(missing_cols) || error("CSV is missing required columns: " * join(missing_cols, ", "))

# Coerce to String for robust matching; keep prices numeric and positive
df."brand"    = String.(df."brand")
df."category" = String.(df."category")
df."season"   = String.(df."season")

# Keep valid rows only (positive & nonmissing price)
if "current_price" ∈ names(df)
    df = df[.!ismissing.(df."current_price") .& (df."current_price" .> 0), :]
end

nrow(df) > 0 || error("No valid rows after cleaning (check 'current_price').")

# Menus: derive allowed values from the data (sorted)
categories = sort!(unique(df."category"))
seasons    = sort!(unique(df."season"))

cmenu = RadioMenu(categories; pagesize = max(1, min(length(categories), 12)))
smenu = RadioMenu(seasons;    pagesize = max(1, min(length(seasons), 12)))

println("\nUse ↑/↓ to move and Enter to select.\n")

while true
    # ----- pick slice -----
    cidx = request("Select category:", cmenu)
    sidx = request("Select season:",    smenu)

    category_sel = categories[cidx]
    season_sel   = seasons[sidx]

    # restrict brands to those that actually exist in the chosen slice
    slice = df[(df."category" .== category_sel) .& (df."season" .== season_sel), :]
    if nrow(slice) == 0
        println("\nNo rows for $category_sel / $season_sel — try another selection.")
        print("\nMake another selection? (y/n): ")
        lowercase(chomp(readline())) in ("y","yes") || (println("\nAll set ✨"); break)
        continue
    end

    brands_slice = sort!(unique(slice."brand"))
    if length(brands_slice) < 2
        println("\nFewer than 2 brands available for this slice — try another.")
        print("\nMake another selection? (y/n): ")
        lowercase(chomp(readline())) in ("y","yes") || (println("\nAll set ✨"); break)
        continue
    end

    # two brand picks (ensure they differ)
    bmenu1 = RadioMenu(brands_slice; pagesize = max(1, min(length(brands_slice), 12)))
    bidx1  = request("Select Brand 1:", bmenu1)
    brand1 = brands_slice[bidx1]

    # build Brand 2 menu without Brand 1
    brands2 = [b for b in brands_slice if b != brand1]
    bmenu2  = RadioMenu(brands2; pagesize = max(1, min(length(brands2), 12)))
    bidx2   = request("Select Brand 2:", bmenu2)
    brand2  = brands2[bidx2]

    println("\nInputs:")
    println("  Category: $category_sel")
    println("  Season:   $season_sel")
    println("  Brand 1:  $brand1")
    println("  Brand 2:  $brand2")

    # ----- compute averages -----
    sub = slice[(slice."brand" .== brand1) .| (slice."brand" .== brand2), :]

    if nrow(sub) == 0
        println("\nNo matching rows found for your selections.")
    else
        fmean(x) = mean(skipmissing(x))
        avg = combine(groupby(sub, "brand"), "current_price" => fmean => :avg_price)

        # pretty print table
        println("\nAverage current price for selected brands in $category_sel / $season_sel:")
        show(avg, allrows=true, allcols=true); println()

        if nrow(avg) == 2
            a = only(avg.:avg_price[avg."brand" .== brand1])
            b = only(avg.:avg_price[avg."brand" .== brand2])
            diff = a - b
            println("\nSummary:")
            println("  $(brand1): $(round(a, digits=2))")
            println("  $(brand2): $(round(b, digits=2))")
            println("  Difference ($(brand1) - $(brand2)): ", round(diff, digits=2))
        else
            # if one brand is missing after filtering (e.g., all nonpositive/ missing prices)
            present = join(avg."brand", ", ")
            println("\nNote: Only found data for: $present")
        end
    end

    print("\nCompare another pair? (y/n): ")
    answer = lowercase(chomp(readline()))
    answer in ("y","yes") || (println("\nAll set ✨"); break)
end