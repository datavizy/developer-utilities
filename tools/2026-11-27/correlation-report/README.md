# Correlation Report

`correlation-report.sh` computes Pearson correlation and a least-squares line from paired CSV observations. It is a small command-line check for exploratory research: when two numeric measurements appear to move together, the report gives a reproducible descriptive summary that can guide plotting and follow-up analysis. It does not establish causation or statistical significance.

## Prerequisites

The launcher requires Bash and Python 3. The Python algorithm uses only the standard library; there are no third-party dependencies. Python can be selected with the `PYTHON_BIN` environment variable. For example, `PYTHON_BIN=python3` uses the usual interpreter command.

## Input format and launch

Provide a UTF-8 CSV file with a header row, then select existing predictor and response columns by their exact header names:

```bash
bash correlation-report.sh --file measurements.csv --x x --y y
```

The CSV reader accepts UTF-8 with or without a byte-order mark. Each selected cell must parse as a finite floating-point number to be included. A row with a missing, nonnumeric, NaN, or infinite value in either selected column is omitted. The report counts omitted rows. At least two complete finite pairs are required, and both columns must vary; otherwise the tool reports an error. Extra columns are ignored. The selected columns must exist in the CSV header.

## Reading the JSON report

The utility prints indented JSON with sorted keys. `n_pairs` is the number of included observations and `omitted_rows` is the number skipped for invalid selected values. `x_column` and `y_column` identify the chosen fields. `pearson_r` is Pearson's correlation coefficient. `least_squares_slope` and `least_squares_intercept` define the fitted line $\hat{y}=\text{slope}\,x+\text{intercept}$, using ordinary least squares for predicting y from x.

Correlation describes linear association, not causality. The fitted line is descriptive and does not provide a significance test, confidence interval, prediction interval, or claim that the relationship generalizes. Inspect a scatterplot and the data collection process before interpreting the numbers.

## Method and limitations

The script reads rows once, retaining valid pairs, then calculates means and centered sums: $S_{xx}=\sum(x_i-\bar{x})^2$, $S_{yy}=\sum(y_i-\bar{y})^2$, and $S_{xy}=\sum(x_i-\bar{x})(y_i-\bar{y})$. It reports $r=S_{xy}/\sqrt{S_{xx}S_{yy}}$, slope $=S_{xy}/S_{xx}$, and intercept $=\bar{y}-\text{slope}\,\bar{x}$. Summation uses Python's `math.fsum`; the correlation value is bounded to [-1, 1] to guard against floating-point rounding. Runtime is linear in the number of CSV rows, and memory use is linear in the number of valid pairs because the implementation retains them.

This workflow connects to graph-embedding practice in a practical way. An embedding is a compact feature representation whose usefulness depends on what it preserves. Likewise, a correlation report compresses paired measurements into a few summaries, which are useful for screening but cannot replace inspecting the observations or validating a scientific model. The book topic motivates thinking carefully about representations and their limits; it does not specify this utility. The tool does not handle weights, groups, robust correlation, missing-data imputation, significance testing, or causal inference. Outliers can strongly affect Pearson correlation and the fitted line.

## Reproducible setup and checks

```bash
bash correlation-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Graph Data Science with Neo4j _ Learn How to Use Neo4j 5 -- Scifo, Estelle -- 1st edition, Birmingham, UK, 2023, 7 Automatically Extracting Features with Graph Embeddings for Machine Learning. The implementation is an independently written practical utility.
