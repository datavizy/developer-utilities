## Correlation Report

`correlation-report` is a small command-line utility for exploratory statistical analysis. It reads two numeric columns from a CSV file and reports Pearson’s correlation coefficient and the least-squares line predicting the selected response column from the selected predictor column. It is useful when a scientist wants a quick, repeatable check of linear association before building a more complete analysis.

The network-analysis workflow in this portfolio article emphasizes defining relationships and keeping analytical choices visible. This utility addresses a different kind of relationship: paired numeric measurements rather than graph edges. It can help explore whether two measured attributes move together, but it does not construct or analyze networks, and it does not establish a causal relationship. The article motivates the value of explicit definitions and reproducibility; it does not specify this utility.

### Prerequisites

The launcher is a Bash script that invokes Python 3. The Python algorithm uses only the standard library, so there are no third-party Python dependencies. Set `PYTHON_BIN` if Python 3 is available under a non-default executable name. The input must be a readable UTF-8 CSV file with a header row.

### Input and launch

Choose two existing header names: `--x` is the predictor column and `--y` is the response column. For example:

```bash
bash correlation-report.sh --file measurements.csv --x x --y y
```

The file should contain one observation per row, with numeric values in both selected columns. The CSV reader handles quoted CSV fields, and UTF-8 files with a byte-order mark are accepted. Rows with a missing, nonnumeric, or nonfinite value in either selected column are omitted as incomplete pairs. The report gives the number of retained pairs and the number of omitted rows. At least two complete finite pairs are required, and both columns must vary. The selected columns must exist in the header.

### Output and interpretation

Successful execution prints a JSON object containing `n_pairs`, `omitted_rows`, the selected column names, `pearson_r`, `least_squares_slope`, `least_squares_intercept`, and an interpretation note. Pearson’s $r$ describes the direction and strength of linear association, ranging from -1 to 1. The fitted line is $y = \text{slope} \times x + \text{intercept}$. The slope is the fitted change in response per one-unit increase in predictor; the intercept is the fitted response when the predictor is zero. Whether that intercept is scientifically meaningful depends on the measurement context.

The output is descriptive. It includes no p-value, confidence interval, hypothesis test, or causal estimate. Correlation can be affected by outliers, nonlinear patterns, restricted ranges, and confounding variables. Inspect the data and use an appropriate inferential design when the research question requires one.

### Method and limitations

The implementation computes the column means, then sums centered squares and cross-products. It calculates $r = s_{xy}/\sqrt{s_{xx}s_{yy}}$, slope $= s_{xy}/s_{xx}$, and intercept $= \bar y - \text{slope}\,\bar x$. It uses Python’s `math.fsum` for the centered sums and clips the computed correlation to the valid range [-1, 1] to guard against floating-point rounding. The calculation is linear in the number of CSV rows, with memory use also linear because the finite pairs are retained before calculation.

Rows with missing, unparsable, or nonfinite selected values are skipped, not imputed. Constant selected columns are rejected because correlation and/or the fitted slope calculation require variation. The utility does not validate whether observations are independent, choose transformations, detect outliers, or determine whether a linear model is appropriate. Treat its output as a compact exploratory summary and document the data selection and scientific assumptions in any report.

## Reproducible setup and checks

```bash
bash correlation-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Data Science Essentials in Python- Collect - Organize - -- Dmitry Zinoviev, Chapter 7Working with Network Data. The implementation is an independently written practical utility.
