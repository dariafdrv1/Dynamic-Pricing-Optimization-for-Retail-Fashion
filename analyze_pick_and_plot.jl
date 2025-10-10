# analyze_pick_and_plot.jl
# Usage:
#   julia --project analyze_pick_and_plot.jl /Users/marcelasantos/Desktop/Project/timeseries_sales.csv [/Users/marcelasantos/Desktop/Project]

using CSV, DataFrames, Statistics, GLM, StatsModels, Plots
using REPL.TerminalMenus
gr()

# ---- inputs ----
inpath = length(ARGS) ≥ 1 ? ARGS[1] : "/Users/marcelasantos/Desktop/Project/timeseries_sales.csv"
outdir = length(ARGS) ≥ 2 ? ARGS[2] : "/Users/marcelasantos/Desktop/Project"

isfile(inpath) || error("CSV not found at: $inpath")
isdir(outdir)  || mkpath(outdir)

df = CSV.read(inpath, DataFrame)
df = df[(df.sim_price .> 0) .& (df.sim_demand .> 0), :]

# helpers
safe_slug(s::AbstractString) = replace(replace(s, r"\s+" => "_"), r"[^A-Za-z0-9_]" => "")

# force Vector{String} for menus
brands     = sort!(collect(String.(unique(df.brand))))
categories = sort!(collect(String.(unique(df.category))))
seasons    = sort!(collect(String.(unique(df.season))))

bmenu = RadioMenu(brands;     pagesize = max(1, min(length(brands), 12)))
cmenu = RadioMenu(categories; pagesize = max(1, min(length(categories), 12)))
smenu = RadioMenu(seasons;    pagesize = max(1, min(length(seasons), 12)))

while true
    println()
    bidx = request("Select brand:", bmenu)
    cidx = request("Select category:", cmenu)
    sidx = request("Select season:", smenu)

    brand_sel    = brands[bidx]
    category_sel = categories[cidx]
    season_sel   = seasons[sidx]

    # slice
    g = df[(String.(df.brand)    .== brand_sel) .&
           (String.(df.category) .== category_sel) .&
           (String.(df.season)   .== season_sel), :]

    if nrow(g) < 3
        println("Not enough points for $brand_sel / $category_sel / $season_sel — try another.")
        print("\nMake another selection? (y/n): ")
        answer = lowercase(chomp(readline()))
        answer in ("y","yes") || (println("\nAll set ✨"); break)
        continue
    end

    # prepare logs
    g.log_p = log.(g.sim_price)
    g.log_q = log.(g.sim_demand)

    # elasticity
    m     = lm(@formula(log_q ~ log_p), g)
    beta  = coef(m)[2]
    r2val = GLM.r2(m)

    # plot
    p = scatter(g.sim_price, g.sim_demand;
                legend=false, xlabel="Price", ylabel="Demand",
                title = "$brand_sel / $category_sel / $season_sel — price vs demand\nelasticity=$(round(beta,digits=2)), R²=$(round(r2val,digits=2))",
                markersize=5)

    xp = range(minimum(g.sim_price), maximum(g.sim_price), length=200)
    θ  = ([ones(nrow(g)) g.log_p]) \ g.log_q
    plot!(p, xp, exp.(θ[1] .+ θ[2] .* log.(xp)), linewidth=2)

    # save
    fname   = "pvq_$(safe_slug(brand_sel))_$(safe_slug(category_sel))_$(safe_slug(season_sel)).png"
    pngpath = joinpath(outdir, fname)
    savefig(p, pngpath)

    # show & auto-open
    try
        display(p)             # show a window (if available)
        run(`open $(pngpath)`) # macOS: open the saved PNG
    catch e
        @info "Plot saved but couldn't auto-open. Open manually:" pngpath error=e
    end

    println("✅ Saved plot to: $pngpath")

    print("\nMake another plot? (y/n): ")
    answer = lowercase(chomp(readline()))
    answer in ("y","yes") || (println("\nAll set ✨"); break)
end