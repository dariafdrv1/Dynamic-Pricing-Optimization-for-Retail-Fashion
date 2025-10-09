# Dynamic Pricing Optimization for Retail Fashion

# Problem Description

In the retail fashion market, customers compare products and prices across different brands before making their final purchase decisions. Since pricing strategies have become increasingly crucial, we have decided to develop a program that helps customers analyze and compare retail prices efficiently. In addition to supporting consumers, the program can also be valuable for suppliers and retailers, allowing them to observe market developments, monitor competitors’ pricing strategies, and benchmark their own position against other brands.  

The main goal of this project is to create a program that any user can access to compare the prices between two selected brands. This will be achieved by developing a modular program capable of processing and filtering data based on product category, season, and brand, ultimately enabling clear and efficient price comparisons.  

With our project, **Dynamic Pricing Optimization for Retail Fashion**, we aim to simplify a detailed dataset, *fashion_boutique_dataset*, which contains 14 variables: product ID, category, brand, season, size, color, original price, markdown percentage, current price, purchase date, stock quantity, customer rating, return status, and return reason. From this dataset, we focus only on five variables: category, brand, season, original price, and purchase date. These variables allow direct comparisons of products, brands, and pricing over time.  

For example, using the system, a user can easily compare the prices of jeans from Zara and H&M, or explore how outerwear prices change across different seasons.  

# Program Development

The program is developed using a modular coding strategy, where each part of the code is designed to perform a specific function. This modular approach enhances clarity, maintainability. When combined, the modules allow users to interact with the program and compare prices across different brands, categories, and seasons.

The first part of our program focuses on building the foundation of the information system used to analyse fashion product prices across categories, brands, and seasons.
The process begins with data review and cleaning, so that it contains only the variables relevant to the analysis: 

- 6 categories (Outerwear, Tops, Accessories, Shoes, Bottoms, Dresses)  
- 10 brands (Zara, Uniqlo, Banana Republic, Mango, H&M, Ann Taylor, Gap, Forever21)  
- 4 seasons (Spring, Summer, Fall, Winter)  

These lists guarantee that user interactions remain consistent and prevent processing errors caused by variations in text formatting or typos. 

# Part 1: Brand Comparison Program

This part of the project introduces the first interactive module, which allows users to compare the prices between **two selected fashion brands** within a specific **category** and **season**. It forms the foundation of the analysis system by combining user input validation, data filtering, and statistical comparison.

## Step 1: User Interface

This initial phase focuses on direct interaction with the user. The program requires the user to provide three specific inputs:

1. **Product category:** the user selects one of the six available options.  
2. **Two brands to compare:** selected from the available brands.  
3. **Season:** the user selects the desired season.  

This step validates the inputs to ensure they are correct, that the two brands are different and that all inputs match the allowed variables exactly. If the input is invalid, the program asks the user to re-enter it.  

This step ensures that the comparison is performed only on valid and consistent data. 

## Step 2: Data Filtering

After collecting and validating all user inputs, the program searches the dataset to keep only the rows that match user’s choices: 

- **Product Category:** Items must belong to the selected category.  
- **Season:** Items must correspond to the chosen season.  
- **Brands:** Items must be sold by one of the two selected brands.  

This process narrows the dataset to the products that user wants to compare. If no matching products are found (for instance, if one of the brands has no items in that category or season), the program informs the user that there is **no data available** for the requested analysis. 

## Step 3: Average Price Analysis

The program proceeds to calculate and present the average prices for comparison. In this stage, the program identifies the average prices of the products belonging to the selected brands. Moreover, the program associates the results with the selected season, allowing the analysis to take into account the seasonal context of the prices.

If data exists only for one of the two brands within the chosen category and season, the program informs the users that **one of the selected brands has no available price data** for that specific comparison. 

## Error Handling

An important feature of the program is the implementation of **error handling and input validation**. For example, if the user types a brand name incorrectly, provides only one brand instead of two, or enters a season or category that does not exist in the system (e.g., “glasses”) the program displays an error message and asks the user to enter the information again.  

This ensures that the calculations are performed only with valid and consistent data.

## Part 2: Data Visualization and Price Distribution Analysis

After the user has selected a specific **category** and **season**, this step focuses on analyzing and visualizing how prices vary across different brands within that selection. Unlike the first program, which compares only two brands, this step provides an overview of **all brands** available in the chosen category and season.

Once the user inputs their selections, the program automatically filters the dataset to include only the rows that match those choices. This ensures that the following analysis and visualizations are based on the most relevant and accurate data subset.

For each brand present in the filtered dataset, the program calculates:

- **Average current price**: the mean value of all product prices for that brand.

- **Minimum and maximum prices**: representing the brand’s overall price range within the selected category and season.

These aggregated results are then displayed in the console, showing:

- The mean and median prices across all brands (for the entire slice).

- A detailed table listing each brand’s average, minimum, and maximum price.

After computing these statistics, the user is asked whether they would like to see the price range between brands visually.
If confirmed, the program produces a **bar chart** illustrating the average prices per brand, optionally adjusted to reflect the full price range (from the minimum to maximum value). Each bar is labeled with the corresponding brand name and annotated with its average price value, providing a clear and immediate visual comparison between brands.

This visualization enables users, retailers, and analysts to:

- Identify which brands position themselves at the higher or lower end of the pricing spectrum.

- Observe pricing trends within a given season and category.

- Understand competitive dynamics in the fashion market at a glance.

If no data is available for the selected combination (for example, if a certain category is not sold by any brand in that season), the program communicates this clearly and terminates.

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

