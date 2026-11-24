## Overview

`csv-statistics.sh` summarizes one numeric column from a CSV file and computes a 95% percentile bootstrap interval for its mean. It prints JSON, which is convenient for saving as a research artifact or passing to another script. The tool does not fit regression models or test hypotheses.

The regression topic motivates a practical workflow: inspect and summarize measurements before building a model, and preserve the analysis settings needed to reproduce that inspection. This utility supports that workflow by producing descriptive statistics and a seeded interval. That is an engineering connection, not a claim that the book specifies this tool.

## Prerequisites and input

The launcher is Bash and invokes Python 3. The Python algorithm is self-contained and has no third-party dependencies. The input must be a UTF-8 CSV file with a header row. Select a numeric column by its exact header name. UTF-8 files with a byte order mark are accepted. Numeric cells are parsed as floating-point values; blank or absent cells count as missing, while nonblank values that cannot be parsed, and nonfinite numbers such as `NaN` or `inf`, count as invalid and are excluded.

The selected column must contain 1 to 10,000 finite numeric values after exclusions. A column name that does not exist, a file access error, and a resample count outside 100 to 10,000 cause an argument error. Rows with missing or invalid values are not imputed. Check the reported counts before interpreting the summary.

## Run it

From a shell with the script available:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42
```

`--file` and `--column` are required. `--seed` defaults to 42. The optional `--resamples` setting defaults to 2000 and accepts integers from 100 through 10,000. For example:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42 --resamples 5000
```

The seed makes the bootstrap resampling repeatable for the same input and compatible runtime behavior. Keep the input file, command, and environment with the result when exact computational reproducibility matters.

## Reading the JSON

The output includes the selected `column`, valid-value count `n`, `missing` and `invalid` counts, arithmetic `mean`, `median`, `minimum`, `maximum`, and `sample_standard_deviation`. The sample standard deviation is `null` when there is only one valid value. `bootstrap_mean_interval_95` contains the lower and upper endpoints, and `bootstrap_method`, `seed`, and `resamples` record the method and settings.

For each resample, the program draws `n` values with replacement from the observed values, calculates a mean, sorts all resampled means, and selects indices `int(0.025 * (B - 1))` and `int(0.975 * (B - 1))`, where `B` is the resample count. These are the implementation's percentile endpoints. The procedure costs approximately O(Bn + B log B) time and O(B) storage for the sorted bootstrap means, in addition to the input values.

## Limits and interpretation

These are descriptive summaries, not significance tests or causal estimates. The interval reflects resampling from the observed values and does not account automatically for clustering, time dependence, survey design, measurement error, or selection bias. If observations are dependent or not representative of the target population, the ordinary resampling scheme may not provide an appropriate interval. The tool does not validate units, detect outliers, infer a data-generating process, or assess regression assumptions. Review the input and analysis design before using results to support a scientific conclusion.

## Reproducible setup and checks

```bash
bash csv-statistics.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Regression- Financial Insights with Excel & Python, Chapter 3: Simple Linear Regression. The implementation is an independently written practical utility.
