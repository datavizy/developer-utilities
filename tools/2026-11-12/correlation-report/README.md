## Correlation Report

`correlation-report` is a small command-line utility for exploratory analysis of two numeric columns in a CSV file. Given paired observations, it reports Pearson correlation and the ordinary least-squares line for predicting the selected response column from the selected predictor column. It is useful for a quick, reproducible check before making a plot or building a fuller analysis. The result is descriptive: it makes no causal or statistical-significance claim.

### Requirements

The launcher is a Bash script and invokes Python 3. The Python algorithm uses only the standard library, so there are no third-party Python dependencies. Make the script executable if needed, and ensure Bash and Python 3 are available. To select a Python executable other than `python3`, set `PYTHON_BIN` in the environment.

### Input and launch

The input is a UTF-8 CSV file with a header row. The selected predictor and response names must match headers exactly. Each data row must contain values convertible to finite numbers in both selected columns to be included. Launch it with:

```bash
bash correlation-report.sh --file measurements.csv --x x --y y
```

The three options shown are required: `--file` names the CSV, `--x` selects the predictor column, and `--y` selects the response column. The file is opened as UTF-8 with an optional byte-order mark handled. Rows with missing, nonnumeric, or nonfinite selected values are omitted from the paired analysis and counted. At least two complete finite pairs and variation in both selected columns are required. Missing values are not imputed.

### Reading the output

The utility prints formatted JSON containing `n_pairs`, `omitted_rows`, the selected column names, `pearson_r`, `least_squares_slope`, `least_squares_intercept`, and an `interpretation` reminder. The fitted line is $\hat{y}=b_0+b_1x$, using the selected `x` column as predictor and `y` as response. Pearson's $r$ is dimensionless; the slope has response-units per predictor-unit, and the intercept has response units. The reported association and line are descriptive. Neither correlation nor the fitted line establishes cause, statistical significance, or out-of-sample predictive performance.

### Method, complexity, and limits

The implementation reads CSV rows, converts the selected fields to floating-point values, and accumulates complete pairs. It computes means and centered sums of squares and cross-products, then calculates $r=S_{xy}/\sqrt{S_{xx}S_{yy}}$, slope $S_{xy}/S_{xx}$, and intercept $\bar{y}-b_1\bar{x}$. `math.fsum` is used for the centered sums. Runtime is $O(n)$ for $n$ rows and memory is $O(n)$ because complete pairs are retained. The computed correlation is clamped to the interval $[-1,1]$ to guard against floating-point rounding beyond its mathematical bounds.

This is a focused exploratory tool, not a full regression package. It does not provide confidence intervals, hypothesis tests, robust regression, weighting, imputation, transformations, or plots. Pearson correlation summarizes linear association and can be sensitive to outliers and nonlinear patterns. Inspect the data and assumptions before drawing scientific conclusions. For reproducibility, keep the input, command, and relevant data-cleaning decisions with the analysis. The ideas of portable computation and explicit interfaces motivate this workflow; they do not imply that the cited book specifies this utility.

## Reproducible setup and checks

```bash
bash correlation-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Rust Fundamentals for Data Science- An Introductory Guide, 1 => 1,. The implementation is an independently written practical utility.
