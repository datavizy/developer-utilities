# Correlation Report

`correlation-report` is a small command-line utility for exploratory analysis of paired numeric observations. It computes Pearson’s correlation coefficient and the ordinary least-squares line predicting a selected response column from a selected predictor column. Its results describe association and a fitted line. They do not make a causal claim or a statistical-significance claim.

## Prerequisites

Run the Bash launcher in an environment with Bash and Python 3.8 or newer available. The Python algorithm uses only the standard library; no third-party packages are required. The launcher honors `PYTHON_BIN` when set, otherwise it invokes `python3`.

## Input and launch

The input is a UTF-8 CSV file with a header row. The selected predictor and response must be columns named by the `--x` and `--y` arguments. Each usable row must contain values convertible to finite Python floating-point numbers in both selected columns. Other columns are ignored.

```bash
bash correlation-report.sh --file measurements.csv --x x --y y
```

For example, a CSV might begin:

```csv
x,y
1.0,2.1
2.0,3.8
3.0,5.2
```

The program reads UTF-8 with an optional byte-order mark. It omits a row if either selected value is empty, cannot be converted to a float, or is nonfinite, including `NaN` and infinity. Omission is pairwise: both selected values must be usable for that row. The output reports how many rows were omitted. At least two complete finite pairs are required, and both columns must vary. Otherwise, the command reports an error.

## Output and interpretation

Successful execution prints a JSON object containing `n_pairs`, `omitted_rows`, `x_column`, `y_column`, `pearson_r`, `least_squares_slope`, `least_squares_intercept`, and `interpretation`. Pearson’s `r` ranges from -1 to 1 and summarizes the direction and strength of linear association in the included pairs. The fitted line is `y = intercept + slope * x`, using the selected columns. The fixed interpretation field explicitly limits the result to descriptive association and a fitted line, with no causal or significance claim.

The tool does not calculate a p-value, confidence interval, prediction interval, or diagnostic report. A strong correlation does not show that changes in `x` cause changes in `y`. Inspect the data and study design before drawing conclusions, especially when observations are dependent, outliers are influential, or the relationship is nonlinear.

## Calculation and limits

The implementation computes column means, centered sums of squares, and the centered cross-product. It calculates Pearson correlation as `sxy / sqrt(sxx * syy)`, clamps the result to the interval [-1, 1] to guard against floating-point rounding, and computes slope as `sxy / sxx` and intercept as `mean(y) - slope * mean(x)`. It uses `math.fsum` for the centered sums. Runtime is O(n) in the number of CSV rows, with O(n) memory because valid pairs are retained for calculation.

This is a compact exploratory utility, not a general regression package. It handles only one selected pair of columns per invocation, uses unweighted ordinary least squares, and performs no missing-data imputation or uncertainty analysis. Its pairwise omission can also change the analyzed sample, so report `omitted_rows` and assess whether missingness could bias interpretation. The workflow reflects a broader reproducibility lesson: explicit inputs and visible handling rules make analyses easier to inspect. That connection motivates the tool; it does not mean the graph-algorithm chapter specifies this utility.

## Reproducible setup and checks

```bash
bash correlation-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Graph Data Science with Neo4j _ Learn How to Use Neo4j 5 -- Scifo, Estelle -- 1st edition, Birmingham, UK, 2023, 10 Writing Your Custom Graph Algorithms with the Pregel API in Java. The implementation is an independently written practical utility.
