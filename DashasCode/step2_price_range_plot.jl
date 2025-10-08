import Pkg
Pkg.add("Plots")
using CSV, DataFrames, Statistics, Plots

const CSV_PATH = "D:\\2_Study\\2_Study Abroad\\Master_PhD Scholarships\\Master Scholarship\\KLU\\Courses\\Scientific Programming\\Git_clone_Retail_Fashion_Boutique\\Dynamic-Pricing-Optimization-for-Retail-Fashion\\DashasCode\\fashion_boutique_dataset11.csv"

# --- Load ---
df = CSV.read(CSV_PATH, DataFrame)
@assert :brand ∈ names(df)          "CSV missing 'brand' (headers are: $(names(df)))"
@assert :category ∈ names(df)       "CSV missing 'category' (headers are: $(names(df)))"
@assert :season ∈ names(df)         "CSV missing 'season' (headers are: $(names(df)))"
@assert :current_price ∈ names(df)  "CSV missing 'current_price' (headers are: $(names(df)))"


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

println("Type inputs exactly as listed.\n")
category = ask_exact("Please input a category:", CATEGORIES)
season   = ask_exact("Please input a season:", SEASONS)

println("\nSelected:\n  Category: $category\n  Season:   $season")

# --- Slice ONLY by (category, season) ---
base = df[(string.(df.category) .== category) .& (string.(df.season) .== season), :]
if nrow(base) == 0
    println("\nNo rows found for ($category, $season). Nothing to plot.")
    exit()
end

# --- Aggregations per brand ---
fmean(x) = mean(skipmissing(x))

avg_all = combine(groupby(base, :brand),
                  :current_price => fmean => :avg_price)

if nrow(avg_all) == 0
    println("\nNo price data to chart for ($category, $season).")
    exit()
end

# Min/Max per brand (for "price range")
range_all = combine(groupby(base, :brand),
                    :current_price => minimum => :min_price,
                    :current_price => maximum => :max_price)

stats = leftjoin(avg_all, range_all, on=:brand)

# Sort by avg_price
sort!(stats, :avg_price, rev=true)

# Console summary
mean_price   = mean(skipmissing(base.current_price))
median_price = median(skipmissing(base.current_price))
println("\nSummary for ($category, $season): n=$(nrow(base)), ",
        "mean=$(round(mean_price; digits=2)), median=$(round(median_price; digits=2))")

println("\nData used for the chart:")
show(stats, allrows=true, allcols=true); println()

# --- FOLLOW-UP (before plotting) ---
print("\nWould you like to see the price range within different brands in this category and season? (Yes/No): ")
resp = lowercase(chomp(readline(stdin)))
show_range = resp in ("y","yes","true","t")


xlabels = string.(stats.brand)
y       = Float64.(stats.avg_price)
xpos    = 1:length(y)

ymax_for_ylim = show_range ? maximum(Float64.(stats.max_price)) : maximum(y)
offset = max(0.5, 0.02 * ymax_for_ylim)        

bar(
    x, y,
    legend = false,
    #xlabel = "Brand",
    xlabel = "Brand", xrotation = 30, bar_width = 0.7,
    ylabel = "Average current price",
    title  = "Avg price by brand — $(category) / $(season)",
    ylim   = (0, maximum(y) * 1.15),
    series_annotations = text.(string.(round.(y; digits=2)), :center, 10, :black, 0, :bottom)
)
