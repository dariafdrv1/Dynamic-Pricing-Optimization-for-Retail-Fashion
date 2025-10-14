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

# Setup

Install the required Julia packages once:
CSV.jl – for reading and writing CSV files
DataFrames.jl – for working with tabular data
	•	Statistics.jl – for basic statistical operations
	•	GLM.jl – for linear regression and elasticity estimation
	•	StatsModels.jl – for regression formula handling
	•	Plots.jl – for data visualization

# Part 1: Brand Comparison Program

This part presents the first interactive module of the project, implemented as a menu-based program that enables users to compare the prices of two fashion brands within a selected category and season. The program begins by displaying menus from which the user selects a product category and season. Based on these choices, the system automatically filters the dataset to show only the brands available within the selected parameters. The user can then choose two different brands to compare. Once the selections are made, the program calculates the average current price for each brand, displays the results in a comparison table, and highlights the price difference between them. If the selected category and season contain no data or fewer than two brands, the program notifies the user and allows them to make another selection. This interactive process can be repeated multiple times, allowing users to explore and compare brand pricing patterns across various categories and seasons.

## Step 1: User Interface

The user interface is designed to provide a simple and intuitive experience through a series of menus. The program guides the user step-by-step to make the necessary selections:

- **Category selection** the user chooses a product category from the available options.

- **Season selection** the user selects a season to analyze.

- **Brand selection** the user selects two different brands to compare from those available in the chosen category and season.

After the selections are made, the program validates the inputs to ensure that the chosen values exist in the dataset and that two distinct brands have been selected. If any input is invalid or unavailable, an error message is displayed, prompting the user to try again. Once the inputs are confirmed, the program performs the price comparison and displays the results clearly on the screen.

## Step 2: Data Filtering

After collecting and validating all user inputs, the program searches the dataset to keep only the rows that match user’s choices: 

- **Product Category:** Items must belong to the selected category.  
- **Season:** Items must correspond to the chosen season.  
- **Brands:** Items must be sold by one of the two selected brands.  

This process narrows the dataset to the products that user wants to compare. If no matching products are found (for instance, if one of the brands has no items in that category or season), the program informs the user that there is **no data available** for the requested analysis. 

## Step 3: Average Price Analysis

The program proceeds to calculate and present the average prices for comparison. In this stage, the program identifies the average current prices of the products belonging to the selected brands. Moreover, the program associates the results with the selected season, allowing the analysis to take into account the seasonal context of the prices.
 
## Error Handling

An important feature of the program is the implementation of **error handling and input validation**. For example, if the user types a brand name incorrectly, provides only one brand instead of two, or enters a season or category that does not exist in the system (e.g., “glasses”) the program displays an error message and asks the user to enter the information again.  

This ensures that the calculations are performed only with valid and consistent data.

## Part 2: Data Visualization and Price Distribution Analysis

This part of the project introduces the second module, implemented as a **menu-based program** that allows users to analyze and visualize how prices vary across all brands within a selected category and season. Unlike the first module, which focuses on comparing only two brands, this step provides a broader market overview by displaying price distributions for all available brands in the chosen segment.

After the user selects a category and season from the menus, the program automatically filters the dataset to include only the rows that match those choices. If no data exists for the selected combination, or if there is only one brand in that category and season, the program notifies the user and allows them to make another selection.

For the valid selection, the program performs a **summary analysis** that calculates the total number of products, the **mean** and **median current prices**, and the **average price per brand**. The results are displayed directly in the console, giving the user an overview of pricing patterns within the chosen slice of data.

To enhance interpretability, the program also generates a **bar chart** illustrating the average current price for each brand. Each bar is labeled with the brand name and annotated with the corresponding price value, providing a clear and immediate visual comparison between brands. Users can choose whether they would like to save each chart as a PNG file for later reference.

Once the visualization is complete, the program asks whether the user would like to analyze another category or season. If confirmed, the process repeats, allowing continuous exploration of price trends across the dataset. This interactive looping design enables users, retailers, and analysts to gain deeper insights into how brand pricing strategies vary across categories and seasonal contexts, supporting both consumer decision-making and competitive benchmarking.
## Part 3: Interactive Exploration (Looped Visualization)

The third part of the program expands the analysis by allowing users to **continuously explore price patterns** across all brands, categories, and seasons in a single interactive session. Unlike the previous modules, which focus on one-time comparisons, this step introduces a **looped visualization system** that lets users generate multiple analyses without restarting the program.

Once the dataset is loaded and validated, the program automatically identifies all available categories and seasons directly from the data. This ensures that the user is always selecting from accurate, up-to-date options and prevents input errors such as typos or unavailable entries.

After the user selects a category and a season, the program filters the dataset to display only the products that match those criteria. It then calculates the average current price for each brand, skipping any missing values to maintain reliable results.

The filtered data is presented visually through a **bar chart**, where:

- The **x-axis** represents the different brands.

- The **y-axis** displays the average current price.

- Each bar is labeled with the brand name and annotated with the corresponding average price value.

- The chart title clearly indicates the selected category and season.

If there is no data available for the chosen combination, the program informs the user and returns to the selection phase without errors or interruptions.

After each visualization, the user is asked whether they would like to analyze another category or season. By confirming, the user can immediately repeat the process with new selections, enabling smooth and continuous exploration of pricing trends across the entire dataset. If the user chooses to exit, the program ends.

This step enhances user interaction by combining automated data filtering, statistical summarization, and dynamic visualization in one continuous loop. It allows both consumers and analysts to easily observe how brand pricing strategies differ across various market conditions and seasonal contexts.

## License 

https://www.apache.org/licenses/LICENSE-2.0

