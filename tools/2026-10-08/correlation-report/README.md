# Correlation Report

`correlation-report.sh` computes Pearson correlation and a least-squares line from paired CSV observations. It is a small exploratory-analysis utility for producing an inspectable numerical summary from two named columns. The report is descriptive: it makes no causal or statistical significance claim.

## Prerequisites

Run the Bash launcher in an environment with Python 3.8 or later available as `python3`. The Python algorithm uses only the standard library, with no third-party dependencies. The launcher also honors the `PYTHON_BIN` environment variable to select the Python executable. The input must be a readable UTF-8 CSV file with a header row.

## Input and launch

Choose one column as the predictor and another as the response. Each CSV record should represent one observational unit, with its x and y values on the same row. For example, a file might have headers `x,y` followed by numeric pairs. The tool accepts finite values convertible to Python floating-point numbers.

Run the documented command:

```bash
bash correlation-report.sh --file measurements.csv --x x --y y
```

All three options are required: `--file` identifies the CSV, `--x` selects the predictor column, and `--y` selects the response column. The selected headers must exist. The command prints an indented JSON object to standard output when it succeeds. Caught argument, file, input, and calculation errors are reported through the command-line parser; CSV parsing errors are not caught.

## Reading the report

The JSON includes `n_pairs`, the number of complete finite pairs used, and `omitted_rows`, the number of CSV data rows skipped because a selected value was missing, could not be converted to a number, or was nonfinite. It also records the selected column names. `pearson_r` is the Pearson correlation. `least_squares_slope` and `least_squares_intercept` define the fitted line $\hat{y}=b_0+b_1x$. The `interpretation` field explicitly describes the result as descriptive association and a fitted line, with no causal or significance claim.

Pearson’s $r$ summarizes linear association, not every possible relationship. A fitted line is a compact summary, not evidence that a straight-line model is adequate. Plot the paired observations and inspect units, outliers, and data collection before drawing scientific conclusions. Skipped rows can affect interpretation if their absence is systematic.

## Algorithm and limits

The program reads records with Python’s CSV dictionary reader, converts the selected fields to floats, and retains only rows where both values are finite. It requires at least two usable pairs and variation in both columns. It computes means, centered sums of squares and cross-products, then calculates $r=S_{xy}/\sqrt{S_{xx}S_{yy}}$, slope $S_{xy}/S_{xx}$, and intercept $\bar{y}-b_1\bar{x}$. The correlation is clipped to the valid numerical interval from -1 to 1 to guard against floating-point rounding beyond the mathematical bounds.

For $n$ input rows, computation takes $O(n)$ time and stores the usable pairs, so memory use is $O(n)$. The tool does not make a plot, test hypotheses, calculate confidence intervals, diagnose model assumptions, handle weights, or establish causation. It also does not identify duplicate records or decide whether row pairing is scientifically valid. Those decisions belong in the research workflow.

The topic of environments and scope motivates a useful engineering habit: make analysis inputs visible. Rather than depending on names left behind in an interactive workspace, this command specifies a file and two columns. That is a practical reproducibility choice inspired by the general value of explicit inputs, not a claim that the book specifies this utility.

## Reproducible setup and checks

```bash
bash correlation-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** The book of R - a first course in programming and statistics, 9.1.1 Environments. The implementation is an independently written practical utility.
