using CSV, DataFrames, Test, Statistics

# Create small test CSV
csv_in = joinpath(@__DIR__, "input_step3.csv")
data = DataFrame(brand = ["Zara", "Zara", "H&M", "H&M", "Other"],
                 category = ["Dresses", "Dresses", "Dresses", "Dresses", "Tops"],
                 season = ["Summer", "Summer", "Summer", "Summer", "Summer"],
                 current_price = [10.0, 20.0, 15.0, 25.0, 30.0])
CSV.write(csv_in, data)

function avg_per_brand(path::AbstractString, category::String, season::String)
    df = CSV.read(path, DataFrame)
    sub = df[(string.(df.category) .== category) .& (string.(df.season) .== season), :]
    if nrow(sub) == 0
        return DataFrame()
    end
    fmean(x) = mean(skipmissing(x))
    avg = combine(groupby(sub, :brand), :current_price => fmean => :avg_price)
    sort!(avg, :avg_price, rev=true)
    return avg
end

@testset "step3 loop - test_step3" begin
    avg = avg_per_brand(csv_in, "Dresses", "Summer")
    @test isa(avg, DataFrame)
    brands = sort(collect(avg.brand))
    @test brands == ["H&M","Zara"]
    z = avg[findfirst(==("Zara"), avg.brand), :]
    h = avg[findfirst(==("H&M"), avg.brand), :]
    @test isapprox(z.avg_price, 15.0; atol=1e-8)
    @test isapprox(h.avg_price, 20.0; atol=1e-8)

    # cleanup
    isfile(csv_in) && rm(csv_in)
end

println("test_step3 finished")
