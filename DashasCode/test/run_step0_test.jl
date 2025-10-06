using CSV, DataFrames

# point at test input and output
input_path = joinpath(@__DIR__, "input_step0.csv")
output_path = joinpath(@__DIR__, "output_step0.csv")

trimstr(x) = x === missing ? missing : strip(String(x))

tofloat(x) = x === missing ? missing : try
    Float64(x)
catch
    try
        parse(Float64, String(x))
    catch
        missing
    end
end

df = CSV.read(input_path, DataFrame)
rename!(df, Dict(n => Symbol(lowercase(String(n))) for n in names(df)))

df.brand         = trimstr.(df.brand)
df.category      = trimstr.(df.category)
df.season        = trimstr.(df.season)
df.current_price = tofloat.(df.current_price)

println("Rows: ", nrow(df), " | Brands: ", length(unique(skipmissing(df.brand))), " | current_price missing: ", count(ismissing, df.current_price))

CSV.write(output_path, df)
println("Wrote normalized file to: ", output_path)
