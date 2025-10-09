import Pkg; Pkg.add(["CSV","DataFrames","Test"])
using Test

# Run each step's non-interactive test file sequentially.
# They create their own temporary CSVs and clean up after themselves.
println("Running all step tests:")

let
    pwd = @__DIR__
    println("- Running test_step1...")
    include(joinpath(pwd, "test_step1.jl"))
    println("- Running test_step2...")
    include(joinpath(pwd, "test_step2.jl"))
    println("- Running test_step3...")
    include(joinpath(pwd, "test_step3.jl"))
end

println("All tests completed.")
