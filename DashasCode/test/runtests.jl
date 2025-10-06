using Test
using CSV, DataFrames

# Include the implementation under test
include(joinpath(@__DIR__, "..", "seasonal_tables.jl"))

# alias the functions from the included file (they are in Main)
const mod = Main

@testset "seasonal_tables tests" begin

    @testset "normbrand & cleancat" begin
        @test mod.normbrand("Zara") == "Zara"
        @test mod.normbrand(" zArA ") == "Zara"
        @test mod.normbrand("H M") == "H&M"
        @test mod.normbrand(missing) === missing

        @test mod.cleancat("summer-dress") == "summer dress"
        @test mod.cleancat("_long__skirt") == "long skirt"
        @test mod.cleancat(missing) === missing
    end

    @testset "ensure_current_price" begin
        df_ok = DataFrame(brand = ["A"], category=["dress"], season=["summer"], current_price=[10.0])
        @test mod.ensure_current_price(df_ok) === nothing

        df_bad = DataFrame(brand = ["A"]) 
        @test_throws ErrorException mod.ensure_current_price(df_bad)
    end

    @testset "table_one_season_dresses aggregation" begin
        df_all = DataFrame(
            brand = ["Zara", "H&M", "Other", "Zara"],
            category = ["dress", "shirt", "dress", "summer dress"],
            season = ["summer", "summer", "winter", "summer"],
            current_price = [10.0, 20.0, 30.0, 30.0]
        )

        tbl = mod.table_one_season_dresses(df_all, "summer")
        # brands should include all unique brands from df_all (sorted)
        expected_brands = sort(unique(df_all.brand))
        @test collect(tbl.brand) == expected_brands

        # Zara average: mean of 10.0 and 30.0 => 20.0
        idx = findfirst(==("Zara"), tbl.brand)
        @test tbl.avg_current_price_dress[idx] == 20.0

        # H&M has no dress rows in summer -> missing
        idx_hm = findfirst(==("H&M"), tbl.brand)
        @test ismissing(tbl.avg_current_price_dress[idx_hm])

        # season with no dress rows returns all brands with missing
        tbl2 = mod.table_one_season_dresses(df_all, "autumn")
        @test all(ismissing, tbl2.avg_current_price_dress)
    end

    @testset "load_and_normalize && build_season_tables_dresses (no CSV save)" begin
        # create a tiny temporary CSV to exercise load_and_normalize
        tmp = tempname() * ".csv"
        data = DataFrame(Brand = [" zara" , "HM"], Category = ["Dress-Long","shirt"], Season = ["Fall","Summer"], Current_Price = [12.5, 20])
        CSV.write(tmp, data)

        df_norm = mod.load_and_normalize(tmp)
        @test all(isa.(df_norm.brand, String))
        # Fall should be normalized to "autumn"
        @test any(occursin.(["autumn"], df_norm.season)) || any(==("autumn"), df_norm.season)

        # run build for a single season, avoid writing CSVs
        tables = mod.build_season_tables_dresses(tmp; seasons = ["summer"], save_csv = false)
        @test haskey(tables, "summer")
        tbls = tables["summer"]
        @test :brand in names(tbls) && :avg_current_price_dress in names(tbls)

        # cleanup
        isfile(tmp) && rm(tmp)
    end

end

println("Tests finished.")
