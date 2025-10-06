using CSV, DataFrames, Test

# Create a small test CSV to exercise the comparison logic
csv_in = joinpath(@__DIR__, "input_step1.csv")
csv_out = joinpath(@__DIR__, "output_step1.csv")

data = DataFrame(brand = ["Zara", "Zara", "H&M", "H&M", "Other"],
                 category = ["Dresses", "Dresses", "Dresses", "Dresses", "Tops"],
                 season = ["Summer", "Summer", "Summer", "Summer", "Summer"],
                 current_price = [10.0, 20.0, 15.0, 25.0, 30.0])

CSV.write(csv_in, data)

function compare_brands_from_csv(path::AbstractString, category::String, season::String, b1::String, b2::String)
    df = CSV.read(path, DataFrame)
    @assert :brand ∈ names(df) && :category ∈ names(df) && :season ∈ names(df) && :current_price ∈ names(df)
    sub = filter(r -> r.category == category && r.season == season && (r.brand == b1 || r.brand == b2), df)
    if nrow(sub) == 0
        return nothing
    end
    fmean(x) = mean(skipmissing(x))
    avg = combine(groupby(sub, :brand), :current_price => fmean => :avg_price)
    return avg
end

@testset "step1 compare two brands - test_step1" begin
    avg = compare_brands_from_csv(csv_in, "Dresses", "Summer", "Zara", "H&M")
    @test isa(avg, DataFrame)
    # check both brands present
    brands = sort(collect(avg.brand))
    @test brands == ["H&M", "Zara"]
    # Zara average = (10 + 20)/2 = 15
    zrow = avg[findfirst(==("Zara"), avg.brand), :]
    hrow = avg[findfirst(==("H&M"), avg.brand), :]
    @test isapprox(zrow.avg_price, 15.0; atol=1e-8)
    @test isapprox(hrow.avg_price, 20.0; atol=1e-8)

    # cleanup
    isfile(csv_in) && rm(csv_in)
end

println("test_step1 finished")
