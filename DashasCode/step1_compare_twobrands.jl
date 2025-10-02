# step_compare_two_brands.jl
# Q1: Category  Q2: Season  Q3: Two brands
# Prints avg current price for each brand in that (category, season) and their difference.

# If needed once:
# import Pkg; Pkg.add(["CSV","DataFrames","Statistics"])

using CSV, DataFrames, Statistics

# Your CSV path
const CSV_PATH = "/Users/dfedorova/github/DashasCode/fashion_boutique_dataset.csv"

# Allowed options (exact match, same style as your original script)
const CATEGORIES = ["Outerwear", "Tops", "Accessories", "Shoes", "Bottoms", "Dresses"]
const BRANDS     = ["Zara", "Uniqlo", "Banana Republic", "Mango", "H&M", "Ann Taylor", "Gap", "Forever21"]
const SEASONS    = ["Spring", "Summer", "Fall", "Winter"]

# Helpers (exact match)
function ask_exact(prompt::String, allowed::Vector{String})
    while true
        print(prompt * " "); flush(stdout)
        ans = chomp(readline(stdin))
        if ans in allowed; return ans; else println("Invalid input. Please type exactly as shown."); end
    end
end

function ask_two_brands(prompt::String, allowed::Vector{String})
    while true
        print(prompt * " "); flush(stdout)
        parts = strip.(split(chomp(readline(stdin)), ","))
        if length(parts) != 2; println("Please provide exactly two brands separated by a comma."); continue; end
        b1, b2 = parts
        if !(b1 in allowed) || !(b2 in allowed); println("One or both brands are invalid."); continue; end
        if b1 == b2; println("Choose two different brands."); continue; end
        return b1, b2
    end
end

# Ask user
println("Type the options exactly as shown. If wrong, you will be asked again.\n")
category = ask_exact("Please input a category (Outerwear, Tops, Accessories, Shoes, Bottoms, Dresses):", CATEGORIES)
brand1, brand2 = ask_two_brands("Please input 2 brands to compare pricing (Zara, Uniqlo, Banana Republic, Mango, H&M, Ann Taylor, Gap, Forever21):", BRANDS)
season = ask_exact("Please input desired season (Spring, Summer, Fall, Winter):", SEASONS)

println("\nInputs recorded:")
println("  Category: $category\n  Brand 1:  $brand1\n  Brand 2:  $brand2\n  Season:   $season")

# Load & guards
df = CSV.read(CSV_PATH, DataFrame)
@assert :brand ∈ names(df) "CSV is missing 'brand'"
@assert :category ∈ names(df) "CSV is missing 'category'"
@assert :season ∈ names(df) "CSV is missing 'season'"
@assert :current_price ∈ names(df) "CSV is missing 'current_price'"

# Filter + aggregate
sub = filter(r -> r.category == category && r.season == season && (r.brand == brand1 || r.brand == brand2), df)

if nrow(sub) == 0
    println("\nNo matching rows found for your selections.")
else
    fmean(x) = mean(skipmissing(x))
    avg = combine(groupby(sub, :brand), :current_price => fmean => :avg_price)

    println("\nAverage current price for selected brands in $category / $season:")
    show(avg, allrows=true, allcols=true); println()

    if nrow(avg) == 2
        a = avg.avg_price[findfirst(==(brand1), avg.brand)]
        b = avg.avg_price[findfirst(==(brand2), avg.brand)]
        diff = a - b
        println("\nSummary:")
        println("  $(brand1): $(round(a, digits=2))")
        println("  $(brand2): $(round(b, digits=2))")
        println("  Difference ($(brand1) - $(brand2)): ", round(diff, digits=2))
    else
        println("\nOne of the brands has no price data for this slice.")
    end
end
