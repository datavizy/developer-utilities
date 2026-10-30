# correlation-report

`correlation-report` is a small command-line utility for exploratory analysis of paired numeric observations. It computes Pearson's correlation coefficient and the least-squares line for a selected predictor and response column. A scatterplot and a fitted line are often a useful first check before more involved modeling: they can reveal direction, scale, unusual points, or a nonlinear pattern that a single correlation cannot describe. This workflow is motivated by the distinction between descriptive summaries and broader model evaluation discussed in the article. The article does not specify this utility.

## Requirements

The launcher is Bash and invokes Python 3. The Python algorithm uses only the standard library; there are no third-party dependencies. Put `correlation-report.sh` on your system and make it executable, or invoke it with `bash` as below. The implementation accepts a UTF-8 CSV file, including a UTF-8 byte-order mark, with a header row.

## Input and launch

The selected `--x` and `--y` values must exactly match column names in the CSV header. Each usable row must contain finite numeric values in both columns. For example:

```bash
bash correlation-report.sh --file measurements.csv --x x --y y
```

The command writes a JSON report to standard output. It does not write a plot or modify the input file. The CLI requires all three arguments shown: `--file`, `--x`, and `--y`.

## Reading the report

The JSON includes `n_pairs` (the number of retained complete finite pairs), `omitted_rows` (rows skipped because either selected value is absent, nonnumeric, or nonfinite), the selected column names, `pearson_r`, `least_squares_slope`, and `least_squares_intercept`. It also returns an interpretation string explicitly describing the results as descriptive association and a fitted line, with no causal or significance claim.

The fitted line is $\hat{y}=b_0+b_1x$. Pearson's $r$ summarizes linear association and ranges from -1 to 1, subject to floating-point rounding. It is not a measure of arbitrary nonlinear dependence. A positive slope does not establish that changes in x cause changes in y.

## Method and limitations

The implementation calculates the sample means, then the centered sums $S_{xx}=\sum(x_i-\bar{x})^2$, $S_{yy}=\sum(y_i-\bar{y})^2$, and $S_{xy}=\sum(x_i-\bar{x})(y_i-\bar{y})$. It returns $r=S_{xy}/\sqrt{S_{xx}S_{yy}}$, slope $b_1=S_{xy}/S_{xx}$, and intercept $b_0=\bar{y}-b_1\bar{x}$. The `math.fsum` function is used for the sums. The calculation takes O(n) time and O(n) memory because the implementation stores valid pairs before computing the summaries.

At least two complete finite pairs are required, and both columns must vary. Constant x or y values cause an error because correlation is undefined in that case. Rows with missing, nonnumeric, NaN, or infinite selected values are omitted as whole pairs. A missing selected header or unreadable file also produces a command-line error. No imputation, outlier detection, uncertainty interval, hypothesis test, significance test, or causal analysis is performed.

Use the output as an exploratory summary, then inspect a scatterplot and consider measurement quality, influential observations, nonlinear structure, and the study design. Pearson correlation and the least-squares line can be sensitive to outliers, and the line can be a poor description when the relationship is nonlinear or the data are clustered. The report alone cannot establish statistical significance or support causal interpretation.

## Reproducible setup and checks

```bash
bash correlation-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Applied Data Science Using PySpark - Learn the End-to-End -- Ramcharan Kakarla & Sundar Krishnan & Sridhar Alla, 6.4.2.3 y-hat prediction to probability to final prediction. The implementation is an independently written practical utility.
