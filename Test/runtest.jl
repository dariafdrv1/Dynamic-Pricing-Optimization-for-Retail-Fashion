using Test, Dates, CSV, DataFrames, Statistics
using StatsModels, GLM

root = @__DIR__
csvpath = joinpath(root, "..", "fashion_boutique_dataset.csv")
step1 = joinpath(root, "..", "step1_compare_two_brands.jl")
step2 = joinpath(root, "..", "step2_avg_price_by_brand.jl")
step3 = joinpath(root, "..", "step3_simulate_timeseries_sales_aligned.jl")
ts_out = joinpath(root, "timeseries_test.csv")

@testset "Project Tests" begin
    @testset "Files" begin
        @test isfile(csvpath)
        @test isfile(step1)
        @test isfile(step2)
    end

    @testset "CSV Header" begin
        cols = String[]
        try
            df = CSV.read(csvpath, DataFrame; limit=0)
            cols = String.(names(df))
        catch _
            try
                cf = CSV.File(csvpath)
                cols = String.(collect(names(cf)))
            catch e
                @test false
            end
        end
        @test all(x -> x in cols, ["brand","category","season","current_price"])
    end

    @testset "Step2 content" begin
        try
            txt = read(step2, String)
            @test occursin("plot_avg_price_by_brand!", txt)
        catch e
            @test false
        end
    end

    @testset "Simulator" begin
        if isfile(ts_out)
            rm(ts_out)
        end
        try
            oldARGS = copy(ARGS)
            empty!(ARGS); push!(ARGS, csvpath); push!(ARGS, ts_out)
            include(step3)
            empty!(ARGS); append!(ARGS, oldARGS)
            @test isfile(ts_out)
        catch e
            empty!(ARGS); append!(ARGS, oldARGS)
            @test false
        end
    end

    @testset "Elasticity & Regressions" begin
        try
            ts = CSV.read(ts_out, DataFrame)
            for col in ["date","brand","category","season","sim_price","sim_demand"]
                @test col in String.(names(ts))
            end
            ts.sim_price = Float64.(ts.sim_price)
            ts.sim_demand = Float64.(ts.sim_demand)
            ts.log_p = log.(ts.sim_price)
            ts.log_q = log.(ts.sim_demand)

            groups = groupby(ts, [:brand, :category])
            fitted = 0
            for g in groups
                if nrow(g) >= 3
                    m = lm(@formula(log_q ~ log_p), g)
                    @test !ismissing(coef(m)[2])
                    fitted += 1
                end
            end
            @test fitted > 0
        catch e
            @test false
        end
    end
end


