using CSV
using DataFrames

file_path = "/Users/dfedorova/github/DashasCode/fashion_boutique_dataset.csv"

df = CSV.read(file_path, DataFrame)

println("First 5 records:")
println(first(df, 5))