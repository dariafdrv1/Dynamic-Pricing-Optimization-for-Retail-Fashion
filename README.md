# Dynamic Pricing Optimization for Retail Fashion

# Problem Description

In the retail fashion market, both customers and suppliers face challenges related to pricing transparency and competition. Customers continuously compare products and prices across different brands to find the best value for their purchases, while suppliers and retailers need to monitor market developments to understand their competitive position. For customers, this means being able to identify which brand offers better prices for similar products; for retailers, it means gaining insight into competitors’ pricing strategies and adjusting their own accordingly.  

To address these challenges, our project introduces a program designed to analyze and compare retail fashion prices in a structured and accessible way. The program allows users to filter and evaluate data based on product category, brand, and season, offering an interactive and data-driven approach to understanding price differences and market trends.  

The main goal of this project is to develop a program that provides meaningful market insights into pricing strategies. By simplifying and structuring fashion retail data, the program enables users, from consumers to brand managers, to make informed decisions. For instance, a consumer can compare the prices of jeans from Zara and H&M to find the best deal, while a retailer can use the same insights to benchmark its pricing performance against competitors and adapt its strategy accordingly.  

With our project, **Dynamic Pricing Optimization for Retail Fashion**, we aim to simplify a detailed dataset, *fashion_boutique_dataset*, which contains 14 variables: product ID, category, brand, season, size, color, original price, markdown percentage, current price, purchase date, stock quantity, customer rating, return status, and return reason. From this dataset, we focus only on four variables: category, brand, season, and current price. These variables allow direct comparisons of products, brands, and pricing over time, forming the foundation for both customer-facing and business-oriented analysis.  

# Program Development

The program is developed using a modular coding strategy, where each part of the code is designed to perform a specific function. This modular approach enhances clarity, maintainability. When combined, the modules allow users to interact with the program and compare prices across different brands, categories, and seasons.

The first part of our program focuses on building the foundation of the information system used to analyse fashion product prices across categories, brands, and seasons.
The process begins with data review and cleaning, so that it contains only the variables relevant to the analysis: 

- 6 categories (Outerwear, Tops, Accessories, Shoes, Bottoms, Dresses)  
- 10 brands (Zara, Uniqlo, Banana Republic, Mango, H&M, Ann Taylor, Gap, Forever21)  
- 4 seasons (Spring, Summer, Fall, Winter)  

These lists guarantee that user interactions remain consistent and prevent processing errors caused by variations in text formatting or typos. 

## User Interface
The program is designed to provide a simple and intuitive UX/UI experience through a series of menus. The program guides the user step-by-step to make the necessary selections:

- **Category selection** the user chooses a product category from the available options.

- **Season selection** the user selects a season to analyze.

- **Brand selection** the user selects two different brands to compare from those available in the chosen category and season.

After the selections are made, the program validates the inputs to ensure that the chosen values exist in the dataset and that two distinct brands have been selected. If any input is invalid or unavailable, an error message is displayed, prompting the user to try again. Once the inputs are confirmed, the program performs the price comparison and displays the results clearly on the screen.

## Data Filtering

After collecting and validating all user inputs, the program searches the dataset to keep only the rows that match user’s choices: 

- **Product Category:** Items must belong to the selected category.  
- **Season:** Items must correspond to the chosen season.  
- **Brands:** Items must be sold by one of the two selected brands.  

This process narrows the dataset to the products that user wants to compare. If no matching products are found (for instance, if one of the brands has no items in that category or season), the program informs the user that there is **no data available** for the requested analysis.

## Error Handling

An important feature of the program is the implementation of **error handling and input validation**. For example, if the user types a brand name incorrectly, provides only one brand instead of two, or enters a season or category that does not exist in the system (e.g., “glasses”) the program displays an error message and asks the user to enter the information again.  

This ensures that the calculations are performed only with valid and consistent data.

# Setup

Install the required Julia packages once:
- CSV.jl – for reading and writing CSV files
- DataFrames.jl – for working with tabular data
- Statistics.jl – for basic statistical operations
- GLM.jl – for linear regression and elasticity estimation
- StatsModels.jl – for regression formula handling
- Plots.jl – for data visualization

# Step 1: Brand Comparison Program

This part presents the first interactive module of the project, implemented as a menu-based program that enables users to compare the prices of two fashion brands within a selected category and season. The program begins by displaying menus from which the user selects a product category and season. Based on these choices, the system automatically filters the dataset to show only the brands available within the selected parameters. The user can then choose two different brands to compare. Once the selections are made, the program calculates the average current price for each brand, displays the results in a comparison table, and highlights the price difference between them. If the selected category and season contain no data or fewer than two brands, the program notifies the user and allows them to make another selection. This interactive process can be repeated multiple times, allowing users to explore and compare brand pricing patterns across various categories and seasons.

## How To Run
1. Download raw code step1_compare_two_brands
2. Run in you terminal with your own path: julia --project step1_compare_two_brands.jl "fashion_boutique_dataset.csv"
3. It produces output


# Step 2 — Avg Price by Brand (Bar Chart)

This module provides an interactive, menu-based bar chart of average current prices by brand within a selected category and season. After the user picks a category and season from the menus, the program filters the dataset and computes each brand’s average current price in that slice. It then renders a bar chart to visualize brand positioning (higher vs. lower priced brands) and prints a short summary (mean/median). If desired, the user can also save each chart as a PNG file. If the chosen slice has no rows or only one brand, the program notifies the user and lets them select again. The menu loop allows repeated exploration across categories and seasons.

## How To Run
	•	Download raw code: step2_avg_price_by_brand.jl
	•	Run in your terminal (display only):

julia --project step2_avg_price_by_brand.jl "fashion_boutique_dataset.csv"


	•	(Optional) Save charts to a folder:

julia --project step2_avg_price_by_brand.jl "fashion_boutique_dataset.csv" "/Users/marcelasantos/Desktop/Project"


	•	It produces: an on-screen bar chart and (optionally) a PNG like
avg_price_by_brand_[Category]_[Season].png.



# Step 3 — Simulate Time-Series Sales

This module generates a synthetic weekly time series for 2024, creating sim_price and sim_demand for every brand × category × season combination present in the original dataset. Prices evolve with gentle volatility and seasonal effects; demand follows a downward-sloping relationship to price (constant-elasticity with noise). The result is a realistic, analysis-ready table you can use for elasticity estimation and plotting in the next steps.

## How To Run
	•	Download raw code: step3_simulate_timeseries_sales_aligned.jl
	•	Run in your terminal:

julia --project step3_simulate_timeseries_sales_aligned.jl


	•	It produces: a CSV named timeseries_sales.csv (≈2.5k rows) with columns
date, brand, category, season, sim_price, sim_demand.

⸻

# Step 4 — Elasticity Estimation and Summary

This step estimates price elasticity of demand by fitting a log-log regression log(demand) ~ log(price) for each brand × category pair using the simulated time series. It returns a compact summary with the estimated elasticity, R² (fit quality), and number of observations per segment. The output can be cited in the report and used to guide which slices to visualize in Step 5.

## How To Run
	•	Option A — if you saved the script as step4_elasticity_summary.jl:

julia --project step4_elasticity_summary.jl


	•	Option B — run the short REPL snippet in Julia:

using CSV, DataFrames, GLM, StatsModels, Statistics
ts = CSV.read("/Users/marcelasantos/Desktop/Project/timeseries_sales.csv", DataFrame)
ts = ts[(ts.sim_price .> 0) .& (ts.sim_demand .> 0), :]
ts.log_p = log.(ts.sim_price); ts.log_q = log.(ts.sim_demand)
function fit(g); m = lm(@formula(log_q ~ log_p), g); (coef(m)[2], r2(m)) end
summ = DataFrame([(b=String(g.brand[1]), c=String(g.category[1]), n=nrow(g),
                   β=fit(g)[1], r2=fit(g)[2]) for g in groupby(ts, [:brand,:category])])
CSV.write("/Users/marcelasantos/Desktop/Project/elasticity_timeseries_summary.csv", summ)


	•	It produces: elasticity_timeseries_summary.csv with columns
brand, category, n, elasticity, r2.


# Step 5 — Analyze, Pick & Plot (Interactive)

This interactive module lets the user pick a brand, category, and season and immediately see a price-vs-demand scatter plot with a fitted curve. It uses the simulated weekly data, fits the same log-log model for the selected slice, and overlays the predicted relationship. Each plot is automatically saved as a PNG and opened on macOS, making it easy to collect visuals for the report.

## How To Run
	•	Download raw code: step5_analyze_pick_and_plot.jl
	•	Run in your terminal:

julia --project step5_analyze_pick_and_plot.jl "/Users/marcelasantos/Desktop/Project/timeseries_sales.csv"


	•	It produces: a PNG like
pvq_[Brand]_[Category]_[Season].png (e.g., pvq_HM_Shoes_Summer.png) and shows the plot.


## License 

https://www.apache.org/licenses/LICENSE-2.0

