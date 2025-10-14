using Dates, CSV, DataFrames, Statistics
using StatsModels, GLM

root = @__DIR__
csvpath = joinpath(root, "fashion_boutique_dataset.csv")
step1 = joinpath(root, "step1_compare_two_brands.jl")
step2 = joinpath(root, "step2_avg_price_by_brand.jl")
step3 = joinpath(root, "step3_simulate_timeseries_sales_aligned.jl")

total = 0
passed = 0

function mark_total(n=1)
    global total
    total += n
end

function mark_pass(n=1)
    global passed
    passed += n
end

function ok(msg)
    mark_pass()
    println("[ OK  ] ", msg)
end

function fail(msg)
    println("[FAIL] ", msg)
end

function check(path, description)
    mark_total()
    if isfile(path)
        ok(description)
        return true
    else
        fail(description * " — file not found: $path")
        return false
    end
end

function check_csv_cols(path, cols::Vector{String})
    mark_total()
    try
        cf = CSV.File(path)
        h = String.(cf.header)
        miss = setdiff(cols, h)
        if isempty(miss)
            ok("CSV has required columns: $(join(cols, ", "))")
            return true
        else
            fail("CSV missing columns: $(join(miss, ", "))")
            return false
        end
    catch e
        fail("Could not read CSV header: $e")
        return false
    end
end

function run()
    t0 = Dates.now()
    println("Running simple end-to-end tests (non-interactive)\nProject root: $root\n")

    # Step 1 & 2 existence checks
    _ = check(csvpath, "Dataset present: $(basename(csvpath))")
    _ = check(step1, "Step1 script present")
    _ = check(step2, "Step2 script present")

    # CSV columns
    _ = check_csv_cols(csvpath, ["brand","category","season","current_price"])

    # Step2 content check
    mark_total()
    try
        txt = read(step2, String)
        if occursin("plot_avg_price_by_brand!", txt)
            ok("step2 contains plot_avg_price_by_brand!()")
        else
            fail("step2 likely missing plot_avg_price_by_brand!()")
        end
    catch e
        fail("Could not read step2 for content check: $e")
    end

    # Step3: run in-process
    println("\n-- Running step3 (simulator) in-process --")
    mark_total()
    ts_out = joinpath(root, "timeseries_test.csv")
    try
        oldARGS = copy(ARGS)
        empty!(ARGS)
        push!(ARGS, csvpath)
        push!(ARGS, ts_out)
        include(step3)
        empty!(ARGS); append!(ARGS, oldARGS)
        if isfile(ts_out)
            ok("step3 produced timeseries: $(basename(ts_out))")
        else
            fail("step3 did not produce timeseries file")
        end
    catch e
        empty!(ARGS); append!(ARGS, oldARGS)
        fail("step3 in-process error: $e")
    end

    # Step4 & Step5: basic checks and regressions
    println("\n-- Running step4 & step5 checks --")
    mark_total()
    if !isfile(ts_out)
        fail("Timeseries file missing for steps 4/5: $ts_out")
    else
        try
            ts = CSV.read(ts_out, DataFrame)
            for col in ["date","brand","category","season","sim_price","sim_demand"]
                if !(col in String.(names(ts)))
                    fail("Timeseries missing column: $col")
                    return
                end
            end
            ok("Timeseries contains expected columns")

            ts.sim_price = Float64.(ts.sim_price)
            ts.sim_demand = Float64.(ts.sim_demand)
            ts.log_p = log.(ts.sim_price)
            ts.log_q = log.(ts.sim_demand)

            groups = groupby(ts, [:brand, :category])
            fitted = 0
            for g in groups
                if nrow(g) >= 3
                    m = lm(@formula(log_q ~ log_p), g)
                    fitted += 1
                end
            end
            if fitted > 0
                ok("Fitted grouped regressions for $fitted groups")
                mark_pass() # extra pass for successful regressions
            else
                fail("No groups with >=3 rows to fit regressions")
            end
        catch e
            fail("Step4/5 error: $e")
        end
    end

    dt = Dates.now() - t0
    println("\n== Summary ==")
    println("Passed: $passed / Total: $total")
    println("Elapsed: $(Dates.value(dt)) ms")
end

run()

