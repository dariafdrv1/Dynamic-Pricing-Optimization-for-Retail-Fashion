using CSV, DataFrames, Test, Statistics

# Create test CSV
csv_in = joinpath(@__DIR__, "input_step2.csv")
data = DataFrame(brand = ["Zara", "Zara", "H&M", "H&M", "Other"],
                 category = ["Dresses", "Dresses", "Dresses", "Dresses", "Tops"],
                 season = ["Summer", "Summer", "Summer", "Summer", "Summer"],
                 current_price = [10.0, 20.0, 15.0, 25.0, 30.0])
CSV.write(csv_in, data)

function compute_stats(path::AbstractString, category::String, season::String)
    df = CSV.read(path, DataFrame)
    sub = df[(string.(df.category) .== category) .& (string.(df.season) .== season), :]
    if nrow(sub) == 0
        return DataFrame()
    end
    fmean(x) = mean(skipmissing(x))
    avg_all = combine(groupby(sub, :brand), :current_price => fmean => :avg_price)
    range_all = combine(groupby(sub, :brand), :current_price => minimum => :min_price, :current_price => maximum => :max_price)
    stats = leftjoin(avg_all, range_all, on=:brand)
    sort!(stats, :avg_price, rev=true)
    return stats
end

@testset "step2 price range - test_step2" begin
    stats = compute_stats(csv_in, "Dresses", "Summer")
    @test isa(stats, DataFrame)
    brands = sort(collect(stats.brand))
    @test brands == ["H&M","Zara"]
    # Zara avg = (10+20)/2 = 15, H&M avg = (15+25)/2 = 20
    z = stats[findfirst(==("Zara"), stats.brand), :]
    h = stats[findfirst(==("H&M"), stats.brand), :]
    @test isapprox(z.avg_price, 15.0; atol=1e-8)
    @test isapprox(h.avg_price, 20.0; atol=1e-8)
    @test z.min_price == 10.0 && z.max_price == 20.0

    # cleanup
    isfile(csv_in) && rm(csv_in)
end

println("test_step2 finished")
