# Copilot Instructions for Dynamic Pricing Optimization for Retail Fashion

## Project Overview
- This project analyzes and compares retail fashion prices using a simplified dataset (`fashion_boutique_dataset.csv`) with a focus on five variables: category, brand, season, original price, and purchase date.
- The main goal is to provide tools for both customers (to compare/filter prices) and businesses (to analyze pricing trends and competition).

## Key Files & Structure
- `fashion_boutique_dataset.csv`: Main dataset for analysis (root and in `DashasCode/`).
- `DashasCode/inputfile.jl`: Likely handles data loading and preprocessing.
- `DashasCode/seasonal_tables.jl`: Presumed to contain logic for seasonal analysis or table generation.
- `boutique_analyzer.jl`: (root) Main or experimental analysis script.
- `upload_csv/`: (empty or for future uploads)

## Data Flow & Patterns
- Data is read from CSV, filtered to the five key variables, and analyzed for price comparisons and trends.
- Analysis is likely performed in Julia scripts, with modular code for data loading and seasonal analysis.
- Scripts are organized by function: data input, seasonal analysis, and main analysis/experimentation.

## Developer Workflows
- **Run analysis:** Open Julia REPL, execute scripts (e.g., `include("DashasCode/inputfile.jl")` or `include("boutique_analyzer.jl")`).
- **Add new analysis:** Place new scripts in the root or `DashasCode/` and follow the pattern of reading from the main CSV and focusing on the five variables.
- **Data updates:** Update `fashion_boutique_dataset.csv` in the root or `DashasCode/` as needed.

## Project-Specific Conventions
- Only five variables from the dataset are used for analysis: category, brand, season, original price, purchase date.
- Scripts should be modular and focused (e.g., separate seasonal logic from data input).
- Use Julia for all analysis scripts.

## Integration & Dependencies
- No explicit package/dependency management found; assume standard Julia CSV/data packages.
- No external APIs or services are referenced.

## Examples
- To analyze seasonal price trends, see `DashasCode/seasonal_tables.jl`.
- For data loading and filtering, see `DashasCode/inputfile.jl`.

---

**If you add new scripts or workflows, update this file with specific instructions and examples.**
