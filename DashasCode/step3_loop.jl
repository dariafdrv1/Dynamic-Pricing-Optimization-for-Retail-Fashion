# bar_avg_price_by_brand_loop.jl
# Plots first, then asks to repeat with another category/season.

# If needed once:
# import Pkg; Pkg.add(["CSV","DataFrames","Statistics","Plots"])

using CSV, DataFrames, Statistics, Plots
gr()  # ensure VS Code shows the plot pane

const CSV_PATH = "/Users/dfedorova/github/DashasCode/fashion_boutique_dataset.csv"

# --- Load once ---
df = CSV.read(CSV_PATH, DataFrame)
@assert :brand ∈ names(df)          "CSV missing 'brand' (headers are: $(names(df)))"
@assert :category ∈ names(df)       "CSV missing 'category' (headers are: $(names(df)))"
@assert :season ∈ names(df)         "CSV missing 'season' (headers are: $(names(df)))"
@assert :current_price ∈ names(df)  "CSV missing 'current_price' (headers are: $(names(df)))"

# Discover allowed values from your data (avoids typos)
CATEGORIES = sort(unique(string.(df.category)))
SEASONS    = sort(unique(string.(df.season)))

# --- Exact-match prompt helper ---
function ask_exact(prompt::String, allowed::Vector{String})
    println(prompt, " ", join(allowed, ", "))
    while true
        print("> "); ans = chomp(readline(stdin))
        if ans in allowed
            return ans
        else
            println("Invalid input. Please type exactly one of: ", join(allowed, ", "))
        end
    end
end

fmean(x) = mean(skipmissing(x))

# FIX A: accept any string type and normalize inside
function plot_for(category::AbstractString, season::AbstractString)
    category = String(category)
    season   = String(season)

    base = df[(string.(df.category) .== category) .& (string.(df.season) .== season), :]
    if nrow(base) == 0
        println("\nNo rows found for ($category, $season).")
        return false
    end

    # averages per brand
    avg_all = combine(groupby(base, :brand), :current_price => fmean => :avg_price)
    if nrow(avg_all) == 0
        println("\nNo price data to chart for ($category, $season).")
        return false
    end
    sort!(avg_all, :avg_price, rev=true)

    # Prepare x/y
    x = string.(avg_all.brand)
    y = Float64.(avg_all.avg_price)

    # Build the plot (labels + spacing + rotation)
    p = bar(
        x, y;
        legend=false,
        xlabel="Brand", xrotation=30, bar_width=0.7,
        ylabel="Average current price",
        title="Avg price by brand — $(category) / $(season)",
        ylim=(0, maximum(y)*1.25),
        series_annotations = text.(string.(round.(y; digits=2)), :center, 10, :black, 0, :bottom)
    )
    display(p)  # show the plot now
    return true
end

# -------- main loop: plot first, then ask to repeat --------
while true
    println("Type inputs exactly as listed.\n")
    category = ask_exact("Please input a category:", CATEGORIES)
    season   = ask_exact("Please input a season:", SEASONS)

    println("\nSelected:\n  Category: $category\n  Season:   $season")
    plotted = plot_for(category, season)

    print("\nWould you like to see another category and/or season? (Yes/No): ")
    again = lowercase(chomp(readline(stdin)))
    again in ("y","yes","true","t") && (println(); continue)

    println("\nAll set — thanks for exploring! 🌟")
    break
end
