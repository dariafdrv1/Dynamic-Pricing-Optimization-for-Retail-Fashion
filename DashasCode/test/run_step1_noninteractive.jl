using CSV, DataFrames, Statistics

infile = joinpath(@__DIR__, "input_step1_run.csv")
outfile = joinpath(@__DIR__, "output_step1_run.txt")

df = CSV.read(infile, DataFrame)
for col in [:brand, :category, :season, :current_price]
    @assert col in names(df) "Missing column $(col) in test CSV"
end

category = "Dresses"
brand1 = "Zara"
brand2 = "H&M"
season = "Summer"

sub = filter(r -> r.category == category && r.season == season && (r.brand == brand1 || r.brand == brand2), df)

open(outfile, "w") do io
    if nrow(sub) == 0
        println(io, "No matching rows found for ($category, $season).")
    else
        fmean(x) = mean(skipmissing(x))
        avg = combine(groupby(sub, :brand), :current_price => fmean => :avg_price)
        println(io, "Average current price for selected brands in $category / $season:")
        show(io, avg, allrows=true, allcols=true)
        println(io)
        if nrow(avg) == 2
            a = avg.avg_price[findfirst(==(brand1), avg.brand)]
            b = avg.avg_price[findfirst(==(brand2), avg.brand)]
            diff = a - b
            println(io, "\nSummary:")
            println(io, "  $(brand1): $(round(a, digits=2))")
            println(io, "  $(brand2): $(round(b, digits=2))")
            println(io, "  Difference ($(brand1) - $(brand2)): ", round(diff, digits=2))
        else
            println(io, "One of the brands has no price data for this slice.")
        end
    end
end

println("Wrote output to: ", outfile)
