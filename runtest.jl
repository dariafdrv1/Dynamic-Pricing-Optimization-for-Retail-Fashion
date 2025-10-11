# This script performs a few non-invasive checks:
#  - dataset file exists and has the required columns
#  - the two script files exist
#  - basic, static checks inside each script (looks for expected
#    function names / keywords) so we don't execute interactive
#    code during tests.

using CSV, DataFrames

root = @__DIR__
csvpath = joinpath(root, "fashion_boutique_dataset.csv")
f1 = joinpath(root, "step1_compare_two_brands.jl")
f2 = joinpath(root, "step2_avg_price_by_brand.jl")

function fail(msg)
    println("[FAIL] ", msg)
    exit(1)
end

function ok(msg)
    println("[ OK ] ", msg)
end

function run_tests()
    println("Running simple smoke tests...\n")

    # 1) CSV exists
    isfile(csvpath) || fail("CSV not found at: $csvpath")
    ok("Found dataset: $(basename(csvpath))")

    # 2) CSV has required columns
    required = ["brand", "category", "season", "current_price"]
    # try to read just the header using CSV.File; fall back to reading a DataFrame
    cols = String[]
    try
        cf = CSV.File(csvpath)
        cols = String.(cf.header)
    catch _
        try
            df = CSV.read(csvpath, DataFrame)
            cols = String.(names(df))
        catch e
            fail("Could not read CSV: $(e)")
        end
    end
    missing_cols = setdiff(required, cols)
    isempty(missing_cols) || fail("CSV is missing required columns: " * join(missing_cols, ", "))
    ok("CSV has required columns: " * join(required, ", "))

    # 3) Script files exist
    isfile(f1) || fail("Missing file: $(f1)")
    isfile(f2) || fail("Missing file: $(f2)")
    ok("Found script files: $(basename(f1)), $(basename(f2))")

    # 4) Static inspections (do not execute scripts)
    txt1 = read(f1, String)
    txt2 = read(f2, String)

    # Basic expectations for step1 — it's allowed to vary, so we keep checks simple
    if occursin("brand", lowercase(txt1)) && occursin("current_price", lowercase(txt1))
        ok("step1 contains expected keywords (brand, current_price)")
    else
        fail("step1_compare_two_brands.jl looks missing expected keywords (brand, current_price)")
    end

    # More specific checks for step2
    if occursin("function plot_avg_price_by_brand!", txt2)
        ok("step2 defines plot_avg_price_by_brand!()")
    else
        fail("step2_avg_price_by_brand.jl missing function plot_avg_price_by_brand!()")
    end

    if occursin("safe_slug", txt2) && occursin("current_price", txt2)
        ok("step2 contains safe_slug and references current_price")
    else
        fail("step2_avg_price_by_brand.jl missing safe_slug or current_price references")
    end

    println("\nAll smoke checks passed. You can run the scripts interactively as described in their headers.")
    exit(0)
end

run_tests()
